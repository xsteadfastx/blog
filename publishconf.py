#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

# This file is only used if you use `make publish` or
# explicitly specify it as your config file.

import os
import sys
sys.path.append(os.curdir)
from pelicanconf import *

SITEURL = 'http://xsteadfastx.org'
RELATIVE_URLS = False

DELETE_OUTPUT_DIRECTORY = True

FEED_DOMAIN = SITEURL

# Following items are often useful when publishing

# PIWIK
PIWIK_URL = 'piwik.luftmentsh.org'
PIWIK_SITE_ID = 5

# TWITTER
TWITTER_CARDS = True

# DISQUS
DISQUS_SITENAME = "xsteadfastx"

#ISSO_URL = 'http://comments.xsteadfastx.org'
