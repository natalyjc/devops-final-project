# Configuration Reference

This document explains all configuration files in the project, their purpose, and how they contribute to the DevOps pipeline.

## Build Configuration

### `webpack.config.js`
**Purpose:** Bundles source code for production and provides development server

```javascript
module.exports = {
  entry: './src/index.js',                    // Entry point
  output: {
    filename: 'bundle.js',                     // Output bundle name
    path: path.resolve(__dirname, 'dist'),     // Output directory
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',              // Transpile ES6+ to ES5
          options: {
            presets: ['@babel/preset-env'],
          },
        },
      },
    ],
  },
  devServer: {
    static: './dist',
    port: 8000,                                // Dev server port
    hot: true,                                 // Hot reload enabled
    open: true,                                // Auto-open browser
  },
  devtool: 'source-map',                       // Debug support
};
```

**Key Features:**
- Babel transpilation for cross-browser ES5 compatibility
- Source maps for debugging minified production code
- Hot Module Replacement (HMR) for instant feedback during development
- Separate dev/prod configurations via `--mode` flag

### `.babelrc.json`
**Purpose:** Babel configuration for transpiling modern JavaScript

```json
{
  "presets": [
    [
      "@babel/preset-env",
      {
        "useBuiltIns": "entry",
        "corejs": 3
      }
    ]
  ]
}
```

**Explanation:**
- `@babel/preset-env`: Automatically determines Babel plugins/polyfills needed for target browsers
- `useBuiltIns: entry`: Imports necessary polyfills explicitly (smaller bundle than `usage`)
- `corejs: 3`: Uses Core.js v3 for polyfills (modern, well-maintained)

## Testing Configuration

### `jest.config.js`
**Purpose:** Jest unit testing framework configuration

```javascript
module.exports = {
  testEnvironment: 'jsdom',                    // Simulate browser environment
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],  // Setup hooks
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/index.js',
  ],
  coverageThreshold: {
    global: {
      branches: 60,                            // 60% branch coverage minimum
      functions: 60,
      lines: 60,
      statements: 60,
    },
  },
  testMatch: [
    '**/tests/**/*.test.js',                   // Test file patterns
  ],
};
```

**Key Features:**
- `testEnvironment: jsdom`: Provides `window`, `document`, `canvas` globals like browser
- Coverage thresholds enforce code quality standards
- Glob patterns for organizing tests in `tests/` directory

### `jest.setup.js`
**Purpose:** Mock browser APIs for p5.js canvas testing

```javascript
global.HTMLCanvasElement.prototype.getContext = () => ({
  fillStyle: '',
  fill: jest.fn(),                            // Mock canvas methods
  beginPath: jest.fn(),
  // ... more canvas API mocks
});
```

**Why Needed:**
- p5.js uses Canvas API which doesn't exist in Node.js test environment
- Mocking prevents "canvas is not defined" errors
- Allows unit testing of audio/effects logic without rendering

## Code Quality Configuration

### `.eslintrc.json`
**Purpose:** ESLint code style and error detection rules

```json
{
  "env": {
    "browser": true,                          // Browser globals (window, document)
    "es2021": true,                           // ES2021 features allowed
    "jest": true,                             // Jest globals (describe, test, expect)
    "node": true                              // Node.js globals (require, module)
  },
  "extends": [
    "eslint:recommended",                     // Standard rule set
    "prettier"                                // Disable formatting conflicts with Prettier
  ],
  "rules": {
    "prettier/prettier": "error",             // Prettier formatting enforced
    "no-unused-vars": ["error", {
      "argsIgnorePattern": "^_"               // Allow unused params starting with _
    }],
    "eqeqeq": ["error", "always"],           // Require === (no ==)
    "curly": ["error", "all"],               // Require curly braces
  }
}
```

**Rules Enforced:**
- No unused variables (catches dead code)
- Strict equality (prevents type coercion bugs)
- Consistent formatting via Prettier
- No console.log in production code

### `.prettierrc.json`
**Purpose:** Code formatter configuration (consistent style)

```json
{
  "semi": true,                               // Semicolons required
  "trailingComma": "es5",                     // Trailing commas in ES5-compatible structures
  "singleQuote": true,                        // Single quotes over double quotes
  "printWidth": 100,                          // Wrap lines > 100 chars
  "tabWidth": 2                               // 2-space indentation
}
```

**Integration:**
- Runs automatically via `npm run lint --fix`
- Integrated into ESLint (prettier/prettier rule)
- Pre-commit hooks can enforce (not setup yet)

## Deployment Configuration

### `Dockerfile`
**Purpose:** Package application in Docker container

```dockerfile
# Stage 1: Builder (build artifacts)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci                                    # Clean install
COPY src webpack.config.js .babelrc.json .
RUN npm run build                             # Build webpack bundle

# Stage 2: Production (minimal runtime)
FROM node:18-alpine
COPY --from=builder /app/dist ./dist
RUN npm install -g http-server               # Install static server
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8000', ...)"
CMD ["http-server", "dist", "-p", "8000", "--cors"]
```

**Multi-Stage Benefits:**
- **Stage 1 (Builder):** Contains webpack, babel, source code (not needed in runtime)
- **Stage 2 (Production):** Only includes built artifacts + http-server (~150MB vs ~500MB)
- **Result:** Smaller image, faster pulls, reduced attack surface

