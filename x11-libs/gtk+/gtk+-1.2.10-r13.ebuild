# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtk+/gtk+-1.2.10-r12.ebuild,v 1.17 2013/05/01 03:22:51 tetromino Exp $

EAPI=4
GNOME_TARBALL_SUFFIX="gz"
inherit gnome.org eutils toolchain-funcs autotools multilib-minimal

DESCRIPTION="The GIMP Toolkit"
HOMEPAGE="http://www.gtk.org/"
SRC_URI="${SRC_URI} http://www.ibiblio.org/gentoo/distfiles/gtk+-1.2.10-r8-gentoo.diff.bz2"

LICENSE="LGPL-2.1+"
SLOT="1"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="nls debug"

# Supported languages and translated documentation
# Be sure all languages are prefixed with a single space!
MY_AVAILABLE_LINGUAS=" az ca cs da de el es et eu fi fr ga gl hr hu it ja ko lt nl nn no pl pt_BR pt ro ru sk sl sr sv tr uk vi"
IUSE="${IUSE} ${MY_AVAILABLE_LINGUAS// / linguas_}"

RDEPEND=">=dev-libs/glib-1.2:1[${MULTILIB_USEDEP}]
	x11-libs/libXi[${MULTILIB_USEDEP}]
	x11-libs/libXt[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	x11-proto/inputproto[${MULTILIB_USEDEP}]
	x11-proto/xextproto[${MULTILIB_USEDEP}]
	nls? ( sys-devel/gettext dev-util/intltool )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-m4.patch
	epatch "${FILESDIR}"/${P}-automake.patch
	epatch "${FILESDIR}"/${P}-cleanup.patch
	epatch "${DISTDIR}"/gtk+-1.2.10-r8-gentoo.diff.bz2
	epatch "${FILESDIR}"/${PN}-1.2-locale_fix.patch
	epatch "${FILESDIR}"/${P}-as-needed.patch
	sed -i '/libtool.m4/,/AM_PROG_NM/d' acinclude.m4 #168198
	epatch "${FILESDIR}"/${P}-automake-1.13.patch #467520

	eautoreconf

	multilib_copy_sources
}

multilib_src_configure() {
	local myconf=
	use nls || myconf="${myconf} --disable-nls"
	strip-linguas ${MY_AVAILABLE_LINGUAS}

	if use debug ; then
		myconf="${myconf} --enable-debug=yes"
	else
		myconf="${myconf} --enable-debug=minimum"
	fi

	if multilib_is_native_abi; then
		confbin="/usr/bin/glib-config"
	else
		confbin="/usr/bin/glib-config.${ABI}"
	fi

	GLIB_CONFIG=${confbin} \
	econf \
		--sysconfdir=/etc \
		--with-xinput=xfree \
		--with-x \
		${myconf}
}

multilib_src_compile() {
	emake CC="$(tc-getCC)"
}

multilib_src_install() {
	default

	dodoc AUTHORS ChangeLog* HACKING
	dodoc NEWS* README* TODO
	docinto docs
	cd docs
	dodoc *.txt *.gif text/*
	dohtml -r html

	#install nice, clean-looking gtk+ style
	insinto /usr/share/themes/Gentoo/gtk
	doins "${FILESDIR}"/gtkrc
}

pkg_postinst() {
	if [[ -e /etc/X11/gtk/gtkrc ]] ; then
		ewarn "Older versions added /etc/X11/gtk/gtkrc which changed settings for"
		ewarn "all themes it seems.  Please remove it manually as it will not due"
		ewarn "to /env protection."
	fi

	echo ""
	einfo "The old gtkrc is available through the new Gentoo gtk theme."
}
