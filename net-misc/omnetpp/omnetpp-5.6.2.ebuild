# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="OMNeT++ Discrete Event Simulator"
HOMEPAGE="https://omnetpp.org/"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${PN}-${P}"
fi

RESTRICT="mirror test"
LICENSE="omnetpp"
SLOT="0"
IUSE=""

DEPEND="
	dev-python/pandas
	dev-python/posix-ipc
	dev-python/scipy
"
RDEPEND="
	${DEPEND}
"

src_prepare() {
	default
	cp configure.user.dist configure.user || die
}

src_configure() {
	export PATH="$(pwd)/bin:${PATH}"
	econf
}
