# kubespray
[Kubespray](https://github.com/kubernetes-sigs/kubespray) deployment against an ESXI host

### Dependencies
| Label | Comment |
| - | - |
| [Ansible](https://docs.ansible.com/) | Configuration management automation tool|
| [ESXI (6.7u3)](https://my.vmware.com/en/group/vmware/evalcenter?p=free-esxi6) | Hypervisor |
| [Python](https://www.python.org/downloads/) | Programming language required to run ansible |
| [Vagrant](https://www.vagrantup.com/docs) | VM manager. Local dev/test environment |
| [Virtualenv](https://docs.python.org/3/tutorial/venv.html) | Python environment isolation |
|||

### Preflight Steps
1. Copy the [sample.env.yaml](./sample.env.yaml) to `env.yaml` and populate the following fields
    - host: # ESXI host
    - user: # esxi user id
    - password: # esxi password

2. Initialise kubespray as submodule.
    - Update the tag version `_KUBESPRAY_TAG` in [kubespray.env](./kubespray.env)
    - Execute `make submodule`. This initialises and updates [kubespray](https://github.com/kubernetes-sigs/kubespray) as a submodule

3. Deploy VM
    - Execute `make up` to deploy n VM's to the ESXI host
    - *NOTE:* Execute `vagrant status` to perform a healtcheck
    - Execute `vagrant ssh ${NODENAME}` to ssh into ${NODENAME}

4. Prepare Ansible inventory
    - Execute `make inventory`. This generates the inventory to be consumed by [kubespray](https://github.com/kubernetes-sigs/kubespray).
    - Update the inventory as needed. Default location is at ./inventory/cluster/hosts.yaml

4. Execute `make playbook` to run kubespray playbook `cluster.yml` against the nodes 
    - ![alt text](kubespray-7n.jpg "Kubespray 7 node cluster")

### ToDo
- Get kubeconfig from remote master node to user's workstation
- Create a make target that generates a script for sourcing the kubeconfig
- Add kubeconfig and source script to [.gitignore](./.gitignore)
- Update [README.md](./README.md) involving kubeconfig
- Create make targets involving an ansible playbook dry-run