# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is an **R-universe registry** for the `queelius` namespace. It contains a single `packages.json` file that tells [R-universe](https://r-universe.dev) which R packages to build and distribute as binaries. The built packages are served at https://queelius.r-universe.dev.

Package builds are handled externally by R-universe. This repository also
contains the task-oriented ecosystem README, dated reviews and release evidence
under `reviews/`, and a standalone base-R app under `examples/deadline-benchmark/`.

Validate the app with `Rscript examples/deadline-benchmark/tests/test-analysis.R`
and `Rscript examples/deadline-benchmark/tests/test-cli.R`. Refresh the README
inventory using `Rscript tools/refresh-inventory.R` from this directory, with
package checkouts beside it. The script reads DESCRIPTION files as DCF and uses
packages.json as the registry source of truth.

See `reviews/2026-10-28/review.md` and `releases.json` for the latest review and
submission evidence. Keep upload, maintainer confirmation and CRAN acceptance
distinct; the live confirmation form requires current R-devel checks.

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
