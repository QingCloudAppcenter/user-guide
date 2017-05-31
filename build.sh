#!/bin/bash
if not type "gitbook" >/dev/null 2>/dev/null; then

npm install -g gitbook-cli
fi
gitbook install

FILENAME="_book/qingcloud-apps-user-guide"
gitbook build . $FILENAME
gitbook pdf . $FILENAME.pdf
gitbook epub . $FILENAME.epub
