# Heckweek2020

### Purpose

Since this whole purpose is easy to deploy Kubernetes, people can easily taste CaaSP. So hopefully microCaaSP makes a connection to paid CaaSP. So this can be used as CaaSP marketing purpose or Kubernetes educational purpose.

Target Platform: KVM

Education and marketing
    One VM, One kubernetes master node, terminal web UI.
    For web terminal, there is one such tool called xterm.js and very well applied example of xterm is in jupyter notebook named termiado. 
    After a user run one command. users can access Web terminal, which pre-configured kubectl with kubeconfig.



The baked images are microCaaSP-lb.qcow2,  microCaaSP-master.qcow2, and microCaaSP-worker.qcow2. Each imagerepectively corresponds with loadbalancer, master, and worker nodes. The master node and worker node already have pre-installed kubernetes cluster with k8s dashboard, kubebox, and stratos.

After you run `./install.sh`, you need to wait ~ 5 min until all nodes and k8s containers are active.

How to check k8s are active:
    If you can access http://microcaasp-kubebox.com:32080, k8s cluster is ready to explore.

How to deploy apps:
    If you access sles15 in default namespace from http://microcaasp-kubebox.com:32080, click "r". Then you will have k8s terminal with active kubectl. Try to run "kubectl get pod -A". If you are done using the terminal, type "exit".   

Three apps are pre-installed for user can explore microCaaSP.
These are all web-based apps.


Usages:
  kubebox: http://microcaasp-kubebox.com:32080
           To run kubectl, go to default namespace, choose sles15, and click "r"

  kubernetes dashboard: https://microcaasp-dashboard.com:32443
           To check dashboard token, run "kubectl describe secrets -n kube-system  $(kubectl get secret -n kube-system| awk '/dashboard-admin/{print $1}')" in sles15 from kubebox above 

  stratos: https://microcaasp-stratos.com:32443
           To login, username admin, password: admin123



I could not upload microCaaSP-lb.qcow2, microCaaSP-master.qcow2, microCaaSP-worker.qcow2 because those sizes are big.  Current sizes are:

661M microCaaSP-lb.qcow2
root  4.7G microCaaSP-master.qcow2
9.6G microCaaSP-worker.qcow2

Considerations:
1. Combine LB node with master node.
2. reducing the qcow2 sizes and upload to internet so that install.sh will downlaod qcow2 and install.
3. it can be too heavy. So think about removing k8s dashboard and stratos.


