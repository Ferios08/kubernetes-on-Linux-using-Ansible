# This is used to deploy kuberntetes cluster using Ansible on Ubuntu, CentOS 7 and Redhat 7

## 1. You need ansible installed on your server:
To install ansible: 
* [Ubuntu](https://phoenixnap.com/kb/install-ansible-ubuntu-20-04)
* [CentOS/RHEL](hhttps://www.decodingdevops.com/how-to-install-ansible-in-redhat-linux-centos/)


## 2. No need to generate SSH keys and copy them to remote servers

The pre-setup script will do all the config for you.
Just give the infos needed by the cluster which are:
* The master's private and public IP
* The default user used to access the machines during the installation
* The password that will be asked to copy the key to remote servers.
the Pod network which will be used to setup your cluster. For now only weavenet and calico are supported.
* Cert manager and let's encrypt will be setted up automatically. So we will need your email for that.
* In addition to ansible, we need other dependencies to be installed like sshpass. No need to worry, the pre-setup script got this.

Don't forget to make the setup.sh and the pre-setup.sh scripts executables:
```sh
chmod +x setup.sh pre-setup.sh
```
once you are ready, you can launch the pre-setup.sh:
```sh
./pre-setup.sh
```
Once your setup is ready and your configuration is created successfully, you can verify in the "hosts" and "env_vairables" files. You are ready to launch the installation with:
```sh
./setup.sh
```
you will be asked to enter your password, as we will need root access to perform some actions