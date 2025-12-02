/**
 * Main p5.js sketch file
 * Audio-reactive heart visualization
 */

import { HeartShape } from './visualization/shapes.js';
import { Effects } from './visualization/effects.js';

let mic;
let fft;
let smoothedPulse = 0;
let userImg = null;
let useHeart = true;
let fileInput;
let showInstructions = true;

const heartShape = new HeartShape();
const effects = new Effects();

function setup() {
  createCanvas(windowWidth, windowHeight);
  angleMode(DEGREES);
  colorMode(HSB, 360, 255, 255, 255);
  noStroke();

  mic = new p5.AudioIn();
  mic.start();
  mic.amp(2.0);

  fft = new p5.FFT(0.5, 1024);
  fft.setInput(mic);

  fileInput = createFileInput(handleFile);
  fileInput.position(20, 20);
  fileInput.style('color', 'white');
  fileInput.style('font-size', '14px');
  fileInput.attribute('accept', 'image/png');

  effects.initializeBounce(width, height);
}

function draw() {
  background(0, 25);

  const shapeSize = 300 * smoothedPulse;
  effects.updateBounce(width, height, shapeSize);

  push();
  translate(effects.posX, effects.posY);

  effects.updateRotation();
  if (effects.rotateEnabled) {
    rotate(effects.rotationAngle);
  }

  const level = mic.getLevel();
  const targetPulse = map(level, 0, 0.2, 0.3, 1.8, true);
  smoothedPulse = lerp(smoothedPulse, targetPulse, 0.15);

  const baseHue = (frameCount * 2) % 360;

  if (useHeart) {
    heartShape.draw(this, baseHue, smoothedPulse);
  } else if (userImg) {
    drawUserImage(baseHue);
  }
  pop();

  if (showInstructions) {
    drawInstructions();
  }
}

function drawUserImage(baseHue) {
  const imgSize = 300 * smoothedPulse;
  const tintHue = (baseHue + 30) % 360;
  tint(tintHue, 255, 255, 220);
  imageMode(CENTER);
  image(userImg, 0, 0, imgSize, imgSize);
}

function handleFile(file) {
  if (file.type === 'image' && file.subtype === 'png') {
    userImg = loadImage(file.data, () => {
      useHeart = false;
    });
  } else {
    alert('Please upload a PNG image!');
  }
}

function keyPressed() {
  if (keyCode === ENTER) {
    useHeart = true;
    userImg = null;
  } else if (key === 'R' || key === 'r') {
    effects.toggleRotation();
  } else if (key === 'B' || key === 'b') {
    effects.toggleBounce();
  } else if (key === 'E' || key === 'e') {
    showInstructions = !showInstructions;
    if (showInstructions) {
      fileInput.show();
    } else {
      fileInput.hide();
    }
  } else {
    const fs = !fullscreen();
    fullscreen(fs);
    resizeCanvas(windowWidth, windowHeight);
  }
}

function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
}

function drawInstructions() {
  resetMatrix();
  fill(255);
  textAlign(LEFT, TOP);
  textSize(14);
  text(
    'Upload a PNG image to replace the heart.\nPress ENTER to keep the heart.\nPress R to toggle rotation.\nPress B to toggle bouncing.\nPress E to hide/show instructions and upload button.\nPress any other key for fullscreen.',
    20,
    height - 130
  );
}
