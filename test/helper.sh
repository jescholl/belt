[[ -n "$ZSH_VERSION" ]] && setopt shwordsplit

SHUNIT2=${SHUNIT2:-$(command -v shunit2)}

export PREFIX="$PWD/test"
export HOME="$PREFIX/home"

. ./share/toolbelt/belt.sh

setUp() { return; }
tearDown() { return; }
oneTimeTearDown() { return; }
