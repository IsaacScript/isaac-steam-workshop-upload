# https://hub.docker.com/r/cm2network/steamcmd/
FROM cm2network/steamcmd:root as workshop-upload

ENV CONFIG_VDF_CONTENTS=

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["."]
ENTRYPOINT ["/entrypoint.sh"]
