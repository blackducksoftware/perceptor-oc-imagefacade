# Results

Using perceptor with blackduck's scanner, you can use this custom image facade to generate real results, without needing any kind of privileged containers running.  

You also can use it to detect NEW vulnerabilities introduced to containers at RUNTIME.

![alt text](https://github.com/blackducksoftware/perceptor-oc-imagefacade/blob/master/imagefacadearch.png?raw=true)


OpsSight 2 supports any kind of image source, here are examples of real scans using the image facade, which does not need any kind of privileged access or service account, in this repo:

![alt text](https://github.com/blackducksoftware/perceptor-oc-imagefacade/blob/master/opssight-image-facade.png?raw=true)

Scanning with 'real' docker images yields a similar result for many imgaes:

![alt text](https://github.com/blackducksoftware/perceptor-oc-imagefacade/blob/master/realimg.png?raw=true)


# Testing

First, start the image facade by running the following:

- `export GOPATH=/go/`

- `go build -o imagefacade_os ./cmd/imagefacadeos/imagefacade_os.go  ; ./imagefacade_os`

And then, test the image facade (or any image facade) in isolation, by simply running these two commands:

- `curl -d '{"PullSpec":"sha256:a1eb671e9f35b284c4f22"}' -X POST localhost:8000/pullimage`

This should kick off an image pull in your image facade.

- `curl -d '{"PullSpec":"sha256:a1eb671e9f35b284c4f22"}' -X POST localhost:8000/checkimage`

```
➜  openshift git:(781614d) ✗ curl -d '{"PullSpec":"sha256:a1eb671e9f35b284c4f22"}' -X POST localhost:8000/checkimage
{"PullSpec":"sha256:a1eb671e9f35b284c4f22","ImageStatus":2}%
```
