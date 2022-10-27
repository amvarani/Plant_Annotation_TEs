import subprocess

def check_installed_programs():
    programs = ["matcher", "transeq", "hmmsearch", "hmmconvert", "trf"]

    try:
        subprocess.call(programs)
    except OSError as e:
        if e.errno == os.errno.ENOENT:
            pass
            # handle file not found error.
        else:
            # Something else went wrong while trying to
            # run `wget`
           raise
