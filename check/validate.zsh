emulate -L zsh

local template="${1?missing template argument}"; shift
local workdir="$(mktemp -d -t jsonschema.XXXX)"
trap 'rm -rf -- "$workdir"' EXIT

for f in "$@"
	tar -xaf "$f" -C "$workdir"

jsonschema validate \
	--http \
	--template "$template" \
	./etc/csaf_json_schema.json \
	"$workdir"/**.json
