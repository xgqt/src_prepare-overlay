# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Unix command line queue utility"
HOMEPAGE="https://github.com/leahneukirchen/nq"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/leahneukirchen/${PN}.git"
else
	SRC_URI="https://github.com/leahneukirchen/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="CC0-1.0"
SLOT="0"
IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	!dev-gap/nq
	!dev-util/fq
"

BDEPEND="
	test? (
		dev-lang/perl
	)
"

src_prepare() {
	default

	sed -i -e 's/CFLAGS=/CFLAGS?=/' Makefile || die
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
}
