@@@@@@@@@@@@@@@@@
release-ghub-pypi
@@@@@@@@@@@@@@@@@

.. FEAT-REQU/2020-01-25: (lb): Add kcov Bash coverage of the release script.

.. .. image:: https://travis-ci.org/hotoffthehamster/release-ghub-pypi.svg?branch=develop
..   :target: https://travis-ci.org/hotoffthehamster/release-ghub-pypi
..   :alt: Build Status
..
.. .. image:: https://codecov.io/gh/hotoffthehamster/release-ghub-pypi/branch/develop/graph/badge.svg
..   :target: https://codecov.io/gh/hotoffthehamster/release-ghub-pypi
..   :alt: Coverage Status
..
.. .. image:: https://readthedocs.org/projects/release-ghub-pypi/badge/?version=latest
..   :target: https://release-ghub-pypi.readthedocs.io/en/latest/
..   :alt: Documentation Status
..
.. .. image:: https://img.shields.io/github/release/hotoffthehamster/release-ghub-pypi.svg?style=flat
..   :target: https://github.com/hotoffthehamster/release-ghub-pypi/releases
..   :alt: GitHub Release Status

.. image:: https://img.shields.io/github/license/hotoffthehamster/release-ghub-pypi.svg?style=flat
  :target: https://github.com/hotoffthehamster/release-ghub-pypi/blob/develop/LICENSE
  :alt: License Status

One dev's tool to codify their release process.

########
Overview
########

.. *(We'll see if I spend time to document this tool. Here's a brief taste.)*

I run the
`bin/release-ghub-pypi <bin/release-ghub-pypi>`__
script to manage my Python software versioning,
and to release Python packages both to GitHub,
and to PyPI.

The other files are essentially Python project boilerplate
(that I can diff against each of the Python projects I maintain
to keep their project metadata up to date and using the latest
techniques).

GitHub + PyPI Release tool
==========================

Run the
`bin/release-ghub-pypi <bin/release-ghub-pypi>`__
script to manage the release process of a Python package
published to GitHub and to PyPI.org.

- The tool handles both *test* and *production* releases:

  - The tool prepares *test* releases from the 'develop' branch.

    - It uploads the compiled distribution to the developer's GitHub
      releases and to the test.PyPI.org server.

  - The tool prepares *production* releases from the 'master' branch.

    - It uploads the compiled distribution to the organization's GitHub
      releases and to the production PyPI.org server.

- The tool expects to find passwords and/or tokens in the local Password Store
  (``pass``).

When you run the tool, it checks which branch is checked out to decide what
to do — if your 'master' branch is checked out, the tool prepares a production
release. Otherwise, if any other branch is checked out, the tool changes to
the 'develop' branch and prepares a test package.

The release tool behavior is driven by the different release versions
it finds, and a little user interaction.

- The latest commit of the 'develop' or 'master' branch must have a version tag.

  - The current release version is determined from the version tag on the latest git commit.

  - The working tree and index must be clean.

- The release versions on GitHub and PyPI.org should make sense.

   - If the current release version is behind either GitHub or PyPI,
     the tool complains and dies.

   - If the current release version is ahead of GitHub/PyPI, the
     tool asks if you want to upload your new release to GitHub/PyPI.

   - If the current release version is the same as on GitHub/PyPI,
     the tool asks if you want to remove the GitHub/PyPI release.

- For the GitHub release:

  - If the current release version matches the latest GitHub release,
    the tool asks if you want to delete it (or to skip the operation).

  - Otherwise, if the current release version is newer than on GitHub,
    the tool asks if you'd like to push the branch and version tag,
    and to upload the release package.

- For the PyPI release:

  - If the current release version is newer than on PyPI,
    the tool offers to upload the package.

  - Otherwise, if the current release version matches the latest PyPI release,
    the tool offers to open a browser window to PyPI.org's delete page.

    - Note that removing a PyPI release is a one-time operation.
      That is, once uploaded, a PyPI version may not be uploaded again.
      (It may be deleted, just not replaced.)

    - If you skip the delete prompt, the tool will continue and run
      the smoke test.

  - After uploading to PyPI -- or if you re-run the tool using a previously
    uploaded release version (via SCM tag) but decline to remove the PyPI
    release -- the tool will run a simple smoke test against the release.

    - The smoke test creates a new Python virtual environment, installs the
      package, and runs a basic sanity check: it prints the package docstring,
      and it compares the package version against the current release version.

- Finally, on success, the tool opens browser windows to both of the project's
  GitHub and PyPI release pages.

Refer to the `bin/release-ghub-pypi source code <bin/release-ghub-pypi>`__
for more details, and to see if this tool might work for your package release!

#############
Prerequisites
#############

Here's how one might configure Debian/Ubuntu/Linux Mint and a ``virtualenv``
to run the release script.

.. code-block:: sh

   $ apt install curl git jq pass python3 python3-pip  # probably as sudo

   $ pip3 install --user --upgrade virtualenv virtualenvwrapper

   $ PATH=$HOME/.local/bin \
     GOPATH=$HOME/.gopath \
     go get -u github.com/aktau/github-release

   $ mkvirtualenv -a $(pwd) --python=/usr/bin/python3.7 release

   (release) $ pip install pep440-version-compare-cli

   (release) $ pip install twine

.. |home-fries| replace:: ``home-fries``
.. _home-fries: https://github.com/landonb/home-fries

.. |fries-lib| replace:: ``.fries/lib``
.. _fries-lib: https://github.com/landonb/home-fries/tree/master/.fries/lib

.. MAYBE/2020-01-26: (lb): Public these three scripts independently,
..                         and show how to install using `bpkg` et al.

Caveat: This package also requires Bash headers from |home-fries|_.

- It expects to load the three files,
  ``color_funcs.sh``, ``git_util.sh``, and ``logger.sh``,
  that you copy from |fries-lib|_,
  from your user's ``$PATH``.

