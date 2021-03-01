# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
	"github.com/go-ini/ini v1.62.0"
	"github.com/go-ini/ini v1.62.0/go.mod"
	"github.com/gopherjs/gopherjs v0.0.0-20181017120253-0766667cb4d1"
	"github.com/gopherjs/gopherjs v0.0.0-20181017120253-0766667cb4d1/go.mod"
	"github.com/jtolds/gls v4.20.0+incompatible"
	"github.com/jtolds/gls v4.20.0+incompatible/go.mod"
	"github.com/mattn/go-colorable v0.1.8"
	"github.com/mattn/go-colorable v0.1.8/go.mod"
	"github.com/mattn/go-isatty v0.0.12"
	"github.com/mattn/go-isatty v0.0.12/go.mod"
	"github.com/smartystreets/assertions v0.0.0-20180927180507-b2de0cb4f26d"
	"github.com/smartystreets/assertions v0.0.0-20180927180507-b2de0cb4f26d/go.mod"
	"github.com/smartystreets/goconvey v1.6.4"
	"github.com/smartystreets/goconvey v1.6.4/go.mod"
	"golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2/go.mod"
	"golang.org/x/net v0.0.0-20190311183353-d8887717615a/go.mod"
	"golang.org/x/net v0.0.0-20210226172049-e18ecbb05110"
	"golang.org/x/net v0.0.0-20210226172049-e18ecbb05110/go.mod"
	"golang.org/x/sys v0.0.0-20190215142949-d0b11bdaac8a/go.mod"
	"golang.org/x/sys v0.0.0-20200116001909-b77594299b42/go.mod"
	"golang.org/x/sys v0.0.0-20200223170610-d5e6a3e2c0ae/go.mod"
	"golang.org/x/sys v0.0.0-20201119102817-f84b799fce68"
	"golang.org/x/sys v0.0.0-20201119102817-f84b799fce68/go.mod"
	"golang.org/x/term v0.0.0-20201126162022-7de9c90e9dd1/go.mod"
	"golang.org/x/text v0.3.0/go.mod"
	"golang.org/x/text v0.3.3/go.mod"
	"golang.org/x/tools v0.0.0-20180917221912-90fa682c2a6e/go.mod"
	"golang.org/x/tools v0.0.0-20190328211700-ab21143f2384/go.mod"
	"gopkg.in/ini.v1 v1.62.0"
	"gopkg.in/ini.v1 v1.62.0/go.mod"
)

#EGO_SUM=(
#	"github.com/go-ini/ini v1.55.0"
#	"github.com/go-ini/ini v1.55.0/go.mod"
#	"github.com/mattn/go-colorable v0.1.6"
#	"github.com/mattn/go-colorable v0.1.6/go.mod"
#	"github.com/mattn/go-isatty v0.0.12"
#	"github.com/mattn/go-isatty v0.0.12/go.mod"
#	"golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2/go.mod"
#	"golang.org/x/net v0.0.0-20200506145744-7e3656a0809f"
#	"golang.org/x/net v0.0.0-20200506145744-7e3656a0809f/go.mod"
#	"golang.org/x/sys v0.0.0-20190215142949-d0b11bdaac8a"
#	"golang.org/x/sys v0.0.0-20190215142949-d0b11bdaac8a/go.mod"
#	"golang.org/x/sys v0.0.0-20200116001909-b77594299b42"
#	"golang.org/x/sys v0.0.0-20200116001909-b77594299b42/go.mod"
#	"golang.org/x/sys v0.0.0-20200223170610-d5e6a3e2c0ae"
#	"golang.org/x/sys v0.0.0-20200223170610-d5e6a3e2c0ae/go.mod"
#	"golang.org/x/sys v0.0.0-20200323222414-85ca7c5b95cd"
#	"golang.org/x/sys v0.0.0-20200323222414-85ca7c5b95cd/go.mod"
#	"golang.org/x/text v0.3.0"
#	"golang.org/x/text v0.3.0/go.mod"
#)

go-module_set_globals

DESCRIPTION="Commandline tool to customize Spotify client."
HOMEPAGE="https://github.com/khanhas/spicetify-cli"
SRC_URI="
	https://github.com/khanhas/spicetify-cli/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_SUM_SRC_URI}
"

LICENSE="Apache-2.0 BSD GPL-3 MIT"
SLOT="0"
KEYWORDS="~amd64"

INSTALLDIR="/opt/${PN}"

#src_unpack() {
#	unpack "${DISTDIR}"/golang.org%2Fx%2Fsys%2F@v%2Fv0.0.0-20200323222414-85ca7c5b95cd.zip
#	go-module_src_unpack
#	default
#}

#src_prepare() {
	# Have to do this as eclass has issues with this for reasons unknown to me
#	mkdir -p "${HOME}"/go/pkg/mod/golang.org/x/
#	cp -r "${WORKDIR}"/golang.org/x/sys\@v0.0.0-20200323222414-85ca7c5b95cd/ "${HOME}"/go/pkg/mod/golang.org/x/sys\@v0.0.0-20200323222414-85ca7c5b95cd
#	default
#}

src_compile() {
	go build
}

src_install() {
	insinto "${INSTALLDIR}"
	doins -r {CustomApps,Extensions,Themes,jsHelper,spicetify-cli}
	dobin "${FILESDIR}/spicetify"
	fperms +x "${INSTALLDIR}/spicetify-cli"
}
