#!/usr/bin/env python
#
# === List network interface information ===
#
# MIT License
# Copyright (c) 2016 Attila Majoros
#
# Source: https://github.com/majk1/shellrc/blob/master/utils/netinfo.py
#

import plistlib
import subprocess
import sys
import re

CMD = ['system_profiler', '-xml', 'SPNetworkDataType']


def to_s(value, first_item=False, none_value='-', joiner=', '):
    if value is None:
        return none_value
    if isinstance(value, str):
        return value
    if isinstance(value, set):
        if not value:
            return none_value
        elif first_item and value:
            return next(iter(value))
        else:
            return joiner.join(value)
    return str(value)


def format_item(target, name, value, first_item=False, none_value='-', joiner=', '):
    target.append('{title:>14}: {value}'.format(title=name, value=to_s(value, first_item=first_item,
                                                                       none_value=none_value, joiner=joiner)))


def print_usage():
    sys.stderr.write('Usage: netinfo.py [options [-s <search> [-s <search>]]]\n')
    sys.stderr.write('Options:\n')
    sys.stderr.write('  -1, --one, --oneliner     - print only one line information about interface\n')
    sys.stderr.write('  -v, --verbose             - print also the fields with no data\n')
    sys.stderr.write('  -i, --ip, --has-ip-only   - print interfaces with assigned IP only\n')
    sys.stderr.write('  -a, --all-ip              - print all ip addresses while in oneliner mode\n')
    sys.stderr.write('  -s, --search              - filter with parameter\n')
    sys.stderr.write('\n')
    sys.stderr.write('Examples:\n')
    sys.stderr.write('  ./netinfo.py --one -s en -s vpn\n')
    sys.stderr.write('\n')


def log_err_and_exit(ret, message, print_usage_after_message=False):
    sys.stderr.write(message + '\n')
    if print_usage_after_message:
        sys.stderr.write('\n')
        print_usage()
    sys.exit(ret)


