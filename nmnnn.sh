#!/bin/bash
# NotMuch New n Notify
# Based on https://github.com/natmey/dotfiles/blob/master/notmuch/notmuch-notification.sh

LIMIT=3
SORT="newest-first"
SEARCH="tag:unread \
    and not folder:gandi/n7.net7.root \
    and not folder:gandi/ToTheWeb.Admin \
    and not folder:gandi/Junk"

notmuch new

COUNT=$(notmuch count "$SEARCH")

if [ "$COUNT" -gt 0 ]; then
    SUMMARY=$(notmuch search --format=text --output=summary --limit="$LIMIT" --sort="$SORT" "$SEARCH" | cut -d' ' -f2-)

  notify-send "$COUNT mails" "$SUMMARY"
fi
