#!/bin/sh -l

set -e

echo ">>>>> Start deploy to MingxuanAWA/blog <<<<<"
echo ">>> Install Git ..."
apt-get update
apt-get install -y git
mkdir -p /root/.ssh/
echo "$DEPLOY_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
cd "${GITHUB_WORKSPACE}"
npm install
npx hexo clean
npx hexo generate
git clone git@github.com:MingxuanAWA/blog repo
cd repo
git rm -r .
cp -rf ../public/* .
git config user.name "MingxuanAWA"
git config user.email "mxgame@foxmail.com"
git add .
git commit --allow-empty -m "Deploy to MingxuanAWA/blog"
git push origin master --force
echo ">>> Deployment successful!"


