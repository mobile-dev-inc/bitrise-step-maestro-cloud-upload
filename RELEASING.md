# Releasing

How to cut a new version of this step and publish it to the Bitrise StepLib.

## Prerequisites

- The [Bitrise CLI](https://app.bitrise.io/cli) installed and set up.
- Push access to this repo and to [`mobile-dev-inc/bitrise-steplib`](https://github.com/mobile-dev-inc/bitrise-steplib) (our fork of the official StepLib).

## 1. Make your changes on a branch

Create a new branch and make your changes. Step logic lives in `step.sh`; inputs are declared in `step.yml`. Per the [Contributing section of the README](README.md#contributing), doc changes should be reflected in both `README.md` and `step.yml`.

## 2. Update the changelog

Add a new section to the top of [`CHANGELOG.md`](CHANGELOG.md), under the `# Changelog` heading, in the form:

```
## X.Y.Z - YYYY-MM-DD

- <user-facing change>
- <user-facing change>
```

Versioning follows semver. Deprecating or adding an input is a minor bump; bug fixes are a patch bump.

## 3. Run the tests locally

Per the [Testing section of the README](README.md#testing):

```bash
npm install -g bats bats-support bats-assert
BATS_LIB_PATH=`npm root -g` bats test.bats
```

## 4. Bump the version and tag the branch

- Bump `BITRISE_STEP_VERSION` in [`bitrise.yml`](bitrise.yml) to `X.Y.Z`.
- Tag the branch tip with the **same** version. Tags use bare semver (no `v` prefix), matching every existing tag.
- Push the branch and the tag.

```bash
git tag X.Y.Z
git push origin <branch-name>
git push origin X.Y.Z
```

> Do **not** merge into `main` yet — the StepLib publish step below runs against the tagged commit on this branch.

## 5. Publish to the Bitrise StepLib

From the project root, on the branch you just pushed:

```bash
bitrise run share-this-step
```

This uses the `share-this-step` workflow defined in [`bitrise.yml`](bitrise.yml), which creates a new branch in our fork at [`mobile-dev-inc/bitrise-steplib`](https://github.com/mobile-dev-inc/bitrise-steplib).

> If you have GPG signing of commits enabled and the command fails, run `export GPG_TTY=$(tty)` first and retry.

Then open the fork on GitHub — you should see a "Compare & pull request" prompt. Open the PR against the upstream `bitrise-io/bitrise-steplib`.

## 6. Wait for Bitrise review

Someone from Bitrise will review and merge the StepLib PR. Once merged, the new version is live for Bitrise users.

## 7. Merge into main

Once the StepLib PR is merged (or earlier, if you prefer — the tag has already shipped), merge the feature branch from step 1 into `main`.
