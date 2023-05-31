#!/usr/local/bin/python3
import sys
import re
import os
import plistlib

# Using plutil: JSON --> PLIST
# plutil -convert xml1 ./cal.json -o out.plist

if len(sys.argv) != 3:
    print("Usage: %s filename.plist filename.out" % sys.argv[0])
    sys.exit(0)


with open(sys.argv[1], 'rb') as file_in, open(sys.argv[2], 'wb') as file_out:
    pl = plistlib.load(file_in)
    plistlib.dump(pl, file_out, sort_keys=True)
