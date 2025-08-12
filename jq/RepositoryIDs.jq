# Prints out any PURLs that seem to have repository-related problems:
# - qualifier  missing the "repository_id" qualifier
# - map        ID in qualifier not in the repository-to-cpe.json
import "repository-to-cpe" as $mapping;
import "lib" as lib;
$mapping::mapping as $map |
tostream |
	lib::purls |
	select(
		startswith("pkg:rpm/redhat/") and
		contains("@") and
		contains("arch=")
	) |
	(
		(
			select(contains("repository_id=") | not) |
				[ "qualifier", . ]
		)
		,
		(
			select(
				match("repository_id=(?<id>[^&]+)") |
				has("id") and (.id | in($map.data) | not)
			) |
				[ "map", . ]
		)
	) |
	@tsv
