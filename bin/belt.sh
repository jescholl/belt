#!/usr/bin/env bash

#set -x

tool_version=""
tool_path=""
version_reason=""

belt_help() {
  cat <<EOT
Usage: belt <command> [<args>]

Some useful commands are:
  exec      <tool> <version> [<args>]
  install   <tool> <version>
  init
  use       <tool> <version>
  uninstall <tool> [version]
  upgrade   <tool>
  which     <tool>
  versions  [tool]
EOT
}

belt_init() {
  BELT_ROOT=$(cd -- "${0%/*}/../" && pwd -P)
  cat <<EOT
export BELT_ROOT="$BELT_ROOT"
export BELT_DIR="\${BELT_DIR:-$HOME/.belt}"
export PATH="\${BELT_ROOT}/bin:\$PATH"
belt() {
  local action="\$1"
  #if [ "\$action" == "use" ]; then
  #  local tool_name="\$2"
  #  local version="\$3"
  #  if [[ -n "\$tool_name" && -n "\$version" ]]; then
  #  fi
  #  export BELT_"\$(echo "\$tool_name" | tr '[:lower:]' '[:upper:]')"_VERSION="\$version"
  #else
    belt.sh "\$@"
  #fi
}
EOT
}

belt_use() {
  local tool_name="$1"
  local version="$2"
  if [[ "${#@}" -ne 2 || -z "$tool_name" || -z "$version" ]]; then
    error "Usage: belt use <tool> <version>"
  fi
  echo "$version" > "${BELT_DIR}/.${tool_name}-version"
}


log() {
  [ "$BELT_LOG" == "true" ] && echo "$@" >&2
}

error() {
  log "$@"
  exit 1
}

BELT_MODULE_DIR="$BELT_ROOT/share/toolbelt/tools" # FIXME: this is a dumb var name

belt_which() {
  tool_name=$1

  [ -n "$tool_name" ] || error "BELT WHICH: Must passs tool name"
  local tool_version version_reason # set by tool_version
  tool_version "$tool_name"

  log "BELT WHICH: $tool_name: ${BELT_DIR}/${tool_name}/${tool_version}"

  local tool_path="${BELT_DIR}/${tool_name}/${tool_version}"
  if [[ -f "$tool_path" || "$fetch_remote_version" == "true" ]]; then
    echo "$tool_path"
  else
    return 1
  fi
}

belt_exec() {
  tool_name=$1; shift
  #tool_path="${tool_path:-$(fetch_remote_version=true belt_which "$tool_name")}"

  log "BELT EXEC: $tool_name $*"

  if ! tool_path="$(belt_which "$tool_name")"; then
  #if ! [ -f "$tool_path" ]; then
    log "BELT_EXEC: Installing $tool_name"
    belt_install "$tool_name"
    tool_path="$(belt_which "$tool_name")"
  fi

  log "$tool_path" "$@"
  "$tool_path" "$@"
}

belt_install() {
  local tool_name=$1 tool_path
  fetch_remote_version=true tool_version "$tool_name"
  tool_path="$(fetch_remote_version=true belt_which "$tool_name")"
  #log "path = $(fetch_remote_version=true belt_which "$tool_name")"
  collect_system_info

  [ -d "${tool_path%/*}" ] || mkdir -p "${tool_path%/*}"
  log belt_module "$tool_name" install "$tool_version" "$os_type" "$os_arch" "$tool_path"
  if ! belt_module "$tool_name" install "$tool_version" "$os_type" "$os_arch" "$tool_path"; then
    exit "$?"
  fi
}

belt_module() {
  module=$1; shift
  "${BELT_MODULE_DIR}/${module}.sh" "$@"
  return "$?"
}

collect_system_info() {
  os_type=${OS_TYPE:-$(uname | tr '[:upper:]' '[:lower:]')}
  os_arch=${OS_ARCH:-$(uname -m)}
  os_arch=${os_arch/x86_64/amd64}
  os_arch=${os_arch/i[123456789]86/i386}

  if [[ -z "$os_type" || -z "$os_arch" ]]; then
    cat <<EOT
Unable to detect OS type and architecture
Please set the OS_TYPE and OS_ARCH environment variables
Example:
  export OS_TYPE=darwin # or linux, sunos, openbsd, freebsd
  export OS_ARCH=amd64 # or i386, arm
EOT
    return 1
  fi
}

belt_versions() {
  local only_tool="$1"

  for tool in "$BELT_MODULE_DIR/"*; do
    local tool_name current_version
    tool_name="$(basename -s .sh "$tool")"

    if [[ -n "$only_tool" && "${tool_name}" != "${only_tool}" ]]; then
      continue
    fi
    echo "$tool_name:"

    local tool_version version_reason # set by tool_version
    tool_version "$tool_name"
    #current_version="$(tool_version "$tool_name")"

    current_version="$tool_version"
    for version in $(tool_versions "$tool_name"); do
      if [[ "$version" == "$current_version" ]]; then
        echo "  * $version ($version_reason)"
      else
        echo "    $version"
      fi
    done
  done
}

tool_version() {
  local tool_name=$1
  local version reason version_var

  fetch_remote_version=${fetch_remote_version:-false}

  # check for env var
  version_var="\$BELT_$(echo "$tool_name" | tr '[:lower:]' '[:upper:]')_VERSION"
  version="$(eval echo "$version_var")"
  reason="Set with $version_var"
  #version="$(eval echo "\$BELT_$(echo "$tool_name" | tr '[:lower:]' '[:upper:]')_VERSION")"

  # check for .$tool_name-version
  if [ -z "$version" ]; then
    dir="$PWD"

    until [[ -z "$dir" || -f "${dir}/.${tool_name}-version" ]]; do
      dir=${dir%/*}
    done
    version="$(cat "${dir}/.${tool_name}-version" 2> /dev/null)"
    reason="Set in ${dir}/.${tool_name}-version"
  fi

  # check default version
  if [ -z "$version" ]; then
    version="${version:-$(cat "${BELT_DIR}/.${tool_name}-version" 2> /dev/null)}"
    reason="Set in ${BELT_DIR}/.${tool_name}-version"
  fi

  # check for the latest installed version
  if [ -z "$version" ]; then
    version="$(tool_versions "$tool_name" | head -n 1)"
    reason="No version set, using latest installed"
  fi

  # check for latest available
  if [[ -z "$version" && "$fetch_remote_version" == "true" ]]; then
    version="$(belt_module "$tool_name" latest_version )"
    reason="No version set, downloading latest"
  fi

  tool_version="$version"
  version_reason="$reason"
}

tool_versions() {
  local tool_name=$1
  local tool_dir="${BELT_DIR}/${tool_name}"

  if [[ -d "${tool_dir}" && -n "$(ls -A "${tool_dir}")" ]]; then
    versions=("${tool_dir}"/*)
    echo "${versions[@]##*/}" | tr ' ' '\n' | sort -rV
  fi
}

action=$1; shift
"belt_$action" "$@"
