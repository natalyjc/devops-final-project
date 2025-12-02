/**
 * Audio Input Module
 * Handles microphone input and audio analysis
 */

export class AudioInput {
  constructor() {
    this.mic = null;
    this.fft = null;
    this.level = 0;
    this.smoothedLevel = 0;
  }

  async initialize() {
    // This will be initialized in the p5 setup() function
    // We export this class for testing purposes
  }

  getLevel() {
    return this.level;
  }

  getSmoothedLevel(targetLevel, smoothFactor = 0.15) {
    this.smoothedLevel = this.lerp(this.smoothedLevel, targetLevel, smoothFactor);
    return this.smoothedLevel;
  }

  lerp(a, b, t) {
    return a + (b - a) * t;
  }

  mapLevel(level, inMin = 0, inMax = 0.2, outMin = 0.3, outMax = 1.8) {
    if (inMax === inMin) {
      return outMin;
    }
    const mapped = ((level - inMin) / (inMax - inMin)) * (outMax - outMin) + outMin;
    return Math.max(outMin, Math.min(outMax, mapped));
  }
}

export default AudioInput;
