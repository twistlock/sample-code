# This example assumes Ubuntu 18.03, 2 vCPUs, 7-8GB RAM, 100GB disk.
# Get the TL_PROD_URL for the current recommended release from https://docs.twistlock.com using your license token.
# You'll need your full license key once you install to activate Twistlock.
# Browse to https://<server IP>:8083 after installation to create your admin user, add your license key, and get started.


TL_PROD_URL=https://XXXXXXX/XXXXXXXX/XXXXXXXXX/twistlock_XXXXX_XXXXX_XXXXX.tar.gz

sudo apt-get update

echo ‘########################’

echo "Installing Docker CE "
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 19.03 | head -1 | awk '{print $3}')

echo ‘########################’

echo "Installing Twistlock onebox"
wget $TL_PROD_URL
mkdir twistlock
tar xvzf twistlock*.tar.gz -C twistlock
sudo twistlock/twistlock.sh -s onebox
