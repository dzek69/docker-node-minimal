# docker-node-minimal

Ultra small docker images producer with node support. Optionally add ffmpeg and youtube-dl.

## Disclaimer

This is made for personal use with raspberry pi. It may produce broken images on other processor architectures, as it
removes some stuff from `/usr/local/include/node/openssl/archs`.

## Requirements

You need docker-squash installed as these images are removing stuff from official node alpine images so to get real
disk size savings you need to squash images. `docker-squash` seems to be better choice than built-in squashing.

See: https://github.com/jwilder/docker-squash

## Usage

All builds are run through `make` file, containing bash script.

```bash
MODULE=node SQUASH=true NODE_VERSION=10.0.0 VERSION=1.0.0 ./make
```

It requires all these environmental variables set.

- `MODULE` is one of three values: `node`, `ffmpeg`, `youtube`.
    - `node` uses `node-alpine` image and just strips all not-needed-to-run-node-app files
    - `ffmpeg` uses image built with `MODULE=node` and adds pre-build ffmpeg to that (currently uses mirrored ffmpeg
       as official was terribly slow to download)
    - `youtube` uses image built with `MODULE=ffmpeg` and adds 

- `SQUASH` if set to any value - built image will be squashed. Use only for `node` to save disk space if multiple
images with add-ons based on `node` images will be used.

- `NODE_VERSION` is a version of source `node` image on which script will be basing to create images. It is required
only for base `node`, but currently `make` script will stop anyway if it's not provided for other modules too

- `VERSION` is a version tag which new image should be tagged with.

Currently all images uses `dzek69/noderasp` prefix as image name. It is hardcoded.

## License

MIT