#!/usr/bin/python
from os import listdir
from os.path import isfile, join
import re
path = "PowerAPIApp/API"
onlyFiles = [f for f in listdir(path) if isfile(join(path, f))]
bigFile = ""
imports = [""]
def parseImport(string):
    matches = re.match("(?:import\s*)(.*)(?:\s*)",string)
    if matches is not None:
        return matches.group(0)
    else:
        return None

for file in onlyFiles:
    with open(path+"/"+file,'r') as f:
        for line in f:
            parsed = ""
            if "import" in line:
                parsed = parseImport(line)
                if parsed is not None:
                    if parsed not in imports:  #if we have not yet seen this import$
                        imports.append(parsed)
                        #print line
                        bigFile+=line
                else:
                    bigFile+=line
            else:
                bigFile+=line
with open("PowerAPI_DISTRIBUTION.swift",'w') as out:
    out.write(bigFile)
            
