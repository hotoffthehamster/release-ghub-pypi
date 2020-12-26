@@@@@@@@@@@@@@@@@
release-ghub-pypi
@@@@@@@@@@@@@@@@@

.. .. image:: https://travis-ci.com/hotoffthehamster/release-ghub-pypi.svg?branch=release
..   :target: https://travis-ci.com/hotoffthehamster/release-ghub-pypi
..   :alt: Build Status
..
.. .. image:: https://codecov.io/gh/hotoffthehamster/release-ghub-pypi/branch/release/graph/badge.svg
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
  :target: https://github.com/hotoffthehamster/release-ghub-pypi/blob/release/LICENSE
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

GitHub + PyPI Release tool
==========================

Run the
`bin/release-ghub-pypi <bin/release-ghub-pypi>`__
script to manage the release process of a Python package
published to GitHub and to PyPI.org.

- The tool handles both *test* and *production* releases:

  - The tool prepares *test* releases from the 'proving' branch.

    - It uploads the compiled distribution to the developer's GitHub
      releases and to the test.PyPI.org server.

  - The tool prepares *production* releases from the 'release' branch.

    - It uploads the compiled distribution to the organization's GitHub
      releases and to the production PyPI.org server.

- The tool expects to find passwords and/or tokens in the local Password Store
  (``pass``).

When you run the tool, it checks which branch is checked out to decide what
to do — if your 'release' branch is checked out, the tool prepares a production
release. Otherwise, if any other branch is checked out, the tool changes to
the 'proving' branch and prepares a test package.

The release tool behavior is driven by the different release versions
it finds, and a little user interaction.

- The latest commit of the 'proving' or 'release' branch must have a version tag.

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
      package, and runs a basic validation: it prints the package docstring,
      and it compares the package version against the current release version.

- Finally, on success, the tool opens browser windows to both of the project's
  GitHub and PyPI release pages.

Refer to the `bin/release-ghub-pypi source code <bin/release-ghub-pypi>`__
for more details, and to see if this tool might work for your package release!
Or keep reading for a few examples and setup instructions.

Usage examples
==============

Here's a look at how the release tool warns you if you forgot
to update the release notes with the latest release version:

.. raw:: html

    <a href="https://asciinema.org/a/313251?size=medium">
      <img src="https://asciinema.org/a/313251.png" width="737"/>
    </a>

#############
Prerequisites
#############

Install dependencies
====================

.. |github-release| replace:: ``github-release``
.. _github-release: https://github.com/meterup/github-release

This script has a handful of dependencies that should be easy to setup.

- Install these packages typically available from the OS package manager:

  ``curl``, ``git``, ``jq``, ``pass``, ``python3``, and ``python3-pip``.

- Install these packages from the `Python Package Index <https://pypi.org/>`__ using ``pip``:

  ``virtualenv``, and ``virtualenvwrapper``.

- Install the |github-release| tool from GitHub using ``go`` (see below).

- Create a virtual environment and install a few more ``pip`` packages:

  ``pep440-version-compare-cli``, and ``twine``

  (or skip the virtual environment and install systemwide).

- And you'll obviously need Bash, as well as the standard pipeline tools,
  like ``head`` and ``mktemp``, that are included in
  `GNU coreutils <https://www.gnu.org/software/coreutils/>`__.

Install example
===============

Here's how one might install the dependencies
on a Debian/Ubuntu/Linux Mint distribution.

.. code-block:: sh

   # Install distro packages -- you'll probably want to `sudo`.
   $ apt install curl git jq pass python3 python3-pip

   # Install system Python packages.
   $ pip3 install --user --upgrade virtualenv virtualenvwrapper

   # Install the github-release tool local to your user.
   $ go get -u github.com/meterup/github-release

   # Create a virtual environment for the last few pieces.
   $ mkvirtualenv -a $(pwd) --python=/usr/bin/python3.8 release

   # Install a PEP440 version compare tool.
   (release) $ pip3 install pep440-version-compare-cli

   # Install the PyPI publishing tool.
   (release) $ pip3 install twine

Create passwords
================

You'll want to create two to four passwords in your
`Password Store <https://www.passwordstore.org/>`__
(i.e., using ``pass``).

