# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic unpacker desktop wrapper

# Latest versions are in http://icculus.org/twilight/darkplaces/files/
MY_PV="${PV/_beta/beta}"
MY_SOURCE="${PN}enginesource${MY_PV}.tar.gz"

# Different Quake 1 engines expect the lights in different directories
# http://www.fuhquake.net/download.html and http://www.kgbsyndicate.com/romi/
MY_LIGHTS="fuhquake-lits.rar"

DESCRIPTION="Enhanced engine for iD Software's Quake 1"
HOMEPAGE="http://icculus.org/twilight/darkplaces/"
GIT_COMMIT="95ed24831ca8dcbf6ae8f886733c35ce2ad83272"
SRC_URI="https://github.com/DarkPlacesEngine/darkplaces/archive/${GIT_COMMIT}.tar.gz -> "${MY_SOURCE}"
	lights? (
		http://www.fuhquake.net/files/extras/${MY_LIGHTS}
		http://www.kgbsyndicate.com/romi/id1.pk3 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="capture cdinstall cpu_flags_x86_sse debug dedicated demo ipv6 lights sdl textures"

REQUIRED_USE="
	amd64? ( cpu_flags_x86_sse )
"

SDL_RDEPEND="
	media-libs/libsdl2[udev]
	x11-libs/libX11
	media-libs/libogg
	media-libs/libtheora
	media-libs/libvorbis
	media-libs/libxmp
"
RDEPEND="
	dev-libs/d0_blind_id
	dev-games/ode
	net-misc/curl
	virtual/jpeg:0
	sys-libs/zlib
	media-libs/libpng
	cdinstall? ( games-fps/quake1-data )
	demo? ( games-fps/quake1-demodata )
	textures? ( >=games-fps/quake1-textures-20050820 )
	sdl? ( ${SDL_RDEPEND} )
"
BDEPEND="lights? (
		app-arch/unrar
		app-arch/unzip
	)
	app-alternatives/tar
	app-alternatives/gzip
	sys-apps/coreutils
	sys-apps/sed
	virtual/pkgconfig
"

S="${WORKDIR}"
dir="/usr/share/quake1"

src_unpack() {
	if use lights ; then
		elog "FuhQuake lights: enabled"
		unpack "${MY_LIGHTS}"
		unpack_zip "${DISTDIR}"/id1.pk3
		mv *.lit maps/ || die
		mv ReadMe.txt rtlights.txt
	else
		elog "FuhQuake lights: disabled"
	fi
	tar --strip-components 1 -xf "${DISTDIR}/${MY_SOURCE}"
}

src_prepare() {
	default
	cd "${S}"
	rm mingw_note.txt
	strip-flags
	patch -p1 -i "${FILESDIR}/0020-make-sse-selectable.patch"
	patch -p1 -i "${FILESDIR}/0030-builddate-template.patch" || die
	sed -i "s/%{PVR}/${PVR}/" builddate.c || die
	# Only additional CFLAGS optimization is the -march flag
	local march=$(get-flag -march)
	sed -i \
		-e "s:-lasound:$(pkg-config --libs alsa):" \
		-e "/^CPUOPTIMIZATIONS/d" \
		-e '/^OPTIM_RELEASE/s/=.*/=$(CFLAGS)/' \
		-e '/^OPTIM_DEBUG/s/=.*/=$(CFLAGS)/' \
		-e '/^LDFLAGS_DEBUG/s/$/ $(LDFLAGS)/' \
		-e '/^LDFLAGS_RELEASE/s/$/ $(LDFLAGS)/' \
		-e "s:strip:true:" \
		makefile.inc || die
	if ! use ipv6; then
		elog "IPv6 support: disabled"
		sed -i 's/^#\(CFLAGS_NET+=-DNOSUPPORTIPV6\)$/\1/' makefile || die
	else
		elog "IPv6 support: enabled"
	fi
}

src_compile() {
	local video_capture="disabled"
	if use capture; then
		elog "Video capture: enabled"
		video_capture="enabled"
	else
		elog "Video capture: disabled"
	fi
	local sse_enabled=0
	if use cpu_flags_x86_sse; then
		elog "Skeletal animations: uses SSE"
		sse_enabled=1
	else
		if use amd64; then
			elog "Skeletal animations: uses SSE, not disabling on AMD64"
			sse_enabled=1
		else
			elog "Skeletal animations: uses generic code"
		fi
	fi
	local opts="DP_FS_BASEDIR=\"${dir}\" \
		DP_LINK_JPEG=shared \
		DP_LINK_CRYPTO=shared \
		DP_LINK_CRYPTO_RIJNDAEL=shared \
		DP_LINK_ZLIB=shared \
		DP_LINK_ODE=shared \
		DP_VIDEO_CAPTURE=${video_capture} \
		DP_PRELOAD_DEPENDENCIES=1 \
		GENTOO_BUILD=1 \
		DP_SSE=${sse_enabled}"
	local type="release"
	if use debug; then
		type="debug"
	fi
	if use sdl; then
		emake ${opts} "sdl-${type}"
	fi
	if use dedicated; then
		emake ${opts} "sv-${type}"
	fi
}

src_install() {
	if use sdl; then
		local type=sdl
		# darkplaces executable is needed, even just for demo
		newbin "${PN}-${type}" ${PN}
		newicon darkplaces72x72.png ${PN}.png
		if use demo; then
			# Install command-line for demo, even if not desktop entry
			make_wrapper ${PN}-demo "${PN} -game demo"
		fi
		if use demo && ! use cdinstall; then
			make_desktop_entry ${PN}-demo "Dark Places (Demo)"
		else
			# Full version takes precedence over demo
			make_desktop_entry ${PN} "Dark Places"
		fi
	fi
	if use dedicated; then
		newbin ${PN}-dedicated ${PN}-ded
	fi
	dodoc *.txt todo "${WORKDIR}"/*.txt
	if use lights; then
		insinto "${dir}"/id1
		doins -r "${WORKDIR}"/{cubemaps,maps}
		if use demo ; then
			# Set up symlinks, for the demo levels to include the lights
			local d
			for d in cubemaps maps ; do
				dosym "${dir}/id1/${d}" "${dir}/demo/${d}"
			done
		fi
	fi
}

pkg_postinst() {
	if ! use cdinstall && ! use demo ; then
		elog "Remember to place pak0.pak and pak1.pak in ${dir}/id1"
		if use cdda; then
			elog "If you wish to have the original soundtrack available without playing from an optical drive, please make sure that the path ${dir}/id1/sound/cdtracks exists, and that it contains the original soundtrack. The expected filename schema is track%i.%s with a double-digit count, either in WAV RIFF or OGG Vorbis format."
		fi
	fi
}
