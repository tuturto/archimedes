# -*- coding: utf-8 -*-
#
# Copyright (c) 2016-2017 Tuukka Turto
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

from setuptools import setup

long_description = """Archimedes is very minimal set of macros that make
writing tests with Hy, Hypothesis and Hamcrest more fun. """

install_requires = ['hy>=0.12.1', 'hypothesis>=3.6.1']

setup(
    name='libarchimedes',
    version='0.4.0',
    install_requires=install_requires,
    packages=['archimedes'],
    package_dir={'archimedes': 'src/archimedes'},
    package_data={
        'archimedes': ['*.hy']
    },
    author="Tuukka Turto",
    author_email="tuukka.turto@oktaeder.net",
    long_description=long_description,
    description='Hy macros for Hypothesis (among orther things)',
    license="MIT",
    url="http://github.com/tuturto/archimedes",
    platforms=['any'],
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Lisp",
        "Topic :: Software Development :: Libraries",
    ]
)
