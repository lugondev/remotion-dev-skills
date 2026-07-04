---
name: remotion-best-practices
description: Create, edit, and render videos with Remotion — a React-based video framework. Load when writing Remotion compositions, animations, effects, captions, audio, transitions, 3D content, maps, voiceover, or when rendering videos with the Remotion CLI, Studio, or Player. Covers project setup, animations, assets, sequencing, captions, audio/sfx, visual effects, 3D/Three.js, maps (MapLibre), Google/local fonts, TailwindCSS, transitions, parameterized videos, GIFs, Lottie, FFmpeg, silence detection, voiceover, transparent videos, and rendering.
metadata:
  tags: remotion, video, react, animation, composition
---

# Remotion Skill

Your Remotion knowledge may be outdated for version-specific APIs. For the latest API docs, prefer retrieval over pre-training.

## Retrieval Sources

| Topic | Docs URL | Use for |
|-------|----------|---------|
| Core | https://www.remotion.dev/docs/ | General API reference |
| Effects | https://www.remotion.dev/docs/effects | Built-in visual effects |
| Custom effects | https://www.remotion.dev/docs/create-effect | `createEffect()` API |
| Transitions | https://www.remotion.dev/docs/transitions | Scene transitions |
| Captions | https://www.remotion.dev/docs/captions | Caption rendering |
| Media utils | https://www.remotion.dev/docs/media-utils | Audio/video metadata |
| Player | https://www.remotion.dev/docs/player | Embedded <Player> |
| Studio | https://www.remotion.dev/docs/studio | Remotion Studio |
| Renderer | https://www.remotion.dev/docs/renderer | Programmatic rendering |
| MCP | https://www.remotion.dev/docs/mcp | Claude MCP integration |

## Capabilities

Remotion provides:

- **React-based video** — Compose videos as React components with JSX, hooks, and CSS
- **Frame-accuracy** — Every frame is a function of time via `useCurrentFrame()`
- **Interpolation** — `interpolate()` with easing for CSS transform, opacity, and layout animations
- **Sequencing** — `<Sequence>` for delay, trim, and duration control of nested components
- **Assets** — `<Img>`, `<Video>` (`@remotion/media`), `<Audio>` (`@remotion/media`), `staticFile()`
- **Captions** — SRT import, transcription with Whisper, caption rendering with styles
- **Audio** — Volume envelope, speed, trimming, pitch shift, sound effects via `@remotion/sfx`
- **Visual effects** — 50+ WebGL/canvas effects via `@remotion/effects`, custom `createEffect()`
- **3D** — Three.js + React Three Fiber integration via `@remotion/three`
- **Maps** — MapLibre with animated flyovers and routes
- **Transitions** — Pre-built slide/wipe/fade and custom transitions via `@remotion/transitions`
- **Google & local fonts** — `@remotion/google-fonts` and `loadFont()` for local fonts
- **TailwindCSS** — Tailwind CSS v4 integration via `@remotion/tailwind-v4`
- **Parameterized videos** — Input props with Zod schemas for dynamic video generation
- **Transparent video** — Render with alpha channel (WebM, ProRes)
- **FFmpeg integration** — Trimming, silence detection, audio extraction
- **Lottie & GIFs** — `@remotion/lottie` and synchronized GIF display
- **Voiceover** — ElevenLabs TTS integration
- **Programmatic rendering** — CLI (`npx remotion render`), stills, and Node.js API

## Project setup

Scaffold a new project in an empty folder:

```bash
npx create-video@latest --yes --blank --no-tailwind my-video
```

Replace `my-video` with a suitable project name.

## Designing a video

Load [rules/video-layout.md](rules/video-layout.md) before designing visual scenes, layouts, promos, motion graphics, or text-heavy videos for video-first layout and text sizing guidance.

### Animations

Animate properties using `useCurrentFrame()` and `interpolate()`. Prefer `interpolate()` over `spring()` unless physics-based motion is explicitly needed. Use `Easing.bezier()` to customize timing, including jumpy or overshooting motion.

For animations editable in Remotion Studio, keep `interpolate()` inline in the `style` prop and use individual CSS transform properties (`scale`, `translate`, `rotate`) instead of composing a `transform` string.

