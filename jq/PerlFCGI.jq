# Prints out CVE IDs for the "perl-FCGI" module.
import "lib" as lib;
.document.tracking.id as $id |
	tostream |
	lib::purls |
	select(startswith("pkg:rpm/redhat/perl-FCGI")) |
	$id, halt
