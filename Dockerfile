FROM centos:centos7

COPY ./dockerless_image_facade ./

CMD ["./dockerless_image_facade"]
