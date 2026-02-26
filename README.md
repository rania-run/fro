# fro

[![CI](https://github.com/rania-run/fro/actions/workflows/ci.yml/badge.svg)](https://github.com/rania-run/fro/actions/workflows/ci.yml)
[![pub.dev](https://img.shields.io/pub/v/fro.svg)](https://pub.dev/packages/fro)

Dart CLI for managing Flutter app versions, build numbers, and releases across environments.

---

## Install

```bash
dart pub global activate fro
```

---

## Usage

```bash
# Show current version from pubspec.yaml
fro check

# Compare pubspec version against the latest git tag for an environment
fro check --env=prod

# Bump version and create a git tag
fro bump --env=prod --strategy=patch   # 1.2.3+45 → 1.2.4+46
fro bump --env=stg  --strategy=minor   # 1.2.3+45 → 1.3.0+46

# Full release (bump + tag + optional store upload)
fro release --env=prod
fro release --env=prod --ci            # non-interactive, for CI pipelines
```

### Git tag format

```
prod-v1.2.3+45
stg-v1.2.3+78
dev-v0.1.0+12
```

Build numbers are independent per environment and never reset to zero.

---

## Config (`fro.yaml`)

Place this at the root of your Flutter project:

```yaml
environments:
  - name: prod
    track: production
  - name: stg
    track: beta
  - name: dev
    track: internal
```

---

## Credentials

Never pass credentials via CLI args. Use environment variables:

```bash
export FRO_PLAYSTORE_KEY_PATH=/path/to/key.json
export FRO_APPSTORE_PRIVATE_KEY=/path/to/key.p8
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). All contributions require:

- `dart analyze` — clean
- `dart format` — applied
- Tests for new behaviour
