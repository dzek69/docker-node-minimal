# docker-node-minimal

Ultra small docker images producer with node support. Optionally add ffmpeg and youtube-dl.

| Name | Compressed/transfer size | Disk Size |
|------|--------------------------:|----------:|
| node | 23MB | 45 MB |
| ffmpeg | 37MB | 68 MB |
| youtube | 50MB | 108 MB |

## Disclaimer

This is made for personal use with linux x64.
Version 1.x was intended for ARM/Raspberry Pi.

It may produce broken images on other processor architectures than x64, as it removes some stuff from
`/usr/local/include/node/openssl/archs`. Tweak it for use with other architectures.

## Requirements

### When building directly:

- docker
- docker-squash: https://github.com/goldmann/docker-squash
- python, pip - required by docker-squash

### When building within docker

- docker

## Usage

### When building directly:

All builds are run through `make` file, containing bash script.

```bash
MODULE=node SQUASH=true NODE_VERSION=10.0.0 VERSION=1.0.0 ./make
# Will produce dzek69/nodemin:1.0.0-node image based on node:10.0.0-alpine

MODULE=ffmpeg NODE_VERSION=10.0.0 VERSION=1.0.0 ./make
# Will produce dzek69/nodemin:1.0.0-ffmpeg image based on dzek69/nodemin:1.0.0-node

MODULE=youtube NODE_VERSION=10.0.0 VERSION=1.0.0 ./make
# Will produce dzek69/nodemin:1.0.0-youtube image based on dzek69/nodemin:1.0.0-ffmpeg
```

### When building within docker:

First you can build the builder:
```bash
docker build . -t builder
```

Then you can build the images:

```bash
docker run -e NODE_VERSION=11.10.0 -e SQUASH=true -e VERSION=11.10.0 -e MODULE=node -v /var/run/docker.sock:/var/run/docker.sock -it builder ./make
# Will produce dzek69/nodemin:11.10.0-node image based on node:11.10.0-alpine

docker run -e NODE_VERSION=11.10.0 -e VERSION=11.10.0 -e MODULE=ffmpeg -v /var/run/docker.sock:/var/run/docker.sock -it builder ./make
# Will produce dzek69/nodemin:11.10.0-ffmpeg image based on dzek69/nodemin:11.10.0-node

docker run -e NODE_VERSION=11.10.0 -e VERSION=11.10.0 -e MODULE=youtube -v /var/run/docker.sock:/var/run/docker.sock -it builder ./make
# Will produce dzek69/nodemin:11.10.0-youtube image based on dzek69/nodemin:11.10.0-ffmpeg
```

## Environmental variables explained:

- `MODULE` is one of three values: `node`, `ffmpeg`, `youtube`.
    - `node` uses `node-alpine` image and just strips all not-needed-to-run-node-app files
    - `ffmpeg` uses image built with `MODULE=node` and adds pre-build ffmpeg to that (currently uses mirrored `ffmpeg`
       as official is terribly slow to download, at least from my location)
    - `youtube` uses image built with `MODULE=ffmpeg` and adds `youtube-dl` (and `python` required by `youtube-dl`)

- `SQUASH` if set to any value - built image will be squashed. Use only for `node` to save disk space if multiple
images with add-ons based on `node` images will be used.

- `NODE_VERSION` is a version of source `node` image on which script will be basing to create images. It is required
only for base `node`, but currently `make` script will stop anyway if it's not provided for other modules too

- `VERSION` is a version tag which new image should be tagged with.

Currently all images uses `dzek69/nodemin` prefix as image name. It is hardcoded. Some other stuff shouldn't be
hardcoded as well.

## How to use these images

These images are published on public Docker Hub as `dzek69/nodemin`

https://hub.docker.com/r/dzek69/nodemin/tags/

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
FROM dzek69/nodemin:11.1.0.0-node

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