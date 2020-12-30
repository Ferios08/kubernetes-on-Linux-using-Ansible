# Find out which system I am :)
YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)

echo -e "Installing packages $*:"
for i in $*; do  
    if [[ ! -z $YUM_CMD ]]; then
        echo -e "Installing $i"
        sudo yum install $i  -y
    elif [[ ! -z $APT_GET_CMD ]]; then
        echo -e "Installing $i"
        sudo apt-get update && sudo apt install $i  -y
    else
        echo -e "Error! Can't install package $i ! Please install it Manually"
    fi
done