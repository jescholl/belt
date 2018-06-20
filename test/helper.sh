[[ -z "$SHUNIT2"     ]] && SHUNIT2=/usr/share/shunit2/shunit2
#[[ -n "$ZSH_VERSION" ]] && setopt shwordsplit

export PREFIX="$PWD/test"
export HOME="$PREFIX/home"
export PATH="$PWD/bin:$PATH"

. ./share/tool_keeper/tool_keeper.sh

setUp() { return; }
tearDown() { return; }
oneTimeTearDown() { return; }
