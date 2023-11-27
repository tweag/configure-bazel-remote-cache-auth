#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -o nounset -o pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -o errexit
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

configure_bazel_remote_auth_sh_location=configure_bazel_remote_header/tools/configure_bazel_remote_auth.sh
configure_bazel_remote_auth_sh="$(rlocation "${configure_bazel_remote_auth_sh_location}")" || \
  (echo >&2 "Failed to locate ${configure_bazel_remote_auth_sh_location}" && exit 1)

# MARK - Setup

bazelrc_path="my-workspace/.bazelrc"

setup_test() {
  local dir
  dir="$(dirname "${bazelrc_path}")"
  rm -rf "${dir}"
  mkdir -p "${dir}"
}

# MARK - Test

output="$( "${configure_bazel_remote_auth_sh}" --remote-header foo )"
assert_equal "--remote_header=foo" "${output}" "specify remote header"

output="$( "${configure_bazel_remote_auth_sh}" --buildbuddy-api-key bb-api-key )"
assert_equal "--remote_header=x-buildbuddy-api-key=bb-api-key" "${output}" \
  "specify BuildBuddy API key"

output="$( "${configure_bazel_remote_auth_sh}" )"
assert_equal "--noremote_upload_local_results" "${output}" \
  "no remote header, no BuildBuddy API key"

# Be sure to append output to the bazelrc file
setup_test
cat >"${bazelrc_path}" <<-EOF
# Pre-existing content
EOF
output="$( "${configure_bazel_remote_auth_sh}" --remote-header bar "${bazelrc_path}" )"
expected="$(cat <<-EOF
# Pre-existing content
--remote_header=bar
EOF
)"
assert_equal "" "${output}" "no output when path is specified"
actual="$( <"${bazelrc_path}" )"
assert_equal "${expected}" "${actual}" \
  "flag values should be appended to bazelrc file"

# Use REMOTE_HEADER env var
setup_test
REMOTE_HEADER="foo" BAZELRC_PATH="${bazelrc_path}" \
  "${configure_bazel_remote_auth_sh}"
actual="$( <"${bazelrc_path}" )"
assert_equal "--remote_header=foo" "${actual}" "use REMOTE_HEADER env var"

# Use BUILDBUDDY_API_KEY env var
setup_test
BUILDBUDDY_API_KEY="bb-api-key" BAZELRC_PATH="${bazelrc_path}" \
  "${configure_bazel_remote_auth_sh}"
actual="$( <"${bazelrc_path}" )"
assert_equal "--remote_header=x-buildbuddy-api-key=bb-api-key" "${actual}" \
  "use REMOTE_HEADER env var"
