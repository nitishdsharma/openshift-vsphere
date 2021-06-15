#!/bin/bash

#set -x

# sourcing the configuration file

set -a
source ../config/config.ini

#################### Functions start here ####################

downloads_image() {
 version=$1
 if [[ "$version" == "4.6" ]]
 then 
	 wget -q https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/$version/latest/rhcos-$version.8-x86_64-metal.x86_64.raw.gz -O /var/www/html/ocp4/rhcos-$version
	 wget -q https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/stable-$version/openshift-install-linux-$version.30.tar.gz
	 tar -xvzf openshift-install-linux-$version.30.tar.gz
	 echo $JB_PASSWORD | sudo -S cp openshift-install /usr/local/bin/.
	 echo $JB_PASSWORD | sudo -S cp openshift-install /usr/bin/.
	 rm README.md openshift-install openshift-install-linux-$version.30.tar.gz
 elif [[ "$version" == "4.7" ]]
 then 
	 wget -q https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/$version/latest/rhcos-$version.7-x86_64-metal.x86_64.raw.gz -O /var/www/html/ocp4/rhcos-$version
	 wget -q https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/stable-$version/openshift-install-linux-$version.13.tar.gz
	 tar -xvzf openshift-install-linux-$version.13.tar.gz
	 echo $JB_PASSWORD | sudo -S cp openshift-install /usr/local/bin/.
	 echo $JB_PASSWORD | sudo -S cp openshift-install /usr/bin/.
	 rm README.md openshift-install openshift-install-linux-$version.13.tar.gz
 fi
}


