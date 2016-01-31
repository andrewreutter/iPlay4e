#!/usr/bin/python
# -*- coding: utf-8 -*-

import creole

config = dict(
    name='creole',
    version=creole.__version__,
    url='http://oink.sheep.art.pl/WikiCreole%20parser%20in%20python',
    download_url='http://oink.sheep.art.pl/+download/creole-1.0.tar.gz',
    license='GNU General Public License (GPL), BSD',
    author='Radomir Dopieralski, Thomas Waldmann',
    author_email='creole@sheep.art.pl',
    description='Parser for WikiCreole text markup.',
    long_description=creole.__doc__,
    keywords='wiki wikicreole creole markup text',
    py_modules=['creole'],
    data_files=[
        ('share/doc/creole.py/examples', ['creole2html.py']),
        ('share/doc/creole.py/tests', ['test.py']),
        ('share/doc/creole.py/', ['COPYING']),
    ],
    scripts=['creole2html.py'],
    platforms='any',
    classifiers=[
        'Topic :: Text Processing :: Markup',
        'License :: OSI Approved :: GNU General Public License (GPL)',
        'Intended Audience :: Developers',
        'Topic :: Communications',
        'Topic :: Internet :: WWW/HTTP :: Dynamic Content',
        'Programming Language :: Python',
        'Operating System :: OS Independent',
        'License :: OSI Approved :: BSD License',
    ],
)

from distutils.core import setup
setup(**config)

