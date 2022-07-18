#!/usr/bin/env python3

r"""

 This script can be used to fix the "exec format error" seen with tools like gzip in
 WSL with Ubuntu 22.04 in Q1/Q2 2022

 A hacky fix for broken executables in WSL/Ubuntu 22.0
 see https://github.com/microsoft/WSL/issues/8219

 Be careful as this could really break things!
 The author takes no responsibility for the action of this script

 All credit to https://github.com/wangqr for the basis
 Author: the-moog - June 16th 2022
"""


import argparse
from pathlib import Path
import os
import sys

try:
    from elftools.elf.elffile import ELFFile
except ImportError:
    print("Package missing, use")
    print("pip install pyelftools as root")

if os.geteuid() != 0:
    print("  NOTE: You will probably need to run this using sudo or as root, trying anyway\n")

this_module = sys.modules[__name__]

def get_backup_path(file_path, backup_path=None):
    bk_file = Path(str(file_path) + ".bak")
    if backup_path is not None:
        backup_path = Path(backup_path)
        if backup_path.name == "":
            bk_file = Path(backup_path) / bk_file.name
        else:
            bk_file = backup_path
    return bk_file

def fix(file, backup_path=None, overwrite=False):
    target_p_align = 0x1000
    in_file = Path(file)
    bk_file = get_backup_path(file, backup_path)
    out_file = in_file
    in_stat = in_file.lstat()

    assert in_file.exists(), f"{in_file} does not exist"
    assert os.access(in_file, os.X_OK), f"{in_file} is not executable, check what you are doing"
    assert os.access(in_file, os.W_OK), f"You don't have rights to modify {in_file}"
    assert os.access(bk_file.parent, os.W_OK), f"I can't create backup in {bk_file.parent}"

    print(f"Backing up {in_file} to {bk_file}")

    if bk_file.exists():
        if not overwrite:
            raise IOError(f"Backup {bk_file} exists, use -o to force overwrite")
        else:
            os.unlink(bk_file)

    in_file.rename(bk_file)

    if not bk_file.exists:
        raise IOError(f"Unexpected error creating backup {bk_file}")

    print(f"Fixing {in_file}....")

    updated = False
    error = None
    try:
        with bk_file.open('rb') as fp:
            bdata = bytearray(fp.read())
            elf = ELFFile(fp)
            header_size = elf.structs.Elf_Phdr.sizeof()
            for i in range(elf.num_segments()):
                header = elf.get_segment(i).header

                if header.p_type == 'PT_LOAD' and header.p_align != target_p_align:
                    print(f"Changing alignment of program header {i} from {header.p_align} to {target_p_align}")
                    header.p_align = target_p_align
                    header_offset = elf._segment_offset(i)
                    bdata[header_offset:header_offset+header_size] = elf.structs.Elf_Phdr.build(header)
                    updated = True
    except Exception as er:
        # Capture all errors so we can first
        # try to complete the task or restore the backup
        error = er
    finally:
        if updated and error is None:
            try:
                with out_file.open('wb') as fp:
                    fp.write(bdata)
                    out_file.chmod(in_stat.st_mode)
            except Exception as er:
                error = er

    if not updated or error is not None:
        print("No action, or error, restoring backup")
        out_file.unlink()
        bk_file.rename(in_file)
        if error is not None:
            raise error


def undo(file, backup_path=None):
    in_file = Path(file)
    bk_file = get_backup_path(file, backup_path)

    assert bk_file.exists(), f"{in_file} does not appear to have a backup as {bk_file}"

    if not in_file.exists():
        print(f"File {in_file} is missing, trying to restore from {bk_file} anyway")
    else:
        assert os.access(in_file, os.W_OK), "You can't restore the backing as you can't alter the destination"

    print(f"Restoring {in_file} from {bk_file}")
    if in_file.exists():
        in_file.unlink()
    bk_file.rename(in_file)

parser = argparse.ArgumentParser(description=this_module.__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)

parser.add_argument('file', type=Path, help="Path to file to fix", metavar='<file_path>')
parser.add_argument("-u", help="Undo if possible", dest="undo", action="store_true")
parser.add_argument("-b", type=Path, help="Alternate backup path", dest="backup_path", metavar="<backup_path>", default=None)
parser.add_argument("-o", help="Overwrite existing backup", dest="overwrite", action="store_true")

args = parser.parse_args()

if not args.undo:
    try:
        fix(args.file, backup_path=args.backup_path, overwrite=args.overwrite)
    except AssertionError as er:
        print(er)
    except IOError as er:
        print(f"ERROR: {er}")
    else:
        print("Success\n")
else:
    undo(args.file, backup_path=args.backup_path)
