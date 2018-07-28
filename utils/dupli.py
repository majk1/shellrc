#!/usr/bin/env python

import sys
import os
import hashlib


BUF_SIZE = 65536


class DuplFile:
    def __init__(self, root, name):
        self.path = os.path.join(root, name)
        self.name = name
        self.size = os.stat(self.path).st_size
        self.hash = ''
    
    def calculateHash(self):
        sha1 = hashlib.sha1()
        with open(self.path, 'rb') as f:
            while True:
                data = f.read(BUF_SIZE)
                if not data:
                    break
                sha1.update(data)
        self.hash = sha1.hexdigest()


class Duplicates:
    def __init__(self):
        self.files = []

    def addFile(self, duplFile):
        self.files.append(duplFile)

    def size(self):
        return len(self.files)

    def _byChecksum(self, duplFiles):
        checksumMap = {}
        for f in duplFiles:
            f.calculateHash()
            if f.hash in checksumMap:
                hashEqDuplFiles = checksumMap[f.hash]
            else:
                hashEqDuplFiles = []
            hashEqDuplFiles.append(f)
            checksumMap[f.hash] = hashEqDuplFiles
        return checksumMap

    def _bySize(self):
        sizeMap = {}
        for f in self.files:
            if f.size in sizeMap:
                sizeFiles = sizeMap[f.size]
            else:
                sizeFiles = []
            sizeFiles.append(f)
            sizeMap[f.size] = sizeFiles
        return sizeMap

    def findDuplicates(self):
        sizeMap = self._bySize()
        dupls = []
        for _, files in sizeMap.items():
            if (len(files) > 1):
                checkedDups = []
                hashMap = self._byChecksum(files)
                for _, chkFiles in hashMap.items():
                    if (len(chkFiles) > 1):
                        checkedDups.extend(chkFiles)
                if len(checkedDups) > 1:
                    dupls.append(checkedDups)
        return dupls


def sizeof_fmt(num, suffix='B'):
    for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
        if abs(num) < 1024.0:
            return "%3.1f%s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f%s%s" % (num, 'Yi', suffix)

def findDuplicates(root_path):
    duplicates = Duplicates()
    for root, _, filenames in os.walk(root_path):
        for filename in filenames:
            if (filename != '.DS_Store'):
                duplicates.addFile(DuplFile(root, filename))
    dups = duplicates.findDuplicates()
    
    print('Listing duplicates:')

    saveSize = 0
    for dup in dups:
        print(f'\nDuplicate files with sha1:{dup[0].hash} and size {dup[0].size}')
        saveSize += dup[0].size * (len(dup) - 1)
        for dFile in dup:
            print(f' - {dFile.path}')

    print(f'\nFound {len(dups)}, storage waste is {sizeof_fmt(saveSize)}')


if __name__ == '__main__':
    root_path = '.'
    if (len(sys.argv) > 1):
        root_path = sys.argv[1]
    findDuplicates(root_path)
