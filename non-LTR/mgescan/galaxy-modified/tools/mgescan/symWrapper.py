"""symWrapper.

Usage:
    symWrapper.py <output> <inputs>...

"""
from docopt import docopt
import os
import tempfile
import tarfile
import shutil

def main():
    arguments = docopt(__doc__, version="symWrapper 0.1")

    out_file = arguments['<output>']

    tmpfile = tempfile.mkstemp(dir="./")
    tmpfilename = tmpfile[1]
    tar = tarfile.open(tmpfilename, "w")

    tmpdir = tempfile.mkdtemp(dir="./")
    for input in arguments['<inputs>']:
        filename = os.path.basename(input)
        new_filepath = tmpdir + filename
        os.symlink(input, new_filepath)
        tar.add(new_filepath, arcname=filename)

    tar.close()
    shutil.move(tmpfilename, out_file)
    shutil.rmtree(tmpdir)

if __name__ == "__main__":
    main()

