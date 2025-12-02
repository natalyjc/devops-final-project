// Jest setup file for p5.js testing
global.HTMLCanvasElement.prototype.getContext = () => ({
  fillStyle: '',
  fill: jest.fn(),
  beginPath: jest.fn(),
  moveTo: jest.fn(),
  lineTo: jest.fn(),
  arc: jest.fn(),
  stroke: jest.fn(),
  closePath: jest.fn(),
  clearRect: jest.fn(),
  fillRect: jest.fn(),
  drawImage: jest.fn(),
  translate: jest.fn(),
  rotate: jest.fn(),
  save: jest.fn(),
  restore: jest.fn(),
});

global.HTMLCanvasElement.prototype.toDataURL = () => '';
