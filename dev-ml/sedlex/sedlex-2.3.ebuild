# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit dune

DESCRIPTION="An OCaml lexer generator for Unicode"
HOMEPAGE="https://github.com/ocaml-community/sedlex/"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ocaml-community/${PN}.git"
else
	SRC_URI="https://github.com/ocaml-community/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

UCD_URL_BASE="https://www.unicode.org/Public/12.1.0/ucd"
SRC_URI+="
	${UCD_URL_BASE}/DerivedCoreProperties.txt -> ${P}-DerivedCoreProperties.txt
	${UCD_URL_BASE}/extracted/DerivedGeneralCategory.txt -> ${P}-DerivedGeneralCategory.txt
	${UCD_URL_BASE}/PropList.txt -> ${P}-PropList.txt
"

LICENSE="MIT"
SLOT="0"
IUSE="+ocamlopt"

RDEPEND="
	<dev-ml/ppxlib-0.22.0

	dev-ml/gen
	dev-ml/uchar
"
DEPEND="${RDEPEND}"

src_unpack() {
	default

	for txt in DerivedCoreProperties DerivedGeneralCategory PropList; do
		echo "Copy ${DISTDIR}/${P}-${txt}.txt to ${S}/src/generator/data/${txt}.txt"
		cp "${DISTDIR}/${P}-${txt}.txt" "${S}/src/generator/data/${txt}.txt" \
			|| die "failed to copy ${P}-${txt}.txt to ${txt}.txt"
	done
}

src_prepare() {
	default

	# Remove dune file with rules to download additional txt files
	rm "${S}/src/generator/data/dune" \
		|| die "faled to remove src/generator/data/dune"
}
