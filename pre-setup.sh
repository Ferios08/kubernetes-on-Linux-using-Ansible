#!/bin/bash
echo -e "Welcome to the Pre Setup script"
echo -e "backing up  old configurations"
mkdir -p backup
mv -f env_variables hosts docker-proxy.conf backup/ 2>/dev/null; true
echo -e "a Copy of hosts & env_variables will be created and modified for your setup"
cp -f templates/env_variables-template  env_variables 2>/dev/null; true
cp -f templates/hosts-template  hosts 2>/dev/null; true


# Find out which system I am :)
YUM_CMD=$(which yum  2> /dev/null)
APT_GET_CMD=$(which apt-get  2> /dev/null)

 if [[ ! -z $YUM_CMD ]]; then
    echo -e "CentOS/RedHat detected"
    sleep 1;
 elif [[ ! -z $APT_GET_CMD ]]; then
    echo -e "Debian/Ubuntu detected"
    sleep 1;
 else
    echo -e "System not supported :("
 fi

echo -e "Making scripts executable"
chmod +x scripts/*
#Installing dependencies, you can add as many dependencies as you want.
./scripts/install_package.sh sshpass

#Installing Ansible
while true; do
    read -p "Do you want me to install ansible for you?:(yes/no)" yn
    case $yn in
        [Yy]* ) ./scripts/install_ansible.sh ; break;;
        [Nn]* ) echo -e "As you like."; break;;
        * ) echo "Please answer with yes or no.";;
    esac
done


echo -n "What is the master's private IP?: "
read pvip
sed -i "s/internalIP/$pvip/g" env_variables

echo -n "What is the master's public IP?: "
read pbip
sed -i "s/externalIP/$pbip/g" env_variables

echo -n "What is your default user?: "
read username

sed -i "s/ansible_host=/ansible_host=$pvip/g" hosts
sed -i "s/ansible_user=/ansible_user=$username/g" hosts
sed -i "s/username/$username/g" env_variables



while true; do
    re='^[0-9]+$'
   
    echo -n "How many worker nodes do you have?: "
    read workers

    if  ! [[ $workers =~ $re ]] ; then
        echo -e "Invalid value."

    elif [ $workers -lt 0 ] ; then   
        echo -e "Wrong number value, please enter a positive value."

    elif  [ $workers -gt -1 ] ; then
        break

    fi
    echo
done

# Generating ssh key / ignoring if already exist
ssh-keygen -t rsa -f $HOME/.ssh/id_rsa  -q -P ""  <<< y
echo # blanc line

# Assuming that all nodes have the same password, asking the user to enter it:
read -s -p "Please insert your nodes' Password: " password
echo
read -s -p "Password comfirm: " password2

# check if passwords match and if not ask again
while [ "$password" != "$password2" ];
do
    echo
    echo "Please try again"
    read -s -p "Password: " password
    echo
    read -s -p "Password (again): " password2
done
echo # blanc line
# Copy the ssh key to the master
sshpass -p "$password" ssh-copy-id -o StrictHostKeychecking=no $username@$pvip 
echo -e "Copied ssh-key to master node."
# Changing master's hostname
ssh $pvip sudo hostnamectl set-hostname k8s-master
echo -e "Changed master's hostname to k8s-master"

if [ "$workers" -eq "0" ]
then
  sed -i "s/TAINTED: NO/TAINTED: yes/g" env_variables

else
  # Asking if the master is tainted:
  while true; do
      read -p "Do you wish to taint your master Node?:(yes/no)" yn
      case $yn in
          [Yy]* ) sed -i "s/TAINTED: false/TAINTED: true/g" env_variables; break;;
          [Nn]* ) break;;
          * ) echo "Please answer with yes or no.";;
      esac
  done
  # ADDING WORKER NODES
  for (( i = 1; i < workers+1; i++ ))
  do

    echo -n "enter ther worker number $i's ip: "
    read ip
    echo "k8s-worker-$i ansible_host=$ip  ansible_user=$username" >> hosts
    echo -n "Node worker-$i added to hosts file."
    echo # blanc line

    sshpass -p "$password" ssh-copy-id -o StrictHostKeychecking=no $username@$ip 
    echo -e "Copied ssh-key to worker-$i Node."
    echo # blanc line
    ssh $ip sudo hostnamectl set-hostname k8s-worker-$i
    echo -e "Changed node's hostname to k8s-worker-$i"

  done
fi
echo -n "Please enter your mail that will be used by lets Encypt: "
read mail
sed -i "s/mymail/$mail/g" env_variables

echo -n "Please choose which Pod network plugin to install? actually supporting weavenet and calico: "
read plugin
sed -i "s/weavenet/$plugin/g" env_variables

echo -e "To install a specific version of Kubernetes, set it up manually in the env_variables file:"

#Configuring Env Proxy
while true; do
    read -p "Are your nodes using a proxy? (yes/no): " yn
    case $yn in
        [Yy]* ) # Reading HTTP_PROXY
                echo -n "Enter your ENV http_proxy: "
                read httpx
                sed -i "s+http_proxy:+http_proxy: $httpx+g" env_variables
                # Reading HTTPS_PROXY
                echo -n "Enter your ENV https_proxy: "
                read httpsx
                sed -i "s+https_proxy:+https_proxy: $httpsx+g" env_variables
                # Reading NO_PROXY
                echo -n "Enter your ENV no_proxy (comma serarated list supported, no spaces)Enter if empty: "
                read nopx
                sed -i "s+no_proxy:+no_proxy: $nopx+g" env_variables
                echo -e "ENV proxy configured successfully"
                break;;
        [Nn]* ) break;;
        * ) echo "Please answer with yes or no.";;
    esac
done

#Configuring Docker Proxy
while true; do
    read -p "Are you using docker behind a proxy?:(yes/no)" yn
    case $yn in
        [Yy]* ) sed -i "s/DOCKER_PROXY: false/DOCKER_PROXY: true/g" env_variables;
                cp templates/docker_proxy-template  docker-proxy.conf
                # Reading HTTP_PROXY
                echo -n "Enter your docker http_proxy: "
                read httpx
                sed -i "s+HTTPX+$httpx+g" docker-proxy.conf
                # Reading HTTPS_PROXY
                echo -n "Enter your docker https_proxy: "
                read httpsx
                sed -i "s+HTTPSX+$httpsx+g" docker-proxy.conf
                # Reading NO_PROXY
                echo -n "Enter your docker no_proxy (comma serarated list supported, no spaces): "
                read nopx
                sed -i "s+NOPX+$nopx+g" docker-proxy.conf
                cp docker-proxy.conf $HOME/
                echo -e "Docker proxy configured successfully"
                break;;
        [Nn]* ) break;;
        * ) echo "Please answer with yes or no.";;
    esac
done

echo
echo

echo -ne '######                     (25%)\r'
sleep 1
echo -ne '############               (50%)\r'
sleep 1
echo -ne '##################         (75%)\r'
sleep 1
echo -ne '########################   (100%) Setup completed! \r'
echo -ne '\n'

echo -e "Please Note that this Script back your current setup up if launched again, and it will overwrite any backed up configuration"
echo # blanc line
echo -e "##############################################################################################"
echo # blanc line
echo -e "you can check the  env_variables and hosts file to verify your actual configuration :)"