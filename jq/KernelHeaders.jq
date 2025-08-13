# Prints out CVE IDs for references to the kernel-headers package.
import "lib" as lib;
.document.tracking.id as $id |
	tostream |
	lib::purls |
	select(startswith("pkg:rpm/redhat/kernel-headers")) |
	[ $id, . ] |
	@tsv , halt
