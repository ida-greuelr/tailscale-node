# Tailscale node docker image

This simple ubuntu based image will start an ephemeral tailscale-node. It is derived from tailscales own best practices for ephemeral nodes, but is also able to auto-generate a valid ssl cert for you ts.net name.
There are some env vars to configure your connection, only the auth key is mandatory:

- `TS_AUTHKEY` = tskey-auth-XYZ    _mandatory_
- `TS_HOSTNAME` = "$HOST"          _container id is default value_
- `TS_ACCEPT_ROUTES` = true
- `TS_ACCEPT_DNS` = true
- `TS_CERT` = false                _tailscale will try to  [fetch a SSL cert](https://tailscale.com/kb/1153/enabling-https/?q=https#provision-tls-certificates-for-your-devices)_
- `TS_EXTRA_ARGS` = ""
- `TSD_EXTRA_ARGS` = ""

To run your ephemeral node simply exececute:

```bash
docker build --rm  -t tailscale-node:latest . 
docker run --rm -it -e TS_AUTHKEY="tskey-auth-XYZ-XYZ" -e TS_HOSTNAME=ephem-docker tailscale-node:latest
```

## Use tailscale-node as a base image

If you want to use this image as a base image, write your Dockerfile like this:

```Dockerfile
FROM tailscale-node:latest

COPY your stuff here

RUN some things here

CMD ["/my-cool-app/start.sh"]

```

*ONLY OVERWRITE THE* **ENTRYPOINT** *IF YOU KNOW WHAT YOU'RE DOING*

Otherwise tailscale(d) will not be started correctly.

## TS_CERT

If you enable the TS_CERT flag, tailscale will try to fetch a valid SSL cert for you _ts.net_ domain. Therefor you will have to enable [DNS](https://tailscale.com/kb/1081/magicdns/?q=Magic#enabling-magicdns) and [HTTPS](https://tailscale.com/kb/1153/enabling-https/?q=https#configure-https) support for your tailscale net.

If everything went well, your cert and key can be found at `/etc/ssl/private/tailscale.{crt|key}`
