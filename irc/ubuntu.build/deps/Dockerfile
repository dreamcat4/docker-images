FROM ubuntu:18.04
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"
# apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y


# Install s6-overlay
ENV s6_overlay_version="1.22.1.0"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz /tmp/
RUN tar hzxf /tmp/s6-overlay-amd64.tar.gz -C / --exclude=usr/bin/execlineb \
 && tar hzxf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin/execlineb && $_clean
ENV S6_LOGGING="1"
# ENV S6_KILL_GRACETIME="3000"


# Supportive pkgs
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget curl git sudo nano less man && $_apt_clean

# Output folder
RUN mkdir -p /out

# ===
# ZNC - install build time dependancies
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    znc znc-dev ca-certificates libcurl4-openssl-dev make && $_apt_clean


# znc - Build external modules
RUN mkdir -p /build/znc-modules/out \
 && date -I > /out/znc_modules_version

WORKDIR /build/znc-modules


# aka.pl - Trace nick changes / aka
RUN git clone https://github.com/MuffinMedic/znc-aka.git \
 && cd znc-aka && ls -lsa && cp aka.py /build/znc-modules/out


# Get backlog from full znc logs, instead of just the buffer
RUN git clone https://github.com/FruitieX/znc-backlog.git \
 && cd znc-backlog && make \
 && ls -lsa && cp backlog.so /build/znc-modules/out


# Per-client channel lists, and part 2x to leave
RUN git clone https://github.com/jpnurmi/znc-chanfilter.git \
 && cd znc-chanfilter && znc-buildmod chanfilter.cpp \
 && ls -lsa && cp chanfilter.so /build/znc-modules/out


# Part 2x to leave, same unified channels list between all clients
RUN mkdir partdetach2 && cd partdetach2 \
 && wget https://gist.githubusercontent.com/Socialery/7058137/raw/2eeb084c5be845d0b4dd37bc5576ce8160140c3c/partdetach2.cpp \
 && znc-buildmod partdetach2.cpp \
 && ls -lsa && cp partdetach2.so /build/znc-modules/out


# # Push and http get nofitications for mobile etc
# RUN git clone https://github.com/dreamcat4/znc-push.git \
#  && cd znc-push && git checkout feature/jdb8s-cmdline-plus \
#  && make command=yes \
#  && ls -lsa && cp push.so /build/znc-modules/out

# # Push and http get nofitications for mobile etc
# RUN git clone https://github.com/jreese/znc-push.git \
#  && cd znc-push && make curl=yes \
#  && ls -lsa && cp push.so /build/znc-modules/out

# Push and http get nofitications for mobile etc
RUN git clone https://github.com/jreese/znc-push.git \
 && cd znc-push && make \
 && ls -lsa && cp push.so /build/znc-modules/out


# Urlbuffer - save seen urls to a local txt file
RUN git clone https://github.com/dreamcat4/urlbuffer.git \
 && cd urlbuffer && znc-buildmod urlbuffer.cpp \
 && ls -lsa && cp urlbuffer.so /build/znc-modules/out


# ZNC - Check which modules were built
RUN ls -lsa /build/znc-modules/out/

# Create tarball in /out/
RUN cd /build/znc-modules/out && tar -czvf /out/znc-modules-$(cat /out/znc_modules_version)_linux-x86_64.tar.gz *


# ===
# atheme - install build time dependancies
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf automake libtool gettext libpcre3-dev perl && $_apt_clean


# atheme - Build external modules
RUN mkdir -p /build/atheme/out
WORKDIR /build/atheme

# atheme - ./configure && make && make install
RUN git clone https://github.com/atheme/atheme.git && cd atheme \
 && atheme_version="$(git tag | grep 'atheme-[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*' | sort | tail -1 | sed -e 's/^atheme-//')" \
 && echo "$atheme_version" > /out/atheme_version \
 && git checkout "atheme-${atheme_version}" \
 && git submodule update --init \
 && \
    ./configure --sysconfdir=/etc/atheme --localstatedir=/var \
    --localedir=/usr/share/locale --datarootdir=/usr/share --prefix=/usr --enable-fhs-paths \
    --enable-contrib --with-pcre --with-perl \
    \
 && make && make install DESTDIR=$PWD/out


# Create tarball in /out/
RUN cd atheme/out && tar -czvf /out/atheme-$(cat /out/atheme_version)_linux-x86_64.tar.gz *


# Upload tvheadend ubuntu .deb pkgs --> bintray.com
WORKDIR /out
ADD upload-to-bintray /bin/
RUN chmod +x /bin/upload-to-bintray


# Execute our upload script
ADD bintray-env /out/
RUN upload-to-bintray && rm /out/bintray-env && ls -lsa /out/


# Default container settings
VOLUME /out
ENTRYPOINT ["/init","/bin/sleep","99999999"]



# `configure' configures xtheme 7.4.0-alpha1 to adapt to many kinds of systems.

