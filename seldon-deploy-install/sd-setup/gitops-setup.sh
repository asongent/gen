#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail
set -o noclobber
set -o noglob

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

REPONAME="$1"
NAMESPACES="$2"
READROLES=${3:-""}
WRITEROLES=${4:-""}
DEPLOYNAMESPACE=${5:-"seldon-system"}

SDCONFIG_FILE=${HOME}/.config/seldon/seldon-deploy/sdconfig.txt
source "${SDCONFIG_FILE}"

TEMPRESOURCES=${STARTUP_DIR}/tempresources

GIT_PROVIDER=${GIT_PROVIDER:-"github"}
GIT_URL=${GIT_URL:-}
GIT_API=${GIT_API:-}
GIT_AUTHOR_STRING=${GIT_AUTHOR_STRING:-"${GIT_USER} <${GIT_EMAIL}>"}

if [ "${GIT_PROVIDER}" = "github" ] && [ -z "${GIT_URL}" ]; then
  GIT_URL=${GIT_URL:-"${GIT_PROVIDER}.com"}
  GIT_API=${GIT_API:-"api.${GIT_PROVIDER}.com"}
elif [ "${GIT_PROVIDER}" = "bitbucket" ] && [ -z "${GIT_URL}" ]; then
  GIT_URL=${GIT_URL:-"${GIT_PROVIDER}.org"}
  GIT_API=${GIT_API:-"api.${GIT_PROVIDER}.org"}
elif [ "${GIT_PROVIDER}" != "github" ] && [ "${GIT_PROVIDER}" != "bitbucket" ]; then
  echo "Only github and bitbucket providers are supported."
  exit
fi

if [ -z "${GIT_URL}" ]; then
  echo "Please configure GIT_URL environmental variable."
  exit
fi

GIT_REPO_URL=${GIT_REPO_URL:-"${GIT_URL}/${GIT_USER}/${REPONAME}"}

echo "Git provider: $GIT_PROVIDER"
echo "Git provider url: $GIT_URL"
echo "Git provider repo url: $GIT_REPO_URL"
echo "Git provider API url: $GIT_API"
echo "Git author string: $GIT_AUTHOR_STRING"

find_deploy() {
  DEPLOYPOD=$(kubectl get pod -n ${DEPLOYNAMESPACE} -l app.kubernetes.io/name=seldon-deploy -o jsonpath='{.items[*].metadata.name}')
  if [ -z "${DEPLOYPOD}" ]
  then
    echo "deploy needs to be running in order to configure webhooks"
    return 1
  fi
}

setup_tempresources() {
    ${STARTUP_DIR}/clean
    mkdir -p ${TEMPRESOURCES}
}


