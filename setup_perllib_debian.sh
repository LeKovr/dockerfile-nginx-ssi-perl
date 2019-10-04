
apt-get -y install \
    libexception-class-perl \
    libclass-accessor-perl \
    libdata-formvalidator-perl \
    libnet-ip-perl \
    libtemplate-perl \
    libmime-tools-perl \
    libjson-xs-perl \
    libauthen-captcha-perl \
    libdbd-pg-perl \
    libfile-desktopentry-perl \
    libtext-iconv-perl \
    libspreadsheet-writeexcel-perl \
    libmldbm-perl \
    libclass-dbi-abstractsearch-perl \
    libnumber-format-perl \
    libxml-libxml-perl \
    libcrypt-ssleay-perl \
    libxml-simple-perl \
    libdata-serializer-perl \
    libwww-perl \
    libhtml-strip-perl \
    libgd-gd2-noxpm-perl \
    libstring-random-perl \
    perlmagick \
    shared-mime-info \
    cpanminus \
    libio-string-perl \
    libspreadsheet-parseexcel-perl \
    libdate-calc-perl \
    liblist-moreutils-perl \
    libimager-perl \
    libinline-perl \
    libhpdf-dev \
    libperl-dev \
    libjson-rpc-perl \
    libjson-perl libwww-perl cpanminus \
    libfcgi-procmanager-perl libcache-fastmmap-perl \
    libcgi-simple-perl libdbi-perl libdbd-pg-perl libfcgi-perl \
    liblocale-maketext-lexicon-perl liblocale-maketext-simple-perl \
    libtemplate-perl  libipc-shareable-perl liburi-perl \
    libtext-multimarkdown-perl libtext-diff-perl \
    libany-moose-perl libxml-simple-perl \
    libsoap-lite-perl libio-string-perl \
    libfcgi-client-perl \
    libmime-tools-perl \
    libperl6-junction-perl \
    libxml-compile-perl \
    desktop-file-utils \
    || exit 1

update-desktop-database

cpanm enum \
  && cpanm Toolbox::Simple \
  && cpanm Attribute::Property \
  && cpanm URI::Escape::JavaScript \
  && cpanm PDF::Haru \
  && cpanm FCGI::Daemon \
  && cpanm -n http://www.cpan.org/authors/id/T/TW/TWINKLE/URI-UTF8-Punycode-1.05.tar.gz \
  && cpanm http://www.cpan.org/authors/id/S/SA/SAMTREGAR/HTML-Template-2.9.tar.gz \
  || { cat /root/.cpanm/build.log && exit 1 ; }

# libhtml-template-perl \
# same as BSD copy

# To build HTML::Restrict without gcc if no liblist-moreutils-perl:
#  && cpanm http://search.cpan.org/CPAN/authors/id/R/RE/REHSACK/List-MoreUtils-0.400_010.tar.gz \
