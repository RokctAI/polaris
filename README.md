# polaris

A lender's loan app for borrowers on phone and desktop: apply, send documents, accept the contract and follow the loan.

Spawned by [RokctAI Factory](https://github.com/rokctai/factory) from <https://github.com/RokctAI/factory/issues/38>.

<!-- @generated-tour-gallery-start -->
## App tour

Styled stills from the committed guided tour - regenerated on every
tour run, so new screens appear here automatically.

| Welcome | Auth Login | Auth Register |
| :---: | :---: | :---: |
| ![Welcome][s01] | ![Auth Login][s02] | ![Auth Register][s03] |
| **Auth Reset Password** | **Polaris Wizard** | **Polaris Affordability** |
| ![Auth Reset Password][s04] | ![Polaris Wizard][s05] | ![Affordability][s06] |
| **Polaris Details** | **Polaris Documents** | **Polaris Agreement** |
| ![Polaris Details][s07] | ![Polaris Documents][s08] | ![Agreement][s09] |
| **Polaris Consent** | **Polaris Outcome** | |
| ![Polaris Consent][s10] | ![Polaris Outcome][s11] | |

The full tour lives in the [feature guide](marketing/tour/feature-guide.md),
with walkthrough videos alongside it in [`marketing/tour/`](marketing/tour).

[s01]: marketing/tour/store/01-welcome.png
[s02]: marketing/tour/store/02-auth_login.png
[s03]: marketing/tour/store/03-auth_register.png
[s04]: marketing/tour/store/04-auth_reset_password.png
[s05]: marketing/tour/store/05-polaris_wizard.png
[s06]: marketing/tour/store/06-polaris_affordability.png
[s07]: marketing/tour/store/07-polaris_details.png
[s08]: marketing/tour/store/08-polaris_documents.png
[s09]: marketing/tour/store/09-polaris_agreement.png
[s10]: marketing/tour/store/10-polaris_consent.png
[s11]: marketing/tour/store/11-polaris_outcome.png
<!-- @generated-tour-gallery-end -->

<!-- @generated-render-strip-start -->
## Design review strip

[render-strip.html](marketing/tour/render-strip.html)
is one self-contained page of this app's real screens - rendered
headlessly from the code in this commit, before the tour's emulator
legs ran, with every point numbered from the widget's own measured
rectangle.

GitHub serves a committed .html file as source, so open it from a
local checkout (or download the raw file) to read the page.
<!-- @generated-render-strip-end -->

## Status

Nothing is built yet. The full brief lives in [docs/spec.md](docs/spec.md); the
build instructions for the agent live in [AGENTS.md](AGENTS.md).

## Getting started

```bash
bash .rokct/bootstrap.sh   # installs the Rokct agent protocol into this repo
```

<!-- @generated-recompose-start -->
## Recomposing this app

`lib/` is fully installer-generated and disposable - it is safe to delete
and is gitignored. Anything app-specific lives in tracked manifests
(`app_routes`, or `host_routes` in `composer.json`), never in `lib/` itself.

To regenerate it:

```sh
python3 .rokct/initiate.py   # provisions the composer under .rokct/skills/
python3 .rokct/skills/.rok/flutter/scripts/compose.py
```

Session cleanup (`python3 .rokct/end_protocol.py`) wipes the provisioned
tools again.
<!-- @generated-recompose-end -->
