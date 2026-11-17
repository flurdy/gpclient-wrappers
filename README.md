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

Other projects can call `bin/gp-connect --config <file>` instead of copying it. Settings and
behaviour are in [docs/configuration.md](docs/configuration.md).
