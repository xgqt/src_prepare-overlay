# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic unpacker desktop

# This is the only known version of the engine to work with this mod
ENGINE_PV="20170829_beta1"
ENGINE_SOURCE="darkplacesenginesource${ENGINE_PV}.tar.gz"

DESCRIPTION="A mod that makes Quake faster paced, harder, gorier and more violent."
HOMEPAGE="https://www.moddb.com/mods/quake-15 https://icculus.org/twilight/darkplaces"
GIT_COMMIT="175af02fa8e6bc5c14ebac952c6925f9328c2348"
SRC_URI="
	https://github.com/DarkPlacesEngine/darkplaces/archive/${GIT_COMMIT}.tar.gz -> "${ENGINE_SOURCE}"
	https://archive.org/download/quake15-mirror/Q15_PublicBeta1.7z
	https://archive.org/download/quake15-mirror/patch2.7z -> Q15_patch2.7z
	https://icculus.org/%7Emarco/sources/lmp2tga.c
"

LICENSE="GPL-2 UNKNOWN"
SLOT="0"
# DarkPlaces' PNG is broken on big endian and this mod unfortunately uses PNG a lot. Sorry :(
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="alsa capture cdda cpu_flags_x86_sse cpu_flags_x86_sse2 debug dedicated ipv6 opengl oss sdl textures"

REQUIRED_USE="
	alsa? ( !oss )
	oss? ( !alsa )
	|| ( alsa oss sdl )
	^^ ( opengl sdl )
	amd64? (
		cpu_flags_x86_sse
		cpu_flags_x86_sse2
	)
"
GLX_RDEPEND="
	x11-libs/libX11
	x11-libs/libXpm
	x11-libs/libXext
	x11-libs/libXxf86vm
	virtual/opengl
	alsa? ( media-libs/alsa-lib )
	media-libs/libogg
	media-libs/libvorbis
	capture? ( media-libs/libtheora[encode] )
	!capture? ( media-libs/libtheora )
"
SDL_RDEPEND="
	media-libs/libsdl2[udev]
	x11-libs/libX11
	alsa? ( media-libs/alsa-lib )
	media-libs/libogg
	media-libs/libvorbis
	capture? ( media-libs/libtheora[encode] )
	!capture? ( media-libs/libtheora )
"
RDEPEND="
	dev-libs/d0_blind_id
	dev-games/ode
	net-misc/curl
	media-libs/libjpeg-turbo
	sys-libs/zlib
	media-libs/libpng
	textures? ( >=games-fps/quake1-textures-20050820 )
	opengl? ( ${GLX_RDEPEND} )
	sdl? ( ${SDL_RDEPEND} )
"
BDEPEND="
	opengl? (
		sys-devel/gcc
		media-gfx/imagemagick
		app-arch/unzip
	)
	sdl? (
		sys-devel/gcc
		media-gfx/imagemagick
		app-arch/unzip
	)
	app-arch/p7zip
	app-alternatives/tar
	app-alternatives/gzip
	sys-apps/coreutils
	sys-devel/patch
	sys-apps/sed
	virtual/pkgconfig
"

S="${WORKDIR}"
WAD_DIR="/usr/share/quake15"

src_unpack() {
	mkdir engine
	tar -C engine --strip-components 1 -xf "${DISTDIR}/${ENGINE_SOURCE}"
	7z x "${DISTDIR}/Q15_PublicBeta1.7z" quake15
	7z x -y "${DISTDIR}/Q15_patch2.7z" quake15
	ln -s /usr/share/quake1/id1/sound quake15/sound
}

src_prepare() {
	default
	cd "${S}/engine"
	rm mingw_note.txt
	strip-flags
	patch -p1 -i "${FILESDIR}/0010-fix-dpsoftras-alignment.patch"
	patch -p1 -i "${FILESDIR}/0020-do-not-assume-sse2-is-available-just-because-sse-is-available.patch"
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
	if ! use cdda; then
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
	patch -p1 -i "${FILESDIR}/0030-builddate-template.patch"
	sed -i "s/%{PVR}/${ENGINE_PV}/" builddate.c || die
	patch -p1 -i "${FILESDIR}/0040-enforce-quake15.patch"
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
	local sse2_enabled=0
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
	if use cpu_flags_x86_sse2; then
		elog "Softrender: uses SSE2"
		sse2_enabled=1
	else
		if use amd64; then
			elog "Softrender: uses SSE2, not disabling on AMD64"
			sse2_enabled=1
		else
			elog "Softrender: disabled"
		fi
	fi
	local opts="DP_FS_BASEDIR=\"${WAD_DIR}\" \
		DP_LINK_JPEG=shared \
		DP_LINK_CRYPTO=shared \
		DP_LINK_CRYPTO_RIJNDAEL=shared \
		DP_LINK_ZLIB=shared \
		DP_LINK_ODE=shared \
		DP_VIDEO_CAPTURE=${video_capture} \
		DP_PRELOAD_DEPENDENCIES=1 \
		GENTOO_BUILD=1 \
		DP_SSE=${sse_enabled} \
		DP_SSE2=${sse2_enabled} \
		FORCEGAME=quake15"
	# If neither OSS or ALSA are selected, then SDL must be selected.
	# However, SDL is a backend for both graphics and sound - so not
	# having ALSA or OSS is only an option, if OpenGL is not.
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
	ln -s /usr/share/quake1/id1 id1
	# Only compile a maximum of 1 client
	pushd "${WORKDIR}/engine"
	local compile_client=false
	if use sdl; then
		compile_client=true
		emake ${opts} "sdl-${type}"
	elif use opengl; then
		compile_client=true
		emake ${opts} "cl-${type}"
	fi
	if use dedicated; then
		emake ${opts} "sv-${type}"
	fi
	popd
	if ${compile_client}; then
		pushd "${WORKDIR}"
		unzip -j quake15/q15.pk3 gfx/qplaque.lmp
		gcc "${DISTDIR}/lmp2tga.c" -o lmp2tga
		./lmp2tga qplaque.lmp
		convert qplaque.tga -gravity North -chop 0x112 "${WORKDIR}/engine/${PN}.png"
		popd
	fi
}

src_install() {
	pushd "${WORKDIR}/engine"
		if use opengl || use sdl ; then
			local type=$(use sdl && echo "sdl" || echo "glx")
			newbin "darkplaces-${type}" ${PN}
			newicon ${PN}.png ${PN}.png
			make_desktop_entry ${PN} "Quake 1.5"
		fi
		if use dedicated; then
			newbin darkplaces-dedicated ${PN}-ded
		fi
		dodoc *.txt todo "${WORKDIR}"/engine/*.txt
	popd
	insinto "${WAD_DIR}"
	doins id1
	doins -r quake15
}

pkg_postinst() {
	elog "Please make sure that the path /usr/share/quake1/id1 exists and place pak0.pak and pak1.pak in /usr/share/quake1/id1"
	if use cdda; then
		elog "If you wish to have the original soundtrack available without playing from an optical drive, please make sure that the path /usr/share/quake1/id1/sound/cdtracks exists, and that it contains the original soundtrack. The expected filename schema is track%i.%s with a double-digit count, either in WAV RIFF or OGG Vorbis format."
	fi
	if use sdl && ! use alsa; then
		einfo "If audio latency is an issue, consider choosing OpenGL and ALSA USE flags instead of SDL."
	fi
}
