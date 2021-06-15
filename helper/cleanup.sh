#!/bin/bash


set -a
source ../config/config.ini

export GOVC_URL="$USERNAME:$PASSWORD@$VCENTERHOSTNAME"

govc vm.destroy ocp-bootstrap
govc vm.destroy ocp-cp-1
govc vm.destroy ocp-cp-2
govc vm.destroy ocp-cp-3
govc vm.destroy ocp-w-1

