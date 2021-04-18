# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit dune

DESCRIPTION="Binding to the SHA cryptographic functions"
HOMEPAGE="https://github.com/djs55/ocaml-sha"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/djs55/ocaml-sha.git"
else
	SRC_URI="https://github.com/djs55/ocaml-sha/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/ocaml-sha-${PV}"
fi

LICENSE="ISC"
SLOT="0"
IUSE="+ocamlopt test"

RDEPEND="
	dev-ml/stdlib-shims
	test? (
		dev-ml/ounit2
	)
"
DEPEND="${RDEPEND}"
