/**
 * Heart Shape Drawing Module
 * Handles rendering of heart shape with glow effects
 */

export class HeartShape {
  constructor() {
    this.glowLayers = 4;
  }

  /**
   * Draw a heart shape with glow effect
   * @param {object} p - p5.js instance
   * @param {number} baseHue - Base hue value (0-360)
   * @param {number} pulse - Pulse scale factor (0-2)
   */
  draw(p, baseHue, pulse) {
    for (let g = 3; g >= 0; g--) {
      const glowScale = 10 + g * 6;
      const alpha = 120 - g * 30;
      const hue = (baseHue + g * 15) % 360;

      p.fill(hue, 255, 255, alpha);
      p.beginShape();

      for (let angle = 0; angle < 360; angle += 2) {
        const x = 16 * Math.pow(Math.sin((angle * Math.PI) / 180), 3);
        const y =
          13 * Math.cos((angle * Math.PI) / 180) -
          5 * Math.cos((2 * angle * Math.PI) / 180) -
          2 * Math.cos((3 * angle * Math.PI) / 180) -
          Math.cos((4 * angle * Math.PI) / 180);

        const xScaled = x * glowScale * pulse * 0.6;
        const yScaled = -y * glowScale * pulse * 0.6;

        p.vertex(xScaled, yScaled);
      }

      p.endShape(p.CLOSE);
    }
  }

  /**
   * Calculate bounds of heart shape for collision detection
   */
  getBounds(pulse) {
    const maxSize = 300 * pulse;
    return {
      width: maxSize,
      height: maxSize,
    };
  }
}

export default HeartShape;
