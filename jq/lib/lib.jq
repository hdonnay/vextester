module {
	name: "vextester",
};
import "const" as $const;

# Produce all "purl" properties.
#
# Expects streaming input.
def purls:
	select(has(1) and .[0][-1] == "purl") | .[1] 
;

# Produce all "cpe" properties.
#
# Expects streaming input.
def cpes:
	select(has(1) and .[0][-1] == "cpe") | .[1] 
;

# Produce true if the input value is a string with a known PURL type.
#
# See also: https://github.com/package-url/purl-spec/blob/main/purl-types-index.json
def test_purl_type:
	[
		startswith("pkg:alpm/"),
		startswith("pkg:apk/"),
		startswith("pkg:bitbucket/"),
		startswith("pkg:bitnami/"),
		startswith("pkg:cargo/"),
		startswith("pkg:cocoapods/"),
		startswith("pkg:composer/"),
		startswith("pkg:conan/"),
		startswith("pkg:conda/"),
		startswith("pkg:cpan/"),
		startswith("pkg:cran/"),
		startswith("pkg:deb/"),
		startswith("pkg:docker/"),
		startswith("pkg:gem/"),
		startswith("pkg:generic/"),
		startswith("pkg:github/"),
		startswith("pkg:golang/"),
		startswith("pkg:hackage/"),
		startswith("pkg:hex/"),
		startswith("pkg:huggingface/"),
		startswith("pkg:luarocks/"),
		startswith("pkg:maven/"),
		startswith("pkg:mlflow/"),
		startswith("pkg:npm/"),
		startswith("pkg:nuget/"),
		startswith("pkg:oci/"),
		startswith("pkg:pub/"),
		startswith("pkg:pypi/"),
		startswith("pkg:qpkg/"),
		startswith("pkg:rpm/"),
		startswith("pkg:swid/"),
		startswith("pkg:swift/")
	] |
	any
;

# Produce true if the input string is a PURL for a Red Hat rpm.
def test_redhat_rpm:
	startswith("pkg:rpm/redhat/")
;

# Produce true if the input string is a PURL for a specific Red Hat rpm.
def test_one_redhat_rpm:
	test_redhat_rpm and contains("@")
;

# Produce true if the input string is a PURL for a specific Red Hat rpm from a
# module.
def test_redhat_rpm_module:
	test_redhat_rpm and contains("rpmmod=")
;
