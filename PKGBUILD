# Maintainer: Alexander Epaneshnikov <alex19ep@archlinux.org>
# Contributor: libertylocked <libertylocked@disroot.org>

pkgname=bitwarden
pkgver=2026.8.0
pkgrel=2
_electronversion=43
pkgdesc='A secure and free password manager for all of your devices'
arch=('x86_64')
url='https://github.com/bitwarden/clients/tree/main/apps/desktop'
license=('GPL-3.0-only')
depends=("electron$_electronversion" 'libnotify' 'org.freedesktop.secrets' 'libxtst' 'libxss' 'libnss_nis')
makedepends=('git' 'npm' 'python' 'python-setuptools' 'node-gyp' 'nodejs-lts-jod' 'jq' 'rust' 'fdupes')
source=(bitwarden::git+https://github.com/bitwarden/clients.git#tag=desktop-v$pkgver
        messaging.main.ts.patch
        nativelib.patch
        native-messaging.main.ts.patch
        no-sourcemaps.patch
        remove-unnecessary-deps.patch
        ${pkgname}.sh
        ${pkgname}.desktop)
sha512sums=('706a2023b67512e9d07b0710ae27b128b3778cfdf4a9e5643d14e8f676d4a267ec2a791301eb2f631310af505e39144a0ed8a67a4bd85c692190d987a73c40b1'
            'a04cd8bad95e5b8f9f04c9e6b4f4de8b249fa29037d70e9191d150dce4cead95ec0863081415bbd1f0f534657aa41c25eb82386ba5a8e998737325ea84682c7c'
            '0a769e138c54c7600d72e66e832af43bc7157682a995a08ec0c343909fe5b7cae4a7d547507807320f783af8e282ddc16cacec19f66cc5a029cfc6c2e1cc7468'
            '878b2189b21f1c1d054f57c6096a11dc15a855346c897176575e6ad11db7a24d44176ec94bfa8ab7fb7e1f9b8f60d03ff4c41c5c3dfe062159447dd0e2f674f5'
            'e32d7b2d2149dc40a5e9be541126066ad04bc91e2e1639b7f9c021ff6f370713b6c555fa007331acdbd46dc02ce951d4644d0236357993fe6d6650d342c155ce'
            '234672ba976bad52fd8a903d1bd768dc475e40e6414720fe341d65a278cb1053266c41753504b03a5ff9c2788a3ecb200bad7f4319cf2f89aff1f2d97e35b700'
            '00af9f1b0318aed814dfb38ea03bba3af47c80131a184b0ca1835c0ce0a55ebae3058ffea430ff29d720217283feb2c734874bb82a08e4b87223613c314d32dd'
            'ccd3f085f54c627a393c79f257379129af90b9f04bc74c5125efd5c4eadc9a25383ce0e444431140b3cf955987e90c44b514b73a8f34f258122d197fd91c1340')

prepare() {
	cd bitwarden/apps/desktop

	export npm_config_cache="$srcdir/npm_cache"
	export ELECTRON_SKIP_BINARY_DOWNLOAD=1

	# Remove unused postinstall script (electron-rebuild)
	sed -i '/"postinstall":/d' package.json

	# Patch build to make it work with system electron
	export SYSTEM_ELECTRON_VERSION=$(electron$_electronversion -v | sed 's/v//g')
	export ELECTRONVERSION=$_electronversion
	sed -i "s|@electronversion@|${ELECTRONVERSION}|" "$srcdir/bitwarden.sh"

	cd ../../
	# This patch is required to make "Start automatically on login" work
	patch -p1 -i "$srcdir/messaging.main.ts.patch"
	# This patch is required to make "browser integration" work
	patch -p1 -i "$srcdir/native-messaging.main.ts.patch"
	# rust build
	patch -p1 -i "$srcdir/nativelib.patch"
	# patches from opensuse
	patch -p1 -i "$srcdir/no-sourcemaps.patch"
	patch -p1 -i "$srcdir/remove-unnecessary-deps.patch"
	npm ci
	pushd apps/desktop/desktop_native
	cargo fetch --locked --target "$(rustc --print host-tuple)"
	popd
}

