#!/bin/bash

PATCH=${1//*\//}

if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  SRC_PATCH_COMMAND="patch -d $(git rev-parse --show-toplevel) -p1"
  SRC_CHECKOUT_COMMAND="git -C $(git rev-parse --show-toplevel) checkout ."
else
  SRC_PATCH_COMMAND="cat"
  SRC_CHECKOUT_COMMAND=""
fi

# Optional, clean repository before applying new patch
${SRC_CHECKOUT_COMMAND}

if [[ "${PATCH}" =~ ^[0-9]+$ ]]; then
  echo "Applying Gitea pull request patch"
  wget -qO- "https://projects.blender.org/blender/blender/pulls/${PATCH}.diff" | ${SRC_PATCH_COMMAND}
elif [[ "${PATCH}" =~ ^P[0-9]+$ ]]; then
  echo "Applying hastebin patch"
  wget -qO- "https://hastebin.com/raw/${PATCH}" | ${SRC_PATCH_COMMAND}
else
  echo "Unknown patch format"
  exit 1
fi
