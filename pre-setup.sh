#!/bin/bash
echo -e "Welcome to the Pre Setup script"
echo -e "backing up  old configurations"
mkdir -p backup
mv -f env_variables hosts backup/ 2>/dev/null; true
echo -e "a Copy of hosts & env_variables will be created and modified for your setup"
cp -f templates/env_variables-template  env_variables 2>/dev/null; true
cp -f templates/hosts-template  hosts 2>/dev/null; true

echo -n "What is the master's private IP?: "
read pvip
sed -i "s/internalIP/$pvip/g" env_variables

echo -n "What is the master's public IP?: "
read pbip
sed -i "s/externalIP/$pbip/g" env_variables

echo -n "What is your default user?: "
read username

sed -i "s/ansible_host=/ansible_host=$pvip/g" hosts
sed -i "s/aansible_user=/ansible_user=$username/g" hosts


echo -n "How many worker nodes do you have?: "
read workers

for (( i = 1; i < workers+1; i++ ))
do

   echo -n "enter ther worker number $i's ip: "
   read ip
   echo "k8s-worker-$i ansible_host=$ip  ansible_user=$username" >> hosts

done

echo -n "Please enter your mail that will be used by lets Encypt: "
read mail
sed -i "s/mymail/$pbip/g" env_variables

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

echo -e "Please Note that this Script back your current setup up if launched again, and it will overwrite any backed up configuration"
echo -e "you can check the  env_variables and hosts file to verify your actual configuration"