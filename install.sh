#!/bin/bash

echo "Please enter your password if requested."

pkgs="qemu-kvm guestfs-tools libvirt-daemon-qemu virt-manager"

for pkg in $pkgs; do
	rpm --quiet --query $pkg || sudo zypper in --no-confirm --auto-agree-with-licenses $pkg
done

sudo systemctl start libvirtd  && sudo systemctl enable libvirtd

sudo virsh pool-define-as --target /var/lib/libvirt/images/ --name default --type dir
sudo virsh pool-autostart default
sudo virsh pool-start default

cat <<EOT >> /tmp/microCaaSP.xml
<network connections='2'>
  <name>microCaaSP-network</name>
  <uuid>e1bc32f9-06db-4e44-98e9-080bbf49fecc</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr99' stp='on' delay='0'/>
  <mac address='52:54:00:23:54:18'/>
  <domain name='caasp.local'/>
  <dns enable='yes'/>
  <ip family='ipv4' address='10.17.0.1' prefix='22'>
    <dhcp>
      <range start='10.17.0.2' end='10.17.3.254'/>
      <host mac='52:54:00:52:71:d9' name='microCaaSP-lb' ip='10.17.1.0'/>
      <host mac='52:54:00:fa:b8:38' name='microCaaSP-master' ip='10.17.2.0'/>
      <host mac='52:54:00:82:d1:0f' name='microCaaSP-worker' ip='10.17.3.0'/>
    </dhcp>
  </ip>
</network>
EOT

virsh net-define /tmp/microCaaSP.xml
virsh net-start microCaaSP-network

rm  /tmp/microCaaSP.xml


virt-install --connect qemu:///system --virt-type kvm --name microCaaSP-lb --ram 1024 --vcpus=1 --os-type linux --os-variant sle15 --disk path=microCaaSP-lb.qcow2,format=qcow2 --import --network network=microCaaSP-network,mac=52:54:00:52:71:d9  --noautoconsole


virt-install --connect qemu:///system --virt-type kvm --name microCaaSP-master --ram 2048 --vcpus=2 --os-type linux --os-variant sle15 --disk path=microCaaSP-master.qcow2,format=qcow2 --import --network network=microCaaSP-network,mac=52:54:00:fa:b8:38 --noautoconsole


virt-install --connect qemu:///system --virt-type kvm --name microCaaSP-worker --ram 2048 --vcpus=2 --os-type linux --os-variant sle15 --disk path=microCaaSP-worker.qcow2,format=qcow2 --import --network network=microCaaSP-network,mac=52:54:00:82:d1:0f --noautoconsole



# insert/update hosts entry
ip_address="10.17.2.0"
host_name="microcaasp-dashboard.com microcaasp-kubebox.com microcaasp-stratos.com"
# find existing instances in the host file and save the line numbers
matches_in_hosts=$(grep -n "$host_name" /etc/hosts)
host_entry="${ip_address} ${host_name}"


if [ -z "$matches_in_hosts" ]; then
    echo "Adding new hosts entry."
    echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null
fi

cat << EOF
You need to wait ~ 5 min until all nodes and k8s containers are active
Usages:
  kubebox: http://microcaasp-kubebox.com:32080
           To run kubectl, go to default namespace, choose sles15, and click "r"

  kubernetes dashboard: https://microcaasp-dashboard.com:32443
           To check dashboard token, run "kubectl describe secrets -n kube-system  $(kubectl get secret -n kube-system| awk '/dashboard-admin/{print $1}')" in sles15 from kubebox above 

  stratos: https://microcaasp-stratos.com:32443
           To login, username admin, password: admin123

EOF