custom_install_config() {
 if [ -d "live/ocp-install" ]
 then
	 echo "Directory already exists. cleaning it up"
         rm -rf live/ocp-install
         mkdir -p live/ocp-install
 else
         mkdir -p live/ocp-install
 fi

 # Copy install-config template to ocp-install dir
 mv live/install-config.yaml live/ocp-install/.

 # Create openshift cluster manifests
 openshift-install create manifests --dir=live/ocp-install/

 if [[ "$NETWORKTYPE" == "Calico" ]]
 then
	 curl https://docs.projectcalico.org/manifests/ocp/crds/01-crd-installation.yaml -o live/ocp-install/manifests/01-crd-installation.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/01-crd-imageset.yaml -o live/ocp-install/manifests/01-crd-imageset.yaml
 	 curl https://docs.projectcalico.org/manifests/ocp/crds/01-crd-tigerastatus.yaml -o live/ocp-install/manifests/01-crd-tigerastatus.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_bgpconfigurations.yaml -o live/ocp-install/manifests/crd.projectcalico.org_bgpconfigurations.yaml
 	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_bgppeers.yaml -o live/ocp-install/manifests/crd.projectcalico.org_bgppeers.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_blockaffinities.yaml -o live/ocp-install/manifests/crd.projectcalico.org_blockaffinities.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_clusterinformations.yaml -o live/ocp-install/manifests/crd.projectcalico.org_clusterinformations.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_felixconfigurations.yaml -o live/ocp-install/manifests/crd.projectcalico.org_felixconfigurations.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_globalnetworkpolicies.yaml -o live/ocp-install/manifests/crd.projectcalico.org_globalnetworkpolicies.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_globalnetworksets.yaml -o live/ocp-install/manifests/crd.projectcalico.org_globalnetworksets.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_hostendpoints.yaml -o live/ocp-install/manifests/crd.projectcalico.org_hostendpoints.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_ipamblocks.yaml -o live/ocp-install/manifests/crd.projectcalico.org_ipamblocks.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_ipamconfigs.yaml -o live/ocp-install/manifests/crd.projectcalico.org_ipamconfigs.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_ipamhandles.yaml -o live/ocp-install/manifests/crd.projectcalico.org_ipamhandles.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_ippools.yaml -o live/ocp-install/manifests/crd.projectcalico.org_ippools.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_kubecontrollersconfigurations.yaml -o live/ocp-install/manifests/crd.projectcalico.org_kubecontrollersconfigurations.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_networkpolicies.yaml -o live/ocp-install/manifests/crd.projectcalico.org_networkpolicies.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/crds/calico/kdd/crd.projectcalico.org_networksets.yaml -o live/ocp-install/manifests/crd.projectcalico.org_networksets.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/tigera-operator/00-namespace-tigera-operator.yaml -o live/ocp-install/manifests/00-namespace-tigera-operator.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/tigera-operator/02-rolebinding-tigera-operator.yaml -o live/ocp-install/manifests/02-rolebinding-tigera-operator.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/tigera-operator/02-role-tigera-operator.yaml -o live/ocp-install/manifests/02-role-tigera-operator.yaml
 	 curl https://docs.projectcalico.org/manifests/ocp/tigera-operator/02-serviceaccount-tigera-operator.yaml -o live/ocp-install/manifests/02-serviceaccount-tigera-operator.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/tigera-operator/02-configmap-calico-resources.yaml -o live/ocp-install/manifests/02-configmap-calico-resources.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/tigera-operator/02-tigera-operator.yaml -o live/ocp-install/manifests/02-tigera-operator.yaml
	 curl https://docs.projectcalico.org/manifests/ocp/01-cr-installation.yaml -o live/ocp-install/manifests/01-cr-installation.yaml
 fi

 # Removing the manifests which are not requried

 rm live/ocp-install/openshift/99_openshift-cluster-api_master-machines-*.yaml 
 rm live/ocp-install/openshift/99_openshift-cluster-api_worker-machineset-*.yaml

 sleep 10

 # Creating ignition files.

 openshift-install create ignition-configs --dir live/ocp-install/

 # Moving the ignition files to http server path /var/www/html/ocp4

 cp -R live/ocp-install/* /var/www/html/ocp4
 echo $JB_PASSWORD | sudo -S chown -R ubuntu:ubuntu /var/www/html/ocp4/

 # Placing the kubeconfig file at default path

 cp live/ocp-install/auth/kubeconfig /home/ubuntu/.kube/config
 echo $JB_PASSWORD | sudo -S chown -R ubuntu:ubuntu /home/ubuntu/.kube/config
}


#################### Main script starts here ######################


echo "Starting the configuration process..."

echo ""
echo ""

sleep 2

# Download ocp vm image

echo "Downloading the installation files and images..."
downloads_image $OCPVERSION

echo ""
echo ""

# Creating the customized install-config.yaml file

echo "Creating the ignition files for OCP cluster."

echo ""
echo ""

if [ -z live/install-config.yaml ]; then rm live/instal-config.yaml; fi
envsubst < template/install-config.yaml > live/install-config.yaml
echo "The install-config.yaml file created for the OCP cluster"

# Exporting IP addresses of OCP vm's as per the provided subnet

export ocpbootstrap_ip=`../helper/cidr-to-ip.sh $SUBNET_RANGE 0.50`
export ocp_cp1_ip=`../helper/cidr-to-ip.sh $SUBNET_RANGE 0.31`
export ocp_cp2_ip=`../helper/cidr-to-ip.sh $SUBNET_RANGE 0.32`
export ocp_cp3_ip=`../helper/cidr-to-ip.sh $SUBNET_RANGE 0.33`
export ocp_w1_ip=`../helper/cidr-to-ip.sh $SUBNET_RANGE 0.41`
export ocp_w2_ip=`../helper/cidr-to-ip.sh $SUBNET_RANGE 0.42`
export apache_server_ip=`ifconfig | grep -iw inet | grep -i broadcast | awk '{print $2}'`

# Creating json files which would be consumed by Packer tool to spin up the VM's.

if [ -z live/ocp-bootstrap.json ]; then rm live/ocp-bootstrap.json; fi
envsubst < "template/packer_vm_jsons/ocp-bootstrap.json" > "live/ocp-bootstrap.json"

if [ -z live/ocp-cp-1.json ]; then rm live/ocp-cp-1.json; fi
envsubst < "template/packer_vm_jsons/ocp-cp-1.json" > "live/ocp-cp-1.json"

if [ -z live/ocp-cp-2.json ]; then rm live/ocp-cp-2.json; fi
envsubst < "template/packer_vm_jsons/ocp-cp-2.json" > "live/ocp-cp-2.json"

if [ -z live/ocp-cp-3.json ]; then rm live/ocp-cp-3.json; fi
envsubst < "template/packer_vm_jsons/ocp-cp-3.json" > "live/ocp-cp-3.json"

if [ -z live/ocp-w-1.json ]; then rm live/ocp-w-1.json; fi
envsubst < "template/packer_vm_jsons/ocp-w-1.json" > "live/ocp-w-1.json"

# Creating ignition_files and moving them to the file server directory /var/www/html/ocp4

custom_install_config

set +a
