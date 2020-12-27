# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="Urho3D"

inherit xdg cmake

DESCRIPTION="Cross-platform 2D and 3D game engine"
HOMEPAGE="https://urho3d.github.io/"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}/${MY_PN}.git"
else
	if [[ "${PV}" == *_alpha ]]; then
		MY_PV="${PV/_alpha/-ALPHA}"
	else
		MY_PV="${PV}"
	fi
	SRC_URI="https://github.com/${PN}/${MY_PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${MY_PN}-${MY_PV}"
fi

RESTRICT="mirror test"
LICENSE="MIT"
SLOT="0"
IUSE="X alsa doc jack pulseaudio vulkan wayland"

RDEPEND="
	media-libs/glew
	media-libs/libsdl2
	virtual/opengl
	X? (
		x11-apps/xinput
		x11-libs/libX11
		x11-libs/libXScrnSaver
		x11-libs/libXcursor
		x11-libs/libXinerama
		x11-libs/libXrandr
	)
	alsa? ( media-libs/alsa-lib )
	jack? ( virtual/jack )
	pulseaudio? ( media-sound/pulseaudio )
	vulkan? ( dev-util/vulkan-headers )
	wayland? ( dev-libs/wayland )
"
DEPEND="
	${RDEPEND}
	doc? ( app-doc/doxygen[dot]	)
"

src_configure() {
	filter-flags -fno-common
	append-flags -fcommon
	filter-flags -D_FORTIFY_SOURCE=2

	local mycmakeargs=(
		-DALSA=$(usex alsa ON OFF)
		-DALSA_SHARED=$(usex alsa ON OFF)
		-DASSEMBLY=ON
		-DJACK=$(usex jack ON OFF)
		-DJACK_SHARED=$(usex jack ON OFF)
		-DPULSEAUDIO=$(usex pulseaudio ON OFF)
		-DPULSEAUDIO_SHARED=$(usex pulseaudio ON OFF)
		-DURHO3D_DOCS=$(usex doc ON OFF)
		-DVIDEO_OPENGL=ON
		-DVIDEO_OPENGLES=OFF
		-DVIDEO_VULKAN=$(usex vulkan ON OFF)
		-DVIDEO_WAYLAND=$(usex wayland ON OFF)
		-DVIDEO_WAYLAND_QT_TOUCH=OFF
		-DVIDEO_X11=$(usex X ON OFF)
		-DVIDEO_X11_XCURSOR=$(usex X ON OFF)
		-DVIDEO_X11_XINERAMA=$(usex X ON OFF)
		-DVIDEO_X11_XINPUT=$(usex X ON OFF)
		-DVIDEO_X11_XRANDR=$(usex X ON OFF)
		-DVIDEO_X11_XSCRNSAVER=$(usex X ON OFF)
		-DVIDEO_X11_XSHAPE=$(usex X ON OFF)
		-DVIDEO_X11_XVM=$(usex X ON OFF)
		-DWAYLAND_SHARED=$(usex wayland ON OFF)
		-DX11_SHARED=$(usex X ON OFF)
	)
	cmake_src_configure
}
