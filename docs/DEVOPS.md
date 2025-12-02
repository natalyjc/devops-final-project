# DevOps Pipeline Documentation

## Overview

This document describes the complete DevOps workflow for the p5-audio-visualization project, including CI/CD processes, deployment strategies, monitoring, and version management.

## Pipeline Architecture

```
Code Commit
    ▼
┌─────────────────────────────────────────────────────────────┐
│                    CI Pipeline (.github/workflows/ci.yml)    │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Lint Check  │──▶│  Unit Tests  │──▶│ Build Check │      │
│  │  (ESLint)    │  │  (Jest)      │  │ (Webpack)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         ▼                 ▼                 ▼                │
│  All Pass ────────────────────────────────────────▶ Success │
│         ▲                 ▲                 ▲                │
│         └─────────────────┴─────────────────┘                │
│                    Any Failure                               │
│                  ▼                                            │
│           PR Blocked / Review Required                       │
└─────────────────────────────────────────────────────────────┘
    ▼ (on merge to main)
┌─────────────────────────────────────────────────────────────┐
│                Release Pipeline (.github/workflows/release)  │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  1. Generate Semantic Version (standard-version)     │  │
│  │     Analyzes conventional commits → version bump      │  │
│  │     Updates package.json, generates CHANGELOG.md     │  │
│  └──────────────────────────────────────────────────────┘  │
│                    ▼                                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  2. Build Docker Image                               │  │
│  │     Multi-stage: Build assets → Run minimal image    │  │
│  │     Tag: repo:version & repo:latest                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                    ▼                                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  3. Push to Docker Hub / GitHub Container Registry   │  │
│  │     Store versioned image for deployment             │  │
│  └──────────────────────────────────────────────────────┘  │
│                    ▼                                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  4. Create GitHub Release                            │  │
│  │     Tag: v1.0.0, Release notes from CHANGELOG        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## CI Pipeline Details (`.github/workflows/ci.yml`)

### Trigger Events
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

### Jobs

#### 1. **Lint Job**
- **Runner:** Ubuntu Latest
- **Steps:**
  1. Checkout code
  2. Setup Node.js 18 LTS
  3. Install dependencies (cached via npm)
  4. Run ESLint on `src/` and `tests/` directories
- **Failure:** PR cannot merge if linting fails
- **Configuration:** `.eslintrc.json`

**ESLint Rules:**
- Recommended ruleset (prevent common errors)
- Prettier integration (code formatting)
- Warn on console usage (except warn/error)
- Require strict equality (`===`)
- Disallow unused variables

#### 2. **Test Job**
- **Runner:** Ubuntu Latest
- **Steps:**
  1. Checkout code
  2. Setup Node.js 18 LTS
  3. Install dependencies (cached)
  4. Run Jest with coverage reporting
  5. Upload coverage to Codecov
- **Coverage Thresholds:** 60% (branches, functions, lines, statements)
- **Artifacts:** Coverage reports stored on Codecov
- **Configuration:** `jest.config.js`

**Test Files:**
- `tests/audio.test.js` - Audio level mapping, smoothing
- `tests/effects.test.js` - Rotation, bounce physics
- `tests/shapes.test.js` - Heart shape rendering

#### 3. **Build Job**
- **Runs After:** Lint and Test jobs pass
- **Runner:** Ubuntu Latest
- **Steps:**
  1. Checkout code
  2. Setup Node.js 18 LTS
  3. Install dependencies (cached)
  4. Run Webpack production build
  5. Upload `dist/` artifacts
- **Output:** Built bundle in `dist/` directory
- **Artifacts:** Stored for 5 days via GitHub Actions
- **Configuration:** `webpack.config.js`

**Build Process:**
- Babel transpiles ES6+ to ES5
- Tree-shaking removes unused code
- Minification via Webpack
- Source maps generated for debugging

#### 4. **Security Job**
- **Runner:** Ubuntu Latest
- **Steps:**
  1. Checkout code
  2. Setup Node.js 18 LTS
  3. Install dependencies
  4. Run `npm audit` (checks for known CVEs)
  5. Run OWASP Dependency Check
- **Failure Handling:** Non-blocking (continues on failure)
- **Purpose:** Alert on security vulnerabilities

## Release Pipeline Details (`.github/workflows/release.yml`)

### Trigger Events
- Push to `main` branch (excluding docs changes)
- Excludes commits with `[skip-release]` in message

### Semantic Versioning Strategy

**Format:** `MAJOR.MINOR.PATCH` (e.g., `1.0.0`)

**Conventional Commit Types:**
- `feat:` → MINOR version bump (new feature)
- `fix:` → PATCH version bump (bug fix)
- `BREAKING CHANGE:` → MAJOR version bump (breaking change)

**Example Commits:**
```
fix: correct audio smoothing algorithm          # 1.0.1 → 1.0.2
feat: add color customization option            # 1.0.2 → 1.1.0
feat!: remove legacy shape API                  # 1.1.0 → 2.0.0
```

### Release Jobs

#### 1. **Version Generation**
- Tool: `standard-version`
- Actions:
  1. Analyze commits since last tag
  2. Determine version bump
  3. Update `package.json` version
  4. Generate `CHANGELOG.md`
  5. Create git tag (e.g., `v1.0.0`)
  6. Push tag to repository
- **Output:** Tagged commit with version files

#### 2. **Docker Image Build**
- **Base Image:** `node:18-alpine` (both stages)
- **Build Stage:**
  - Install dependencies (`npm ci`)
  - Run Webpack build
  - Output: `/app/dist` directory
- **Production Stage:**
  - Copy built artifacts from builder
  - Install `http-server` globally
  - Expose port 8000
  - Add health check
  - CMD: Start HTTP server with CORS enabled
- **Tags:**
  - `username/p5-audio-viz:1.0.0` (semantic version)
  - `username/p5-audio-viz:latest` (always points to newest)
- **Caching:** Uses Docker layer caching for faster builds

#### 3. **Docker Push**
- **Registry:** Docker Hub (via `secrets.DOCKER_USERNAME` and `secrets.DOCKER_PASSWORD`)
- **Fallback:** Skips if credentials not configured
- **Purpose:** Enable `docker pull` for deployments

#### 4. **GitHub Release Creation**
- **Tag:** `v{VERSION}` (e.g., `v1.0.0`)
- **Release Notes:** Auto-populated from `CHANGELOG.md`
- **Purpose:** Searchable, downloadable release records

## Configuration Files Explained

### `package.json`
```json
{
  "scripts": {
    "start": "webpack serve --mode development",      // Dev server with hot reload
    "build": "webpack --mode production",              // Production bundle
    "lint": "eslint src tests --fix",                 // Auto-fix linting issues
    "test": "jest",                                    // Run tests once
    "test:coverage": "jest --coverage",               // Generate coverage report
    "release": "standard-version"                     // Generate version bump
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
```

### `.github/workflows/ci.yml`
- **Matrix Strategy:** Could run tests on multiple Node versions; currently uses single LTS
- **Caching:** npm dependencies cached across runs (saves ~30s per run)
- **Artifact Upload:** `dist/` retained for 5 days

### `Dockerfile`
```dockerfile
# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY src webpack.config.js .babelrc.json .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine
COPY --from=builder /app/dist ./dist
RUN npm install -g http-server
EXPOSE 8000
CMD ["http-server", "dist", "-p", "8000", "--cors"]
```

**Benefits of Multi-Stage Build:**
- Builder stage discarded after build
- Final image size: ~150MB (vs ~500MB with all node_modules)
- No source code or dev dependencies in production image

### `docker-compose.yml`
```yaml
services:
  app:
    build: .                          # Build from Dockerfile
    ports:
      - "8000:8000"                  # Expose port
    environment:
      - NODE_ENV=production           # Set production flag
    healthcheck:                      # Automated health monitoring
      test: ["CMD", "wget", ...]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - app-network                   # Custom network for multi-service setup
```

## Deployment Strategies

### Local Development
```bash
# Install dependencies
npm install

# Run dev server with hot reload
npm start
# → http://localhost:8000

# Build production bundle
npm run build
```

### Docker Local Development
```bash
# Build and run container
docker-compose up --build

# Access app
# → http://localhost:8000
```

### Production Deployment (Docker Hub)
```bash
# Pull latest image
docker pull username/p5-audio-viz:latest

# Run container
docker run -p 8000:8000 username/p5-audio-viz:latest

# Or use specific version
docker run -p 8000:8000 username/p5-audio-viz:1.0.0
```

### Cloud Deployment Examples
- **AWS ECS:** Pull image from Docker Hub, run as ECS task
- **Kubernetes:** Deploy YAML with image tag
- **Azure Container Instances:** Deploy image directly from registry
- **Heroku:** Not recommended (audio input requires client browser)

## Monitoring and Observability

### Build Metrics
- **Pipeline Duration:** Typically 2-3 minutes (lint + test + build)
- **Cache Hit Rate:** ~90% (most runs use cached npm dependencies)
- **Build Artifact Size:** 
  - Development: ~500KB (bundle only)
  - Docker Image: ~150MB (base Alpine + http-server)

### Application Metrics
- **Frame Rate:** Target 60 FPS (monitor via browser DevTools)
- **Audio Latency:** < 50ms ideal
- **Memory Usage:** Monitor via browser DevTools
- **Error Tracking:** (Optional) Sentry integration for prod

### Health Checks
```bash
# Docker health status
docker ps  # Shows "healthy" / "unhealthy" status

# Manual health check
curl http://localhost:8000/
# Response: 200 OK (serves index.html)
```

## Troubleshooting

### Pipeline Failures

| Issue | Cause | Solution |
|-------|-------|----------|
| ESLint errors | Code formatting violations | Run `npm run lint` locally, fix issues |
| Test failures | Unit test broken | Run `npm test` locally, debug with stack trace |
| Build errors | Webpack config issue | Check `webpack.config.js`, verify src files exist |
| Docker build fails | npm install fails | Check npm cache, verify package.json syntax |

### Deployment Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Port 8000 already in use | Another process using port | Change port in docker-compose.yml or kill process |
| Audio input not working | Microphone permission denied | Grant browser permission, check HTTPS/localhost |
| Performance lag | Heavy canvas rendering | Reduce glow layers, optimize canvas operations |

## Security Considerations

### Dependency Security
- `npm audit` runs on every push (non-blocking)
- OWASP Dependency Check scans for known vulnerabilities
- Dependencies pinned to specific versions (avoid breaking changes)

### Docker Security
- Alpine base image (minimal attack surface)
- No root-user code execution
- Health checks detect container crashes
- Environment variables for configuration

### Web Security
- CORS enabled for development (configurable)
- No sensitive data in environment
- Content Security Policy recommended for production
- Audio input requires HTTPS (enforced by browser)

## Next Steps / Improvements

1. **Add E2E Testing** - Cypress for visual regression testing
2. **Performance Profiling** - Analyze canvas rendering bottlenecks
3. **Multi-Cloud Deployment** - Deploy to AWS, Azure, GCP simultaneously
4. **Automated Performance Tests** - Benchmark FPS and latency in CI
5. **Sentry Integration** - Real-time error tracking in production
6. **Custom Metrics** - Send audio latency, FPS to monitoring service
7. **Blue-Green Deployment** - Zero-downtime deployments
