if [ -z "${NODE_VERSION}" ]; then
    echo "NODE_VERSION env variable must be set"
    exit 1
fi
if [ -z "${VERSION}" ]; then
    echo "VERSION env variable must be set"
    exit 1
fi
if [ -z "${MODULE}" ]; then
    echo "MODULE env variable must be set"
    exit 1
fi

echo "docker build . -f Dockerfile.${MODULE} -t dzek69/noderasp:${VERSION}-${MODULE} --build-arg VERSION=${VERSION} --build-arg NODE_VERSION=${NODE_VERSION}"

docker build . -f Dockerfile.${MODULE} -t dzek69/noderasp:${VERSION}-${MODULE} --build-arg VERSION=${VERSION} --build-arg NODE_VERSION=${NODE_VERSION}
if ! [ -z "${SQUASH}" ]; then
    docker-squash dzek69/noderasp:${VERSION}-${MODULE} -t dzek69/noderasp:${VERSION}-${MODULE}
fi

echo "You can push with:"
echo "docker push dzek69/noderasp:${VERSION}-${MODULE}"