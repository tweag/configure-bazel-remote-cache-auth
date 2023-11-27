# Configure Bazel Remote Cache Authentication (Remote Header)

[![Build](https://github.com/tweag/configure-bazel-remote-cache-auth/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/tweag/configure-bazel-remote-cache-auth/actions/workflows/ci.yml)

Updates a bazelrc file with flags that authenticate Bazel remote cache queries or disables remote
cache uploads if a value is not found.

- If `remote_header` is provided, it is used as the value for Bazel's
  [`--remote_header` flag](https://bazel.build/reference/command-line-reference#flag--remote_header).
- If `remote_header` is not provided and `buildbuddy_api_key` is provided, a remote header value is 
  constructed using the API key value (e.g. `x-buildbuddy-api-key=${buildbuddy_api_key}`).
- If a value is not found for `remote_header` or `buildbuddy_api_key`, the `--remote_header` flag is
  not written and the
  [`--noremote_upload_local_results` flag](https://bazel.build/reference/command-line-reference#flag--remote_upload_local_results)
  is written instead.


## Usage

```yaml
name: Run Bazel Tests

on:
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4

      # Either specify the BuildBudddy API key or for more control of the remote header, you can
      # specify the entire remote header value.

      # Option #1: Specify the BuildBuddy API key.
      - name: Configure Bazel remote cache authentication
        uses: tweag/configure-bazel-remote-cache-auth@hash  # <== Replace hash with the latest release hash
        with:
          buildbuddy_api_key: ${{ secrets.BUILDBUDDY_API_KEY }}

      # Option #2: Speciy the remote header value.

      - name: Configure Bazel remote cache authentication
        uses: tweag/configure-bazel-remote-cache-auth@hash  # <== Replace hash with the latest release hash
        with:
          remote_header: "some-custom-value"

      - name: Build and Test
        shell: bash
        run: |
          bazelisk test //...
```

### Inputs

`buildbuddy_api_key`: Optional. The BuildBuddy API key value. If a value is not set for `remote_header`, this
value will be used to generate a remote header value.

`remote_header`: Optional. The value to be use for the remote header flag.

`bazelrc_path`: The path to the bazelrc file to update. (default: `.bazelrc`)

###
