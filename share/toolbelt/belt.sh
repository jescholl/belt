BELT_VERSION="0.1.0"
BELT_DIR=${BELT_DIR:-~/.belt}
SOURCE=${BASH_SOURCE[0]:-${(%):-%x}}
BELT_MODULE_DIR=$( cd "${SOURCE%/*}/tools" && pwd )

for tool in $BELT_MODULE_DIR/*; do
  tool_name=$(basename -s .sh $tool)
  [ -d "${BELT_DIR}/${tool_name}" ] || mkdir -p "${BELT_DIR}/${tool_name}"

source /dev/stdin <<EOT
$tool_name() {
  belt exec "$tool_name" "\${BELT_$(echo $tool_name | tr '[:lower:]' '[:upper:]')_VERSION:-any}" \$@
}
EOT
done
unset tool_name tool SOURCE

belt() {
  action=$1; shift

  case "$action"; in
    module)
      module=$1; shift
      "${BELT_MODULE_DIR}/${module}.sh" "$@"
      ;;
    *)
      _belt_$action "$@"

  esac

  command -v _belt_$action > /dev/null
  if [ "$?" -eq "0" ]; then
    echo "executing function _belt_$action $@"
    _belt_$action "$@"
  elif [ -f "${BELT_MODULE_DIR}/${tool_name}.sh" ]; then
    echo "executing script: ${BELT_MODULE_DIR}/${tool_name}.sh '${action}' '$@'"
    "${BELT_MODULE_DIR}/${tool_name}.sh" "${action}" "$@"
  else
    echo "script does not exist: ${BELT_MODULE_DIR}/${tool_name}.sh"
  fi


  # FIXME: this could be better by minimizing the functions in the environment (just belt()), and running everything else through a shell script
}

_belt_completion() {
  echo "FIXME: add completion" >&2
}

_belt_help() {
  cat <<EOT
Usage: belt <command> [<args>]

Some useful commands are:
  exec      <tool> <version> [<args>]
  install   <tool> <version>
  use       <tool> <version>
  which     <tool> <version>
  versions  [tool]
EOT
}

_belt_use() {
  local tool_name=$1
  local version=$2
  echo "USE: setting version to $version" >&2

  export BELT_$(echo $tool_name | tr '[:lower:]' '[:upper:]')_VERSION=$version
}

_belt_which() {
  local tool_name=$1
  local version=$2
  echo "${BELT_DIR}/${tool_name}/${version}"
}

_belt_install() {
  local tool_name=$1; shift
  local version=$1; shift

  local os_type=${OS_TYPE:-$(uname | tr '[:upper:]' '[:lower:]')}
  local os_arch=${OS_ARCH:-$(uname -m)}
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

  local url=$(belt "$tool_name" url "$os_type" "$os_arch" "$version")
  local install_path=$(belt which "$tool_name" "$version")

  curl -Lsfo $install_path $url
  if [ "$?" -eq "0" ]; then
    chmod +x $install_path
  else
    cat <<EOT
Unable to download $tool_name
url: $url
path: $install_path
EOT
    return 1
  fi
}

_belt_exec() {
  local tool_name=$1; shift
  local version=$1; shift

  case "$version" in
    any)
      version=$(belt version $tool_name | tail -n 1)
      version=${version:-$(belt latest $tool_name)}
      ;;
    latest)
      version=$(belt latest $tool_name)
      belt use kubectl $version
      ;;
  esac

  local tool_path=$(_belt_which $tool_name $version)

  if ! [ -f "$tool_path" ]; then
    belt install "$tool_name" "$version"
  fi
  $tool_path $@
}

_belt_versions() {
  for tool in $BELT_MODULE_DIR/*; do
    tool_name=$(basename -s .sh $tool)
    echo $tool_name:
    local current_version=$(_belt_version $tool_name)
    for version in $(__belt_tool_versions $tool_name); do
      if [[ "$version" == "$current_version" ]]; then
        echo "  * $version"
      else
        echo "    $version"
      fi
    done
  done
}

_belt_version() {
  tool_name=$1
  version=$(eval echo \$BELT_$(echo $tool_name | tr '[:lower:]' '[:upper:]')_VERSION)
  version=${version:-$(__belt_tool_versions $tool_name | tail -n 1)}
  echo $version
}

__belt_tool_versions() {
  local tool_name=$1
  local tool_dir=${BELT_DIR}/${tool_name}
  if [[ -d "${tool_dir}" && -n "$(ls -A "${tool_dir}")" ]]; then
    versions=("${tool_dir}"/*)
    echo ${versions[@]##*/} | tr ' ' '\n' | sort -V
    #versions=${versions##*/}
    #warn e: $(echo ${versions[@]} | tr ' ' '\n' | sort -V)

    #echo  $(echo ${versions##*/} | tr ' ' 'n' | sort -V)
    #for version in ${versions[@]}; do
    #  basename $version
    #done
  fi
}
