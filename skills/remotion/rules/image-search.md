---
name: image-search
description: Finding images for Remotion video backgrounds and assets using TeguSearch and Unsplash APIs
metadata:
  tags: images, search, unsplash, tegusearch, backgrounds, assets, stock-photos
---

# Image search for Remotion

When creating a Remotion composition, source background images, textures, and visual assets using these two APIs.

## TeguSearch — general web image search

Distributed SearXNG search with an `images` category. Returns direct image URLs, cleaned of SVGs, placeholders, and Flickr noise. Up to **50 results** per query.

**Base URL:** `https://tegusearch-main.lugondev.workers.dev`

### Search for images

```
GET /search?q=<keyword>&categories=images&safesearch=1
```

**Parameters:**
| Param | Default | Description |
|-------|---------|-------------|
| `q` | — | Search keyword (required) |
| `categories` | `general` | Use `images` for image search |
| `safesearch` | `0` | `1` = moderate, `2` = strict |
| `language` | `auto` | e.g. `en`, `vi`, `ja` |
| `pageno` | `1` | Page number (1-based) |
| `time_range` | — | `day`, `week`, `month`, `year` |

**Response:**
```json
{
  "results": [
    {
      "url": "https://example.com/photo.jpg",
      "title": "Photo title",
      "img_src": "https://example.com/photo.jpg",
      "content": "Description",
      "source": "example.com",
      "category": "images"
    }
  ]
}
```

The `img_src` field contains the direct image URL.

### Example

```bash
curl "https://tegusearch-main.lugondev.workers.dev/search?q=mountain+landscape&categories=images&safesearch=1&pageno=1"
```

```ts
const res = await fetch(
  "https://tegusearch-main.lugondev.workers.dev/search?" +
  new URLSearchParams({ q: "mountain landscape", categories: "images", safesearch: "1" })
);
const { results } = await res.json();
```

### CORS

Open (`Access-Control-Allow-Origin: *`) — callable directly from browser or Studio.

## Unsplash Rotating Proxy — high-quality stock photos

Drop-in proxy for the [Unsplash API](https://unsplash.com/documentation). Rotates through a pool of 17 API keys (~850 req/hr combined). No authentication needed.

**Base URL:** `https://unsplash-wrapped.lugondev.workers.dev`

### Usage

Take any Unsplash API URL, swap `api.unsplash.com` with the proxy host, and drop `client_id`:

```
https://api.unsplash.com/search/photos?query=love&client_id=XXX
        ↓
https://unsplash-wrapped.lugondev.workers.dev/search/photos?query=love
```

### Common requests

```bash
# Search photos
curl "https://unsplash-wrapped.lugondev.workers.dev/search/photos?query=mountain&per_page=10&page=1"

# Random photo (great for backgrounds)
curl "https://unsplash-wrapped.lugondev.workers.dev/photos/random?query=nature&orientation=landscape"

# Single photo by id
curl "https://unsplash-wrapped.lugondev.workers.dev/photos/2PODhmrvLik"

# Curated list
curl "https://unsplash-wrapped.lugondev.workers.dev/photos?per_page=20&order_by=popular"
```

### Health check

Before a batch job, confirm pool capacity:

```bash
curl "https://unsplash-wrapped.lugondev.workers.dev/health-check"
```

```json
{
  "summary": "17/17 keys healthy",
  "keys": [
    { "client_id": "JN9Q…", "ok": true, "status": 200, "rate_limit": "47/50" }
  ]
}
```

### Notes

- Do **not** send a `client_id` — the proxy supplies its own.
- `Access-Control-Allow-Origin: *` is added automatically.
- Pass-through Unsplash rate-limit headers (`X-Ratelimit-Remaining`) reflect the specific key that served the request.
- See full parameter reference at https://unsplash.com/documentation.

## Tips for Remotion

- For **full-frame backgrounds**, search Unsplash with `orientation=landscape` (16:9) or `orientation=squarish` (1:1).
- For **text overlays**, search for images with negative space or solid-color areas.
- Use `staticFile()` to reference images downloaded to `public/`, or use direct URLs in `<Img>` for remote assets.
- When using remote URLs with `<Img>`, ensure the URL has CORS headers (both APIs support CORS).
