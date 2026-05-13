# Prints out all PURLs with "tag" qualifiers.
import "lib" as lib;
tostream |
	lib::purls |
  select([startswith("pkg:oci"), contains("tag=")] | all)
