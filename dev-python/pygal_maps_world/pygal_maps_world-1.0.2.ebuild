# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..9} )
inherit distutils-r1

DESCRIPTION="World maps for pygal"
# http://pygal.org/ is dead as of 20210519, therefore use the next best thing
HOMEPAGE="https://pypi.org/project/pygal_maps_world/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="~amd64"
# There are no tests
RESTRICT="test"

RDEPEND="dev-python/pygal[${PYTHON_USEDEP}]"
