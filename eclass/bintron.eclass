# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2


# @ECLASS: bintron.eclass
# @MAINTAINER:
# src_prepare group
# @AUTHOR:
# Maciej Barć <xgqt@riseup.net>
# @SUPPORTED_EAPIS: 7
# @BLURB: Common configuration eclass for binary packages built with Electron
# @DESCRIPTION:
# This eclass is used in Electron packages ebuilds

# shellcheck shell=bash disable=2034


# Inherits
inherit optfeature xdg


case "${EAPI}"
in
	[0-6] )
		die "EAPI: ${EAPI} too old"
		;;
	7 )
		true
		;;
	* )
		die "EAPI: ${EAPI} not supported"
		;;
esac


# Exported functions
export_functions=(
	src_prepare
	src_compile
	src_install
	pkg_postinst
)
EXPORT_FUNCTIONS "${export_functions[@]}"


RESTRICT+=" bindist mirror "


_BINTRON_LANGS="
	am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh-CN zh-TW
"

# @ECLASS-VARIABLE: BINTRON_LANGS
# @DESCRIPTION:
# List of language packs available for this package.

: ${BINTRON_LANGS:=${_BINTRON_LANGS}}


# @FUNCTION: _bintron_set_l10n_IUSE
# @USAGE:
# @INTERNAL
# @DESCRIPTION:
# Converts and adds BINTRON_LANGS to IUSE. Called automatically if
# BINTRON_LANGS is defined.

_bintron_set_l10n_IUSE() {
	local lang
	for lang in ${BINTRON_LANGS}; do
		# Default to enabled since we bundle them anyway.
		# USE-expansion will take care of disabling the langs the user has not
		# selected via L10N.
		IUSE+=" l10n_${lang} "
	done
}

if [[ ${BINTRON_LANGS} ]]; then
	_bintron_set_l10n_IUSE
fi


BINTRON_DEPEND="
	>=app-accessibility/at-spi2-atk-2.26:2
	>=app-accessibility/at-spi2-core-2.26:2
	>=dev-libs/atk-2.26
	>=dev-libs/libxml2-2.9.4-r3[icu]
	>=dev-libs/nss-3.26
	>=media-libs/alsa-lib-1.0.19
	>=media-libs/freetype-2.11.0-r1
	>=media-libs/libwebp-0.4.0
	>=net-print/cups-1.3.11
	app-arch/bzip2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	media-libs/flac
	media-libs/fontconfig
	media-libs/libjpeg-turbo
	media-libs/libpng
	net-misc/curl[ssl]
	sys-apps/dbus
	sys-apps/pciutils
	sys-libs/zlib[minizip]
	virtual/opengl
	virtual/ttf-fonts
	virtual/udev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libxkbcommon
	x11-libs/pango
"
RDEPEND+="${BINTRON_DEPEND}"


# The package will be already compiled,
# also most likely the package will be pre-stripped too.
QA_PREBUILT='*'
QA_PRESTRIPPED='*'


# @ECLASS-VARIABLE: BINTRON_HOME
# @DESCRIPTION:
# Path where the package contents will we installed.

: ${BINTRON_HOME:="/usr/share/${PN}/"}


# Adapted from chromium-2.eclass

# @FUNCTION: bintron_remove_language_paks
# @USAGE:
# @DESCRIPTION:
# Removes pak files from the current directory for languages that the user has
# not selected via the L10N variable.
# Also performs QA checks to ensure BINTRON_LANGS has been set correctly.

function bintron_remove_language_paks() {
	pushd ./locales >/dev/null || die

	# Look for missing pak files.
	local lang
	for lang in ${BINTRON_LANGS}; do
		if [[ ! -e ${lang}.pak ]]; then
			eqawarn "L10N warning: no .pak file for ${lang} (${lang}.pak not found)"
		fi
	done

	# Remove pak files that the user does not want.
	local pak
	for pak in *.pak; do
		lang=${pak%.pak}
		if [[ ${lang} == en-US ]]; then
			continue
		fi
		if ! has ${lang} ${BINTRON_LANGS}; then
			eqawarn "L10N warning: no ${lang} in LANGS"
			continue
		fi
		if ! use l10n_${lang}; then
			rm "${pak}" || die
			rm -f "${pak}.info" || die
		fi
	done

	popd >/dev/null || die
}


# @FUNCTION: bintron_src_prepare
# @DESCRIPTION:
# Default src_prepare.

function bintron_src_prepare() {
	xdg_src_prepare
	bintron_remove_language_paks
}


# @FUNCTION: bintron_src_compile
# @DESCRIPTION:
# Default src_compile.

function bintron_src_compile() {
	true
}


# @FUNCTION: bintron_install_copy
# @DESCRIPTION:
# Install all the files in a given directory, or current directory.

function bintron_install_copy() {
	mkdir -p "${ED}/${BINTRON_HOME}" || die "Failed: mkdir"
	cp -r ./"${1}"/* "${ED}/${BINTRON_HOME}" || die "Failed: copy $(pwd)"
}


# @FUNCTION: bintron_link_bin
# @DESCRIPTION:
# Link launchers in "bin" directory.

function bintron_link_bin() {
	if [[ -d "${ED}/${BINTRON_HOME}"/bin ]]; then
		local bin
		for bin in "${ED}/${BINTRON_HOME}"/bin/*; do
			mkdir -p "${ED}/usr/bin/" || die "Failed: mkdir"
			chmod +x "${bin}" || die "Failed: make ${bin} executable"

			local binname
			binname="$(basename "${bin}")"
			ln -s "${BINTRON_HOME}/${binname}" "${ED}/usr/bin/${binname}" ||
				die "Failed: link ${bin}"
		done
	fi
}


# @FUNCTION: bintron_src_install
# @DESCRIPTION:
# Default src_install.
function bintron_src_install() {
	bintron_install_copy .
	bintron_link_bin
}


# @FUNCTION: bintron_pkg_postinst
# @DESCRIPTION:
# Default pkg_postinst.

function bintron_pkg_postinst() {
	xdg_pkg_postinst
	optfeature "password storage" app-crypt/libsecret kde-frameworks/kwallet
}
