# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
addr2line-0.15.2
adler-1.0.2
aho-corasick-0.7.18
ansi_term-0.11.0
anyhow-1.0.41
app_dirs2-2.3.2
atty-0.2.14
autocfg-1.0.1
backtrace-0.3.60
base64-0.10.1
base64-0.13.0
bitflags-1.2.1
block-buffer-0.7.3
block-buffer-0.9.0
block-padding-0.1.5
bstr-0.2.16
bumpalo-3.7.0
byte-tools-0.3.1
byte-unit-4.0.12
byteorder-1.4.3
bytes-0.4.12
bytes-1.0.1
cc-1.0.68
cesu8-1.1.0
cfg-if-0.1.10
cfg-if-1.0.0
clap-2.33.3
clearscreen-1.0.4
cloudabi-0.0.3
combine-4.6.0
core-foundation-0.9.1
core-foundation-sys-0.8.2
cpufeatures-0.1.4
crc32fast-1.2.1
crossbeam-deque-0.7.3
crossbeam-epoch-0.8.2
crossbeam-queue-0.2.3
crossbeam-utils-0.7.2
curl-0.4.38
curl-sys-0.4.44+curl-7.77.0
darling-0.10.2
darling-0.12.4
darling_core-0.10.2
darling_core-0.12.4
darling_macro-0.10.2
darling_macro-0.12.4
derivative-2.2.0
derive_builder-0.10.2
derive_builder_core-0.10.2
derive_builder_macro-0.10.2
digest-0.8.1
digest-0.9.0
dirs-2.0.2
dirs-sys-0.3.6
either-1.6.1
encoding_rs-0.8.28
error-chain-0.12.4
fake-simd-0.1.2
filetime-0.2.14
flate2-1.0.20
fnv-1.0.7
foreign-types-0.3.2
foreign-types-shared-0.1.1
form_urlencoded-1.0.1
fs2-0.4.3
fsevent-0.4.0
fsevent-sys-2.0.1
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.31
futures-channel-0.3.15
futures-core-0.3.15
futures-cpupool-0.1.8
futures-io-0.3.15
futures-sink-0.3.15
futures-task-0.3.15
futures-util-0.3.15
generic-array-0.12.4
generic-array-0.14.4
getrandom-0.1.16
getrandom-0.2.3
gimli-0.24.0
glob-0.3.0
globset-0.4.8
h2-0.1.26
h2-0.3.3
hashbrown-0.9.1
headers-0.2.3
headers-core-0.1.1
heck-0.3.3
hermit-abi-0.1.18
http-0.1.21
http-0.2.4
http-body-0.1.0
http-body-0.4.2
httparse-1.4.1
httpdate-1.0.1
hyper-0.12.36
hyper-0.14.9
hyper-tls-0.5.0
ident_case-1.0.1
idna-0.2.3
indexmap-1.6.2
inotify-0.7.1
inotify-sys-0.1.5
iovec-0.1.4
ipnet-2.3.1
itoa-0.4.7
jni-0.19.0
jni-sys-0.3.0
js-sys-0.3.51
kernel32-sys-0.2.2
lazy_static-1.4.0
lazycell-1.3.0
libc-0.2.97
libz-sys-1.1.3
lock_api-0.3.4
log-0.4.14
matches-0.1.8
maybe-uninit-2.0.0
md-5-0.9.1
memchr-2.4.0
memoffset-0.5.6
mime-0.3.16
miniz_oxide-0.4.4
mio-0.6.23
mio-0.7.13
mio-extras-2.0.6
mio-uds-0.6.8
miow-0.2.2
miow-0.3.7
native-tls-0.2.7
ndk-0.3.0
ndk-glue-0.3.0
ndk-macro-0.2.0
ndk-sys-0.2.1
net2-0.2.37
nix-0.20.0
nom-5.1.2
notify-4.0.17
ntapi-0.3.6
num_cpus-1.13.0
num_enum-0.5.1
num_enum_derive-0.5.1
object-0.25.3
once_cell-1.8.0
opaque-debug-0.2.3
opaque-debug-0.3.0
open-1.7.0
openssl-0.10.35
openssl-probe-0.1.4
openssl-src-111.15.0+1.1.1k
openssl-sys-0.9.64
parking_lot-0.9.0
parking_lot_core-0.6.2
percent-encoding-2.1.0
phf-0.8.0
phf_codegen-0.8.0
phf_generator-0.8.0
phf_shared-0.8.0
pin-project-lite-0.2.6
pin-utils-0.1.0
pkg-config-0.3.19
ppv-lite86-0.2.10
proc-macro-crate-0.1.5
proc-macro-error-1.0.4
proc-macro-error-attr-1.0.4
proc-macro2-1.0.27
quote-1.0.9
rand-0.7.3
rand-0.8.4
rand_chacha-0.2.2
rand_chacha-0.3.1
rand_core-0.5.1
rand_core-0.6.3
rand_hc-0.2.0
rand_hc-0.3.1
rand_pcg-0.2.1
redox_syscall-0.1.57
redox_syscall-0.2.9
redox_users-0.4.0
regex-1.5.4
regex-syntax-0.6.25
remove_dir_all-0.5.3
reqwest-0.11.3
rustc-demangle-0.1.20
rustc_version-0.2.3
ryu-1.0.5
same-file-1.0.6
schannel-0.1.19
scopeguard-1.1.0
security-framework-2.3.1
security-framework-sys-2.3.0
semver-0.9.0
semver-parser-0.7.0
serde-1.0.126
serde_derive-1.0.126
serde_json-1.0.64
serde_urlencoded-0.7.0
sha-1-0.8.2
sha2-0.9.5
siphasher-0.3.5
slab-0.4.3
smallvec-0.6.14
socket2-0.4.0
string-0.2.1
strsim-0.8.0
strsim-0.9.3
strsim-0.10.0
structopt-0.3.21
structopt-derive-0.4.14
syn-1.0.73
tempfile-3.2.0
termcolor-1.1.2
terminfo-0.7.3
textwrap-0.11.0
thiserror-1.0.25
thiserror-impl-1.0.25
time-0.1.43
tinyvec-1.2.0
tinyvec_macros-0.1.0
tokio-0.1.22
tokio-1.7.1
tokio-buf-0.1.1
tokio-codec-0.1.2
tokio-current-thread-0.1.7
tokio-executor-0.1.10
tokio-fs-0.1.7
tokio-io-0.1.13
tokio-native-tls-0.3.0
tokio-reactor-0.1.12
tokio-sync-0.1.8
tokio-tcp-0.1.4
tokio-threadpool-0.1.18
tokio-timer-0.2.13
tokio-udp-0.1.6
tokio-uds-0.2.7
tokio-util-0.6.7
toml-0.5.8
tower-service-0.3.1
tracing-0.1.26
tracing-core-0.1.18
try-lock-0.2.3
typenum-1.13.0
unicode-bidi-0.3.5
unicode-normalization-0.1.19
unicode-segmentation-1.7.1
unicode-width-0.1.8
unicode-xid-0.2.2
url-2.2.2
utf8-width-0.1.5
vcpkg-0.2.14
vec_map-0.8.2
version_check-0.9.3
walkdir-2.3.2
want-0.2.0
want-0.3.0
wasi-0.9.0+wasi-snapshot-preview1
wasi-0.10.2+wasi-snapshot-preview1
wasm-bindgen-0.2.74
wasm-bindgen-backend-0.2.74
wasm-bindgen-futures-0.4.24
wasm-bindgen-macro-0.2.74
wasm-bindgen-macro-support-0.2.74
wasm-bindgen-shared-0.2.74
watchexec-1.16.0
web-sys-0.3.51
which-4.1.0
winapi-0.2.8
winapi-0.3.9
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.5
winapi-x86_64-pc-windows-gnu-0.4.0
winreg-0.7.0
ws2_32-sys-0.2.1
xdg-2.2.0
zip-0.5.13
"

