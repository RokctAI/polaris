#!/usr/bin/env bash
# Install the Rokct agent protocol into this repo. Run once, before the first
# commit. The protocol is fetched rather than vendored so a spawned repo never
# ships a stale copy of it.
#
# No .workspace_config.json ships with this scaffold: initiate.py derives one.
# It reads the git origin URL and, on seeing the literal substring `RokctAI/`,
# routes working files to RokctAI/occultation without prompting. Spawned repos
# are created under RokctAI, so that branch is the one taken and the prompt is
# never reached. Do not re-point origin at a non-RokctAI fork before running
# this — that origin falls through to an interactive input() with no CI guard,
# which dies with EOFError on any unattended run, and it also strips the .rok
# skill. See docs/app-factory.md in the factory.
set -euo pipefail

mkdir -p .rokct
curl -sSL https://raw.githubusercontent.com/RokctAI/The-Rokct-Protocol/main/profiles/local/initiate.py \
  -o .rokct/initiate.py
python3 .rokct/initiate.py
