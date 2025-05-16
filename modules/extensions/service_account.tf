# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  sa_with_cluster_role_bindings = {
    for k, v in var.service_accounts : k => v
    if lookup(v, "sa_cluster_role_binding", null) != null
  }
  sa_with_role_bindings = {
    for k, v in var.service_accounts : k => v
    if lookup(v, "sa_role_binding", null) != null
  }
}

resource "null_resource" "service_account_crb" {
  for_each = var.create_service_account ? local.sa_with_cluster_role_bindings : {}

  triggers = {
    service_account_name                 = each.value.sa_name
    service_account_namespace            = each.value.sa_namespace
    service_account_cluster_role         = each.value.sa_cluster_role
    service_account_cluster_role_binding = each.value.sa_cluster_role_binding

    # Parameters ignored as triggers in the life_cycle block. Required to establish connections.
    bastion_host    = var.bastion_host
    bastion_user    = var.bastion_user
    ssh_private_key = var.ssh_private_key
    operator_host   = var.operator_host
    operator_user   = var.operator_user
  }

  connection {
    bastion_host        = self.triggers.bastion_host
    bastion_user        = self.triggers.bastion_user
    bastion_private_key = self.triggers.ssh_private_key
    host                = self.triggers.operator_host
    user                = self.triggers.operator_user
    private_key         = self.triggers.ssh_private_key
    timeout             = "10m"
    type                = "ssh"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get ns ${self.triggers.service_account_namespace} || kubectl create ns ${self.triggers.service_account_namespace}",
      "kubectl create sa -n ${self.triggers.service_account_namespace} ${self.triggers.service_account_name}",
      "kubectl create clusterrolebinding ${self.triggers.service_account_cluster_role_binding} --clusterrole=${self.triggers.service_account_cluster_role} --serviceaccount=${self.triggers.service_account_namespace}:${self.triggers.service_account_name}"
    ]
  }

  provisioner "remote-exec" {
    when       = destroy
    on_failure = continue
    inline = [
      "kubectl delete clusterrolebinding ${self.triggers.service_account_cluster_role_binding}",
      "kubectl delete sa -n ${self.triggers.service_account_namespace} ${self.triggers.service_account_name}"
    ]
  }

  lifecycle {
    ignore_changes = [
      triggers["bastion_host"],
      triggers["bastion_user"],
      triggers["ssh_private_key"],
      triggers["operator_host"],
      triggers["operator_user"]
    ]
  }
}

resource "null_resource" "service_account_rb" {
  for_each = var.create_service_account ? local.sa_with_role_bindings : {}

  triggers = {
    service_account_name         = each.value.sa_name
    service_account_namespace    = each.value.sa_namespace
    service_account_cluster_role = each.value.sa_cluster_role
    service_account_role         = lookup(each.value, "sa_role", "")
    service_account_role_binding = each.value.sa_role_binding

    # Parameters ignored as triggers in the life_cycle block. Required to establish connections.
    bastion_host    = var.bastion_host
    bastion_user    = var.bastion_user
    ssh_private_key = var.ssh_private_key
    operator_host   = var.operator_host
    operator_user   = var.operator_user
  }

  connection {
    bastion_host        = self.triggers.bastion_host
    bastion_user        = self.triggers.bastion_user
    bastion_private_key = self.triggers.ssh_private_key
    host                = self.triggers.operator_host
    user                = self.triggers.operator_user
    private_key         = self.triggers.ssh_private_key
    timeout             = "10m"
    type                = "ssh"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get ns ${self.triggers.service_account_namespace} || kubectl create ns ${self.triggers.service_account_namespace}",
      "kubectl create sa -n ${self.triggers.service_account_namespace} ${self.triggers.service_account_name}",
      self.triggers.service_account_role != "" ?
      "kubectl create rolebinding -n ${self.triggers.service_account_namespace} ${self.triggers.service_account_role_binding} --role=${self.triggers.service_account_role} --serviceaccount=${self.triggers.service_account_namespace}:${self.triggers.service_account_name}" :
      "kubectl create rolebinding -n ${self.triggers.service_account_namespace} ${self.triggers.service_account_role_binding} --clusterrole=${self.triggers.service_account_cluster_role} --serviceaccount=${self.triggers.service_account_namespace}:${self.triggers.service_account_name}"
    ]
  }

  provisioner "remote-exec" {
    when       = destroy
    on_failure = continue
    inline = [
      "kubectl delete rolebinding -n ${self.triggers.service_account_namespace} ${self.triggers.service_account_role_binding}",
      "kubectl delete sa -n ${self.triggers.service_account_namespace} ${self.triggers.service_account_name}"
    ]
  }

  lifecycle {
    ignore_changes = [
      triggers["bastion_host"],
      triggers["bastion_user"],
      triggers["ssh_private_key"],
      triggers["operator_host"],
      triggers["operator_user"]
    ]
  }
}