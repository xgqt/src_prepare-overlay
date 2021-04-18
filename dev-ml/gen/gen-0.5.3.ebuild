# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit dune

DESCRIPTION="Iterators for OCaml, both restartable and consumable"
HOMEPAGE="https://github.com/c-cube/gen/"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/c-cube/gen.git"
else
	SRC_URI="https://github.com/c-cube/gen/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

# doc:  odoc
# test: qcheck qtest
RESTRICT="test"
LICENSE="BSD-2"
SLOT="0"
IUSE="+ocamlopt"
