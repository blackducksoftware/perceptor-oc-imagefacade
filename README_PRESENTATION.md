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

# Testing in Openshift

Use an image-registry.json file such as this, with the only change being in the perceptor-imagefacade stanza.

```
➜  openshift git:(781614d) ✗ cat image-registry-custom.json
{
  "pod": [
    {
      "name": "image-perceiver",
      "image": "opssight-image-processor",
      "tag": "2.0.0"
    },
    {
      "name": "pod-perceiver",
      "image": "opssight-pod-processor",
      "tag": "2.0.0"
    },
    {
      "name": "perceptor",
      "image": "opssight-core",
      "tag": "2.0.0"
    },
    {
      "name": "perceptor-imagefacade",
      "image": "perceptor-if-ex",
      "tag": "master"
    },
    {
      "name": "perceptor-scanner",
      "image": "opssight-scanner",
      "tag": "2.0.0"
    },
    {
      "name": "perceptor-protoform",
      "image": "opssight-deployer",
      "tag": "2.0.0"
    }
  ]
}
```

Then, launch opssight, like this, note that we have uploaded all images to a custom registry.

```
./install.sh -c gcr.io -I gke-verification/blackducksoftware -H 104.198.184.167 -U sysadmin -W blackduck -P 443 --hub-max-concurrent-scans=1
```
