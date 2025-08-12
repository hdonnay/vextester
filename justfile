#!/usr/bin/env -S just --justfile

zsh := require('zsh')
curl := require('curl')
parallel := require('parallel')
tar := require('tar')
jq := require('jq')
just := just_executable()

url := 'https://security.access.redhat.com/data/csaf/v2/vex/'
archive_pat := 'csaf_vex_????-??-??.tar.zst'
split_pat := 'csaf_vex_????.tar.zst'
cachedir := cache_directory() / 'vextester'
set shell := ["zsh", "-uc"]

[private]
default:
	@just --list
	@print "\nFetch VEX data from: {{url}}"
	@setopt extended_glob;\
		print "\n"Available jq scripts:;\
		for n in **/(*~lib).jq(#q.:t:r);\
			print " - $n"

[private]
check_cachedir:
	@[[ -d {{cachedir}} ]] || mkdir -p '{{cachedir}}'

[private]
check_archive: check_cachedir
	@[[ -n {{cachedir / archive_pat}}(#qN) ]]

[private]
check_split:
	@[[ -n {{cachedir / split_pat}}(#q.Y1N) ]] || \
		{{just_executable()}} update

# Fetch the current VEX archive.
[group('setup')]
fetch: check_cachedir
	#!/usr/bin/env -S zsh -euo pipefail
	cd '{{cachedir}}'
	local archive="$({{curl}} -sSfL "{{url}}archive_latest.txt")"
	print fetching "${archive:t}"
	{{curl}} '-#SfLOC' - "{{url}}${archive}"

# Split the current VEX archive for parallel processing.
[group('setup')]
split: check_archive
	#!/usr/bin/env -S zsh -euo pipefail
	local workdir="$(mktemp -d -t split_corpus.XXXX)"
	trap 'print cleaning up; rm -rf -- "$workdir"' EXIT

	local tarfile=$(print {{cachedir / archive_pat}}(OnY1))
	print extracting "${tarfile:t}"
	{{tar}} -xaf "$tarfile" -C "$workdir"

	print repacking
	find "$workdir" -type f -name '*.json' -printf '%P\n'|
		{{parallel}} --progress --pipe --fifo -N 1 --max-lines 5000 \
			{{tar}} --create --zstd \
				--file {{cachedir / 'csaf_vex_{#:%04d}.tar.zst'}} \
				-C "$workdir" \
				-T '{}' \
				--xform "'s,.*/,,'"

# Update the current VEX archive, removing old archives.
[group('setup')]
update: fetch && split
	@rm -rf -- {{cachedir / archive_pat}}(On[2,-1]) {{cachedir / split_pat}}(.N)

# Remove all cached data.
[confirm]
[group('setup')]
clean:
	@rm -vrf -- '{{cachedir}}' ||:


# Run the named jq script across a split archive.
jq script: check_split
	#!/usr/bin/env -S zsh -euo pipefail
	setopt EXTENDED_GLOB

	local script=$(print (jq/)#{{script}}(.jq)#)
	if [[ -z "$script" ]]; then
		print unable to find jq script >&2
		exit 99
	fi

	{{parallel}} \
			{{tar}} -xOaf '{}' \|\
			{{jq}} --unbuffered -r -L ./jq/lib -f "${script}" \|\
			sort -u \
			::: {{cachedir / split_pat}}(.N) |
		sort -u

# Run all jq scripts.
all: check_split
	@for f in *.jq(.N); do \
		print {{style("command")}}just jq "$f"{{NORMAL}} && {{just}} jq "$f";\
	done

# TODO: Some extra scaffolding for post-processing jq output.
# Run the named "check" script.
[private]
check script: check_split
	#!/usr/bin/env -S zsh -euo pipefail
	setopt EXTENDED_GLOB

	local script=$(print (check/)#{{script}}(.zsh)#(#qN))
	[[ -z "$script" ]] && exec {{just}} jq "{{script}}"

	local jq="$(sed -n '/^# jq:/{s/.\+:[[:space:]]*//;p;q}' "$script")"
	if [[ -z "$jq" ]]; then
		print unable to find jq script >&2
		exit 99
	fi
	{{just}} jq "$jq" | {{zsh}} "$script"
