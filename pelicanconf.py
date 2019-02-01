# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from datetime import datetime

AUTHOR = "marvin"
SITENAME = "xsteadfastx"
SITEURL = ""
TIMEZONE = "Europe/Berlin"

# can be useful in development, but set to False when you're ready to publish
RELATIVE_URLS = True

FLATTR_USER = "xsteadfastx"
PDF_GENERATOR = False
REVERSE_CATEGORY_ORDER = True
LOCALE = "C"
DEFAULT_PAGINATION = False
DEFAULT_DATE = (2012, 3, 2, 14, 1, 1)

FEED_DOMAIN = SITEURL
FEED_MAX_ITEMS = 100
# FEED_ALL_ATOM = 'feeds/all.atom.xml'
FEED_ATOM = "feed/index.html"
# CATEGORY_FEED_ATOM = 'feeds/%s.atom.xml'
RSS_FEED_SUMMARY_ONLY = False

# global metadata to all the contents
# DEFAULT_METADATA = (('yeah', 'it is'),)

# path-specific metadata
EXTRA_PATH_METADATA = {
    # 'extra/robots.txt': {'path': 'robots.txt'},
    # 'extra/CNAME': {'path': 'CNAME'},
    "extra/.htaccess": {"path": ".htaccess"},
    "extra/.well-known/acme-challenge/.keep": {
        "path": ".well-known/acme-challenge/.keep"
    },
}

# static paths will be copied without parsing their contents
STATIC_PATHS = [
    "images",
    # 'extra/robots.txt',
    # 'extra/CNAME',
    "extra/.htaccess",
    "extra/.well-known/acme-challenge/.keep",
    # 'code',
    # 'notebooks'
]

# custom page generated with a jinja2 template
# TEMPLATE_PAGES = {'pages/jinja2_template.html': 'jinja2_template.html'}

# code blocks with line numbers
PYGMENTS_RST_OPTIONS = {"linenos": "table"}

# foobar will not be used, because it's not in caps. All configuration keys
# have to be in caps
# foobar = "barbaz"

THEME = "themes/marat"
OUTPUT_PATH = "output"
PATH = "content"

ARTICLE_URL = "{date:%Y}/{date:%m}/{date:%d}/{slug}/"
ARTICLE_SAVE_AS = "{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html"

# plugins
PLUGIN_PATHS = ["pelican-plugins", "pelican-plugins-3rd"]
PLUGINS = [
    "liquid_tags.youtube",
    "liquid_tags.vimeo",
    "liquid_tags.flickr",
    "liquid_tags.soundcloud",
    "liquid_tags.giphy",
    "liquid_tags.audio",
    "liquid_tags.gram",
    "tipue_search",
    "ipynb.liquid",
]

CACHE_CONTENT = True
LOAD_CONTENT_CACHE = True

# tags
TAG_URL = "tag/{slug}.html"
TAG_SAVE_AS = "tag/{slug}.html"

# api keys
FLICKR_API_KEY = "2207902126a225122e46533e82b6a947"
GIPHY_API_KEY = "dc6zaTOxFJmzC"

DEFAULT_PAGINATION = 5
COPYRIGHT_YEAR = datetime.utcnow().strftime("%Y")
CC_LICENSE = {
    "name": "Creative Commons Attribution-ShareAlike",
    "version": "4.0",
    "slug": "by-sa",
}

MAIN_MENU = False
SOCIAL = (
    ("twitter", "https://twitter.com/xsteadfastx"),
    ("mastodon", "https://chaos.social/@xsteadfastx"),
    ("github", "https://github.com/xsteadfastx"),
    ("flickr", "https://www.flickr.com/photos/marvinxsteadfast/"),
    ("rss", "{}/{}".format(FEED_DOMAIN, FEED_ATOM)),
)
LINKS = (("Archive", SITEURL + "/archives.html"),)