```tsx
import { useCurrentFrame, Easing, interpolate, useVideoConfig } from "remotion";

export const FadeIn = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const opacity = interpolate(frame, [0, 2 * fps], [0, 1], {
    extrapolateRight: "clamp",
    extrapolateLeft: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

  return <div style={{ opacity }}>Hello World!</div>;
};
```

**Prefer:**
```tsx
style={{
  scale: interpolate(frame, [0, 100], [0, 1]),
  translate: interpolate(frame, [0, 100], ["0px 0px", "100px 100px"]),
  rotate: interpolate(frame, [0, 100], ["20deg", "90deg"]),
}}
```

**Over:**
```tsx
const scale = interpolate(frame, [0, 100], [0, 1]);

style={{
  transform: `scale(${scale})`,
}}
```

CSS transitions or animations are FORBIDDEN — they will not render correctly.
Tailwind animation class names are FORBIDDEN — they will not render correctly.

### Assets

Find images for backgrounds and assets using [rules/image-search.md](rules/image-search.md) (TeguSearch + Unsplash proxy).

Place assets in the `public/` folder at your project root. Reference them with `staticFile()`.

```tsx
import { Img, staticFile } from "remotion";
import { Video, Audio } from "@remotion/media";

export const MyComposition = () => {
  return (
    <>
      <Img src={staticFile("logo.png")} style={{ width: 100, height: 100 }} />
      <Video src={staticFile("video.mp4")} style={{ opacity: 0.5 }} />
      <Audio src={staticFile("audio.mp3")} />
    </>
  );
};
```

Assets can also use remote URLs:
```tsx
<Video src="https://remotion.media/video.mp4" />
```

### Sequencing

Use `<Sequence>` to delay, trim, or limit the duration of content. `<Sequence>` defaults to an absolute fill; use `layout="none"` for inline content.

```tsx
import { AbsoluteFill, Sequence, useCurrentFrame, useVideoConfig } from "remotion";

export const Main = () => {
  const { fps } = useVideoConfig();

  return (
    <AbsoluteFill>
      <Sequence>
        <Background />
      </Sequence>
      <Sequence from={1 * fps} durationInFrames={2 * fps} layout="none">
        <Title />
      </Sequence>
      <Sequence from={2 * fps} durationInFrames={2 * fps} layout="none">
        <Subtitle />
      </Sequence>
    </AbsoluteFill>
  );
};
```

### Composition setup

Width, height, fps, and duration are defined in `src/Root.tsx`:

```tsx
import { Composition } from "remotion";
import { MyComposition } from "./MyComposition";

export const RemotionRoot = () => {
  return (
    <Composition
      id="MyComposition"
      component={MyComposition}
      durationInFrames={100}
      fps={30}
      width={1080}
      height={1080}
    />
  );
};
```

See [rules/compositions.md](rules/compositions.md) for stills, folders, default props, and nested compositions.

### Dynamic metadata

Use `calculateMetadata` to set duration, dimensions, and props dynamically:

```tsx
import { Composition, CalculateMetadataFunction } from "remotion";
import { MyComposition, MyCompositionProps } from "./MyComposition";

const calculateMetadata: CalculateMetadataFunction<MyCompositionProps> = async ({ props, abortSignal }) => {
  const data = await fetch(`https://api.example.com/video/${props.videoId}`, { signal: abortSignal }).then((r) => r.json());

  return {
    durationInFrames: Math.ceil(data.duration * 30),
    props: { ...props, videoUrl: data.url },
    width: 1080,
    height: 1080,
  };
};

