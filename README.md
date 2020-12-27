# This is used to deploy kuberntetes cluster using Ansible

0 All nodes must be Iniated with the file "file/initiate.sh"
  and for you need a host with a recent version of Ansible and git,
  It can be one of these nodes or an other one within the same network
  you can install them via:
  sudo yum install ansible git -y


1 Add your nodes to  the hosts file, 
  you must use private IPS

2 Added your Master Private IP and Public IP to enc_variables file, and other info such ansible default user

3 Run "setup.sh" after running chmod +x setup.sh
  or run them manually using:
  sudo ansible-playbook -K setup_master_node.yml -i hosts
  sudo ansible-playbook -K setup_worker_nodes.yml -i hosts
  sudo ansible-playbook -K after_cluster_setup.yml -i hosts

4 You can run additional post-cluster configuration playybooks in the "config/" folder


Annnd 5, Happy Devops x)

