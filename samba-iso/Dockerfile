FROM dreamcat4/samba
MAINTAINER dreamcat4 <dreamcat4@gmail.com>


# Start scripts
ENV S6_LOGGING="0"
ADD services.d /etc/services.d


# Default container settings
ENTRYPOINT ["/init"]



