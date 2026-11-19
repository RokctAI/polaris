# polaris

A lender's loan app for borrowers on phone and desktop: apply, send documents,
accept the contract and follow the loan.

<!-- @generated-store-description-start -->
Polaris is a loan you can understand. Before you apply, see the most a short-term loan can cost under the National Credit Act: interest, the initiation fee, the monthly service fee, the VAT on them, and credit life cover if you take it, each one under the ceiling the Act sets. Every rand of the cost is shown before you agree to anything.

Apply in six clear steps, with no branch and no paperwork. An honest
affordability check comes first: your income in, the answer out. Pass it and
your details arrive prefilled, so you only confirm them. Then add four
documents: your ID front and back, a bank statement and a selfie.

Read the agreement in the app, then approve the DebiCheck mandate and submit.
Nothing is paid out until you agree. We text you the moment there is a decision.

Every loan lives in one place: see what was paid out and what has been repaid,
and keep your profile and settings one tap away.

Short-term loans under the National Credit Act are capped at R8 000 and repaid
within six months. Polaris works inside those limits. <!--
@generated-store-description-end -->

Spawned by [RokctAI Factory](https://github.com/rokctai/factory) from
<https://github.com/RokctAI/factory/issues/38>.

<!-- @generated-tour-gallery-start -->
## App tour

Styled stills from the committed guided tour - regenerated on every
tour run, so new screens appear here automatically.

| Welcome | Auth Login | Auth Register |
| :---: | :---: | :---: |
| ![Welcome][s01] | ![Auth Login][s02] | ![Auth Register][s03] |
| **Auth Reset Password** | **Polaris Home** | **Polaris Wizard** |
| ![Auth Reset Password][s04] | ![Polaris Home][s05] | ![Polaris Wizard][s06] |
| **Polaris Affordability** | **Polaris Details** | **Polaris Documents** |
| ![Affordability][s07] | ![Polaris Details][s08] | ![Polaris Documents][s09] |
| **Polaris Agreement** | **Polaris Consent** | **Polaris Outcome** |
| ![Agreement][s10] | ![Polaris Consent][s11] | ![Polaris Outcome][s12] |
| **Polaris History** | **Polaris Profile** | |
| ![Polaris History][s13] | ![Polaris Profile][s14] | |

The full tour lives in the [feature guide](marketing/tour/feature-guide.md),
with walkthrough videos alongside it in [`marketing/tour/`](marketing/tour).

[s01]: marketing/tour/store/01-welcome.png
[s02]: marketing/tour/store/02-auth_login.png
[s03]: marketing/tour/store/03-auth_register.png
[s04]: marketing/tour/store/04-auth_reset_password.png
[s05]: marketing/tour/store/05-polaris_home.png
[s06]: marketing/tour/store/06-polaris_wizard.png
[s07]: marketing/tour/store/07-polaris_affordability.png
[s08]: marketing/tour/store/08-polaris_details.png
[s09]: marketing/tour/store/09-polaris_documents.png
[s10]: marketing/tour/store/10-polaris_agreement.png
[s11]: marketing/tour/store/11-polaris_consent.png
[s12]: marketing/tour/store/12-polaris_outcome.png
[s13]: marketing/tour/store/13-polaris_history.png
[s14]: marketing/tour/store/14-polaris_profile.png
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
