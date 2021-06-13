.PHONY: up down clean status config login provision \
	kubespray_repo_init kubespray_tag kubespray_venv_init \
	kubespray_get_ip kubespray_init_inventory

_VM=time vagrant

# Vagrant
clean:
	$(call venv_exec,.venv,$(_VM) destroy)
	rm -rf .vagrant

config:
	$(call venv_exec,.venv,$(_VM) validate)

down:
	$(call venv_exec,.venv,$(_VM) suspend)

login:
	$(call venv_exec,.venv,$(_VM) ssh)

provision:
	$(call venv_exec,.venv,$(_VM) provision)

status:
	$(call venv_exec,.venv,$(_VM) status)
	
up:
	$(call venv_exec,.venv,$(_VM) up)

venv_init:
	$(call venv_exec,.venv,pip install -r requirements.txt)
	$(call venv_exec,.venv,pip install --upgrade pip)

### KUBESPRAY ###
include kubespray.env
kubespray_repo_init:
	$(call submodule_exec,kubespray,update --init --recursive,$(_KUBESPRAY_GIT))

kubespray_tag:
	$(call submodule_git,kubespray,checkout $(_KUBESPRAY_TAG),$(_KUBESPRAY_GIT))

kubespray_venv_init:
	$(call venv_exec,.venv,pip install -r $(_KUBESPRAY_DIR)/contrib/inventory_builder/test-requirements.txt)
	$(call venv_exec,.venv,pip install -r $(_KUBESPRAY_DIR)/requirements.txt)

kubespray_get_ip:
	$(_KUBESPRAY_SSH_CFG)
	$(eval TMP = $(shell $(_VAGRANT_REGEX_IP)))
	@echo $(TMP) > .ip

kubespray_init_inventory:
	$(eval TMP = ($(shell $(_VAGRANT_REGEX_IP))))
	cd $(_KUBESPRAY_INVENTORY_SRC) && cp -r sample cluster
ifneq ($(wildcard $(_KUBESPRAY_DIR)),"")
	$(call venv_exec,.venv, \
		cd $(_KUBESPRAY_DIR) && \
		declare -a IPS=$(TMP) && \
		CONFIG_FILE=$(_KUBESPRAY_CONFIG) python3 $(_KUBESPRAY_BUILDER_SCRIPT) $${IPS[@]} \
	)
	rsync -a -v $(_KUBESPRAY_INVENTORY_SRC)/cluster inventory/
else
	@echo "$(_KUBESPRAY_DIR) exist"
	@ls -l $(_KUBESPRAY_DIR)
endif
	#  ansible-playbook -i inventory/cluster/hosts.yaml  submodules/kubespray/cluster.yml -vv -b
	
# VENV FUNCTIONS
define venv_exec
	$(if [ ! -f "$($(1)/bin/activate)" ], python3 -m venv $(1))
	( \
    	source $(1)/bin/activate; \
    	$(2) \
	)
endef

define submodule_exec
	@if [ ! -d "submodules/$(1)" ]; then git submodule add $(3) submodules/$(1); fi
	( \
    	git submodule $(2) \
	)
endef

define submodule_git
	@if [ ! -d "submodules/$(1)" ]; then git submodule add $(3) submodules/$(1); fi
	( \
    	cd submodules/$(1) && git $(2) \
	)
endef