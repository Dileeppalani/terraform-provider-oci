// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

variable "availability_domain" {
  default = 3
}

resource "oci_core_virtual_network" "vcn1" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "TFExampleVCN"
  dns_label      = "tfexamplevcn"
}

// A regional subnet will not specify an Availability Domain
resource "oci_core_subnet" "subnet1" {
  cidr_block        = "10.0.1.0/24"
  display_name      = "TFRegionalSubnet"
  dns_label         = "regionalsubnet"
  compartment_id    = "${var.compartment_ocid}"
  vcn_id            = "${oci_core_virtual_network.vcn1.id}"
  security_list_ids = ["${oci_core_virtual_network.vcn1.default_security_list_id}"]
  route_table_id    = "${oci_core_virtual_network.vcn1.default_route_table_id}"
  dhcp_options_id   = "${oci_core_virtual_network.vcn1.default_dhcp_options_id}"
}

// An AD based subnet will supply an Availability Domain
resource "oci_core_subnet" "subnet2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
  cidr_block          = "10.0.2.0/24"
  display_name        = "TFADSubnet"
  dns_label           = "adsubnet"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.vcn1.id}"
  security_list_ids   = ["${oci_core_virtual_network.vcn1.default_security_list_id}"]
  route_table_id      = "${oci_core_virtual_network.vcn1.default_route_table_id}"
  dhcp_options_id     = "${oci_core_virtual_network.vcn1.default_dhcp_options_id}"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}
