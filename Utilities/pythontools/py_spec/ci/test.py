#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: Caoxiang Zhu (czhu@ppp.gov)
For any help, type ./compare_spec.py -h
"""
import numpy as np
from py_spec import SPEC
import argparse

# parse command line arguments
parser = argparse.ArgumentParser(description="Compare two SPEC HDF5 outputs")
parser.add_argument("filename", type=str, help="file name to be compared")
parser.add_argument("reference", type=str, help="reference data")
parser.add_argument("-t", "--tol", type=float, default=1E-12, help="difference tolerance")

args = parser.parse_args()
print('Compare SPEC outputs in {:s} and {:s} with tolerance {:12.5E}'.format(
        args.filename, args.reference, args.tol))
data_A = SPEC(args.filename)
data_B = SPEC(args.reference)
tol = args.tol
match = True


def compare(data, reference, localtol):
    global match
    for key, value in vars(data).items():
        if isinstance(value, SPEC):  # recurse data (csmiet: I'm nt the biggest fan of this recursion...)
            print('------------------')
            print('Elements in '+key)
            compare(value, reference.__dict__[key], localtol)
        else:
            if key in ['filename', 'version']:  # not compare filename and version
                continue
            elif key == 'iterations':  # skip iteration data (might be revised)
                continue
            elif key == 't':  # skip poincare.t Not the best, but only t so far (so good)
                continue
            else:
                # print(key)
                diff = np.linalg.norm(np.abs(np.array(value) - np.array(reference.__dict__[key]))) \
                        / np.size(np.array(value)) # divide by number of elements
                unmatch = diff > localtol
                if unmatch:
                    match = False
                    print('UNMATCHED: '+key, ', diff={:12.5E}'.format(diff))
                else:
                    print('ok: ',key, 'element average difference = {}'.format(diff))
    return


compare(data_A, data_B, tol)
print('===================')
if match:
    print('All the terms are within tolerance.')
else:
    print('Differences in some elements are larger than the tolerence.')
    raise SystemExit('Differences in some elements are larger than the tolerence.')


exit
