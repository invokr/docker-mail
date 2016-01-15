#!/usr/bin/python
import sys
import os
from mako.template import Template

if (len(sys.argv) != 2):
    print("Usage: config-apply.py <FILENAME>")
    sys.exit()

file = open(sys.argv[1], "r+")
file.write(Template(file.read()).render(env=os.environ))
file.close()