**HEALTHCHECK Explanation:**
```dockerfile
--interval=30s      # Check every 30 seconds
--timeout=3s        # Fail if no response in 3 seconds
--start-period=5s   # Allow 5 seconds startup grace period
--retries=3         # Mark unhealthy after 3 consecutive failures
```

### `docker-compose.yml`
**Purpose:** Define multi-container setup for local development

```yaml
version: '3.9'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile                  # Use local Dockerfile
    ports:
      - "8000:8000"                          # Map container port → host port
    environment:
      - NODE_ENV=production                  # Production mode
    healthcheck:                              # Container health monitoring
      test: ["CMD", "wget", "--quiet", ...]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - app-network                          # Custom bridge network

networks:
  app-network:
    driver: bridge
```

**Usage:**
```bash
docker-compose up --build    # Build image and run container
docker-compose down          # Stop and remove containers
docker-compose logs -f       # Stream logs
docker-compose ps            # List running services
```

## Versioning Configuration

### `package.json` (Version Field)
**Purpose:** Semantic versioning for npm packages

```json
{
  "version": "0.1.0",                        // MAJOR.MINOR.PATCH
  "name": "p5-audio-visualization",
  "description": "Audio-reactive heart visualization",
  "main": "src/index.js",
  "scripts": {
    "release": "standard-version",           // Auto-bump version
    "release:publish": "git push --follow-tags origin main"
  }
}
```

**Version Bump Strategy (from Git commits):**
- `fix:` → patch version (0.1.0 → 0.1.1)
- `feat:` → minor version (0.1.1 → 0.2.0)
- `BREAKING CHANGE:` → major version (0.2.0 → 1.0.0)

## CI/CD Workflows

### `.github/workflows/ci.yml`
**Purpose:** Runs lint, test, build on every push/PR

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]                # Trigger on push to main/develop
  pull_request:
    branches: [main, develop]                # Trigger on PRs

jobs:
  lint:                                      # ESLint check
  test:                                      # Jest unit tests
  build:                                     # Webpack production build
  security:                                  # npm audit + OWASP check
```

**Execution Order:**
1. Lint & Test run **in parallel** (independence)
2. Build runs **after** both pass (dependency)
3. Security runs **in parallel** (non-blocking)

**Key Optimizations:**
- `cache: npm` - Caches node_modules between runs (~30s savings)
- `needs: [lint, test]` - Build only runs if both pass

### `.github/workflows/release.yml`
**Purpose:** Auto-version, Docker build, GitHub release on main commits

```yaml
name: Release Pipeline

on:
  push:
    branches: [main]
    paths-ignore:
      - 'docs/**'                            # Skip if only docs change
      - 'CHANGELOG.md'

jobs:
  release:
    if: "!contains(github.event.head_commit.message, 'skip-release')"
```

**Release Steps:**
1. Generate semantic version via `standard-version`
2. Build Docker image with version tag
3. Push to Docker Hub / GitHub Container Registry
4. Create GitHub Release with CHANGELOG

**Skipping Release:**
```bash
git commit -m "fix: minor tweak [skip-release]"
# Release job will be skipped
```

## GitHub Configurations

### `.github/ISSUE_TEMPLATE/bug_report.md`
**Purpose:** Standardize bug reporting format

```yaml
---
name: Bug Report
about: Create a report to help us improve
labels: bug
---

## Description
[What is the bug?]

## Steps to Reproduce
1. 
2. 
3. 

## Expected vs Actual Behavior
[What should happen vs what actually happens?]
```

### `.github/ISSUE_TEMPLATE/feature_request.md`
**Purpose:** Standardize feature request format

### `.github/ISSUE_TEMPLATE/devops_task.md`
**Purpose:** Track DevOps infrastructure/deployment work

## Configuration Summary Table

| File | Purpose | Trigger | Executor |
|------|---------|---------|----------|
| `webpack.config.js` | Bundle code | `npm start`, `npm run build` | Webpack |
| `.babelrc.json` | Transpile JS | Webpack (via babel-loader) | Babel |
| `jest.config.js` | Unit testing | `npm test` | Jest |
| `jest.setup.js` | Test setup | Jest initialization | Jest |
| `.eslintrc.json` | Lint rules | `npm run lint` | ESLint |
| `.prettierrc.json` | Code formatting | `npm run lint --fix` | Prettier |
| `Dockerfile` | Container image | GitHub Actions / manual | Docker |
| `docker-compose.yml` | Local dev stack | `docker-compose up` | Docker Compose |
| `.github/workflows/ci.yml` | Lint→Test→Build | Push/PR events | GitHub Actions |
| `.github/workflows/release.yml` | Version→Docker→Release | Push to main | GitHub Actions |
| `package.json` (version) | Semantic version | `npm run release` | standard-version |

## Testing Configuration Locally

### Run Linter
```bash
npm run lint              # Report violations
npm run lint --fix       # Auto-fix violations
```

### Run Tests
```bash
npm test                 # Run once
npm test:watch          # Re-run on file changes
npm test:coverage       # Generate coverage report
```

### Build Production Bundle
```bash
npm run build           # Output: dist/bundle.js (~150KB minified)
```

### Run with Webpack Dev Server
```bash
npm start               # Auto-opens http://localhost:8000 with hot reload
```

### Run with Docker
```bash
docker build -t p5-viz .
docker run -p 8000:8000 p5-viz
```

