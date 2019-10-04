# -------------------------------------------------------------------------------
# Setup LANG

# From https://github.com/docker-library/postgres
apt-get -y install locales
localedef -i ru_RU -c -f CP1251 -A /usr/share/locale/locale.alias ru_RU.CP1251
localedef -i ru_RU -c -f KOI8-R -A /usr/share/locale/locale.alias ru_RU.KOI8-R
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
