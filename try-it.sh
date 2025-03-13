#!/bin/bash

PATCH=${1//*\//}

if `git rev-parse --is-inside-work-tree > /dev/null 2>&1`; then
  SRC_PATCH_COMMAND="patch -d `git rev-parse --show-toplevel` -p1"
  SRC_CHECKOUT_COMMAND="git -C `git rev-parse --show-toplevel` checkout ."
else
  SRC_PATCH_COMMAND="cat"
  SRC_CHECKOUT_COMMAND=""
fi

# Optional, clean repository before applying new patch
${SRC_CHECKOUT_COMMAND}

if [[ "${PATCH}" =~ ^P[0-9]+$ ]]; then
  echo "Applying dev.b.o paste patch"
  # Assume it's a paste from developer.blender.org.
  # TODO(sergey): Check which exact phabricator it's coming from.
  curl -s https://developer.blender.org/api/paste.query \
       -d api.token=`cat ~/.conduit-dev.b.o` \
       -d ids[0]="${PATCH#P}" | jq -r '.result[].content' | \
    ${SRC_PATCH_COMMAND}
  #wget -qO- "https://developer.blender.org/paste/raw/${PATCH#P}" | ${SRC_PATCH_COMMAND}
elif [[ "${PATCH}" =~ ^D[0-9]+$ ]]; then
  echo "Applying dev.b.o differencial patch"
  # Assume it's a paste from developer.blender.org.
  # TODO(sergey): Check which exact phabricator it's coming from.
  curl -s https://developer.blender.org/api/differential.getrawdiff \
       -d api.token=`cat ~/.conduit-dev.b.o` \
       -d diffID="${PATCH#D}" | jq -r '.result' | \
    ${SRC_PATCH_COMMAND}
else
  echo "Applying hastebin patch"
  wget -qO- https://hastebin.com/raw/$PATCH | ${SRC_PATCH_COMMAND}
fi
