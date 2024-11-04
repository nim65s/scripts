#!/usr/bin/env python

from datetime import datetime
from zoneinfo import ZoneInfo

import httpx
import icalendar

cals = {
    # "3A_SRI_COURS": "https://calendar.google.com/calendar/ical/master.sir.ups%40gmail.com/public/basic.ics",
    # "3A_SRI_TP_G1": "https://calendar.google.com/calendar/ical/lg0vrqu5jj8autgtnf6nep2cgo%40group.calendar.google.com/public/basic.ics",
    # "3A_SRI_TP_G2": "https://calendar.google.com/calendar/ical/gdlsf0bsq0jgg6alasc48epf14%40group.calendar.google.com/public/basic.ics",
    # "M2_ISTR": "https://calendar.google.com/calendar/ical/42ddpalnnci9ab5rqj6etioi0c%40group.calendar.google.com/public/basic.ics",
    "SRI": "https://mergics.saurel.me/public/nim-sri.ics",
    "ISTR": "https://mergics.saurel.me/public/nim-istr.ics",
}

FR = ZoneInfo("Europe/Paris")
MY_KEYWORDS = ["Multithreading", "Conception des systemes orientee objet"]
DTFMT = "%Y/%m/%d %H:%M"
now = datetime.now().astimezone(FR)


def main():
    for cal, url in cals.items():
        print(cal, url)
        r = httpx.get(url, timeout=10)
        events = icalendar.Calendar.from_ical(r.content)
        k = []
        for event in events.walk("VEVENT"):
            start = event["DTSTART"].dt.astimezone(FR)
            if start > now:
                end = event["DTEND"].dt.astimezone(FR)
                duration = (end - start).seconds / 3600
                summary = event["SUMMARY"].to_ical().decode()
                k.append((start, duration, summary))
        for s, d, t in sorted(k):
            print(s.strftime(DTFMT), f"{d:.2f}", t.strip())
        print()


if __name__ == "__main__":
    main()
