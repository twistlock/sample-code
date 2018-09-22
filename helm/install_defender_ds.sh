
while true; do
  str=$(kubectl get svc twistlock-console -n twistlock | grep -v TYPE | awk '{print $4}')
  # Use the below when you want the output not to contain some string
  # Use the below when you want the output to contain some string
  if [[ ! $str =~ "pending" ]]; then
    break
  fi
  echo -n "."
  sleep 3 
done
echo "Twistlock console service up and available"

consoleURL="https://$str:8083"

echo "Browser to $consoleURL  and create an admin account and install license"

echo "Once that is completed, enter your admin user account name:"
read user
echo "Enter password:"
read password

curl -k -u "$user:$password" "$consoleURL/api/v1/defenders/daemonset.yaml?consoleaddr=$str&namespace=twistlock&orchestration=kubernetes&ubuntu=true&selinux=false" > defender_ds.yaml

cat defender_ds.yaml

