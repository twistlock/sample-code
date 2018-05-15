function usage()
{
   echo "Usage: installConsoleK8sUsingTLRegistry <service-type> <Twistlock support token>"
   echo "      service-type can be NodePort or LoadBalancer"
   echo "      you must run this script from Twistlock installation folder (where twistlock.cfg and twistlock_console.tar.gz exists)!"
}

if [ $# -ne 2 ] || [ ! -e twistlock.cfg ]; then
  usage 
  exit 1    
fi

TL_VERSION=$(grep DOCKER_TWISTLOCK_TAG tw*.cfg | awk -F"=" '{print $NF}')
echo "Using configuration found in twistlock.cfg"
echo "Using Twistlock version $TL_VERSION found in twistlock.cfg file known as DOCKER_TWISTLOCK_TAG"

echo "Installing console as a $1 in kubernetes cluster"

tl_registry=$(echo "registry-auth.twistlock.com/tw_$2/twistlock/console:console$TL_VERSION" | tr '[:upper:]' '[:lower:]') 
echo "using Twistlock registry $tl_registry"

linux/twistcli console install \
    --service-type "$1" \
    --verbose \
    --namespace "twistlock" \
    --orchestration-type "kubernetes" \
    --registry-address "$tl_registry" \
    --skip-push 

echo "waiting for console pod to come up"

cnt=0

while [ $cnt -lt 15 ]
do
  sleep 2 
  echo -ne "." 
  running=$(kubectl get pods -n twistlock | grep -c Running)
  if (($running == 1))
  then
    break  
  fi
  ((cnt+=1))
done

if (($cnt == 15)); then
   echo "Problems with console pod coming up!"
   kubectl get pods -n twistlock
   echo "Use kubectl describe pod <console_pod> -n twistlock  to trouble-shoot"
   exit 1
fi

sleep 10

echo ""
echo "Console running, waiting for external IP assignment!"

cnt=0
while [ $cnt -lt 20 ]
do
  sleep 2
  echo -ne "."

  externalIP=$(kubectl get svc -n twistlock | grep -c pending)
  if (($externalIP != 1)); then
     break
  fi
  ((cnt+=1))
done

echo ""

kubectl get pods -n twistlock
kubectl get svc -n twistlock -o wide

echo "Connect to console via browser using external IP and port 8081 or 8083 and add admin user and license, then install defenderDS"

