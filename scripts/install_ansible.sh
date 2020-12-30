# Find out which system I am :)
YUM_CMD=$(which yum  2> /dev/null)
APT_GET_CMD=$(which apt-get  2> /dev/null)
    if [[ ! -z $YUM_CMD ]]; then
        echo -e "Installing Ansible on CentOS"
        sudo yum install -y epel-release  && sudo yum install ansible -y
    elif [[ ! -z $APT_GET_CMD ]]; then
        echo -e "Installing Ansible on Ubuntu"
        sudo apt-get update && sudo apt install software-properties-common -y && sudo apt-add-repository -y --update ppa:ansible/ansible  &&  sudo apt -y install ansible
    else
        echo -e "Error! Can't install package Ansible ! Please install it Manually"
    fi
done