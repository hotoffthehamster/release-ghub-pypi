#!/bin/sh
# vim:tw=0:ts=2:sw=2:et:norl:ft=sh
# Project: https://github.com/landonb/sh-ask-yesnoskip#😷
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Set SKIP_PROMPTS=true to auto-respond 's'kip.

# Set SKIP_PROMPT_NL=true to suppress the blank echo line.

ask_yesnoskip () {
  local the_ask="$1"
  local default_choice="${2:-N}"
  if [ "${default_choice}" = "Y" ]; then
    lng_opts='Yes/no/skip'
    sht_opts='Y/n/s'
  elif [ "${default_choice}" = "N" ]; then
    lng_opts='yes/No/skip'
    sht_opts='y/N/s'
  elif [ "${default_choice}" = "S" ]; then
    lng_opts='yes/no/Skip'
    sht_opts='y/n/S'
  else
    >&2 echo "ASSERT: Unrecognized default_choice: ${default_choice}"
    return 1
  fi

  ${SKIP_PROMPT_NL:-false} || >&2 echo
  >&2 /usr/bin/env echo -n "Please ${lng_opts}: ${the_ask}? [${sht_opts}] "

  local the_choice
  ${SKIP_PROMPTS:-false} && the_choice='s' || read -e the_choice
  [ -z "${the_choice}" ] && the_choice="${default_choice}"
  the_choice="${the_choice,,}"  # lower.

  # We could consider just the first character:
  #   the_choice=${the_choice:0:1}
  # or just demand a one-character response.
  if [ "${the_choice}" != "y" ] && [ "${the_choice}" != "s" ]; then
    return 1
  fi
  echo "${the_choice}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

