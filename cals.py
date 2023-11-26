#!/usr/bin/env python

from datetime import datetime, timezone
from zoneinfo import ZoneInfo

import httpx
import icalendar

cals = {
    "3A_SRI_COURS": "https://calendar.google.com/calendar/ical/master.sir.ups%40gmail.com/public/basic.ics",
    "3A_SRI_TP_G1": "https://calendar.google.com/calendar/ical/lg0vrqu5jj8autgtnf6nep2cgo%40group.calendar.google.com/public/basic.ics",
    "3A_SRI_TP_G2": "https://calendar.google.com/calendar/ical/gdlsf0bsq0jgg6alasc48epf14%40group.calendar.google.com/public/basic.ics",
    "M2_ISTR": "https://calendar.google.com/calendar/ical/42ddpalnnci9ab5rqj6etioi0c%40group.calendar.google.com/public/basic.ics",
}

FR = ZoneInfo("Europe/Paris")
THIS_YEAR = datetime(2023, 7, 1, tzinfo=timezone.utc)
MY_KEYWORDS = ["Multithreading", "Conception des systemes orientee objet"]


def main():
    for cal, url in cals.items():
        print(cal, url)
        r = httpx.get(url)
        events = icalendar.Calendar.from_ical(r.content)
        for event in events.walk("VEVENT"):
            summary = event["SUMMARY"].to_ical().decode()
            # if any(kw in summary for kw in MY_KEYWORDS) and event["DTSTART"].dt >=
            # THIS_YEAR:
            if "GS" in summary and event["DTSTART"].dt >= THIS_YEAR:
                print(
                    event["DTSTART"].dt.astimezone(FR),
                    event["DTEND"].dt.astimezone(FR),
                    summary,
                )


if __name__ == "__main__":
    main()
