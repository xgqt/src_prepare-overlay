# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

BASE_URI="https://repo.jellyfin.org/releases/server/debian/versions/stable"
MY_PN="${PN/-bin}"

if [[ "${PV}" == *_rc* ]]; then
	# _rc -> ~rc
	MY_PV="${PV/_rc/~rc}"
	SERVER_DEB="${MY_PN}-server_${MY_PV}_${ARCH}.deb"
	WEB_DEB="${MY_PN}-web_${MY_PV}_all.deb"
else
	# Add "-1"
	MY_PV="${PV}"
	SERVER_DEB="${MY_PN}-server_${MY_PV}-1_${ARCH}.deb"
	WEB_DEB="${MY_PN}-web_${MY_PV}-1_all.deb"
fi

inherit unpacker systemd wrapper

DESCRIPTION="The Free Software Media System"
HOMEPAGE="https://jellyfin.org"
SRC_URI="
	amd64? (
		${BASE_URI}/server/${MY_PV}/${SERVER_DEB} -> ${P}-server-${ARCH}.deb
	)
	arm64? (
		${BASE_URI}/server/${MY_PV}/${SERVER_DEB} -> ${P}-server-${ARCH}.deb
	)
	${BASE_URI}/web/${MY_PV}/${WEB_DEB} -> ${P}-web.deb
"

RESTRICT="mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

DEPEND="
	!www-servers/jellyfin
"
RDEPEND="
	${DEPEND}
	>=media-video/ffmpeg-4.2.2
	acct-group/jellyfin
	acct-user/jellyfin
	dev-db/sqlite
	dev-util/lttng-ust
	media-libs/fontconfig
	media-libs/freetype
"

QA_PREBUILT="usr/lib/${MY_PN}/bin/*"
QA_PRESTRIPPED="${QA_PRESTRIPPED}"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}/${MY_PN}-default.patch"
)

src_unpack() {
	unpack_deb "${P}-server-${ARCH}.deb"
	unpack_deb "${P}-web.deb"
}

src_install() {
	# Install the Server part
	insinto usr/lib/
	doins -r "usr/lib/${MY_PN}"
	insinto etc
	doins -r "etc/${MY_PN}"

	# Install the Web UI part
	insinto "usr/share/${MY_PN}/web"
	doins -r "usr/share/${MY_PN}/web"/*

	# Install wrappers
	make_wrapper "${MY_PN}" "${EPREFIX}/usr/lib/${MY_PN}/bin/${MY_PN}"
	dosym "${EPREFIX}/usr/bin/${MY_PN}" "${EPREFIX}/usr/bin/${PN}"

	# Install services
	newinitd "${FILESDIR}/${MY_PN}" "${MY_PN}"
	doconfd "etc/default/${MY_PN}"
	dosym "${EPREFIX}/etc/conf.d/${MY_PN}" "${EPREFIX}/etc/default/${MY_PN}"
	systemd_dounit "lib/systemd/system/${MY_PN}.service"
	systemd_install_serviced "etc/systemd/system/${MY_PN}.service.d/${MY_PN}.service.conf"

	# Fix permissions
	chmod +x "${ED}/usr/lib/${MY_PN}"/* || die
	chmod +x "${ED}/usr/lib/${MY_PN}/bin"/* || die
	chown -R jellyfin:jellyfin "${ED}/usr/lib/${MY_PN}" || die
}
