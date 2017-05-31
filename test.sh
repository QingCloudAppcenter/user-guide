#!/bin/bash

if not type "markdownlint" >/dev/null 2>/dev/null; then
npm install -g markdownlint-cli --registry=https://registry.npm.taobao.org
fi

markdownlint --config markdownlint.conf.json docs/*
if [[ $? == 1 ]]; then
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo "please refer to https://github.com/DavidAnson/markdownlint/blob/master/doc/Rules.md"
fi
