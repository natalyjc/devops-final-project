/**
 * Visual Effects Module
 * Handles rotation, bouncing, and other visual effects
 */

class Effects {
  constructor() {
    this.rotationAngle = 0;
    this.rotateEnabled = false;
    this.bounceEnabled = false;
    this.posX = 0;
    this.posY = 0;
    this.velX = 0;
    this.velY = 0;
  }

  initializeBounce(width, height) {
    this.posX = width / 2;
    this.posY = height / 2;
    this.velX = this.randomRange(3, 6);
    this.velY = this.randomRange(3, 6);
  }

  updateBounce(width, height, shapeSize) {
    if (!this.bounceEnabled) {
      this.posX = width / 2;
      this.posY = height / 2;
      return;
    }

    this.posX += this.velX;
    this.posY += this.velY;

    const halfSize = shapeSize / 2;

    if (this.posX + halfSize > width || this.posX - halfSize < 0) {
      this.velX *= -1;
    }
    if (this.posY + halfSize > height || this.posY - halfSize < 0) {
      this.velY *= -1;
    }
  }

  updateRotation() {
    if (this.rotateEnabled) {
      this.rotationAngle += 1;
    }
    return this.rotationAngle;
  }

  toggleRotation() {
    this.rotateEnabled = !this.rotateEnabled;
    return this.rotateEnabled;
  }

  toggleBounce() {
    this.bounceEnabled = !this.bounceEnabled;
    if (this.bounceEnabled) {
      this.velX = this.randomRange(3, 6) * (Math.random() > 0.5 ? 1 : -1);
      this.velY = this.randomRange(3, 6) * (Math.random() > 0.5 ? 1 : -1);
    }
    return this.bounceEnabled;
  }

  randomRange(min, max) {
    return Math.random() * (max - min) + min;
  }
}
