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

    def calculate_hash(self):
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

    def add_file(self, dupl_file):
        self.files.append(dupl_file)

    def size(self):
        return len(self.files)

    def _by_checksum(self, dupl_files):
        checksum_map = {}
        for f in dupl_files:
            f.calculate_hash()
            if f.hash in checksum_map:
                hash_eq_dupl_files = checksum_map[f.hash]
            else:
                hash_eq_dupl_files = []
            hash_eq_dupl_files.append(f)
            checksum_map[f.hash] = hash_eq_dupl_files
        return checksum_map

    def _by_size(self):
        size_map = {}
        for f in self.files:
            if f.size in size_map:
                size_files = size_map[f.size]
            else:
                size_files = []
            size_files.append(f)
            size_map[f.size] = size_files
        return size_map

    def find_duplicates(self):
        size_map = self._by_size()
        dupls = []
        for _, files in size_map.items():
            if len(files) > 1:
                checked_dups = []
                hash_map = self._by_checksum(files)
                for _, chkFiles in hash_map.items():
                    if len(chkFiles) > 1:
                        checked_dups.extend(chkFiles)
                if len(checked_dups) > 1:
                    dupls.append(checked_dups)
        return dupls


def sizeof_fmt(num, suffix='B'):
    for unit in ['', 'Ki', 'Mi', 'Gi', 'Ti', 'Pi', 'Ei', 'Zi']:
        if abs(num) < 1024.0:
            return "%3.1f%s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f%s%s" % (num, 'Yi', suffix)


def find_and_list_duplicates(root):
    duplicates = Duplicates()
    for root, _, filenames in os.walk(root):
        for filename in filenames:
            if filename != '.DS_Store':
                duplicates.add_file(DuplFile(root, filename))
    dups = duplicates.find_duplicates()

    print('Listing duplicates:')

    save_size = 0
    for dup in dups:
        print(f'\nDuplicate files with sha1:{dup[0].hash} and size {dup[0].size}')
        save_size += dup[0].size * (len(dup) - 1)
        for d_file in dup:
            print(f' - {d_file.path}')

    print(f'\nFound {len(dups)}, storage waste is {sizeof_fmt(save_size)}')


if __name__ == '__main__':

    root_path = '.'
    if len(sys.argv) > 1:
        root_path = sys.argv[1]

    find_and_list_duplicates(root_path)
