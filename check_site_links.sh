#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash check_site_links.sh
# Optional:
#   SITE_ROOT=/path/to/site bash check_site_links.sh

SITE_ROOT="${SITE_ROOT:-.}"
CONTENT_DIR="$SITE_ROOT/content"
STATIC_DIR="$SITE_ROOT/static"

if [[ ! -d "$CONTENT_DIR" ]]; then
  echo "ERROR: content directory not found: $CONTENT_DIR"
  exit 1
fi

if [[ ! -d "$STATIC_DIR" ]]; then
  echo "ERROR: static directory not found: $STATIC_DIR"
  exit 1
fi

echo "== Site root =="
echo "$SITE_ROOT"
echo

tmp_refs="$(mktemp)"
tmp_missing="$(mktemp)"
tmp_found="$(mktemp)"

cleanup() {
  rm -f "$tmp_refs" "$tmp_missing" "$tmp_found"
}
trap cleanup EXIT

echo "== 1) Scanning markdown/front matter references =="

# Extract likely static-file references from markdown/front matter.
# Supports:
# - thumbnail: "/images/..."
# - video: "/videos/..."
# - banner_image: "/images/..."
# - ![](/images/...)
# - {{< figure src="/images/..." >}}
# - {{< video src="/videos/..." poster="/images/..." >}}
find "$CONTENT_DIR" -type f \( -name "*.md" -o -name "*.markdown" \) | while read -r file; do
  while IFS= read -r line; do
    # front matter keys
    if [[ "$line" =~ ^[[:space:]]*(thumbnail|video|banner_image|poster)[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
      printf '%s\t%s\n' "$file" "${BASH_REMATCH[2]}" >> "$tmp_refs"
    elif [[ "$line" =~ ^[[:space:]]*(thumbnail|video|banner_image|poster)[[:space:]]*:[[:space:]]*\'([^\']+)\' ]]; then
      printf '%s\t%s\n' "$file" "${BASH_REMATCH[2]}" >> "$tmp_refs"
    elif [[ "$line" =~ ^[[:space:]]*(thumbnail|video|banner_image|poster)[[:space:]]*:[[:space:]]*([^[:space:]]+) ]]; then
      val="${BASH_REMATCH[2]}"
      [[ "$val" == /* ]] && printf '%s\t%s\n' "$file" "$val" >> "$tmp_refs"
    fi

    # markdown image syntax ![](...)
    while [[ "$line" =~ \!\[[^]]*\]\((/[^)]+)\) ]]; do
      printf '%s\t%s\n' "$file" "${BASH_REMATCH[1]}" >> "$tmp_refs"
      line="${line#*"${BASH_REMATCH[0]}"}"
    done

    # shortcode src="/..." poster="/..."
    while [[ "$line" =~ (src|poster)[[:space:]]*=[[:space:]]*\"(/[^\">]+)\" ]]; do
      printf '%s\t%s\n' "$file" "${BASH_REMATCH[2]}" >> "$tmp_refs"
      line="${line#*"${BASH_REMATCH[0]}"}"
    done
  done < "$file"
done

sort -u "$tmp_refs" -o "$tmp_refs"

echo "Found references: $(wc -l < "$tmp_refs" | tr -d ' ')"
echo

echo "== 2) Checking whether referenced files exist in static/ =="

while IFS=$'\t' read -r src_file ref; do
  # convert /images/x.png -> static/images/x.png
  rel="${ref#/}"
  target="$STATIC_DIR/$rel"

  if [[ -f "$target" ]]; then
    printf 'OK\t%s\t%s\n' "$src_file" "$ref" >> "$tmp_found"
  else
    printf 'MISSING\t%s\t%s\t(expected: %s)\n' "$src_file" "$ref" "$target" >> "$tmp_missing"
  fi
done < "$tmp_refs"

missing_count=$(wc -l < "$tmp_missing" | tr -d ' ')
found_count=$(wc -l < "$tmp_found" | tr -d ' ')

echo "Resolved: $found_count"
echo "Missing : $missing_count"
echo

if [[ "$missing_count" -gt 0 ]]; then
  echo "== Missing references =="
  cat "$tmp_missing"
  echo
fi

echo "== 3) Looking for suspicious static filenames =="
echo

echo "-- Files with spaces --"
find "$STATIC_DIR" -type f | grep ' ' || true
echo

echo "-- Files with double extensions like .mp4.mp4 --"
find "$STATIC_DIR" -type f | grep -E '\.(png|jpg|jpeg|mp4|webm|gif)\.\1$' || true
find "$STATIC_DIR" -type f | grep -E '\.mp4\.mp4$|\.png\.png$|\.jpg\.jpg$|\.jpeg\.jpeg$' || true
echo

echo "-- macOS junk files --"
find "$STATIC_DIR" -type f -name ".DS_Store" || true
echo

echo "-- Markdown / README accidentally placed in static --"
find "$STATIC_DIR" -type f \( -name "*.md" -o -name "README*" \) || true
echo

echo "== 4) Looking for duplicate basenames in static =="
find "$STATIC_DIR" -type f | awk -F/ '{print $NF}' | sort | uniq -d | while read -r name; do
  echo "Duplicate basename: $name"
  find "$STATIC_DIR" -type f -name "$name"
  echo
done

echo "== 5) Looking for content refs that differ only by case =="
while IFS=$'\t' read -r src_file ref; do
  rel="${ref#/}"
  target="$STATIC_DIR/$rel"

  if [[ ! -f "$target" ]]; then
    ref_lower="$(printf '%s' "$rel" | tr '[:upper:]' '[:lower:]')"
    candidate="$(find "$STATIC_DIR" -type f | awk -v x="$ref_lower" '
      {
        y=$0
        gsub(/^.*\/static\//, "", y)
        z=tolower(y)
        if (z==x) print $0
      }'
    )"
    if [[ -n "${candidate:-}" ]]; then
      echo "Case-mismatch candidate:"
      echo "  in file : $src_file"
      echo "  ref     : $ref"
      echo "  maybe   : $candidate"
      echo
    fi
  fi
done < "$tmp_refs"

echo "== Done =="
