#!/bin/bash
# cron: letsencrypt renew --non-interactive --renew-hook /root/scripts/renew.sh
# if XMPP certificate is renewed, we want to restart prosody

grep -q 'im.saurel.me' <<< $RENEWED_DOMAINS && systemctl restart prosody
test -z "$RENEWED_DOMAINS" && systemctl restart nginx
