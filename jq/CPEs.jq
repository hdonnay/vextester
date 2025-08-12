# Prints out malformed CPEs.
import "lib" as lib;
tostream |
lib::cpes |
(
	select(match("[c][pP][eE]:/[AHOaho]?(:[A-Za-z0-9\\._\\-~%]*){0,6}") | not) |
	[ "invalid_2.2", . ]
) |
@tsv
