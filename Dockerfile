# https://hub.docker.com/r/cm2network/steamcmd/
FROM cm2network/steamcmd:root as workshop-upload

ENV STEAM_USERNAME=
ENV STEAM_PASSWORD=
ENV STEAM_GUARD_CODE=

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["."]
ENTRYPOINT ["/entrypoint.sh"]
