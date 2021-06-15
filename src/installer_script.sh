#!/usr/bin/env bash

#set -x
set -Eeuo pipefail

set -a
source ../config/config.ini

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] -p param_value arg1 [arg2...]

Installing Openshift Container Platform

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
EOF
  exit
}

# Calling configuration script.

bash $script_dir/configuration.sh

# Creation of OCP vm instances.

declare -a ocp_vm_list
export GOVC_URL="$USERNAME:$PASSWORD@$VCENTERHOSTNAME"

# Customized list of VM instances
oc_vm_list=(ocp-bootstrap ocp-cp-1 ocp-cp-2 ocp-cp-3 ocp-w-1)

echo "Started creating VM instances for OCP cluster"
echo "----------------------------------------------------"

echo ""

echo "Creating the vm instances for OCP:"

echo ""

for instance in `echo -e ${oc_vm_list[@]}`
do
	echo Creating $instance instance
	x=`packer build live/${instance}.json || true`
	if [[ "$x" =~ .*"vsphere-iso: ocp-".* ]]
		then
		govc vm.power -on $instance &
		echo "VM $instance created"
	else
		sleep 1
		govc vm.destroy $instance &
		while [[ "$x" =~ .*"no artifacts were created".* ]]
		do 
			govc vm.destroy $instance &
			sleep 30
			x=`packer build vm_json_dir/${instance}.json || true`
		done
		sleep 1
		govc vm.power -on $instance &
		echo "VM $instance created"
	fi
	echo ""
	echo ""
done

echo "OCP VM instance creation complete"

echo ""
echo ""

echo "Waiting for all controlplane and worker nodes to come up"

echo ""
echo ""

export KUBECONFIG=~/.kube/config

workercheck=`kubectl get nodes`
while [[ "$workercheck" != *"ocp-w"* ]]
do
	sleep 60
	workercheck=`kubectl get nodes || true`
	oc get csr -o name | xargs oc adm certificate approve || true
	oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve || true
done

echo "OCP cluster created successfully"


# Running a command to destroy the bootstrap machine after 100 secs sleep 

sleep 100 && govc vm.destroy ocp-bootstrap

echo ""
echo ""

echo "You can now access the OCP cluster."

echo ""
echo ""

set +a

exit 0
