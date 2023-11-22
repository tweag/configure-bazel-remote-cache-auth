#!/usr/bin/env bash

# NOTE: This script has been implemented so that it can be executed without Bazel. Do not pull in
# external dependencies.

set -o errexit -o nounset -o pipefail

# MARK - Functions

fail() {
  echo >&2 "$@"
  exit 1
}

output_file=""

write() {
  if [[ -n "${output_file:-}" ]]; then
    echo "$@" >> "${output_file}"
  else
    echo "$@"
  fi
}

# MARK - Args


while (("$#")); do
  case "${1}" in
    "--remote-header")
      remote_header="${2}"
      shift 2
      ;;
    "--buildbuddy-api-key")
      buildbuddy_api_key="${2}"
      shift 2
      ;;
    *)
      if [[ -z "${output_file:-}" ]]; then
        output_file="${1}"
        shift 1
      else
        fail "Unexpected argument:" "${1}"
      fi
      ;;
  esac
done

# MARK - Output Settings

if [[ -z "${remote_header:-}" ]] && [[ -n "${buildbuddy_api_key:-}" ]]; then
  remote_header="x-buildbuddy-api-key=${buildbuddy_api_key}"
fi

if [[ -n "${remote_header:-}" ]]; then
  write "--remote_header=${remote_header}"
else
  write "--noremote_upload_local_results"
fi
