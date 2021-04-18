# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit dune

DESCRIPTION="Maps of integers implemented as Patricia trees"
HOMEPAGE="https://github.com/backtracking/ptmap/"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/backtracking/${PN}.git"
else
	SRC_URI="https://github.com/backtracking/${PN}/releases/download/${PV}/${P}.tbz"
	KEYWORDS="~amd64"
fi

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="+ocamlopt"

RDEPEND="
	dev-ml/seq
	dev-ml/stdlib-shims
"
DEPEND="${RDEPEND}"
