#!/usr/bin/env bash

set -v            # print commands before execution, but don't expand env vars in output
set -o errexit    # always exit on error
set -o pipefail   # honor exit codes when piping
set -o nounset    # fail on unset variables

git clone "https://electron-bot:$GH_TOKEN@github.com/electron/electron-api-historian" module
cd module
git submodule update --init
yarn install --frozen-lockfile

git config user.email electron@github.com
git config user.name electron-bot

# Update the electron submodule
pushd electron && git checkout origin/main && popd
# bail if the submodule sha didn't change
if [ "$(git status --porcelain -- electron)" = "" ]; then
  echo "electron origin/main ref has not changed; goodbye!"
  exit 0
fi
git add electron
ELECTRON_SHA=$(git submodule status --cached electron | awk '{print $1}')

yarn run build

# bail if the data didn't change;
# the build script will change the checked out submodule sha,
# so don't include it in the check
if [ "$(git status --porcelain -- index.json)" = "" ]; then
  echo "no new content found; goodbye!"
  exit 0
fi

yarn test

git add index.json
git commit -am "feat: update history (electron@$ELECTRON_SHA)"
git pull --rebase && git push
