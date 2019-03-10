#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import logging
import os
from urllib.error import HTTPError, URLError
from urllib.request import urlopen, Request

import boto3


client = boto3.client('ssm')


def get_secret(key):
    resp = client.get_parameter(
        Name=key,
        WithDecryption=True
    )
    return resp['Parameter']['Value']


HOOK_URL = os.path.join("https://hooks.slack.com/services", get_secret('/monitoring/alerts/slack_webhook'))

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, _context):
    logger.info("Event: " + str(event))

    for record in event['Records']:
        sns = record['Sns']

        slack_message = {
            'channel': os.environ['slack_channel'],
            'text': "*{}*".format(sns["Subject"]),
            'username': "AWS SNS via Lambda",
            "icon_emoji": ":aws-logo:"
        }

        message = json.loads(sns["Message"])

        severity = 'good'

        body = message

        print(message)

        if 'message' in message:
            #Splunk message
            body = message.get('message')
            severity = 'danger' if message.get('source') == 'high' else 'good' if message.get('source') == 'low' else 'warning'
        if 'AlarmName' in message:

            alarm = message.get('AlarmName', 'OK')

            severity = 'danger' if alarm == 'ALARM' else 'good' if alarm == 'OK' else 'warning'

            body = "*AWSAccount:* " + os.environ['account_name'] + "\n"
            body += "*AlarmName:* " + (message.get('AlarmName', '') or '') + "\n"
            body += "*Description:* " + (message.get('AlarmDescription', '') or '') + "\n"
            body += "*State:* " + (message.get('OldStateValue', '') or '') + " -> " + message['NewStateValue'] + "\n"
            body += "*Reason:* " + (message.get('NewStateReason', '') or '') + "\n"
            body += "*Detected at:* " + (message.get('StateChangeTime', '') or '') + "\n"

        slack_message['attachments'] = [
            {
                "color": severity,
                "text": body
            }
        ]

        req = Request(HOOK_URL, json.dumps(slack_message).encode('utf-8'))

        try:
            response = urlopen(req)
            response.read()
            logger.info("Message posted to %s", slack_message['channel'])
        except HTTPError as e:
            logger.error("Request failed: %d %s", e.code, e.reason)
        except URLError as e:
            logger.error("Server connection failed: %s", e.reason)
