#!/bin/bash

https_port="8083"
if [ "$#" -eq 1 ]; then
   https_port=$1 
fi

for cnt in `seq 1 12`;
do
  if [ $(uname) = "Darwin" ]; then   # macOS
    ip=$(kubectl get svc twistlock-console -n twistlock | grep -v CLUSTER-IP | awk '{print $4}')
  else                                 # Linux
    ip=$(kubectl get svc twistlock-console -n twistlock | grep -v CLUSTER-IP | awk '{print $3}')
  fi

  # Use the below when you want the output not to contain some iping
  # Use the below when you want the output to contain some iping
  if [[ ! $ip =~ "pending" ]]; then
    break
  fi
  echo "waiting for Twistlock console service to be up with LoadBalancer assigned"
  echo -n "."
  sleep 3 
done

echo "Twistlock console service up and available"

consoleURL="https://$ip:$https_port"

echo "Browse to $consoleURL  and create an admin account and install license"

echo "Once that is completed, enter your admin user account name:"
read user
echo "Enter password:"
read -s password

curl -k -u "$user:$password" "$consoleURL/api/v1/defenders/daemonset.yaml?consoleaddr=$ip&namespace=twistlock&orchestration=kubernetes&ubuntu=true&selinux=false" > defender_ds.yaml

kubectl create -f defender_ds.yaml

kubectl get pods -n twistlock

echo "Twistlock Defender Daemonset installed, go to console UI and see connected defenders at:  Manage/Defenders/Manage"


