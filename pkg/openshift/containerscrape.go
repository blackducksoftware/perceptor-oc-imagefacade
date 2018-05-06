package openshift

import (
	"fmt"
	"log"
	"os"
	"os/exec"
)

func RunOCGet(server, username, password, image, cpTmp, tarDir string) error {
	return RunCommand(map[string]string{
		"OC_SERVER":  server,   //"18.218.176.19"
		"OC_UN":      username, //clustadm
		"OC_PW":      password, //devops123!
		"SHA":        image,
		"OC_CP_TMP":  cpTmp,  // "/tmp"
		"OC_TAR_DIR": tarDir, //"/temp/hackathon2018"
	})
}

func RunCommand(inputs map[string]string) error {
	fmt.Println(fmt.Sprintf("Running command w/ map %s", inputs))
	path, err := exec.LookPath("./getimage.sh")
	if err != nil {
		panic(err)
		//		panic("no path to image getter")
	}
	cmd := exec.Command(path)

	env := os.Environ()
	for k, v := range inputs {
		env = append(env, fmt.Sprintf("%s=%s", k, v))
		fmt.Println(fmt.Sprintf("--- appending %s %s", k, v))
	}
	cmd.Env = env
	stdOutStderr, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%s\n", stdOutStderr)

	return err
}
