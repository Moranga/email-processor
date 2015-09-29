#!/usr/bin/env python
# -*- coding: utf-8 -*-

import string


def _print(msg):
    print("{} ==> {}".format(datetime.datetime.utcnow(),msg),flush=True)


def filename_from_string(text):
    """Produces a valid (space-free) filename from some text"""
    text = text.lower()
    valid_chars = "-_." + string.ascii_letters + string.digits
    return ''.join(c for c in text if c in valid_chars)
