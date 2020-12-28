#!/bin/bash
echo -e "Welcome to the Pre Setup script"
echo -e "backing up  old configurations"
mkdir -p backup
mv -f env_variables hosts backup/ 2>/dev/null; true
echo -e "a Copy of hosts & env_variables will be created and modified for your setup"
cp -f templates/env_variables-template  env_variables 2>/dev/null; true
cp -f templates/hosts-template  hosts 2>/dev/null; true

#Installing dependencies
echo -e "Installing dependencies"
sudo apt-get update && sudo apt install sshpass -y

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


echo -n "How many worker nodes do you have?: "
read workers

# Generating ssh key / ignoring if already exist
ssh-keygen -t rsa -f $HOME/.ssh/id_rsa  -q -P ""  <<< y

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

# Copy the ssh key to the master
sshpass -p "$password" ssh-copy-id -o StrictHostKeychecking=no $username@$pvip 
 echo -n "Copied ssh-key to master node Node.\n"


echo -n "How many worker nodes do you have?: "
read workers
for (( i = 1; i < workers+1; i++ ))
do

   echo -n "enter ther worker number $i's ip: "
   read ip
   echo "k8s-worker-$i ansible_host=$ip  ansible_user=$username" >> hosts
   echo -n "Node worker-$i added to hosts file.\n"

   sshpass -p "$password" ssh-copy-id -o StrictHostKeychecking=no $username@$ip 
   echo -n "Copied ssh-key to worker-$i Node.\n"

done

echo -n "Please enter your mail that will be used by lets Encypt: "
read mail
sed -i "s/mymail/$mail/g" env_variables

echo -n "Please choose which Pod network plugin to install? actually supporting weavenet and calico: "
read plugin
sed -i "s/weavenet/$plugin/g" env_variables

echo -e "To install a specific version of Kubernetes, set it up manually in the env_variables file:"


echo -ne '######                     (25%)\r'
sleep 1
echo -ne '############               (50%)\r'
sleep 1
echo -ne '##################         (75%)\r'
sleep 1
echo -ne '########################   (100%) Setup completed! \r'
echo -ne '\n'

echo -e "Please Note that this Script back your current setup up if launched again, and it will overwrite any backed up configuration\n"
echo -e "##############################################################################################\n"
echo -e "you can check the  env_variables and hosts file to verify your actual configuration :)"