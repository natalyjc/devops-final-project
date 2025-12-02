# Architecture Documentation

## Project Overview

**p5-audio-visualization** is an interactive, audio-reactive heart visualization built with p5.js and the Web Audio API. The visualization responds to microphone input in real-time, creating an engaging visual experience that pulses, rotates, and bounces based on audio levels.

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Browser Environment                       │
│                                                               │
│  ┌────────────────┐         ┌──────────────────────────┐   │
│  │  Microphone    │────────▶│  Web Audio API           │   │
│  │  Input         │         │  (p5.AudioIn, FFT)       │   │
│  └────────────────┘         └──────────────────────────┘   │
│                                      │                       │
│                                      ▼                       │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Visualization Engine (p5.js)               │    │
│  │                                                     │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │  src/                                        │ │    │
│  │  │  ├── visualization/                          │ │    │
│  │  │  │   ├── shapes.js (HeartShape)            │ │    │
│  │  │  │   └── effects.js (Effects)              │ │    │
│  │  │  ├── utils/                                 │ │    │
│  │  │  │   └── audio.js (AudioInput)             │ │    │
│  │  │  └── index.js (Main sketch)                │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  │                                                     │    │
│  │  Audio Level ──▶ Smoothing ──▶ Pulse Scale       │    │
│  │                     ▼                              │    │
│  │                Effects (Rotation, Bounce)         │    │
│  │                     ▼                              │    │
│  │                Heart Rendering (4-layer glow)     │    │
│  │                     ▼                              │    │
│  │                Canvas Output @ 60 FPS             │    │
│  └────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Interactive Controls (Keyboard)                   │    │
│  │  R: Rotation | B: Bounce | E: UI Toggle           │    │
│  │  Upload PNG | ENTER: Reset | Other: Fullscreen   │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. **AudioInput** (`src/utils/audio.js`)
- **Responsibility:** Audio level capture and smoothing
- **Key Methods:**
  - `mapLevel()` - Maps raw audio level to pulse scale (0.3-1.8 range)
  - `getSmoothedLevel()` - Linear interpolation for smooth transitions
  - `lerp()` - Utility function for interpolation
- **State:**
  - `level` - Current audio level (0-1)
  - `smoothedLevel` - Interpolated audio level

### 2. **HeartShape** (`src/visualization/shapes.js`)
- **Responsibility:** Heart geometry and rendering
- **Key Methods:**
  - `draw(p, baseHue, pulse)` - Renders 4-layer glowing heart
  - `getBounds(pulse)` - Calculates collision bounds for bouncing
- **Visual Features:**
  - Parametric heart curve: `x = 16sin³(θ), y = 13cos(θ) - 5cos(2θ) - 2cos(3θ) - cos(4θ)`
  - 4 glow layers with decreasing alpha and increasing hue offset
  - Dynamic sizing based on pulse value

### 3. **Effects** (`src/visualization/effects.js`)
- **Responsibility:** Interactive visual transformations
- **Features:**
  - **Rotation:** Increments angle continuously when enabled
  - **Bouncing:** Physics-based movement with wall collision detection
  - **Position Management:** Center or bounce position
- **Key Methods:**
  - `toggleRotation()` / `toggleBounce()` - State management
  - `updateRotation()` / `updateBounce()` - Transform updates
  - `randomRange()` - Velocity randomization

### 4. **Main Sketch** (`src/index.js`)
- **Responsibility:** p5.js integration and frame coordination
- **Lifecycle:**
  - `setup()` - Canvas initialization, audio input setup, UI element creation
  - `draw()` - Main rendering loop (60 FPS target)
  - `keyPressed()` - User interaction handling
  - `windowResized()` - Responsive design support

## Data Flow

```
Microphone Input
    ▼
p5.AudioIn (mic.getLevel())
    ▼
AudioInput.mapLevel() [0-0.2] → [0.3-1.8]
    ▼
AudioInput.getSmoothedLevel() (smooth interpolation)
    ▼
smoothedPulse
    ▼
HeartShape.draw()
    ├─▶ 4 glow layers with calculated hue
    └─▶ Vertices calculated using parametric curve
    ▼
Effects transforms applied (rotation, bounce)
    ▼
Canvas rendering @ 60 FPS
```

## State Management

### Global State
- `smoothedPulse` - Current pulse scale (0.3-1.8), used for size scaling
- `baseHue` - Animating hue (0-360), changes every frame
- `rotationAngle` - Accumulates when rotation enabled
- `posX`, `posY` - Shape position (center or bouncing)

### User-Controllable State
- `useHeart` - Heart shape vs. custom image
- `showInstructions` - UI overlay visibility
- `rotateEnabled` - Rotation toggle state
- `bounceEnabled` - Bounce toggle state

## Rendering Pipeline

### Per Frame:
1. **Clear Canvas** - Semi-transparent black (trail effect)
2. **Update Audio** - Read microphone level, smooth interpolation
3. **Transform State** - Update rotation angle, bounce position
4. **Render Shape** - Draw heart or image with glow effect
5. **Render UI** - Draw instructions overlay if enabled

### Performance Considerations
- **Target:** 60 FPS
- **Canvas Size:** Window dimensions (responsive)
- **Glow Layers:** 4 shapes per frame × ~180 vertices = ~720 vertices/frame
- **Optimization:** `noStroke()` reduces vertex complexity

## Module Dependencies

```
index.js (main)
├── HeartShape (src/visualization/shapes.js)
├── Effects (src/visualization/effects.js)
└── (p5.js via global scope)
    └── p5.AudioIn, p5.FFT
```

**Note:** AudioInput class is exported for testing but not currently used in main sketch. It's available for future refactoring.

## Testing Strategy

### Unit Tests (Jest)
- **audio.test.js** - Level mapping, interpolation logic
- **effects.test.js** - Rotation/bounce state management, collision
- **shapes.test.js** - Bound calculation, draw method invocation

### Canvas Testing Challenges
- Canvas operations are mocked in Jest
- Visual regression testing would require Cypress or Playwright
- Manual testing recommended for visual output

## Deployment Targets

### Development
- Local: `npm start` → Webpack dev server on `http://localhost:8000`
- Docker: `docker-compose up`

### Production
- Docker image built via GitHub Actions on release
- Multi-stage Docker build:
  - **Stage 1:** Node.js + npm install + webpack build
  - **Stage 2:** Alpine node + http-server, serving dist files
- Versioning: Semantic versioning via `standard-version`

## Configuration Files

- **webpack.config.js** - Bundling and development server
- **jest.config.js** - Test runner configuration
- **jest.setup.js** - Canvas mock setup for testing
- **.eslintrc.json** - Code quality standards
- **.prettierrc.json** - Code formatting
- **Dockerfile** - Multi-stage production container
- **docker-compose.yml** - Local development container

## Future Extensibility

### Potential Enhancements
1. **More Shapes** - Generalize shape rendering for stars, spirals, etc.
2. **Audio Analysis** - Frequency-specific color mapping (bass→red, treble→blue)
3. **Recording** - Export visualization as video/GIF
4. **Multiplayer** - WebSocket sync of multiple clients
5. **Mobile** - Touch-based controls, responsive UI
6. **Accessibility** - Audio description, keyboard-only mode

## Browser Compatibility

- **Required:** Modern browser with:
  - Canvas support
  - Web Audio API (AudioContext, getUserMedia)
  - ES6+ JavaScript support
- **Tested:** Chrome 90+, Firefox 88+, Safari 14+
- **Limitations:** Audio input requires HTTPS or localhost due to `getUserMedia` security requirements
