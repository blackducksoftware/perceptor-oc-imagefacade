FROM centos:centos7

COPY ./hackathoOn2018 /hackathon/

COPY ./dockerless_image_facade ./

CMD ["./dockerless_image_facade"]