build() {
	cd bitwarden/apps/desktop
	electronDist=/usr/lib/electron$_electronversion
	electronVer=$(electron$_electronversion --version | tail -c +2)
	export npm_config_cache="$srcdir/npm_cache"
	export ELECTRON_SKIP_BINARY_DOWNLOAD=1
	export CXXFLAGS="$CXXFLAGS -Wno-error"
	pushd desktop_native
	cargo rustc --frozen --release --package desktop_napi --lib --crate-type cdylib
	cargo rustc --frozen --release --package desktop_proxy --bin desktop_proxy
	rm -fv napi/desktop_napi.node
	cp -v target/release/libdesktop_napi.so napi/desktop_napi.node
	cargo build --frozen --release --package process_isolation
	popd
	npm run build
	npm run clean:dist
	rm -fv build/desktop_proxy
	cp -v desktop_native/target/release/desktop_proxy build/desktop_proxy
	rm -fv ../../node_modules/argon2/build-tmp-napi-v3/node_gyp_bins/python3
	fdupes build
	pushd build
	#JS debug symbols (unusable)
	find -name '*.map' -type f -print -delete
	#Source code
	find -name '*.c' -type f -print -delete
	find -name '*.cpp' -type f -print -delete
	find -name '*.h' -type f -print -delete
	find -name '*.gyp' -type f -print -delete
	find -name '*.gypi' -type f -print -delete
	find -name '*.ts' -type f -print -delete
	find -name '*.cts' -type f -print -delete
	find -name build-tmp-napi-v3  -print0 |xargs -r0 -- rm -rvf --
	find -name src -print0 |xargs -r0 -- rm -rvf --
	find -name Makefile -type f -print -delete
	find -name 'Pipfile*' -type f -print -delete
	find -name '*.patch' -type f -print -delete
	#Temporary build files
	find -name '.deps' -print0 |xargs -r0 -- rm -rvf --
	find -name 'obj.target' -print0 |xargs -r0 -- rm -rvf --
	find -name 'vendor' -print0 |xargs -r0 -- rm -rvf --
	find -name '*package-lock.json' -type f -print -delete
	find -name '*.mk' -type f -print -delete
	find -name '*.Makefile' -type f -print -delete

	#Documentation
	find -name '*.md' -type f -print -delete
	find -name doc -print0 |xargs -r0 -- rm -rvf --
	find -name test -print0 |xargs -r0 -- rm -rvf --
	#Compile-time-only dependencies
	find -name nan -print0 |xargs -r0 -- rm -rvf --
	find -name node-addon-api -print0 |xargs -r0 -- rm -rvf --
	#Other trash
	find -name '*.yml' -type f -print -delete
	find -name '.npmignore' -type f -print -delete
	find -name '.gitignore' -type f -print -delete

	#Fix file mode
	find . -type f -exec chmod 644 {} \;
	find . -name '*.node' -exec chmod 755 {} \;
	chmod 755 desktop_proxy

	# Remove empty directories
	find . -type d -empty -print -delete
	popd
	npm exec -c "electron-builder --linux --x64 --dir -c.electronDist=$electronDist \
	             -c.electronVersion=$electronVer"
}

package(){
	cd bitwarden/apps/desktop
	install -vDm644 dist/linux-unpacked/resources/app.asar -t "${pkgdir}/usr/lib/${pkgname}"
	install -vDm644 build/package.json -t "${pkgdir}/usr/lib/${pkgname}"
	install -vDm755 build/desktop_proxy -t "${pkgdir}/usr/lib/${pkgname}"
	install -vDm755 desktop_native/target/release/libprocess_isolation.so -t "${pkgdir}/usr/lib/${pkgname}"
	cp -vr dist/linux-unpacked/resources/app.asar.unpacked -t "${pkgdir}/usr/lib/${pkgname}"

	for i in 16 32 64 128 256 512 1024; do
		install -vDm644 resources/icons/${i}x${i}.png "${pkgdir}/usr/share/icons/hicolor/${i}x${i}/apps/${pkgname}.png"
	done
	install -vDm644 resources/icon.png "${pkgdir}/usr/share/icons/hicolor/1024x1024/apps/${pkgname}.png"

	install -vDm755 "${srcdir}/${pkgname}.sh" "${pkgdir}/usr/bin/bitwarden-desktop"
	install -vDm644 "${srcdir}"/${pkgname}.desktop -t "${pkgdir}"/usr/share/applications
}
