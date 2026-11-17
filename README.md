# gpclient-wrappers

Small wrappers around [yuezk's gpclient](https://github.com/yuezk/GlobalProtect-openconnect) for
GlobalProtect VPNs on Linux.

- `bin/gp-connect`: connect from a config file; background by default, `--foreground` to debug.
- `bin/gp-dns-script`: only the domains the VPN pushes use its DNS servers (`systemd-resolved`).
- `bin/gp-firefox`: open the SAML login in a chosen Firefox profile.

```sh
mkdir -p ~/.config/gpclient-wrappers
cp examples/gp.conf.example ~/.config/gpclient-wrappers/config   # edit GP_PORTAL
make up        # make run to stay in the terminal, make down to disconnect
```

Other projects can call `bin/gp-connect --config <file>` instead of copying it.

## Configuration

`gp-connect` sources a bash config (`--config FILE`, `$GP_CONFIG`, or
`~/.config/gpclient-wrappers/config`). Variables are exported. `$GP_HOME` is this repo and
`$GP_CONFIG_DIR` the config's directory, so a config can reference paths relative to itself.
Variables already set in the environment override the config, so `GP_BROWSER=manual make up` uses
gpclient's manual browser mode (paste the callback URL into the terminal). `--dry-run` prints the
command instead of running it; other arguments go straight to `gpclient connect`.

| Variable | Default | Meaning |
|---|---|---|
| `GP_PORTAL` | required | portal hostname |
| `GP_GATEWAY` | prompt | gateway to use (`--gateway`) |
| `GP_BROWSER` | `default` | browser command for the SAML login |
| `GP_FIREFOX_PROFILE` | none | profile directory for `bin/gp-firefox` |
| `GP_HIP` | none | `builtin`, or a path to a HIP report executable (run as `$USER`) |
| `GP_DNS_ONLY_LISTED` | `1` | `1` uses `bin/gp-dns-script`; `0` keeps gpclient's default DNS |
| `GP_FOREGROUND` | unset | non-empty is the same as `--foreground` |

## HIP reports

Some gateways reject a client without a host information profile. If gpclient's built-in report
(`GP_HIP=builtin`) is not accepted, [bechampion/gohip](https://github.com/bechampion/gohip) is a
separate Go tool that generates one; build it and point `GP_HIP` at the binary. Its report is
partly canned (for example the firewall entry), so check your employer's policy first.

## Notes

Background mode logs to `/var/log/gpclient.log` (root-readable). `gp-connect` and `gp-dns-script`
run through `sudo`/root: read any HIP executable you configure first.
