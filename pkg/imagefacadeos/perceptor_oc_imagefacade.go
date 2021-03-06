/*
Copyright (C) 2018 Synopsys, Inc.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.
*/

package mockimagefacade

import (
	"fmt"
	"io"
	"os"

	"github.com/blackducksoftware/perceptor-oc-imagefacade/pkg/common"
	"github.com/blackducksoftware/perceptor-oc-imagefacade/pkg/imagefacade"
	"github.com/blackducksoftware/perceptor-oc-imagefacade/pkg/openshift"

	log "github.com/sirupsen/logrus"
)

type OcImagefacade struct {
	server *imagefacade.HTTPServer
}

func NewOcImagefacade() *OcImagefacade {
	server := imagefacade.NewHTTPServer()

	go func() {
		for {
			select {
			case pullImage := <-server.PullImageChannel():
				log.Infof("received pullImage, doing running async get! %+v", pullImage.Image)
				go openshift.RunOCGet(
					"18.218.176.19",
					"clustadm",
					"devops123!",
					pullImage.Image.DockerPullSpec(),
					"/tmp/images_scratch",
					pullImage.Image.DockerTarFilePath())
				pullImage.Continuation(nil)

			case getImage := <-server.GetImageChannel():
				fmt.Println(fmt.Sprintf("received getImage: %+v", getImage.Image))
				stat, err := os.Stat(getImage.Image.DockerTarFilePath())
				if os.IsNotExist(err) {
					fmt.Println(fmt.Sprintf("FAILURE. %v %v ", err, getImage.Image.DockerTarFilePath()))
					getImage.Continuation(common.ImageStatusInProgress)
				} else {
					fmt.Println(fmt.Sprintf("SUCCESS. image is stored : %v %v", getImage.Image.DockerTarFilePath(), stat.Size()))
					getImage.Continuation(common.ImageStatusDone)
				}
			}
		}
	}()
	return &OcImagefacade{server: server}
}

func copyFile(source string, destination string) error {
	in, err := os.Open(source)
	if err != nil {
		return err
	}
	defer in.Close()

	out, err := os.Create(destination)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, in)
	if err != nil {
		return err
	}
	return out.Close()
}
