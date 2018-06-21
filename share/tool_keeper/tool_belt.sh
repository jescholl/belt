TOOLBELT_VERSION="0.1.0"
TOOLS=()

TOOLBELT_DIR=${TOOLBELT_DIR:-~/.belt}
for tool in "${0%/*}/../share/toolbelt/*.sh"; do
  TOOLS+=("$(basename -s .sh $tool)")
done


# this will be sourced from .zshrc, it needs to find all the tools, and define functions for them
# the functions it defines should make calls to share/toolbelt/toolbelt.sh to determine/cache tool version
# then on subsequent runs it should just execute the cached binary version
# bin/toolbelt will manage the installing of tools (as determined by ... this won't work