init_repo() {
    # assume a GIT_TOKEN= entry in the sdconfig.txt file

    if [ -z "${REPONAME}" ]
    then
      REPONAME="seldon-gitops"
    fi

    if [ -z "${NAMESPACES}" ]
    then
      NAMESPACES="default,kubeflow"
    fi

    git clone https://${GIT_USER}:${GIT_TOKEN}@${GIT_REPO_URL} ${TEMPRESOURCES}/${REPONAME} || true

    mkdir -p ${TEMPRESOURCES}/${REPONAME} || true
    cd ${TEMPRESOURCES}/${REPONAME}
    # create empty README.md
    if test -f "README.md"; then
        echo "README exists"
    else
      echo "Creating README ..."
      echo "Resources to sync to cluster using gitops. Directories represent namespaces." >> README.md
    fi

    #iterate comma-separated namespaces
    for namespace in $(echo $NAMESPACES | sed "s/,/ /g")
    do
      mkdir -p $namespace
      if test -f "./$namespace/README.md"; then
          echo "README exists"
      else
        echo "This dir contains resources synced to the $namespace namespace." >> ./$namespace/README.md
      fi

      # ensure we have namespace in k8s
      kubectl create ns $namespace --dry-run=client -ojson | kubectl apply -f -
      # also need to ensure it has the proper labels
      # remove istio sidecars if on - https://github.com/SeldonIO/seldon-deploy/issues/569
      kubectl label namespace $namespace istio-injection- --overwrite=true
      kubectl label namespace $namespace seldon.gitops=enabled --overwrite=true
      kubectl label namespace $namespace serving.kubeflow.org/inferenceservice=enabled --overwrite=true
      kubectl annotate namespace $namespace git-repo="https://${GIT_REPO_URL}" --overwrite=true

      if [ "$MULTITENANT" = "true" ]
      then
        #give deploy rbac on the namespace
        ${STARTUP_DIR}/apply-role-namespace.sh $namespace
        #install seldon core in this namespace, not clusterwide
        helm delete seldon-core -n seldon-system || true
        kubectl apply -f ${STARTUP_DIR}/resources/seldon-crd.yaml
        kubectl label namespace $namespace seldon.io/controller-id=$namespace --overwrite
        miniokf=$(kubectl get svc -n kubeflow minio-service -o jsonpath="{.metadata.name}" || true)
        #have to install seldon slightly differently for kubeflow or not - check for a minio in kubeflow to know if we're on kubeflow
        if [ -z "${miniokf}" ]
        then
          helm upgrade --install seldon-core seldon-core-operator --repo https://storage.googleapis.com/seldon-charts --namespace $namespace --set istio.gateway="istio-system/seldon-gateway" --set istio.enabled="true" --set certManager.enabled="false" --set singleNamespace="true" --set crd.create="false"
        else
          helm upgrade --install seldon-core seldon-core-operator --repo https://storage.googleapis.com/seldon-charts --namespace $namespace --set istio.gateway="kubeflow/kubeflow-gateway" --set istio.enabled="true" --set certManager.enabled="true" --set singleNamespace="true" --set crd.create="false"
        fi
      fi

      if [ -z "${READROLES}" ] && [ -z "${WRITEROLES}" ]
      then
        kubectl label ns $namespace seldon.restricted=false --overwrite=true
      else
        kubectl label ns $namespace seldon.restricted=true --overwrite=true
      fi

      for readrole in $(echo $READROLES | sed "s/,/ /g")
      do
        kubectl label ns $namespace seldon.group.$readrole=read --overwrite=true
      done

      for writerole in $(echo $WRITEROLES | sed "s/,/ /g")
      do
        kubectl label ns $namespace seldon.group.$writerole=write --overwrite=true
      done

      #setup batch roles
      (
      export TEMPRESOURCES
      export SD_USER_EMAIL
      export SD_PASSWORD
      export STARTUP_DIR
      ${STARTUP_DIR}/batch-sa-for-ns.sh $namespace $DEPLOYNAMESPACE
      )


    done
    echo " done."

    # push to remote repo
    echo "Pushing to remote ..."
    git init
    git add -A
    git commit -m "first commit" --author="${GIT_AUTHOR_STRING}" || true
}

create_git_repo(){
  # get user name
  if [ "${GIT_USER}" = "" ]; then
    echo "Could not find username, ensure sdconfig.txt has GIT_USER set"
    invalid_credentials=1
  fi

  # get repo name
  dir_name=`basename $(pwd)`
  if [ "${GIT_PROVIDER}" = "github" ]; then
    echo "Creating Github repository '${REPONAME}' ..."
    curl -H "Authorization: token ${GIT_TOKEN}" https://${GIT_API}/user/repos -d '{"name":"'${REPONAME}'"}'
    echo "Created Github remote repo."
  elif [ "${GIT_PROVIDER}" = "bitbucket" ]; then
    echo "Creating Bitbucket repository '$REPONAME' ..."
    curl  -u ${GIT_USER}:${GIT_TOKEN} -H "Content-Type: application/json" https://${GIT_API}/2.0/repositories/${GIT_USER}/${REPONAME} -d '{"scm":"git","is_private":false}'
    echo "Created Bitbucket remote repo."
  fi

}

