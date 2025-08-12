# Prints out any PURLs that have correctness problems:
# - type     The "type" part is nonstandard.
# - version  The PURL is for a Red Hat rpm, but does not have a valid VR string.
# - module   The "rpmmod" qualifier is malformed.
import "lib" as lib;
tostream |
	lib::purls |
		(select(lib::test_purl_type | not) | ["type", .])
	,
		(select(
			lib::test_one_redhat_rpm
			and (
				# Check that the version is valid.
				# This just checks that there's a "release" segment, currently.
				split("[@?]"; null) | .[1] |
				contains("-") |
				not
			)
		) | ["version", .])
	,
		(select(
			lib::test_redhat_rpm_module
			and (
				# Check that the module descriptor is valid.
				# More clarification is needed on what information should be
				# here and how it's used.
				#
				# See also: https://issues.redhat.com/browse/SECDATA-1121
				test("rpmmod=(?<name>[^:]+):(?<stream>[^:]+)(:(?<version>[^:]+))?(:(?<context>[^:]+))?") | not
			)
		) | ["module", .])
	# Checks for the "repository_id" got moved to their own script; it was too
	# noisy otherwise.
	| @tsv
