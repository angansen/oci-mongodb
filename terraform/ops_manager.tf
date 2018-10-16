resource "oci_core_instance" "ops_manager" {
  display_name        = "ops_manager"
  compartment_id      = "${var.tenancy_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0],"name")}"
  shape               = "VM.Standard1.2"
  subnet_id           = "${oci_core_subnet.subnet.id}"
  source_details {
    source_id = "${var.images[var.region]}"
  	source_type = "image"
  }
  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(format("%s\n%s\n",
      "#!/usr/bin/env bash",
      file("../scripts/ops_manager.sh")
    ))}"
  }
}

data "oci_core_vnic_attachments" "ops_manager_vnic_attachments" {
  compartment_id      = "${var.tenancy_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0],"name")}"
  instance_id         = "${oci_core_instance.ops_manager.id}"
}

data "oci_core_vnic" "ops_manager_vnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.ops_manager_vnic_attachments.vnic_attachments[0],"vnic_id")}"
}

output "Ops Manager URL" { value = "http://${data.oci_core_vnic.ops_manager_vnic.public_ip_address}:8080/" }
