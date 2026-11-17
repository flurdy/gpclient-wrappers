# Configuration

`gp-connect` sources a bash config (`--config FILE`, `$GP_CONFIG`, or
`~/.config/gpclient-wrappers/config`). Variables are exported. `$GP_HOME` is this repo and
`$GP_CONFIG_DIR` the config's directory, so a config can reference paths relative to itself.

| Variable | Default | Meaning |
|---|---|---|
| `GP_PORTAL` | required | portal hostname |
| `GP_GATEWAY` | prompt | gateway to use (`--gateway`) |
| `GP_BROWSER` | `default` | browser command for the SAML login |
| `GP_FIREFOX_PROFILE` | none | profile directory for `bin/gp-firefox` |
| `GP_HIP` | none | `builtin`, or a path to a HIP report executable (run as `$USER`) |
| `GP_DNS_ONLY_LISTED` | `1` | `1` uses `bin/gp-dns-script`; `0` keeps gpclient's default DNS |
| `GP_FOREGROUND` | unset | non-empty is the same as `--foreground` |

Variables already set in the environment override the config, so `GP_BROWSER=manual bin/gp-connect`
uses gpclient's manual browser mode (paste the callback URL into the terminal). Extra arguments
after the options go straight to `gpclient connect`. `--dry-run` prints the command instead of
running it.

The background mode logs to `/var/log/gpclient.log` (root-readable). `gp-connect` and
`gp-dns-script` run through `sudo`/root: read any HIP executable you configure first.
