# Videos folder

Drop your `.mp4` / `.webm` video files in this folder. They'll be served from `/videos/filename.mp4`.

Then reference them in your collection items:

```yaml
video:  "/videos/my-film.mp4"
poster: "/images/my-film-poster.jpg"
```

Or inline in any Markdown file:

```
{{< video src="/videos/my-film.mp4" poster="/images/my-poster.jpg" caption="Excerpt" >}}
```
