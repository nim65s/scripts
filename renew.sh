#!/bin/bash
# cron: letsencrypt renew --non-interactive --renew-hook /root/scripts/renew.sh
# if XMPP certificate is renewed, we want to restart prosody

systemctl restart $(grep -q 'im.saurel.me' <<< $RENEWED_DOMAINS && echo prosody || echo nginx)
