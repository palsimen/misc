#!/usr/bin/python

# Script to copy all dependencies (shared objects)
# for the binaries in a directory. 
# The rules about which dependencies to copy
# are set using the constants in this file.

import argparse
import subprocess
import logging
import sys
import re
import shutil
import fnmatch

NAME = "CopyDependencies.py"

# Function returns true if string is found in
# search_list using startswith function.
def compare(string, search_list):
    found = False

    for item in search_list:
        if string.startswith(item):
            log.debug("Found match between " + string + " and " + item)
            found = True
            break

    return found

parser = argparse.ArgumentParser(description="Copy dependencies based on 'ldd'")
parser.add_argument("--src",          dest="source",               required=True,                         help="path to binaries")
parser.add_argument("--dst",          dest="destination",          required=True,                         help="path to copy dependencies")
parser.add_argument("--srcexclfiles", dest="source_exclude_files", required=False, nargs="+", default="", help="list of files in source directory to be excluded from 'ldd' command")
parser.add_argument("--libinclfiles", dest="lib_include_files",    required=False, nargs="+", default="", help="list of files to be included although not listed in libinclpaths")
parser.add_argument("--libinclpaths", dest="lib_include_paths",    required=False, nargs="+", default="", help="list of paths to be included")
parser.add_argument("--libexclfiles", dest="lib_exclude_files",    required=False, nargs="+", default="", help="list of lib files to be excluded")
parser.add_argument("--dbg",          dest="debug",                required=False,                        help="turn on debug mode", action="store_true")

args = parser.parse_args()

# Setup logging
log = logging.getLogger(NAME)
if args.debug:
    logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
    log.info("Running in debug mode")
else:
    logging.basicConfig(stream=sys.stdout, level=logging.INFO)

source = args.source
destination = args.destination
source_exclude_files = args.source_exclude_files
lib_include_files = args.lib_include_files
lib_include_paths = args.lib_include_paths
lib_exclude_files = args.lib_exclude_files

log.debug("Source: " + source)
log.debug("Destination: " + destination)
log.debug("Source exclude files: " + ", ".join(source_exclude_files))
log.debug("Lib include files: " + ", ".join(lib_include_files))
log.debug("Lib include paths: " + ", ".join(lib_include_paths))
log.debug("Lib exclude files: " + ", ".join(lib_exclude_files))

# Dictionary to hold all dependencies to be copied
# Key   = libname
# Value = path to lib
dependencies = {}

# Get all binaries in source dir
output = subprocess.check_output(["ls", source])
binaries = output.split("\n")
# Remove last entry, just a newline
binaries = binaries[0:-1]

for binary in binaries:
    # Check that it is not excluded
    if not compare(binary, source_exclude_files):
        log.debug("Binary:" + binary)
        output = subprocess.check_output("ldd " + source + "/" + binary, shell=True)
        liblines = output.split("\n")
        # Remove last entry, just a newline
        liblines = liblines[0:-1]
        for line in liblines:
            # Trim whitespaces on left hand side
            line = line.lstrip()
            log.debug("Dependency: " + line)
            # Split in libname and libpath
            # E.g. libXinerama.so.1 => /lib64/libXinerama.so.1 (0x00007fb3f4b79000
            # \S = all characters except whitespace
            match = re.match(r"([\S]+) => ([\S]+)", line)
            if match:
                libname = match.group(1)
                libpath = match.group(2)

                if not compare(libname, lib_exclude_files):
                    log.debug(libname + " is not in " + " ".join(lib_exclude_files))
                    if compare(libname, lib_include_files):
                        log.debug("Adding " + libname + ": " + libpath)
                        dependencies[libname] = libpath
                    else:
                        if compare(libpath, lib_include_paths):
                            log.debug("Adding " + libname + ": " + libpath)
                            dependencies[libname] = libpath
            else:
                log.warning("Regex returned false for line: " + line)

# Copy the files in dependencies to destination
for libname, libpath in dependencies.iteritems():
    log.info("Copying " + libname + " from " + libpath + " to " + destination)
    shutil.copy2(libpath, destination)
