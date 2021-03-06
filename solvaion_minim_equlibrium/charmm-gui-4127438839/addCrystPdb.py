"""
Generated by CHARMM-GUI (http://www.charmm-gui.org)

addCrystPdb.py

This program is to add CRYST1 information into PDB file.

Correspondance: jul316@lehigh.edu or wonpil@lehigh.edu
Last update: October 5, 2020
"""

from __future__ import print_function
import argparse 

def addCryst(pdbfile, boxinfo):
    inp_pdb = open(pdbfile, 'r').readlines()
    out_pdb = open(pdbfile, 'w')
    wrtcryst = False
    for line in inp_pdb:
        if line.startswith('ATOM') and not wrtcryst:
            out_pdb.write("CRYST1%9.3f%9.3f%9.3f%7.2f%7.2f%7.2f P 1           1\n" % boxinfo)
            out_pdb.write(line)
            wrtcryst = True
        elif line.startswith('CRYST1') and not wrtcryst:
            out_pdb.write("CRYST1%9.3f%9.3f%9.3f%7.2f%7.2f%7.2f P 1           1\n" % boxinfo)
            wrtcryst = True
        elif line.startswith('CRYST1') and wrtcryst:
            continue
        else:
            out_pdb.write(line)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-i',     dest='pdbfile', required=True, help='Input PDB File')
    parser.add_argument('-cryst', dest='boxinfo', required=True, help='Crystal Information', nargs=6)
    args = parser.parse_args()

    addCryst(args.pdbfile, tuple(map(float, args.boxinfo)))

