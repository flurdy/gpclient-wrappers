# gpclient-wrappers

Connecting to a GlobalProtect VPN with [yuezk's gpclient](https://github.com/yuezk/GlobalProtect-openconnect)
gets long quickly: portal, gateway, SAML browser, HIP report, and a VPN that grabs all your DNS.
These wrappers keep those settings in environment variables or a small config file, connect in the
background by default, and send only the domains the VPN pushes to its DNS servers.

Needs Linux with `systemd-resolved` and `sudo`, plus gpclient itself and `/etc/vpnc/vpnc-script`
(the `vpnc-scripts` package), which the DNS wrapper calls.

- `bin/gp-connect`: connect; background by default, `--foreground` to see gpclient output.
- `bin/gp-dns-script`: gpclient `--script` wrapper that limits the VPN's DNS to its own domains.
- `bin/gp-firefox`: open the SAML login in a chosen Firefox profile.
- `bin/gp-status`: show whether it is connected, the tunnel address and its DNS routing; exits 1 when not connected (`make status` ignores that).

## Quick start

```sh
GP_PORTAL=vpn.example.com make up     # connect in the background; make run stays in the terminal
make down                             # disconnect
make status                           # connected? tunnel and DNS
```

With a config file instead (see below), `make up` is enough:

```sh
mkdir -p ~/.config/gpclient-wrappers
cp examples/gp.conf.example ~/.config/gpclient-wrappers/config   # edit GP_PORTAL
make up
```

Other projects can keep their own config and call `bin/gp-connect --config <file>`.

## Configuration

Everything is a `GP_*` variable, set in the environment, in a bash config file, or both. The file
is `--config FILE`, `$GP_CONFIG`, or `$XDG_CONFIG_HOME/gpclient-wrappers/config` (default
`~/.config/...`), and is optional. Only
`GP_PORTAL` is required. Variables in the file are exported. `$GP_HOME` is this repo and
`$GP_CONFIG_DIR` the config's directory, so a config can reference paths relative to itself.
Variables already set in the environment override the config, so `GP_BROWSER=manual make up` uses
gpclient's manual browser mode (paste the callback URL into the terminal). `--dry-run` prints the
command instead of running it. The wrapper's own options come first; from the first other argument
on, everything goes straight to `gpclient connect`.

A fuller config, as a file:

```sh
GP_PORTAL=vpn.example.com
GP_GATEWAY=gateway.example.com
GP_BROWSER=$GP_HOME/bin/gp-firefox
GP_FIREFOX_PROFILE=$HOME/.mozilla/firefox/xxxx.profile
GP_HIP=builtin
```

The same, one-off on the command line:

```sh
GP_PORTAL=vpn.example.com GP_GATEWAY=gateway.example.com GP_HIP=builtin bin/gp-connect
```

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

Background mode logs to `/var/log/gpclient.log` (root-readable). `gp-connect` runs as you and starts
`gpclient` with `sudo -E`; gpclient then runs `bin/gp-dns-script` as root. The config is sourced as
bash by `gp-connect`, and a HIP executable runs as your user. Only use a config, scripts and HIP
executable you trust, and read any you did not write.

## References

- [yuezk/GlobalProtect-openconnect](https://github.com/yuezk/GlobalProtect-openconnect): gpclient
- [bechampion/gohip](https://github.com/bechampion/gohip): HIP report generator
- [OpenConnect HIP](https://www.infradead.org/openconnect/hip.html): what a HIP report is
- [vpnc-script](https://www.infradead.org/openconnect/vpnc-script.html): the script `gp-dns-script` wraps
- [resolvectl](https://www.freedesktop.org/software/systemd/man/latest/resolvectl.html): routing domains and default route

## License

MIT, see [LICENSE](LICENSE).
