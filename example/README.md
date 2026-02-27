# fro — Example Project

A minimal `pubspec.yaml` for smoke-testing the [`fro`](https://pub.dev/packages/fro) CLI. `fro` only reads the pubspec version and git tags — no Flutter project structure needed.

## Prerequisites

```bash
dart pub global activate fro
```

## First-time setup

Run these commands once after cloning. They initialise a local git repo and seed two historical release tags:

```bash
cd example
git init -b main && git add . && git commit -m "chore: initial example project"
git tag prod-v0.9.0+3
git tag prod-us-v0.8.0+2
```

What the tags represent:
- `prod-v0.9.0+3` — a past prod release (older than the current pubspec version)
- `prod-us-v0.8.0+2` — a past prod-us release

---

## Walkthrough

### Step 1 — Check current version

```bash
fro check
```

Expected output:

```
pubspec: 1.0.0+1
```

---

### Step 2 — Check prod environment

```bash
fro check --env=prod
```

Expected output:

```
pubspec:   1.0.0+1
git/prod:  0.9.0+3  ✗ not tagged yet
```

The pubspec version `1.0.0+1` has not been tagged for `prod`, so `fro` reports it as unreleased.

---

### Step 3 — Bump prod (patch)

```bash
fro bump --env=prod --strategy=patch --no-push
```

- Increments the patch version: `1.0.0` → `1.0.1`
- Takes the next build number after the latest `prod` tag (`prod-v0.9.0+3` → build 3): `3+1 = 4`
- Updates `pubspec.yaml` to `1.0.1+4`
- Creates git tag `prod-v1.0.1+4`

Expected output:

```
  current: 1.0.0+1
  next:    1.0.1+4
  tag:     prod-v1.0.1+4
  (tag will not be pushed)

Apply? [y/N] ✓ pubspec.yaml updated to 1.0.1+4
✓ git tag prod-v1.0.1+4 created
```

---

### Step 4 — Bump prod-us (patch)

```bash
fro bump --env=prod-us --strategy=patch --no-push
```

- Increments the patch version: `1.0.1` → `1.0.2`
- Takes the next build number after the latest `prod-us` tag (`prod-us-v0.8.0+2` → build 2): `2+1 = 3`
- Updates `pubspec.yaml` to `1.0.2+3`
- Creates git tag `prod-us-v1.0.2+3`

Expected output:

```
  current: 1.0.1+4
  next:    1.0.2+3
  tag:     prod-us-v1.0.2+3
  (tag will not be pushed)

Apply? [y/N] ✓ pubspec.yaml updated to 1.0.2+3
✓ git tag prod-us-v1.0.2+3 created
```

> **Note:** Each environment maintains an independent build number sequence, derived from that environment's latest tag — not from the pubspec build number.

---

## Reset

To start fresh, run:

```bash
bash setup.sh
```

This wipes the local `.git` directory and resets `pubspec.yaml` back to `1.0.0+1`.

---

## Why `--no-push`?

This example repo has no remote configured. Always pass `--no-push` when running `fro bump` here, otherwise the command will fail trying to push to a non-existent remote.
