#!/bin/bash
if not type "qsctl" >/dev/null 2>/dev/null; then
  echo "install qingstore cli tool,assume you've got python installed"
  echo "make sure you've turned off the socks5 proxy"
  sudo pip install qsctl -U
fi
#qsctl rm -r qs://appcenter-docs/user-guide/apps/ --config .qingcloud/config.yaml
qsctl sync ../_book/qingcloud-apps-user-guide/ qs://appcenter-docs/user-guide/apps/ 
qsctl cp -f ../../index.html qs://appcenter-docs/
