#!/usr/bin/python
import sys
import os
from mako.template import Template

if (len(sys.argv) != 2):
    print("Usage: config-apply.py <FILENAME>")
    sys.exit()

tpl = ""
with open(sys.argv[1]) as file:
    tpl = file.read()

with open(sys.argv[1], "w") as file:
    file.write(Template(tpl).render(env=os.environ))
