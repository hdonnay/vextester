# Prints out all types from all PURLs.
import "lib" as lib;
tostream |
	lib::purls |
	ltrimstr("pkg:") |
	split("/")[0]