class NetworkData:
    PRINT_MODE_VERBOSE = 1
    PRINT_MODE_ONELINER = 2

    def __init__(self):
        self.order = -1
        self.name = None
        self.type = None
        self.interface = None
        self.mac_address = None
        self.v4_addresses = set()
        self.v6_addresses = set()
        self.dns_addresses = set()
        self.dns_domain = None
        self.dns_search = set()
        self.gateway = None
        pass

    def parse(self, item):
        self.order = item['spnetwork_service_order']
        if '_name' in item:
            self.name = item['_name']
        if 'type' in item:
            self.type = item['type']
        if 'interface' in item:
            self.interface = item['interface']
        if 'Ethernet' in item and 'MAC Address' in item['Ethernet']:
            self.mac_address = item['Ethernet']['MAC Address']
        if 'IPv4' in item:
            ipv4 = item['IPv4']
            if 'Addresses' in ipv4:
                self.v4_addresses.update(ipv4['Addresses'])
            if 'DestAddress' in ipv4:
                self.gateway = ipv4['DestAddress']
            elif 'Router' in ipv4:
                self.gateway = ipv4['Router']
        if 'IPv6' in item and 'Addresses' in item['IPv6']:
            self.v6_addresses.update(item['IPv6']['Addresses'])
        if 'DNS' in item:
            dns = item['DNS']
            self.dns_addresses.update(dns['ServerAddresses'])
            if 'DomainName' in dns:
                self.dns_domain = dns['DomainName']
            if 'SearchDomains' in dns:
                self.dns_search.update(dns['SearchDomains'])

    def parse_aliases(self):
        if self.interface:
            p = subprocess.Popen(['ifconfig', self.interface], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            stdout, _ = p.communicate()
            ret = p.wait()
            if ret == 0:
                aliases = re.findall('.*inet ([^ ]+) netmask .*', stdout.decode(), re.MULTILINE)
                if aliases:
                    self.v4_addresses.update(aliases)

    def has_ip(self):
        return self.v4_addresses or self.v6_addresses

    def to_string(self, print_mode=PRINT_MODE_VERBOSE, print_none=False, print_all_ip=False):
        output = []
        if print_mode == NetworkData.PRINT_MODE_VERBOSE:
            pn = print_none
            format_item(output, 'serv order', self.order)
            if pn or self.name:
                format_item(output, 'name', self.name)
            if pn or self.type:
                format_item(output, 'type', self.type)
            if pn or self.interface:
                format_item(output, 'interface', self.interface)
            if pn or self.mac_address:
                format_item(output, 'mac address', self.mac_address)
            if pn or self.v4_addresses:
                format_item(output, 'v4 addresses', self.v4_addresses)
            if pn or self.v6_addresses:
                format_item(output, 'v6 addresses', self.v6_addresses)
            if pn or self.dns_addresses:
                format_item(output, 'dns servers', self.dns_addresses)
            if pn or self.dns_domain:
                format_item(output, 'dns domain', self.dns_domain)
            if pn or self.dns_search:
                format_item(output, 'dns search', self.dns_search)
            if pn or self.gateway:
                format_item(output, 'gateway', self.gateway)
        elif print_mode == NetworkData.PRINT_MODE_ONELINER:
            if not print_all_ip:
                output.append(to_s(self.interface) + ' ' + to_s(self.v4_addresses, first_item=True) + ' (' + to_s(
                    self.name) + ')' + ' ' + to_s(self.type))
            else:
                if not self.v4_addresses:
                    output.append(to_s(self.interface) + ' ' + to_s(self.v4_addresses, first_item=True) + ' (' + to_s(
                        self.name) + ')' + ' ' + to_s(self.type))
                else:
                    for ip in self.v4_addresses:
                        output.append(
                            to_s(self.interface) + ' ' + ip + ' (' + to_s(self.name) + ')' + ' ' + to_s(self.type))
        return '\n'.join(output)


def get_net_config():
    p = subprocess.Popen(CMD, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, _ = p.communicate()
    ret = p.wait()

    if ret != 0:
        log_err_and_exit(ret, 'net config fetch failed')

    try:
        # noinspection PyUnresolvedReferences
        plist = plistlib.readPlistFromString(stdout)
    except AttributeError:
        plist = plistlib.loads(stdout)

    if len(plist) == 0:
        log_err_and_exit(2, 'net config plist is empty')

    if not plist[0]['_items']:
        log_err_and_exit(3, 'network section is empty')

    network_data_types = []
    for item in plist[0]['_items']:
        network_data_type = NetworkData()
        network_data_type.parse(item)
        network_data_type.parse_aliases()
        network_data_types.append(network_data_type)

    return network_data_types


if __name__ == '__main__':
    p_mode = NetworkData.PRINT_MODE_VERBOSE
    p_none = False
    p_all_ip = False
    show_no_ip = True
    search = []

    arg_iter = iter(sys.argv)
    app_name = next(arg_iter)
    for arg in arg_iter:
        if arg == '-1' or arg == '--one' or arg == '--oneliner':
            p_mode = NetworkData.PRINT_MODE_ONELINER
        elif arg == '-v' or arg == '--verbose':
            p_none = True
        elif arg == '-i' or arg == '--ip' or arg == '--has-ip-only':
            show_no_ip = False
        elif arg == '-a' or arg == '--all-ip':
            p_all_ip = True
        elif arg == '-h' or arg == '--help' or arg == '--usage':
            print_usage()
            sys.exit(1)
        elif arg == '-s' or arg == '--search':
            try:
                search.append(next(arg_iter))
            except StopIteration:
                log_err_and_exit(4, 'Argument -s (search) requires a parameter', True)
        else:
            log_err_and_exit(5, 'Unkown flag: ' + arg, True)

    nds = get_net_config()

    i = 0
    for nd in nds:
        if show_no_ip or nd.has_ip():
            verbose_output = nd.to_string(print_none=False, print_mode=NetworkData.PRINT_MODE_VERBOSE).lower()
            match = False
            if not search:
                match = True
            elif all(s.lower() in verbose_output for s in search):
                match = True
            if match:
                if i > 0 and p_mode == NetworkData.PRINT_MODE_VERBOSE:
                    print('--------------------------------------')
                print(nd.to_string(print_none=p_none, print_mode=p_mode, print_all_ip=p_all_ip))
                i = i + 1
