#!/usr/local/bin/python
import sys
import re
import os
import plistlib
import json
import pprint as p

if len(sys.argv) != 2:
    print "Usage: %s filename" % sys.argv[0]
    sys.exit(0)

basename = os.path.splitext(sys.argv[1])[0]

with open(basename + ".json", 'w') as f:
    p = plistlib.readPlist(sys.argv[1])
    # print p.keys()

    f.write(json.dumps(p, ensure_ascii=False, indent=2).encode('utf-8'))
