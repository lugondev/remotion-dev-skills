# @remotion/skills

AI agent skills for Remotion video creation. Provides structured knowledge, code patterns, and best practices that AI coding assistants can load when working with [Remotion](https://remotion.dev).

## What's included

```
skills/
  remotion/
    SKILL.md               # Main skill — loaded by AI agents
    rules/                  # 36+ topical rule files
      3d.md                # Three.js / React Three Fiber
      audio.md             # Trimming, volume, speed, pitch
      audio-visualization.md
      calculate-metadata.md
      compositions.md
      display-captions.md
      effects.md           # 50+ visual effects + custom createEffect()
      ffmpeg.md
      gifs.md
      google-fonts.md
      html-in-canvas.md
      image-search.md      # TeguSearch + Unsplash API
      images.md
      lottie.md
      maplibre.md
      parameters.md        # Zod schemas for input props
      sequencing.md
      sfx.md               # Sound effects
      silence-detection.md
      subtitles.md
      tailwind.md
      text-animations.md
      timing.md
      transitions.md
      transparent-videos.md
      trimming.md
      video-layout.md      # Video-first layout & typography
      videos.md
      voiceover.md         # ElevenLabs TTS
      ...
    rules/assets/          # Reusable Remotion components
      charts-bar-chart.tsx
      text-animations-typewriter.tsx
      text-animations-word-highlight.tsx
```

## Agent setup

Install the skill for your preferred AI coding assistant:

```bash
make all           # Setup for all agents below
make opencode      # opencode (project-local .opencode/)
make claude        # Claude Code (CLAUDE.md)
make copilot       # GitHub Copilot (.github/copilot-instructions.md)
make cursor        # Cursor/Codex (.cursor/rules/)
make list          # Show current setup status
```

Each `make` target regenerates config files from scratch, so updating skill files and re-running `make` keeps everything in sync.

## Development

Preview skill compositions in Remotion Studio:

```bash
npm run dev
```

## Related

- [Remotion docs](https://remotion.dev/docs)
- [Remotion GitHub](https://github.com/remotion-dev/remotion)
