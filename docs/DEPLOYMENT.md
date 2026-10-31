# Deploying

Pramaan is a Flutter web bundle. Vercel's build image has no Flutter SDK, so the
bundle is always compiled on a machine that does have one and the finished
static output is uploaded.

## Automatic (GitHub Actions)

`.github/workflows/deploy.yml` builds `app/` and publishes it on every push to
`main` that touches `app/` or `packages/`.

It needs one repository secret:

| Secret         | Where to get it                                     |
| -------------- | --------------------------------------------------- |
| `VERCEL_TOKEN` | https://vercel.com/account/tokens → Create Token     |

Until that secret exists the workflow still builds and tests the web bundle, but
skips the upload and prints a notice. It does not fail.

Optional repository variables: `VERCEL_SCOPE` (default `suthara`) and
`VERCEL_PROJECT` (default `pramaan`).

## Manual (local machine)

```powershell
pwsh scripts/deploy_vercel.ps1              # build + deploy
pwsh scripts/deploy_vercel.ps1 -SkipBuild   # deploy the existing build
```

The script runs `flutter pub get`, `flutter test`, `flutter build web --release`
and then `vercel deploy --prod` from `app/build/web`.

## Why `git.deploymentEnabled` is false

The root `vercel.json` turns off Vercel's automatic Git deployments:

```json
{ "git": { "deploymentEnabled": false } }
```

Without it, every push makes Vercel build the repository root. There is no
Flutter SDK there, no framework is detected, and the resulting empty deployment
is promoted to production — which replaced the live app with a `404 NOT_FOUND`
page once. Deployments now only happen through the paths above.

`app/web/vercel.json` is a separate file: it is copied into `build/web` by
`flutter build web` so the static upload carries the cache and security
headers.
