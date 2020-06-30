# Prosody (XMPP) on x86_64 and ARM (Raspberry Pi) 

### Supported tags and respective `Dockerfile` links
-	[`latest` (*Dockerfile*)](https://github.com/Tob1asDocker/prosody/blob/master/alpine.x86_64.Dockerfile)
-	[`arm-latest` (*Dockerfile*)](https://github.com/Tob1asDocker/prosody/blob/master/alpine.armhf.Dockerfile)

### What is Prosody?

Prosody is a modern XMPP communication server. It aims to be easy to set up and configure, and efficient with system resources. Additionally, for developers it aims to be easy to extend and give a flexible system on which to rapidly develop added functionality, or prototype new protocols.

> [wikipedia.org/wiki/Prosody_(software)](https://en.wikipedia.org/wiki/Prosody_(software))

![logo](https://avatars1.githubusercontent.com/u/4312871?s=64&v=4)

### About these images:
* based on official Images: [hub.docker.com/_/alpine](https://hub.docker.com/_/alpine) / [github.com/alpinelinux/docker-alpine](https://github.com/alpinelinux/docker-alpine)

### How to use these images:
* configure [`prosody.cfg.lua`](https://github.com/Tob1asDocker/prosody/blob/master/entrypoint.d/prosody.cfg.lua)
*  ``` $ docker run --name prosody -v $(pwd)/prosody/prosody.cfg.lua:/etc/prosody/prosody.cfg.lua -v $(pwd)/prosody/conf.d:/etc/prosody/conf.d -v $(pwd)/prosody/modules-custom:/usr/lib/prosody/modules-custom -p 5222:5222 -p 5269:5269 -d tobi312/prosody:latest```

* Environment Variables:  
  * `TZ` (set timezone, example: "Europe/Berlin")
  * `SELECT_COMMUNITY_MODULES` (select community modules, string with names separate with spaces)
  * `ENABLE_CONFD` (set 1 to enable, only when using default config)
  * `ENABLE_MODULE_PATHS` (set 1 to enable, only when using default config)

* Ports (https://prosody.im/doc/ports):
  * `5000` - proxy
  * `5222` - c2s
  * `5269` - s2s
  * `5280` - http
  * `5281` - https
  * `5347` - components


* In `/entrypoint.d` you can store your own shell scripts, these are executed when the container is started. You can also store configuration files (`*.cfg.lua`) there, these are automatically copied to the right place (`prosody.cfg.lua`->`/etc/prosody/` and `*.cfg.lua`->`/etc/prosody/conf.d` - last you must include conf.d in prosody.cfg.lua). The Volumes `/etc/prosody/prosody.cfg.lua` and `/etc/prosody/conf.d` are then no needed.

#### Docker-Compose

```yaml
version: "2.4"
services:
  prosody:
    image: tobi312/prosody:latest
    #image: tobi312/prosody:arm-latest
    container_name: prosody
    restart: unless-stopped
    ports:
      - 5000:5000
      - 5222:5222
      - 5269:5269
      - 5280:5280
      - 5281:5281
      - 5347:5347
    volumes:
      ## prosody config:
      - ./prosody/prosody.cfg.lua:/etc/prosody/prosody.cfg.lua
      - ./prosody/conf.d:/etc/prosody/conf.d
      ## optional own modules:
      - ./prosody/modules-custom:/usr/lib/prosody/modules-custom
      ## optional: mount folder with own entrypoint-file(s) or *.cfg.lua files:
      #- ./prosody/entrypoint.d:/entrypoint.d:ro
      ## optional: own ssl-cert and -key:
      #- ./prosody/ssl/mySSL.crt:/etc/ssl/certs/ssl.crt:ro
      #- ./prosody/ssl/mySSL.key:/etc/ssl/certs/ssl.key:ro
    environment:
      TZ: "Europe/Berlin"
      SELECT_COMMUNITY_MODULES: "mod_cloud_notify mod_csi mod_http_upload mod_lastlog mod_mam_muc mod_smacks"
      ENABLE_CONFD: 0
      ENABLE_MODULE_PATHS: 0
```

### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/prosody/)
* [GitHub](https://github.com/Tob1asDocker/prosody)