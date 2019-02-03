#!/usr/bin/env python
import argparse
import subprocess
import re
parser = argparse.ArgumentParser()
parser.add_argument('--list', action='store_true')
parser.add_argument('--host')
args=vars(parser.parse_args())

if args['list']:
    with open('./inventory.json', 'r') as inventory:
        print inventory.read()
if args['host']:
    ips=subprocess.Popen('cd ../terraform/stage; terraform output', shell=True,stdout=subprocess.PIPE).stdout.read()
    hosts={
        "appserver":'{'+'"ansible_host":"'+re.search('app_external_ip.+ ([\.0-9]+)', ips).group(1)+'"}',
        "dbserver":'{'+'"ansible_host":"'+re.search('db_external_ip.+ ([\.0-9]+)', ips).group(1)+'"}'
        
    }
    print hosts[args['host']]   




