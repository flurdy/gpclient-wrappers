# gpclient-wrappers

Small bash wrappers for connecting a Linux machine to a GlobalProtect VPN with
[yuezk's gpclient](https://github.com/yuezk/GlobalProtect-openconnect).

- Keep the portal, gateway, SAML browser and HIP report settings in a config file or the
  environment, instead of on a long command line.
- Connect, reconnect, disconnect and check status with `make` targets; connecting runs in the
  background by default.
- Split DNS: only the domains the VPN pushes resolve through its DNS servers; everything else keeps
  your normal DNS.

## Requirements

- Linux with `systemd-resolved` (the DNS wrapper uses `resolvectl`) and `sudo`.
- gpclient, from yuezk's GlobalProtect-openconnect.
- `/etc/vpnc/vpnc-script`, from the `vpnc-scripts` package; `gp-dns-script` wraps it.
- A browser for the SAML login. gpclient's `default` opens your usual one, `GP_BROWSER` picks
  another, and `manual` prints the URL to open yourself. `gp-firefox` adds Firefox profile choice.

Tested on Fedora 44 with gpclient 3.4.0 and Firefox. Other distributions using `systemd-resolved`
and other browsers should work but are untested.

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

## Scripts

| Script | Make target | What it does |
|---|---|---|
| `bin/gp-connect` | `up`, `run`, `reconnect` | Connect, in the background unless `--foreground`. If already connected it says so and does nothing; `--reconnect` disconnects first. |
| `bin/gp-status` | `status` | Show whether it is connected, the tunnel address and DNS routing. Exits 1 when not connected (`make status` ignores that). |
| `bin/gp-dns-script` | — | gpclient `--script` wrapper that limits the VPN's DNS to its own domains. |
| `bin/gp-firefox` | — | Open the SAML login in a chosen Firefox profile. |

`make down` runs `sudo gpclient disconnect` directly.

## Configuration

Everything is a `GP_*` variable (see the table below); only `GP_PORTAL` is required. Set them in a
config file, the environment, or both.

The config file is optional.

Its variables are exported. It can use `$GP_HOME` (this repo) and `$GP_CONFIG_DIR` (its own
directory) to refer to paths relative to itself.

The environment overrides the config, which suits one-off changes:

```sh
GP_BROWSER=manual make up                     # paste the callback URL into the terminal
GP_GATEWAY=other.example.com make reconnect   # switch gateway
```

`gp-connect` options come first; from the first other argument on, everything goes to
`gpclient connect`:

- `--config FILE`: use this config file.
- `--foreground`: stay in the terminal and show gpclient output.
- `--reconnect`: disconnect first.
- `--dry-run`: print the command instead of running it.

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
