# Copyright 2020-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gog.eclass
# @MAINTAINER:
# moog621@gmail.com
# @AUTHOR:
# moog621@gmail.com
# @SUPPORTED_EAPIS: 7
# @BLURB: Functions for interacting with GOG API.
# @DESCRIPTION:
# Sets GOG_GAME_* variables for use with games that can be obtained from GOG.
# Additionally, some games are not available on all platforms. ebuilds are
# allowed to prefer a platform that works best with the host platform.
# However, GOG probably supplies only x86 binaries for Linux, Mac and Windows.
# It is up to the ebuild to enable and offer other alternate avenues to support
# a particular game.

# In order to disable network-sandbox:
PROPERTIES+="live"

# @ECLASS-VARIABLE: GOG_GAME_NAME
# @DESCRIPTION:
# Name of the game as it appears in lgogdownloader list.
: ${GOG_GAME_NAME:=}

# @ECLASS-VARIABLE: GOG_GAME_L10N
# @DESCRIPTION:
# Languages available for the game.
: ${GOG_GAME_L10N:=()}

# @ECLASS-VARIABLE: GOG_GAME_PLATFORM
# @DESCRIPTION:
# This choice specifies which binaries, for which platform, will be downloaded from GOG.
# Sometimes, this can be irrelevant, as unofficial platform binaries may come from 3rd
# party sources.
: ${GOG_GAME_PLATFORM:=}

# @ECLASS-VARIABLE: GOG_GAME_INSTALLER
# @DESCRIPTION:
# Filename of the installer. There can be many, as some games support each language
# through separate installers.
: ${GOG_GAME_INSTALLER:=()}

LICENSE+="GOG_EULA"
# lgogdownloader-3.8::gentoo can be used as it has the necessary patch required for
# headless operations with Portage.
BDEPEND+="
	>=games-util/lgogdownloader-3.8
	app-arch/innoextract
"

gog_sanity_check() {
	portageq envvar GOG_CONFIG >/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		die "Please define GOG_CONFIG in /etc/portage/make.conf as the output of export_gog_to_portage."
	fi
}

gog_initialize() {
	gog_sanity_check
	mkdir -p ~/.config
	echo ${GOG_CONFIG} | base64 -d | tar -Jxf - -C ~
}

# @FUNCTION: gog_download_installer
# @DESCRIPTION:
# Downloads the offline installer of a specified game, with specified language, for the specified platform.
gog_download_installer() {
	lgogdownloader --no-platform-detection --download --game ${GOG_GAME_NAME} --exclude extras --language ${GOG_GAME_L10N} --platform ${GOG_GAME_PLATFORM} >/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		die "lgogdownloader failed. Please make sure it works."
	fi
}

# @FUNCTION: gog_extract_installer
# @DESCRIPTION:
# Extracts the installer of specified filename.
gog_extract_installer() {
	innoextract -e ${GOG_GAME_INSTALLER}
}
