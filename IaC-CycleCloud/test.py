import os
import argparse
import string

parser = argparse.ArgumentParser()
parser.add_argument('--pval', type=int, help='int')
args = parser.parse_args()


f = open("/tmp/pyhello.txt", 'w+')
print("Hello python", file=f)
print(args.pval, file=f)
