#!/usr/bin/env python
# -*- coding: utf-8 -*-

import string
import datetime
import boto3


def _print(msg):
    print("{} ==> {}".format(datetime.datetime.utcnow(), msg), flush=True)


def filename_from_string(text):
    """Produces a valid (space-free) filename from some text"""
    text = text.lower()
    valid_chars = "-_." + string.ascii_letters + string.digits
    return ''.join(c for c in text if c in valid_chars)


def send_metric():
    """Add metric to cloudwatch"""
    client = boto3.client('cloudwatch')
    client.put_metric_data(Namespace='EmailProcessor', MetricData=[
                           {'MetricName': 'processed',
                            'Value': 1,
                            'Unit': 'Count'}])
