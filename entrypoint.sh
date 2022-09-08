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

echo ">>> Setup ssh-private-key"
mkdir -p /root/.ssh/
echo "$DEPLOY_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

echo ">>> Config git ..."

git clone "git@github.com:${TARGET_REPOSITORY}" .deploy_git

# Configures Git.
git config --global user.name "MingxuanAWA"
git config --global user.email "mxgame@foxmail.com"

echo '>>> Start Push ...'
npx hexo deploy -m "Deploy to ${TARGET_REPOSITORY}"

echo ">>> Deployment successful!"
