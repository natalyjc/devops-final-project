/**
 * Heart shape tests
 */

import { HeartShape } from '../src/visualization/shapes.js';

describe('HeartShape', () => {
  let heartShape;

  beforeEach(() => {
    heartShape = new HeartShape();
  });

  describe('constructor', () => {
    test('should initialize with correct glow layers', () => {
      expect(heartShape.glowLayers).toBe(4);
    });
  });

  describe('getBounds', () => {
    test('should calculate bounds based on pulse', () => {
      const bounds = heartShape.getBounds(1.0);
      expect(bounds.width).toBe(300);
      expect(bounds.height).toBe(300);
    });

    test('should scale bounds with pulse value', () => {
      const bounds = heartShape.getBounds(0.5);
      expect(bounds.width).toBe(150);
      expect(bounds.height).toBe(150);
    });

    test('should handle zero pulse', () => {
      const bounds = heartShape.getBounds(0);
      expect(bounds.width).toBe(0);
      expect(bounds.height).toBe(0);
    });
  });

  describe('draw', () => {
    test('should call draw methods without error', () => {
      const mockP5 = {
        fill: jest.fn(),
        beginShape: jest.fn(),
        vertex: jest.fn(),
        endShape: jest.fn(),
        CLOSE: 'CLOSE',
      };

      expect(() => {
        heartShape.draw(mockP5, 120, 1.0);
      }).not.toThrow();
    });

    test('should create glow layers', () => {
      const mockP5 = {
        fill: jest.fn(),
        beginShape: jest.fn(),
        vertex: jest.fn(),
        endShape: jest.fn(),
        CLOSE: 'CLOSE',
      };

      heartShape.draw(mockP5, 120, 1.0);

      // Should call fill once for each glow layer (4 layers)
      expect(mockP5.fill).toHaveBeenCalledTimes(4);
    });
  });
});
