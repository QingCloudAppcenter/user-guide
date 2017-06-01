#!/bin/bash

PWD=`pwd`
set +x
function test_by_docker {
  docker rm -f nodejs_guide
  docker run -d -it --name nodejs_guide -v ${PWD}/docs:/tmp/docs node:alpine /bin/sh
  docker cp markdownlint.conf.json nodejs_guide:/tmp/
  docker exec -it nodejs_guide npm install -g markdownlint-cli --registry=https://registry.npm.taobao.org
  docker exec -it nodejs_guide markdownlint --config /tmp/markdownlint.conf.json /tmp/docs/
}

function test_by_nodejs {
  markdownlint --config markdownlint.conf.json docs/
  if [[ $? == 1 ]]; then
  echo -e "\n"
  echo -e "\n"
  echo -e "\n"
  echo "please refer to https://github.com/DavidAnson/markdownlint/blob/master/doc/Rules.md"
  fi
}

set -x

if type docker &> /dev/null; then
  test_by_docker
elif type node &> /dev/null; then
  if ! type markdownlint &> /dev/null; then
    npm install -g markdownlint-cli --registry=https://registry.npm.taobao.org  
  fi  
  test_by_nodejs
else
  echo "Failed, no docker or nodejs env"
fi

echo "Done"
exit 0