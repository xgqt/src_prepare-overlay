# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic unpacker desktop wrapper

# Latest versions are in http://icculus.org/twilight/darkplaces/files/
MY_PV="${PV/_beta/beta}"
MY_SOURCE="${PN}enginesource${MY_PV}.tar.gz"

# Different Quake 1 engines expect the lights in different directories
# http://www.fuhquake.net/download.html and http://www.kgbsyndicate.com/romi/
MY_LIGHTS="fuhquake-lits.rar"

DESCRIPTION="Enhanced engine for iD Software's Quake 1"
HOMEPAGE="http://icculus.org/twilight/darkplaces/"
GIT_COMMIT="175af02fa8e6bc5c14ebac952c6925f9328c2348"
SRC_URI="https://github.com/DarkPlacesEngine/darkplaces/archive/${GIT_COMMIT}.tar.gz -> "${MY_SOURCE}"
	lights? (
		http://www.fuhquake.net/files/extras/${MY_LIGHTS}
		http://www.kgbsyndicate.com/romi/id1.pk3 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc64 ~arm64"
IUSE="alsa capture cdinstall cdsound debug dedicated demo ipv6 lights opengl oss sdl textures"

REQUIRED_USE="
	alsa? ( !oss )
	oss? ( !alsa )
	|| ( alsa oss sdl )
	^^ ( opengl sdl )
"
GLX_RDEPEND="
	x11-libs/libX11
	x11-libs/libXpm
	x11-libs/libXext
	x11-libs/libXxf86vm
	virtual/opengl
	alsa? ( media-libs/alsa-lib )
	capture? (
		media-libs/libogg
		media-libs/libtheora
		media-libs/libvorbis
	)
"
SDL_RDEPEND="
	media-libs/libsdl2[udev]
	x11-libs/libX11
	alsa? ( media-libs/alsa-lib )
	capture? (
		media-libs/libogg
		media-libs/libtheora
		media-libs/libvorbis
	)
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
	opengl? ( ${GLX_RDEPEND} )
	sdl? ( ${SDL_RDEPEND} )
"
BDEPEND="lights? (
		app-arch/unrar
		app-arch/unzip
	)
	app-alternatives/tar
	app-alternatives/gzip
	sys-apps/coreutils
	sys-devel/patch
	sys-apps/sed
	virtual/pkgconfig
"

S="${WORKDIR}"
dir="/usr/share/quake1"

src_unpack() {
	if use lights; then
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
	elog "Applying GCC 11 patch for software renderer."
	patch -p1 -i "${FILESDIR}/0010-fix-dpsoftras-alignment.patch"
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
	if ! use cdsound; then
		elog "CD support: disabled"
		sed -i \
			-e "s:/dev/cdrom:/dev/null:" \
			cd_linux.c || die
		sed -i \
			-e 's:COM_CheckParm("-nocdaudio"):1:' \
			cd_shared.c || die
	else
		elog "CD support: enabled"
	fi
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
	local opts="DP_FS_BASEDIR=\"${dir}\" \
		DP_LINK_JPEG=shared \
		DP_LINK_CRYPTO=shared \
		DP_LINK_CRYPTO_RIJNDAEL=shared \
		DP_LINK_ZLIB=shared \
		DP_LINK_ODE=shared \
		DP_VIDEO_CAPTURE=${video_capture} \
		DP_PRELOAD_DEPENDENCIES=1"
	# If neither OSS or ALSA are selected, then SDL must be selected.
	# However, SDL is a backend for both graphics and sound - so not having ALSA or OSS is only an option, if OpenGL is not.
	local sound_api="NULL"
	if use oss; then
		sound_api="OSS"
	elif use alsa; then
		sound_api="ALSA"
	elif ! use sdl; then
		die "No sound API has been selected."
	fi
	opts+=" DP_SOUND_API=${sound_api}"
	local type="release"
	if use debug; then
		type="debug"
	fi
	# Only compile a maximum of 1 client
	if use sdl; then
		emake ${opts} "sdl-${type}"
	elif use opengl; then
		emake ${opts} "cl-${type}"
	fi
	if use dedicated; then
		emake ${opts} "sv-${type}"
	fi
}

src_install() {
	if use opengl || use sdl ; then
		local type=glx
		use sdl && type=sdl
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
	if use dedicated ; then
		newbin ${PN}-dedicated ${PN}-ded
	fi
	dodoc *.txt todo "${WORKDIR}"/*.txt
	if use lights ; then
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
	if ! use cdinstall && ! use demo; then
		elog "Place pak0.pak and pak1.pak in ${dir}/id1"
	fi
	if use sdl && ! use alsa; then
		ewarn "Select opengl with alsa, instead of sdl USE flag, for better audio latency."
	fi
}
