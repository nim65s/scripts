#!/usr/bin/env python
'''update gandi DNS domain entry, with LiveDNS v5
Cf. https://doc.livedns.gandi.net/#work-with-domains
'''

import argparse
import ipaddress
import json
import os
from subprocess import check_output

import requests

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('-v', '--verbose', action='store_true')
parser.add_argument('domain')
parser.add_argument('name')
parser.add_argument('--ip', help="defaults to ifconfig.me's return")
parser.add_argument('--api_key', help="defaults to GANDI_API_KEY env var, or the return of 'pass api/gandi'")

args = parser.parse_args()

if args.ip is None:
    args.ip = requests.get('http://ifconfig.me', headers={'User-Agent': 'curl/7.61.1'}).content.decode().strip()

ip = ipaddress.ip_address(args.ip)

if args.api_key is None:
    args.api_key = os.environ.get('GANDI_API_KEY', check_output(['pass', 'api/gandi'], text=True).strip())

key = {'X-Api-Key': args.api_key}

r = requests.get(f'https://dns.api.gandi.net/api/v5/domains/{args.domain}/records/{args.name}', headers=key)
r.raise_for_status()

if r.json()[0]['rrset_values'][0] == args.ip:
    if args.verbose:
        print('ok')
else:
    type_ = 'AAAA' if isinstance(ip, ipaddress.IPv6Address) else 'A'
    url = f'https://dns.api.gandi.net/api/v5/domains/{args.domain}/records/{args.name}/{type_}'
    data = {'rrset_values': [args.ip]}
    headers = {'Content-Type': 'application/json', **key}
    r = requests.put(url, data=json.dumps(data), headers=headers)
    if args.verbose:
        print(r.json())
    else:
        r.raise_for_status()
