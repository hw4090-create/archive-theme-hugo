# check_site_links.sh
## Hugo Site Link Checker / Hugo 网站链接检查脚本

`check_site_links.sh` is a small Bash utility for checking whether the file paths referenced in your Hugo Markdown files actually exist in the `static/` directory.

`check_site_links.sh` 是一个小型 Bash 检查工具，用来核对 Hugo 网站中 Markdown 文件引用的资源路径，是否真实存在于 `static/` 目录中。

It is especially useful for websites with many images and videos, where paths may look correct in local preview but fail after deployment because of filename mismatches, spaces, case differences, or leftover old files.

这个工具特别适合图片和视频较多的网站。很多时候本地预览看起来正常，但上传到服务器后会因为文件名大小写不一致、空格、旧文件残留、双扩展名等问题而失效，这个脚本就是为了解决这类问题。

---

## What this script checks / 这个脚本会检查什么

### English
This script scans:

- Markdown files under `content/`
- front matter fields such as:
  - `thumbnail:`
  - `video:`
  - `banner_image:`
  - `poster:`
- inline Markdown image links such as:
  - `![](/images/example.png)`
- shortcode references such as:
  - `src="/images/example.png"`
  - `poster="/images/example.png"`

Then it compares those references against the real files inside `static/`.

It also reports suspicious files in `static/`, including:

- files with spaces in their names
- double extensions like `.mp4.mp4`
- `.DS_Store`
- misplaced `README.md` or other Markdown files
- duplicate basenames
- possible case mismatch issues

### 中文
这个脚本会扫描：

- `content/` 目录下的 Markdown 文件
- front matter 中常见的资源字段，例如：
  - `thumbnail:`
  - `video:`
  - `banner_image:`
  - `poster:`
- Markdown 正文中的普通图片链接，例如：
  - `![](/images/example.png)`
- shortcode 中的资源引用，例如：
  - `src="/images/example.png"`
  - `poster="/images/example.png"`

然后它会把这些引用路径和 `static/` 中的真实文件逐一比对。

此外，它还会额外报告 `static/` 目录中的可疑文件，例如：

- 文件名中带空格的文件
- 类似 `.mp4.mp4` 这样的双扩展名文件
- `.DS_Store`
- 错误放进 `static/` 的 `README.md` 或其他 Markdown 文件
- 同名重复文件
- 大小写可能不一致的资源路径

---

## Recommended project structure / 推荐目录结构

```text
your-site/
├── content/
├── static/
├── themes/
├── hugo.toml
└── check_site_links.sh