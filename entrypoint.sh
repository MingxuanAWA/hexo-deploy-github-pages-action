#!/bin/sh -l

set -e

# check values

if [ -n "${PUBLISH_REPOSITORY}" ]; then
    TARGET_REPOSITORY=${PUBLISH_REPOSITORY}
else
    TARGET_REPOSITORY=${GITHUB_REPOSITORY}
fi

if [ -n "${BRANCH}" ]; then
    TARGET_BRANCH=${BRANCH}
else
    TARGET_BRANCH="gh-pages"
fi

if [ -n "${PUBLISH_DIR}" ]; then
    TARGET_PUBLISH_DIR=${PUBLISH_DIR}
else
    TARGET_PUBLISH_DIR="./public"
fi

if [ -z "$PERSONAL_TOKEN" ]
then
  echo "You must provide the action with either a Personal Access Token or the GitHub Token secret in order to deploy."
  exit 1
fi

REPOSITORY_PATH="https://x-access-token:${PERSONAL_TOKEN}@github.com/${TARGET_REPOSITORY}.git"

# deploy to
echo ">>>>> Start deploy to ${TARGET_REPOSITORY} <<<<<"

# Installs Git.
echo ">>> Install Git ..."
apt-get update && \
apt-get install -y git && \

# Directs the action to the the Github workspace.
cd "${GITHUB_WORKSPACE}"

echo ">>> Install NPM dependencies ..."
npm install

echo ">>> Clean folder ..."
npx hexo clean

echo ">>> Generate file ..."
npx hexo generate

echo ">>> Config git ..."

# Clone repo.
echo '>>> Start Clone ...'
git clone ${REPOSITORY_PATH} repo

# Copy files
echo '>>> Copy file ...'
cp -rf {TARGET_PUBLISH_DIR}/* repo

# Push
cd repo
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

echo '>>> Start Commit ...'
git add .
git commit --allow-empty -m "Deploy to ${TARGET_REPOSITORY}"

echo '>>> Start Push ...'
git push -u origin "${TARGET_BRANCH}" --force

echo ">>> Deployment successful!"
