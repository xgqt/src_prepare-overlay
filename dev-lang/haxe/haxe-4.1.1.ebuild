# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Before updating first read the recipe:
# https://github.com/ocaml/opam-repository/tree/master/packages/haxe

EAPI=7

# inherit dune

DESCRIPTION="Multi-target universal programming language"
HOMEPAGE="https://haxe.org/"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/HaxeFoundation/${PN}.git"
else
	SRC_URI="https://github.com/HaxeFoundation/haxe-debian/archive/upstream/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/haxe-debian-upstream-${PV}"
fi

LICENSE="GPL-2 MIT"
SLOT="0"
IUSE="+ocamlopt"

RDEPEND="
	<dev-ml/extlib-1.7.8
	>=dev-ml/extlib-1.7.6

	dev-ml/ptmap
	dev-ml/sedlex
	dev-ml/sha
	dev-ml/xml-light

	dev-lang/neko
	dev-libs/libpcre
	net-libs/mbedtls
	sys-libs/zlib
"
DEPEND="${RDEPEND}"

QA_PRESTRIPPED="
	usr/bin/haxelib
"

src_compile() {
	if use ocamlopt; then
		export OCAMLOPT=ocamlopt.opt
	fi

	emake -j1
}

src_install() {
	emake DESTDIR="${D}" INSTALL_DIR=/usr install

	dodoc *.md
}
