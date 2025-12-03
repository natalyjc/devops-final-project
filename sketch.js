// Audio reactive visualization configuration
let mic, fft;
let angleOffset = 0;
let totalBands = 100; // Number of particles in circular pattern
let trailAlpha = 20; // Motion blur effect (0-255)
let particleScaling = 1.0; // Multiplier for particle sizes

function setup() {
  createCanvas(windowWidth, windowHeight);
  angleMode(DEGREES);
  colorMode(HSB, 360, 255, 255, 255);
  
  // Initialize microphone input and frequency analysis
  mic = new p5.AudioIn();
  mic.start();
  fft = new p5.FFT();
  fft.setInput(mic);
  
  noStroke();
  frameRate(60);
}

function draw() {
  // Apply motion blur effect for trailing visualization
  background(0, trailAlpha);

  translate(width / 2, height / 2);
  angleOffset += 0.5; // Slow rotation for organic feel

  // Extract frequency data from microphone input
  let spectrum = fft.analyze();
  let bass = fft.getEnergy("bass");      // Low frequencies (affects radius)
  let mid = fft.getEnergy("mid");        // Mid frequencies (affects width)
  let treble = fft.getEnergy("treble");  // High frequencies (affects height)

  // Map bass to particle ring radius
  let radiusBase = map(bass, 0, 255, 100, 300);
  
  // Draw circular pattern of particles
  for (let i = 0; i < totalBands; i++) {
    let angle = i * (360 / totalBands) + angleOffset;
    // Add sine wave modulation for pulsing effect
    let r = radiusBase + sin(frameCount + i * 10) * 50;

    let x = r * cos(angle);
    let y = r * sin(angle);

    // Color determined by angle for rainbow effect
    let hue = (angle + frameCount) % 360;
    fill(hue, 255, 255, 150);
    
    // Particle size responds to mid and treble frequencies
    let particleWidth = map(mid, 0, 255, 5, 20) * particleScaling;
    let particleHeight = map(treble, 0, 255, 5, 20) * particleScaling;
    ellipse(x, y, particleWidth, particleHeight);
  }
}

function keyPressed() {
  // Press any key to toggle fullscreen mode for immersive experience
  let fs = fullscreen();
  fullscreen(!fs);
}

// Responsive design: handle window resizing
function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
}

function preload() {
  // This function is called before setup to load any assets if needed
  // Currently used for initialization order but no assets to preload
}