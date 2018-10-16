resource "oci_core_instance" "mongodb" {
  display_name        = "mongodb"
  compartment_id      = "${var.tenancy_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0],"name")}"
  shape               = "${var.mongodb["shape"]}"
  subnet_id           = "${oci_core_subnet.subnet.id}"
  source_details {
    source_id = "${var.images[var.region]}"
  	source_type = "image"
  }
  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(format("%s\n%s\n",
      "#!/usr/bin/env bash",
      file("../scripts/mongodb.sh")
    ))}"
  }
  count = "${var.mongodb["node_count"]}"
}

data "oci_core_vnic_attachments" "mongodb_vnic_attachments" {
  compartment_id      = "${var.tenancy_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0],"name")}"
  instance_id         = "${oci_core_instance.mongodb.*.id[0]}"
}

data "oci_core_vnic" "mongodb_vnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.mongodb_vnic_attachments.vnic_attachments[0],"vnic_id")}"
}

output "MongoDB Connection String" { value = "mongodb://username:password@${data.oci_core_vnic.mongodb_vnic.public_ip_address}:27017/" }
output "Ops Manager URL" { value = "http://${data.oci_core_vnic.mongodb_vnic.public_ip_address}:8080/" }