push_repo(){
  set +o errexit
  git remote rm origin
  set -o errexit
  git remote add origin https://${GIT_USER}:${GIT_TOKEN}@${GIT_REPO_URL}
  git push -u origin master || true
  echo "Remote repository repo available."
}

setup_argocd(){
  cd ../
  kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
  if [ "$MULTITENANT" = "true" ]
  then
    cd ..
    ./set-argocd-namespace.sh argocd
    cd ./tempresources
    kubectl apply -n argocd -f argo-cd-v1.6.1-argocd.yaml
  else
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v1.6.1/manifests/install.yaml
  fi
  # if you don't want argocd available externally then patch back to ClusterIP at the end
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
  kubectl rollout status deployment/argocd-application-controller -n argocd
  kubectl rollout status deployment/argocd-repo-server -n argocd
  kubectl rollout status deployment/argocd-server -n argocd
  kubectl rollout status deployment/argocd-redis -n argocd
  kubectl rollout status deployment/argocd-dex-server -n argocd

  # wait to become available - takes a while
  ip=$(kubectl get service argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[*].ip}') || true
  # on aws could be hostname
  if [ -z "${ip}" ]; then
    ip=`kubectl get service argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[*].hostname}'` || true
  fi
  if [[ $ip == *.* ]] ; then
    echo "ip for argocd is $ip"
  else
    sleep 50
  fi
  rm -f argocd
  rm -f argocd-linux-amd64
  wget -q -O argocd "https://github.com/argoproj/argo-cd/releases/download/v1.6.1/argocd-linux-amd64"
  chmod 755 ./argocd
  ARGOCDURL=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2> /dev/null || true)
  #on aws could be hostname
  if [ -z "${ARGOCDURL}" ]; then
    ARGOCDURL=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2> /dev/null || true)
  fi
  ARGOCDINITIALPASS=12341234
  #set password using tools from https://aur.archlinux.org/packages/apache-tools/
  kubectl patch secret -n argocd argocd-secret -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" ${ARGOCDINITIALPASS} | tr -d ':\n')'"}}'

  ./argocd login --insecure ${ARGOCDURL} --username admin --password ${ARGOCDINITIALPASS}

  #note not using auto-prune - that would remove anything that isn't in git
  ./argocd repo add "https://${GIT_REPO_URL}" \
      --username ${GIT_USER} \
      --password ${GIT_TOKEN} \
      --upsert

  ./argocd proj delete seldon -s "https://${GIT_REPO_URL}" 2> /dev/null || true
  ./argocd proj create seldon -s "https://${GIT_REPO_URL}" 2> /dev/null || true
  #whitelist resource types for the project
  ./argocd proj allow-cluster-resource seldon '*' '*'
  ./argocd proj allow-namespace-resource seldon '*' '*'

  #get an access token for REST calls to the project
  ./argocd proj role create seldon seldon-admin 2> /dev/null || true
  ./argocd proj role add-policy seldon seldon-admin --action get --permission allow --object '*' 2> /dev/null || true
  ./argocd proj role add-policy seldon seldon-admin --action create --permission allow --object '*' 2> /dev/null || true
  ./argocd proj role add-policy seldon seldon-admin --action update --permission allow --object '*' 2> /dev/null || true
  ./argocd proj role add-policy seldon seldon-admin --action delete --permission allow --object '*' 2> /dev/null || true
  ./argocd proj role add-policy seldon seldon-admin --action sync --permission allow --object '*' 2> /dev/null || true
  JWT=$(./argocd proj role create-token seldon seldon-admin)
  echo -n $JWT > ./jwt-argocd.txt
  kubectl create secret generic jwt-argocd --from-file=./jwt-argocd.txt --dry-run=client -o yaml | kubectl apply -f -

  #iterate comma-separated namespaces
  for namespace in $(echo $NAMESPACES | sed "s/,/ /g")
  do

    if [ "$MULTITENANT" = "true" ]
    then
      cd ..
      ./set-argocd-namespaced-role.sh ${namespace}
      cd ./tempresources
      kubectl apply -n ${namespace} -f ./argo-cd-namespaced-role-${namespace}.yaml
    fi
    appname="${REPONAME}"-"${namespace}"
    ./argocd proj add-destination seldon https://kubernetes.default.svc $namespace 2> /dev/null || true
    ./argocd app create $appname \
        --repo  "https://${GIT_REPO_URL}" \
        --path $namespace \
        --dest-namespace $namespace \
        --dest-server https://kubernetes.default.svc \
        --sync-policy automated \
        --project seldon \
        --directory-recurse \
        --auto-prune \
        --upsert
    kubectl label namespace $namespace argocdapp=$appname --overwrite=true
    echo "Argocd app $appname created for namespace $namespace, repo $REPONAME"
  done
  echo " "
  echo "For fast syncing to argocd, automatically setting up a webhook."
  echo "Payload URL: https://${ARGOCDURL}/api/webhook"
  echo "Content type: application/json"
  echo "Secret: ${ARGOCDINITIALPASS}"
  echo "SSL verification: Disable"
  if [ "${GIT_PROVIDER}" = "github" ]; then
    curl -u ${GIT_USER}:${GIT_TOKEN} -v -H "Content-Type: application/json" -X POST -d "{\"name\": \"web\", \"active\": true, \"events\": [\"*\"], \"config\": {\"url\": \"https://${ARGOCDURL}/api/webhook\", \"content_type\": \"json\", \"secret\": \"${ARGOCDINITIALPASS}\", \"insecure_ssl\": \"1\" }}" https://${GIT_API}/repos/${GIT_USER}/${REPONAME}/hooks
  elif [ "${GIT_PROVIDER}" = "bitbucket" ]; then
    curl -v -u ${GIT_USER}:${GIT_TOKEN} -v -H "Content-Type: application/json" -X POST -d "{\"description\": \"web\", \"active\": true, \"events\": [\"repo:push\"], \"url\": \"https://${ARGOCDURL}/api/webhook\"}" https://${GIT_API}/2.0/repositories/${GIT_USER}/${REPONAME}/hooks
  fi

  whIp=$(kubectl get service seldon-deploy-webhook -o jsonpath='{.status.loadBalancer.ingress[*].ip}' -n ${DEPLOYNAMESPACE})
  # on aws could be hostname
  if [ -z "${whIp}" ]; then
    whIp=`kubectl get service seldon-deploy-webhook -o jsonpath='{.status.loadBalancer.ingress[*].hostname}' -n ${DEPLOYNAMESPACE}` || true
  fi
  if [[ $whIp == *.* ]] ; then
    echo " "
    echo "ALSO a SECOND json webhook for seldon-deploy to http://$whIp/api/git-webhook. All events and no secret for the second webhook."
    if [ "${GIT_PROVIDER}" = "github" ]; then
      curl -u ${GIT_USER}:${GIT_TOKEN} -v -H "Content-Type: application/json" -X POST -d "{\"name\": \"web\", \"active\": true, \"events\": [\"*\"], \"config\": {\"url\": \"http://${whIp}/api/git-webhook\", \"content_type\": \"json\" }}" https://${GIT_API}/repos/${GIT_USER}/${REPONAME}/hooks
    elif [ "${GIT_PROVIDER}" = "bitbucket" ]; then
      curl -v -u ${GIT_USER}:${GIT_TOKEN} -v -H "Content-Type: application/json" -X POST -d "{\"description\": \"web\", \"events\": [\"repo:push\"], \"url\": \"http://${whIp}/api/git-webhook\", \"active\": true}" https://${GIT_API}/2.0/repositories/${GIT_USER}/${REPONAME}/hooks
    fi
  fi

  #restart deploy to see what might be a newly-labelled namespace
  kubectl delete pod -n seldon-system -l app.kubernetes.io/name=seldon-deploy

}

find_deploy
setup_tempresources
init_repo
create_git_repo
push_repo
setup_argocd
# ${STARTUP_DIR}/clean
