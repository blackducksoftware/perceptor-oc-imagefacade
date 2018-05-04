FROM centos:7

# copy in the entrypoint file and then chmod it
COPY ./docker-entrypoint.sh docker-entrypoint.sh
RUN chmod 777 docker-entrypoint.sh

# copy in the OC Client to /usr/local/bin/ so it 'just works'
COPY ./oc /usr/local/bin/

ENTRYPOINT ["./docker-entrypoint.sh"]