# Usage: ./configure [OPTION]... [VAR=VALUE]...

# To assign environment variables (e.g., CC, CFLAGS...), specify them as
# VAR=VALUE.  See below for descriptions of some of the useful variables.

# Defaults for the options are specified in brackets.

# Configuration:
#   -h, --help              display this help and exit
#       --help=short        display options specific to this package
#       --help=recursive    display the short help of all the included packages
#   -V, --version           display version information and exit
#   -q, --quiet, --silent   do not print `checking ...' messages
#       --cache-file=FILE   cache test results in FILE [disabled]
#   -C, --config-cache      alias for `--cache-file=config.cache'
#   -n, --no-create         do not create output files
#       --srcdir=DIR        find the sources in DIR [configure dir or `..']

# Installation directories:
#   --prefix=PREFIX         install architecture-independent files in PREFIX
#                           [/build/xtheme/xtheme]
#   --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
#                           [PREFIX]

# By default, `make install' will install all the files in
# `/build/xtheme/xtheme/bin', `/build/xtheme/xtheme/lib' etc.  You can specify
# an installation prefix other than `/build/xtheme/xtheme' using `--prefix',
# for instance `--prefix=$HOME'.

# For better control, use the options below.

# Fine tuning of the installation directories:
#   --bindir=DIR            user executables [EPREFIX/bin]
#   --sbindir=DIR           system admin executables [EPREFIX/sbin]
#   --libexecdir=DIR        program executables [EPREFIX/libexec]
#   --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
#   --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
#   --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
#   --libdir=DIR            object code libraries [EPREFIX/lib]
#   --includedir=DIR        C header files [PREFIX/include]
#   --oldincludedir=DIR     C header files for non-gcc [/usr/include]
#   --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
#   --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
#   --infodir=DIR           info documentation [DATAROOTDIR/info]
#   --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
#   --mandir=DIR            man documentation [DATAROOTDIR/man]
#   --docdir=DIR            documentation root [DATAROOTDIR/doc/xtheme]
#   --htmldir=DIR           html documentation [DOCDIR]
#   --dvidir=DIR            dvi documentation [DOCDIR]
#   --pdfdir=DIR            pdf documentation [DOCDIR]
#   --psdir=DIR             ps documentation [DOCDIR]

# System types:
#   --build=BUILD     configure for building on BUILD [guessed]
#   --host=HOST       cross-compile to build programs to run on HOST [BUILD]

# Optional Features:
#   --disable-option-checking  ignore unrecognized --enable/--with options
#   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
#   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
#   --disable-nls           do not use Native Language Support
#   --enable-fhs-paths      Use more FHS-like pathnames (for packagers).
#   --enable-large-net      Enable large network support.
#   --enable-contrib        Enable contrib modules.
#   --disable-ssl           don't use OpenSSL to provide more SASL mechanisms
#   --enable-warnings       Enable compiler warnings
#   --disable-propolice     Disable propolice protections (for debugging.)
#   --enable-profile        Enable profiling extensions
#   --disable-rpath         Disable use of -Wl,-rpath= during linking.

# Optional Packages:
#   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
#   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
#   --with-gnu-ld           assume the C compiler uses GNU ld default=no
#   --with-libiconv-prefix[=DIR]  search for libiconv in DIR/include and DIR/lib
#   --without-libiconv-prefix     don't search for libiconv in includedir and libdir
#   --with-libintl-prefix[=DIR]  search for libintl in DIR/include and DIR/lib
#   --without-libintl-prefix     don't search for libintl in includedir and libdir
#   --with-cracklib         Compile cracklib nickserv submodule for checking
#                           password strength.
#   --without-ldap          Disable building ldap auth module.
#   --without-perl          Disable building perl scripting module.
#   --with-libmowgli[=prefix]
#                           Specify location of system libmowgli install, or
#                           "no" to force use of internal libmowgli
#   --with-pcre             Enable PCRE regular expression support

# Some influential environment variables:
#   CC          C compiler command
#   CFLAGS      C compiler flags
#   LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
#               nonstandard directory <lib dir>
#   LIBS        libraries to pass to the linker, e.g. -l<library>
#   CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
#               you have headers in a nonstandard directory <include dir>
#   CPP         C preprocessor
#   PKG_CONFIG  path to pkg-config utility
#   LIBQRENCODE_CFLAGS
#               C compiler flags for LIBQRENCODE, overriding pkg-config
#   LIBQRENCODE_LIBS
#               linker flags for LIBQRENCODE, overriding pkg-config
#   MOWGLI_CFLAGS
#               C compiler flags for MOWGLI, overriding pkg-config
#   MOWGLI_LIBS linker flags for MOWGLI, overriding pkg-config
#   PCRE_CFLAGS C compiler flags for PCRE, overriding pkg-config
#   PCRE_LIBS   linker flags for PCRE, overriding pkg-config

# Use these variables to override the choices made by `configure' or to help
# it to find libraries and programs with nonstandard names/locations.



