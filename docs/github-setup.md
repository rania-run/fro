# GitHub Setup Reference

Commands used to configure the `rania-run/fro` repository.
Re-run these if you ever recreate the repo or need to audit the setup.

---

## Labels

```bash
gh label create "type: bug"          --color d73a4a --description "Something isn't working"      --repo rania-run/fro
gh label create "type: enhancement"  --color a2eeef --description "New feature or improvement"   --repo rania-run/fro
gh label create "type: question"     --color d876e3 --description "Further information requested" --repo rania-run/fro
gh label create "type: docs"         --color 0075ca --description "Documentation only"            --repo rania-run/fro
gh label create "status: needs triage" --color e4e669 --description "Not yet reviewed"            --repo rania-run/fro
gh label create "status: in progress"  --color fbca04 --description "Actively being worked on"    --repo rania-run/fro
gh label create "priority: high"     --color b60205 --description "Urgent"                        --repo rania-run/fro
gh label create "good first issue"   --color 7057ff --description "Good for newcomers"            --repo rania-run/fro --force
gh label create "breaking change"    --color ee0701 --description "Breaks existing behaviour"     --repo rania-run/fro
```

---

## Milestones

```bash
gh api repos/rania-run/fro/milestones --method POST \
  -f title="v0.1.0" -f description="Core CLI: fro check + fro bump"

gh api repos/rania-run/fro/milestones --method POST \
  -f title="v1.0.0" -f description="Store integration + stable public release"
```

---

## Branch Protection (main)

```bash
gh api repos/rania-run/fro/branches/main/protection \
  --method PUT \
  --header "Accept: application/vnd.github+json" \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["check"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0,
    "dismiss_stale_reviews": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_linear_history": true
}
EOF
```

**What each rule does:**

| Rule | Effect |
|---|---|
| `required_status_checks` | CI (`check` job) must pass before merge |
| `strict: true` | Branch must be up to date with main before merge |
| `required_pull_request_reviews` (0 approvals) | PR required, no approval needed (solo) |
| `allow_force_pushes: false` | Protects commit history |
| `allow_deletions: false` | Prevents accidental branch deletion |
| `required_linear_history: true` | Enforces squash/rebase — no merge commits |

---

## CI Workflow (`check` job)

Defined in `.github/workflows/ci.yml`. Runs on push/PR to `main`:

1. `dart pub get`
2. `dart analyze --fatal-infos`
3. `dart format --set-exit-if-changed .`
4. `dart test`

---

## Publish Workflow

Defined in `.github/workflows/publish.yml`. Triggers on `v*` tags:

```bash
git tag v0.1.0
git push origin v0.1.0
```
