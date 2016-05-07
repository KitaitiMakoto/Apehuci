#!/bin/bash

set -eu

/root/letsencrypt/letsencrypt-auto renew --webroot --webroot-path=/usr/share/groonga/html && \
    /usr/sbin/groonga-httpd -t && \
    systemctl restart groonga-httpd
