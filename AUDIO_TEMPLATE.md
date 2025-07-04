# Audio Template Documentation

This document explains how to use the audio template feature in the Lore.earth site.

## Overview

The audio template allows you to embed one or multiple audio files with rich metadata and playback controls. It uses Howler.js for cross-browser audio support and provides a minimal, clean interface.

## Supported Audio Formats

The audio template supports all formats that Howler.js supports:
- MP3 (.mp3)
- OGG (.ogg)
- WAV (.wav)
- AAC (.aac)
- CAF (.caf)
- M4A (.m4a)
- MP4 (.mp4)
- WEBA (.weba)
- WEBM (.webm)
- DOLBY (.ac3)
- FLAC (.flac)

## Front Matter Configuration

### Single Audio File

```toml
[extra]
[[extra.audio]]
file = "your-audio-file.mp3"
title = "Track Title"
description = "A description of the audio track or recording context."
```

### Multiple Audio Files

```toml
[extra]
[[extra.audio]]
file = "first-track.mp3"
title = "First Track"
description = "Description of the first track."

[[extra.audio]]
file = "second-track.wav"
title = "Second Track"
description = "Description of the second track."
```

### Audio with Image

You can combine audio with images. The audio player will appear below the image:

```toml
[extra]
image = "your-image"
image_alt = "Alt text for image"
image_title = "Image title"

[[extra.audio]]
file = "your-audio.mp3"
title = "Audio Title"
description = "Audio description."
```

## Audio Metadata Fields

All fields are optional:

- **file** (required): The filename of the audio file (must be in `/static/audio/`)
- **title**: Display title for the audio track
- **description**: Detailed description of the track, recording context, or other notes

## Player Features

### Playback Controls
- **Play/Pause**: Click the circular play button
- **Seek**: Click anywhere on the progress bar to jump to that position
- **Rewind**: Skip back 10 seconds
- **Fast Forward**: Skip forward 10 seconds

### Speed Control
Use the dropdown to adjust playback speed:
- 0.5x (half speed)
- 0.75x
- 1x (normal speed)
- 1.25x
- 1.5x
- 2x (double speed)

### Download
Each audio file has its own download button (⬇) that allows users to download the file directly.

## File Organization

Place your audio files in the `/static/audio/` directory:
```
static/
└── audio/
    ├── your-track.mp3
    ├── field-recording.wav
    └── ambient-sounds.ogg
```

## Player Behavior

- Only one audio track can play at a time across the entire page
- Starting a new track will pause any currently playing track
- Progress and time are displayed in MM:SS format
- The player remembers the selected playback speed for each track

## Example Usage

```toml
+++
title = "field recordings"
date = "2025-01-01"

[extra]
[[extra.audio]]
file = "forest-ambience.wav"
title = "Forest Ambience"
description = "Early morning sounds from the old growth forest, captured at dawn when the mist was still rising through the canopy."

[[extra.audio]]
file = "ocean-waves.mp3"
title = "Ocean Waves"
description = "Gentle waves lapping against the rocky shore during low tide. The rhythm creates a natural meditation soundtrack."
+++

A collection of natural soundscapes recorded during quiet moments in the wilderness.
```

## Styling

The audio player uses a minimal design that matches the site's aesthetic:
- Clean, rounded containers with subtle shadows
- Theme color integration for play buttons and progress bars
- Responsive design that stacks controls on mobile devices
- Accessible focus states for keyboard navigation

## Browser Support

The audio template works in all modern browsers thanks to Howler.js, which provides:
- Web Audio API support where available
- HTML5 Audio fallback for older browsers
- Automatic format selection based on browser capabilities