inherit cargo flag-o-matic

DESCRIPTION="A modernized, complete, self-contained TeX/LaTeX engine."
HOMEPAGE="https://tectonic-typesetting.github.io/"
SRC_URI="
	https://github.com/tectonic-typesetting/${PN}/archive/refs/tags/${PN}@${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})
"
S="${WORKDIR}/${PN}-${PN}-${PV}"
RESTRICT="mirror"

LICENSE="Apache-2.0 Artistic-2 BSD-2 BSD CC0-1.0 ISC MIT WTFPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

DEPEND="
	dev-libs/icu
	dev-libs/openssl
	media-gfx/graphite2
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/harfbuzz[graphite,icu]
	media-libs/libpng
	sys-libs/zlib
"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( app-text/mdbook )"

src_configure() {
	# Test fails with -ftree-slp-vectorize, therefore disable
	append-flags -fno-tree-slp-vectorize
	# Linker fails with lto enabled
	filter-flags -flto*

	local myfeatures=(
		external-harfbuzz
	)

	cargo_src_configure
}

src_compile() {
	cargo_src_compile
	if use doc; then
	   pushd docs || die
		mdbook build || die
		HTML_DOCS="${S}/docs/book"
	   popd || die
	fi
}

src_install() {
	cargo_src_install
	einstalldocs
}