export const RemotionRoot = () => {
  return (
    <Composition
      id="MyComposition"
      component={MyComposition}
      fps={30}
      width={1080}
      height={1080}
      defaultProps={{ videoId: "abc123" }}
      calculateMetadata={calculateMetadata}
    />
  );
};
```

See [rules/calculate-metadata.md](rules/calculate-metadata.md) for more.

## Preview & Render

### Studio
```bash
npx remotion studio
```

### Single-frame check
```bash
npx remotion still [composition-id] --scale=0.25 --frame=30
```
At 30 fps, `--frame=30` is the one-second mark (zero-based). Skip for trivial edits.

## Detailed rule references

### Captions & Subtitles
| Rule | Description |
|------|-------------|
| [subtitles.md](rules/subtitles.md) | Caption/subtitle rendering |
| [display-captions.md](rules/display-captions.md) | Display captions on compositions |
| [import-srt-captions.md](rules/import-srt-captions.md) | Import SRT caption files |
| [transcribe-captions.md](rules/transcribe-captions.md) | Transcribe audio to captions with Whisper |

### Audio
| Rule | Description |
|------|-------------|
| [audio.md](rules/audio.md) | Trimming, volume, speed, pitch |
| [audio-visualization.md](rules/audio-visualization.md) | Spectrum bars, waveforms, bass-reactive effects |
| [sfx.md](rules/sfx.md) | Sound effects with `@remotion/sfx` |
| [get-audio-duration.md](rules/get-audio-duration.md) | Get audio duration with Mediabunny |

### Video
| Rule | Description |
|------|-------------|
| [videos.md](rules/videos.md) | Trimming, volume, speed, looping, pitch |
| [get-video-dimensions.md](rules/get-video-dimensions.md) | Get video width/height with Mediabunny |
| [get-video-duration.md](rules/get-video-duration.md) | Get video duration with Mediabunny |
| [transparent-videos.md](rules/transparent-videos.md) | Render with alpha channel |

### Visual Effects
| Rule | Description |
|------|-------------|
| [effects.md](rules/effects.md) | Built-in + custom canvas/WebGL effects |
| [light-leaks.md](rules/light-leaks.md) | Light leak overlays |
| [html-in-canvas.md](rules/html-in-canvas.md) | HTML rendered inside `<HtmlInCanvas>` |

### Text & Typography
| Rule | Description |
|------|-------------|
| [text-animations.md](rules/text-animations.md) | Typography/word-level animation patterns |
| [google-fonts.md](rules/google-fonts.md) | Load Google Fonts |
| [local-fonts.md](rules/local-fonts.md) | Load local fonts |
| [measuring-text.md](rules/measuring-text.md) | Measure text, fit to container, check overflow |

### Layout & Timing
| Rule | Description |
|------|-------------|
| [video-layout.md](rules/video-layout.md) | Video-first layout, composition, text sizing |
| [timing.md](rules/timing.md) | Advanced timing, easing, springs |
| [sequencing.md](rules/sequencing.md) | Delay, trim, limit duration patterns |
| [trimming.md](rules/trimming.md) | Cut beginning or end of animations |

### Transitions
| Rule | Description |
|------|-------------|
| [transitions.md](rules/transitions.md) | Scene transition patterns |

### 3D & Maps
| Rule | Description |
|------|-------------|
| [3d.md](rules/3d.md) | Three.js + React Three Fiber |
| [maplibre.md](rules/maplibre.md) | MapLibre animated maps |

### Image Search & Assets
| Rule | Description |
|------|-------------|
| [image-search.md](rules/image-search.md) | Find images via TeguSearch and Unsplash APIs |
| [images.md](rules/images.md) | Sizing, positioning, dynamic paths, dimensions |
| [gifs.md](rules/gifs.md) | Synchronized GIF display |
| [lottie.md](rules/lottie.md) | Lottie animations |

### DOM Measurement
| Rule | Description |
|------|-------------|
| [measuring-dom-nodes.md](rules/measuring-dom-nodes.md) | Measure DOM element dimensions |
| [measuring-text.md](rules/measuring-text.md) | Measure text dimensions |

### Assets & FFmpeg
| Rule | Description |
|------|-------------|
| [ffmpeg.md](rules/ffmpeg.md) | FFmpeg video operations |
| [silence-detection.md](rules/silence-detection.md) | Detect/trim silent segments |

### Styling
| Rule | Description |
|------|-------------|
| [tailwind.md](rules/tailwind.md) | Tailwind CSS v4 in Remotion |

### Parameterized & Metadata
| Rule | Description |
|------|-------------|
| [parameters.md](rules/parameters.md) | Zod schemas for input props |
| [calculate-metadata.md](rules/calculate-metadata.md) | Dynamic duration, dimensions, data |

### Voiceover
| Rule | Description |
|------|-------------|
| [voiceover.md](rules/voiceover.md) | ElevenLabs TTS voiceover |

## Assets

The `rules/assets/` directory contains reusable Remotion component examples:
- `charts-bar-chart.tsx` — Bar chart component
- `text-animations-word-highlight.tsx` — Word highlight animation
- `text-animations-typewriter.tsx` — Typewriter text animation