- You'll need at least one password each for GitHub and for PyPI.

  - You'll need two passwords for each if you'd like to separate
    your test account from your production account.

    E.g., you can test making alpha releases with your test account
    and not have to worry about people watching your production
    account seeing these artifacts.

- Choose a GitHub account to use for testing or non-production
  use (the author uses their personal GitHub account for this
  role).

  - From your GitHub account, create an application token,
    and record the token in the first line of a new password
    in your password store.

  - Set the ``GHUB_DEV_PASS`` variable (see below) to the name
    (``pass`` path) of the new password entry.

  - Set the ``GHUB_DEV_USER`` variable to your GitHub user name.

- Similarly for your GitHub production account, create an application
  token, and save it to a new password.

  - Then, set ``GHUB_ORG_PASS`` to the name of that password,
    and set ``GHUB_ORG_USER`` to the corresponding GitHub user.

  - If you'd like to push test releases and production releases
    to the same GitHub account, set ``GHUB_ORG_PASS`` to the
    same value as ``GHUB_DEV_PASS``; and set ``GHUB_ORG_USER``
    to the same username as ``GHUB_DEV_USER``.

- For PyPI credentials, set ``PYPI_TEST_USER`` to your test
  user's name, and ``PYPI_TEST_PASS`` to the ``pass`` entry
  containing that user's password.

  - Similarly, record the production PyPI user's name to
    ``PYPI_PROD_USER``, and set the ``pass`` path using
    ``PYPI_PROD_PASS``.

Shell usage
===========

As mentioned in the previous section, you'll need to set some environment variables.

Take a look at the top of the main source file,
`bin/release-ghub-pypi <bin/release-ghub-pypi>`__,
and copy the ``setup_project_vars`` function to a
new executable file.

- Remove the first three lines (the echo-errors-and-exit)

- Review and update all the environment variables.

- Write a ``main`` function that sources the main source
  file, `bin/release-ghub-pypi <bin/release-ghub-pypi>`__,
  calls the function you just copied, and then calls the
  main entry point, ``release-ghub-pypi``.

Example script
--------------

Here's how a release wrapper might look::

  #!/bin/bash

  setup_static_vars_for () {
    local myproj="$1"
    local mypack="${2:-$1}"

    PROJECT_PATH=/github/landonb/${myproj}

    PROJECT_HISTORY=docs/history-ci.md

    GHUB_DEV_USER=landonb
    GHUB_DEV_REPO=${myproj}
    GHUB_DEV_PASS=github-landonb-GITHUB_TOKEN
    GHUB_DEV_BRANCH='proving'
    GHUB_DEV_REMOTE='proving'
    #
    GHUB_ORG_USER=hotoffthehamster
    GHUB_ORG_REPO=${myproj}
    GHUB_ORG_PASS=github-hotoffthehamster-GITHUB_TOKEN
    GHUB_ORG_BRANCH='release'
    GHUB_ORG_REMOTE='release'

    PYPI_PROJECT=${myproj}
    PYPI_PACKAGE=${mypack}
    #
    PYPI_TEST_USER=hotoffthehamster
    PYPI_TEST_PASS=pypi-hotoffthehamster-PYPI_PASSWORD
    #
    PYPI_PROD_USER=hotoffthehamster
    PYPI_PROD_PASS=pypi-hotoffthehamster-PYPI_PASSWORD

    VENV_WORKON=release
    VENV_PYTHON3=/usr/bin/python3.8
    VENV_WRAPPER="${HOME}/.local/bin/virtualenvwrapper.sh"

    # DEV: These are useful when set from CLI, e.g.,
    #       SKIP_BUILD=true SKIP_TESTS=true ./release
    SKIP_BUILD=${SKIP_BUILD:-false}
    SKIP_TESTS=${SKIP_TESTS:-false}
    SKIP_PROMPTS=${SKIP_PROMPTS:-false}
  }

  main () {
    source /github/landonb/release-ghub-pypi/bin/release-ghub-pypi
    setup_static_vars_for 'my-project' 'my_project'
    release-ghub-pypi
  }

  main

Suppose the wrapper script is named ``release``.
Then, to run the release script, load the virtual
environment and run your wrapper script. E.g.,::

  $ workon release
  (release) $ ./release

Enjoy!

