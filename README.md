# Audio Reactive Heart Visualization

An interactive p5.js visualization that responds to audio input, creating a pulsating heart-like pattern driven by microphone input frequencies.

## Features

- **Audio Responsive**: Uses Web Audio API to analyze frequency data from microphone input
- **Visual Effects**: Displays bass, mid, and treble frequencies as animated particles
- **Interactive**: Press any key to toggle fullscreen mode
- **Real-time**: 60 FPS animation with smooth transitions

## How It Works

The sketch analyzes incoming audio from the user's microphone and extracts three frequency bands:
- **Bass**: Controls the base radius of the pattern
- **Mid**: Controls particle size (width)
- **Treble**: Controls particle size (height)

The particles are arranged in a circular pattern with color determined by angle and frame count, creating a rainbow effect.

## Usage

1. Start a local server (recommended due to browser permissions):
   ```bash
   npx http-server
   ```
   
2. Navigate to `http://localhost:8080` in your browser

3. Allow microphone access when prompted

4. Press any key to enter fullscreen mode

## Browser Requirements

- Modern browser with Web Audio API support
- Microphone access permission
- p5.js and p5.sound libraries (loaded via CDN)

## Issue Tracking

This project uses GitHub Issues for tracking bugs, enhancements, and feature requests.

To view or contribute to issues:
1. Visit the GitHub repository
2. Click on the "Issues" tab
3. Browse existing issues or create a new one

## Recent Updates

- **v1.1**: Improved particle animation with smoother frequency analysis
- **v1.0**: Initial release with core audio reactive visualization

## License

Educational project for SSW 590
