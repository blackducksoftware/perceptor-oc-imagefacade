FROM centos:centos7

# Get the image facade shell script

COPY ./getimage.sh /getimage.sh
RUN chmod 777 /getimage.sh
COPY ./oc /usr/local/bin/

# Get the golang binary.
RUN mkdir /tmp/images_scratch
COPY ./imagefacade_os ./
CMD ["./imagefacade_os"]
