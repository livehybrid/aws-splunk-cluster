#! /usr/bin/python

import os
import sys
import hashlib
import subprocess
import datetime
import boto3
import json
import re

OPENSSL_CONFIG_TEMPLATE = """
prompt = no
distinguished_name = req_distinguished_name
req_extensions = v3_req
[ req_distinguished_name ]
C                      = ${ssl_country}
ST                     = ${ssl_state}
L                      = ${ssl_city}
O                      = ${ssl_org}
OU                     = ${ssl_orgunit}
CN                     = %(domain)s
emailAddress           = ${ssl_email}
[ v3_req ]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = %(domain)s
DNS.2 = *.%(domain)s
"""

MYDIR = os.path.abspath(os.path.dirname(__file__))
OPENSSL = '/usr/bin/openssl'
KEY_SIZE = 1024
DAYS = 365
CA_CERT = 'ca.crt'
CA_KEY = 'ca.key'

s3_conn = boto3.client('s3')

dynamodb = boto3.resource('dynamodb')
cert_table = dynamodb.Table("certificates")

crt_response = s3_conn.get_object(Bucket=os.environ['bucket'], Key='ca/{}.crt'.format(os.environ['ca_name']))
with open('/tmp/ca.crt', 'w') as cert_file:
    cert_file.write(crt_response['Body'].read().decode('utf-8'))

key_response = s3_conn.get_object(Bucket=os.environ['bucket'], Key='ca/{}.key'.format(os.environ['ca_name']))
with open('/tmp/ca.key', 'w') as key_file:
    key_file.write(key_response['Body'].read().decode('utf-8'))

secrets_conn = boto3.client('secretsmanager')
ca_password_secret_id = "/pki/ca-password"
ca_password = secrets_conn.get_secret_value(
    SecretId=ca_password_secret_id
)

# Extra X509 args. Consider using e.g. ('-passin', 'pass:blah') if your
# CA password is 'blah'. For more information, see:
#
# http://www.openssl.org/docs/apps/openssl.html#PASS_PHRASE_ARGUMENTS
X509_EXTRA_ARGS = ()


def openssl(*args):
    cmdline = [OPENSSL] + list(args)
    return subprocess.check_output(cmdline)


def handler(event, context):
    rootdir = MYDIR
    keysize = KEY_SIZE
    days = DAYS
    ca_cert = '/tmp/' + CA_CERT
    ca_key = '/tmp/' + CA_KEY
    if 'domain' in event:
        domain = event['domain']
    else:
        domain = 'csr_job'

    output_directory = '/tmp/domains'

    def dfile(ext):
        return os.path.join(output_directory, '%s.%s' % (domain, ext))

    os.chdir(rootdir)

    if not os.path.exists(output_directory):
        os.mkdir(output_directory)



    if 'csr' in event:
        #Originall write it to csr_job
        csr_file = open(dfile('request'), 'w')
        csr_file.write(event['csr'])
        csr_file.close()

        cert_subject = openssl('req',
                               '-in', dfile('request'),
                               '-noout',
                               '-subject')
        regex = r".*\/CN=([\w\-\.]+)"
        domain = re.findall(regex, str(cert_subject))[0]

        print("Using submitted CSR for domain={}".format(domain))

        #Now write it to correctly named file
        csr_file = open(dfile('request'), 'w')
        csr_file.write(event['csr'])
        csr_file.close()


        cert_serial = '0x%s' % hashlib.md5(domain.encode('utf-8') + str(datetime.datetime.now()).encode('utf-8')).hexdigest()

        openssl('x509', '-req', '-days', str(days), '-in', dfile('request'),
                '-CA', ca_cert, '-CAkey', ca_key,
                '-passin', 'pass:{}'.format(ca_password["SecretString"]),
                '-set_serial',
                cert_serial,
                '-out', dfile('crt'),
                '-extensions', 'v3_req',
                *X509_EXTRA_ARGS)

    else:
        if not os.path.exists(dfile('key')):
            openssl('genrsa', '-out', dfile('key'), str(keysize))

        config = open(dfile('config'), 'w')
        config.write(OPENSSL_CONFIG_TEMPLATE % {'domain': domain})
        config.close()

        cert_serial = '0x%s' % hashlib.md5(domain.encode('utf-8') + str(datetime.datetime.now()).encode('utf-8')).hexdigest()

        openssl('req', '-new', '-key', dfile('key'), '-out', dfile('request'),
                '-config', dfile('config'))

        openssl('x509', '-req', '-days', str(days), '-in', dfile('request'),
                '-CA', ca_cert, '-CAkey', ca_key,
                '-passin', 'pass:{}'.format(ca_password["SecretString"]),
                '-set_serial',
                cert_serial,
                '-out', dfile('crt'),
                '-extensions', 'v3_req', '-extfile', dfile('config'),
                *X509_EXTRA_ARGS)

        print("Done. The private key is at %s, the cert is at %s, and the " \
              "CA cert is at %s." % (dfile('key'), dfile('crt'), ca_cert))

        with open(dfile('key'), 'r') as key_file:
            output_key = key_file.read()

    with open(dfile('crt'), 'r') as crt_file:
        output_crt = crt_file.read()
        s3_conn.put_object(
            Bucket=os.environ['bucket'],
            Key=dfile('crt'),
            Body=output_crt,
            ServerSideEncryption='aws:kms',
            SSEKMSKeyId=os.environ['kms']
        )

    now = datetime.datetime.now()
    cert_created_date = now.strftime("%Y-%m-%d %H:%M")
    cert_expiry_date  = (now + datetime.timedelta(days=days)).strftime("%Y-%m-%d %H:%M")

    cert_table.put_item(Item={
        'serial': cert_serial,
        'common_name': domain,
        'enabled': 1,
        'expiry': cert_expiry_date,
        'created': cert_created_date
    })
    if 'csr' in event:
        return json.dumps({"crt": output_crt})
    else:
        return json.dumps({"crt": output_crt, "key": output_key})
