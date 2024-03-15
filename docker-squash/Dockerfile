FROM docker:25.0.4
RUN apk add --no-cache python3 py3-pip && python3 -m venv ~/pyvenv --system-site-packages && ~/pyvenv/bin/pip3 install docker-squash && mkdir /create && ln -s /root/pyvenv/bin/docker-squash /bin/docker-squash
