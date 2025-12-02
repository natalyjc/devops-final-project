/**
 * Audio utility tests
 */

import { AudioInput } from '../src/utils/audio.js';

describe('AudioInput', () => {
  let audioInput;

  beforeEach(() => {
    audioInput = new AudioInput();
  });

  describe('mapLevel', () => {
    test('should map level from input range to output range', () => {
      const result = audioInput.mapLevel(0.1, 0, 0.2, 0.3, 1.8);
      expect(result).toBeCloseTo(1.05, 1);
    });

    test('should clamp output to min when input is below min', () => {
      const result = audioInput.mapLevel(-0.1, 0, 0.2, 0.3, 1.8);
      expect(result).toBeCloseTo(0.3, 1);
    });

    test('should clamp output to max when input is above max', () => {
      const result = audioInput.mapLevel(0.5, 0, 0.2, 0.3, 1.8);
      expect(result).toBeCloseTo(1.8, 1);
    });
  });

  describe('getSmoothedLevel', () => {
    test('should smoothly interpolate to target level', () => {
      const smoothFactor = 0.15;
      let smoothed = 0;

      for (let i = 0; i < 5; i++) {
        smoothed = audioInput.getSmoothedLevel(1.0, smoothFactor);
      }

      expect(smoothed).toBeGreaterThan(0);
      expect(smoothed).toBeLessThan(1.0);
    });

    test('should reach target level eventually', () => {
      audioInput.smoothedLevel = 0;
      const smoothFactor = 1; // Full step

      const result = audioInput.getSmoothedLevel(1.0, smoothFactor);
      expect(result).toBe(1.0);
    });
  });

  describe('lerp', () => {
    test('should lerp between two values', () => {
      expect(audioInput.lerp(0, 10, 0.5)).toBe(5);
      expect(audioInput.lerp(0, 10, 0)).toBe(0);
      expect(audioInput.lerp(0, 10, 1)).toBe(10);
    });
  });
});
