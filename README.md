# docker-node-minimal

Ultra small docker images producer with node support. Optionally add ffmpeg and youtube-dl.

| Name | Compressed/transfer size | Disk Size |
|------|--------------------------:|----------:|
| node | 23MB | 45 MB |
| ffmpeg | 37MB | 68 MB |
| youtube | 50MB | 108 MB |

## Disclaimer

This is made for personal use with raspberry pi. It may produce broken images on other processor architectures, as it
removes some stuff from `/usr/local/include/node/openssl/archs`. Tweak it for use with x86/x64 architecture.

## Requirements

You need docker-squash installed as these images are removing stuff from official node alpine images so to get real
disk size savings you need to squash images. `docker-squash` seems to be better choice than built-in squashing.

See: ~~https://github.com/jwilder/docker-squash~~
https://github.com/goldmann/docker-squash

> I am sorry for keeping invalid link here for so long.

Version 2.x will be itself dockerized.

## Usage

All builds are run through `make` file, containing bash script.

```bash
MODULE=node SQUASH=true NODE_VERSION=10.0.0 VERSION=1.0.0 ./make
```

It requires all these environmental variables set.

- `MODULE` is one of three values: `node`, `ffmpeg`, `youtube`.
    - `node` uses `node-alpine` image and just strips all not-needed-to-run-node-app files
    - `ffmpeg` uses image built with `MODULE=node` and adds pre-build ffmpeg to that (currently uses mirrored `ffmpeg`
       as official was terribly slow to download)
    - `youtube` uses image built with `MODULE=ffmpeg` and adds `youtube-dl` (and `python` required by `youtube-dl`)

- `SQUASH` if set to any value - built image will be squashed. Use only for `node` to save disk space if multiple
images with add-ons based on `node` images will be used.

- `NODE_VERSION` is a version of source `node` image on which script will be basing to create images. It is required
only for base `node`, but currently `make` script will stop anyway if it's not provided for other modules too

- `VERSION` is a version tag which new image should be tagged with.

Currently all images uses `dzek69/noderasp` prefix as image name. It is hardcoded.

## How to use these images

These images are published on public Docker Hub as `dzek69/noderasp`

https://hub.docker.com/r/dzek69/noderasp/tags/

Example of how use this images, you may want to tweak things a little to match your needs.

```Dockerfile
# Use official full-features node as builder (to install node_modules, cleanup sources from unneeded stuff using
# external tools etc)
FROM node:11.1.0-alpine AS builder

# Copy app source as set workdir
COPY ./app /home/node/app
WORKDIR /home/node/app

# Install dependencies
RUN yarn --production
# Remove files from workdir (leaving subdirectories, this is used to clean all config files like .eslintrc, .gitignore,
# package.json, other things not needed to run the app (all of my apps are always in `src` directory)
RUN rm * || true

# Switch to mini image
FROM dzek69/noderasp:11.1.0.0-node

# Copy ready to use file from previously built temporary image
COPY --from=builder /home/node/app /home/node/app
# Set proper owner to files
RUN chown -R node:node /home/node
# Set workdir (you app may expect that)
WORKDIR /home/node/app

# Switch user to prevent running app as root
USER node

# Command to start the app
CMD ["node", "/home/node/app/src"]
```

## License

MIT