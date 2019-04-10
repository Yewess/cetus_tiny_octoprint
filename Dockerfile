FROM fedora:29
EXPOSE 80
RUN dnf update -y && \
    dnf clean all && \
    rm -rf /var/cache/dnf
ADD /rpms.txt /root/
RUN dnf install -y $(cat /root/rpms.txt) && \
    dnf clean all && \
    rm -rf /var/cache/dnf
RUN useradd octoprint
WORKDIR /home/octoprint
ADD /requirements.txt /octoprint.sh /home/octoprint
USER octoprint
RUN virtualenv --python=python2.7 venv && \
    source venv/bin/activate && \
    pip install --force --upgrade pip && \
    pip install --requirement=requirements.txt && \
    rm -rf /home/octoprint/.cache
RUN mkdir -p octoprint && \
    ln -sf octoprint .octoprint
RUN source venv/bin/activate && \
    pip install https://github.com/foosel/OctoPrint/archive/1.3.10.zip && \
    rm -rf /home/octoprint/.cache
RUN source venv/bin/activate && \
    sed -r -i -e 's/serial\.PARITY_ODD/serial.PARITY_NONE/g' \
        $VIRTUAL_ENV/lib/python2.7/site-packages/octoprint/util/comm.py
ADD /Dockerfile /root/
VOLUME ["/home/octoprint/.octoprint"]
ENTRYPOINT ["bash", "/home/octoprint/octoprint.sh"]
