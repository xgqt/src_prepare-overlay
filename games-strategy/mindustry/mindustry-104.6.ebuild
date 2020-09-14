# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN^}"

inherit desktop eutils xdg

DESCRIPTION="A sandbox tower defense game"
HOMEPAGE="https://mindustrygame.github.io"
SRC_URI="https://github.com/Anuken/${MY_PN}/releases/download/v${PV}/${MY_PN}.jar"

RESTRICT="mirror strip"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="
	>=virtual/jdk-1.7:*
"

S="${DISTDIR}"

src_unpack() {
	:
}

src_install() {
	insinto "/opt/${MY_PN}"
	doins "${MY_PN}.jar"

	make_wrapper "mindustry" "java -jar /opt/${MY_PN}/${MY_PN}.jar"
	make_desktop_entry "mindustry" "Mindustry" "mindustry" "Game;StrategyGame;"
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
