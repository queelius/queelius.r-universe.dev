# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is an **R-universe registry** for the `queelius` namespace. It contains a single `packages.json` file that tells [R-universe](https://r-universe.dev) which R packages to build and distribute as binaries. The built packages are served at https://queelius.r-universe.dev.

There is no source code, build system, tests, or CI/CD in this repo. All building and testing is handled externally by R-universe infrastructure when it detects changes to `packages.json`.

## How It Works

- R-universe monitors this repo for changes to `packages.json`
- Each entry specifies a `package` name and a `url` pointing to its GitHub source repository
- R-universe clones each source repo, builds the package, runs its checks, and publishes binaries
- Pushing a commit (even an empty one) triggers a rebuild of all packages

## Common Operations

### Add a new package
Add a JSON object to the `packages.json` array:
```json
{
  "package": "package-name",
  "url": "https://github.com/queelius/package-name"
}
```

### Trigger a rebuild without changes
```bash
git commit --allow-empty -m "Trigger rebuild"
git push
```

### Validate packages.json
```bash
python3 -c "import json; json.load(open('packages.json'))"
```

## Schema

`packages.json` is a JSON array of objects. Each object supports these fields:
- `package` (required): R package name
- `url` (required): Git URL of the source repository
- `subdir`: subdirectory within the repo containing the package (if not root)
- `branch`: specific branch to build from (defaults to HEAD)
