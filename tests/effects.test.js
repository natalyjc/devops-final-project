/**
 * Visual effects tests
 */

import { Effects } from '../src/visualization/effects.js';

describe('Effects', () => {
  let effects;

  beforeEach(() => {
    effects = new Effects();
  });

  describe('toggleRotation', () => {
    test('should toggle rotation enabled state', () => {
      expect(effects.rotateEnabled).toBe(false);
      effects.toggleRotation();
      expect(effects.rotateEnabled).toBe(true);
      effects.toggleRotation();
      expect(effects.rotateEnabled).toBe(false);
    });

    test('should return current state after toggle', () => {
      const state = effects.toggleRotation();
      expect(state).toBe(true);
    });
  });

  describe('toggleBounce', () => {
    test('should toggle bounce enabled state', () => {
      expect(effects.bounceEnabled).toBe(false);
      effects.toggleBounce();
      expect(effects.bounceEnabled).toBe(true);
      effects.toggleBounce();
      expect(effects.bounceEnabled).toBe(false);
    });

    test('should reset velocity when toggling bounce on', () => {
      effects.toggleBounce();
      expect(effects.velX).not.toBe(0);
      expect(effects.velY).not.toBe(0);
    });
  });

  describe('updateRotation', () => {
    test('should increment rotation angle when enabled', () => {
      effects.rotateEnabled = true;
      const angle1 = effects.updateRotation();
      const angle2 = effects.updateRotation();
      expect(angle2).toBe(angle1 + 1);
    });

    test('should not increment rotation when disabled', () => {
      effects.rotateEnabled = false;
      const angle1 = effects.updateRotation();
      const angle2 = effects.updateRotation();
      expect(angle1).toBe(angle2);
    });
  });

  describe('updateBounce', () => {
    test('should center shape when bounce disabled', () => {
      effects.bounceEnabled = false;
      effects.updateBounce(800, 600, 100);
      expect(effects.posX).toBe(400);
      expect(effects.posY).toBe(300);
    });

    test('should bounce off walls', () => {
      effects.bounceEnabled = true;
      effects.posX = 10;
      effects.velX = -5;
      effects.updateBounce(800, 600, 100);
      expect(effects.velX).toBe(5); // Direction reversed
    });
  });

  describe('randomRange', () => {
    test('should return value within range', () => {
      const result = effects.randomRange(3, 6);
      expect(result).toBeGreaterThanOrEqual(3);
      expect(result).toBeLessThan(6);
    });
  });

  describe('initializeBounce', () => {
    test('should set initial bounce position to center', () => {
      effects.initializeBounce(800, 600);
      expect(effects.posX).toBe(400);
      expect(effects.posY).toBe(300);
    });

    test('should set random velocity', () => {
      effects.initializeBounce(800, 600);
      expect(effects.velX).not.toBe(0);
      expect(effects.velY).not.toBe(0);
    });
  });
});
