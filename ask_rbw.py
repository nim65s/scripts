#!/usr/bin/env python
"""
Ask ssh passphrase to rbw.

to use this:
export SSH_ASKPASS_REQUIRE=prefer
export SSH_ASKPASS=~/scripts/ask_rbw.py
"""

import sys
from subprocess import check_output

print(sys.argv, file=sys.stderr)
print(check_output(["rbw", "get", "--folder", "ssh", "laas"], text=True))
