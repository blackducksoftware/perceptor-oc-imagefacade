#!/bin/bash
# set -e

export OC_SERVER="18.218"
export OC_SERVER="${OC_SERVER}.176.19"
export OC_UN="clustadm"

function defaults() {
  export OC_PW="devops123!"
  export OC_CP_TMP="/tmp/hackathon2018_tmp/"
  export OC_TAR_DIR="/tmp/hackathon2018"
  export SHA="272c2760a0f4ee0e664f6c63a1cabb78223f0942fead826a8183fab5856d48e8"
}

function check() {
  echo "CHECKING ENV VARS... will exit if they aren't all set."
  if [[ "$OC_SERVER" == "" ]] ; then exit 33 ; fi
  if [[ "$OC_UN" == "" ]] ; then exit 33 ; fi
  if [[ "$OC_PW" == "" ]] ; then exit 33 ; fi
  if [[ "$OC_CP_TMP" == "" ]] ; then exit 33 ; fi
  if [[ "$OC_TAR_DIR" == "" ]] ; then exit 33 ; fi
  if [[ "$SHA" == "" ]] ; then exit 33 ; fi

  mkdir -p $OC_CP_TMP
  oc login $OC_SERVER:8443 --username=$OC_UN --password=$OC_PW --insecure-skip-tls-verify
}

function setImageInfo() {
  echo $SHA

  oc get pods --all-namespaces -o go-template='{{range .items}} {{.metadata.name}} +{{.metadata.namespace}}+ {{range .status.containerStatuses}} _{{.imageID}}_ {{end}}   {{"\n"}}{{end}} ' \
    > /tmp/oc.yaml

  echo $images
  ns=`cat /tmp/oc.yaml | grep $SHA | head -1 | cut -d'+' -f 2`
  echo "NAMESPACE = $ns"
  echo "############### ${SHA} ###############"
  echo $images | grep $SHA
  echo "########################################"
  pod=`cat /tmp/oc.yaml | grep $SHA | head -1 | cut -d' ' -f 2`
  image=`cat /tmp/oc.yaml | grep $SHA | head -1 | cut -d'_' -f 1`

  echo "acquired namespace $ns with pod $pod (image $image)"
  # now let's copy some files out of the hub-solr container
  # oc cp usage is 'oc cp <namespace/project>/POD:files_to_copy_from_pod /save/files/to/local/dir'
}

function scrapePodIntoFolder() {
  echo "about to scrape from $ns  , the pod $pod"
  mkdir -p $OC_CP_TMP
  # Some may fail, some may succeed.
  oc get pod -o yaml $pod -n $ns > $OC_CP_TMP/pod-meta-scanme.yaml
  oc cp $ns/$pod:/ $OC_CP_TMP
  oc cp $ns/$pod:/bin $OC_CP_TMP
  oc cp $ns/$pod:/etc $OC_CP_TMP
  oc cp $ns/$pod:/var $OC_CP_TMP
  oc cp $ns/$pod:/opt/solr/ $OC_CP_TMP
  oc cp $ns/$pod:/opt/ $OC_CP_TMP
  echo "...attempt to list root container contents for debugging later..."
  oc exec -t -i $pod -n $ns -- ls -altrh
  echo "all done scraping to $OC_CP_TMP, found `ls -altrh $OC_CP_TMP`"
}

function saveFolderToTar() {
  pushd $OC_CP_TMP && ls -l
    tar -cvf $OC_TAR_DIR ./
  popd
}

check
setImageInfo
scrapePodIntoFolder
saveFolderToTar
echo "***************** DEBUG INFO FOR SCRAPE CONTENTS **********************"
tar -tvf $OC_TAR_DIR
echo "***************** END SCRAPE CONTENTS ******************"
