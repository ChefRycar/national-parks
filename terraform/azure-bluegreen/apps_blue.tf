# Create web app-1-blue instance
resource "azurerm_virtual_machine" "app-1-blue" {
  depends_on                    = ["azurerm_virtual_machine.mongodb-1"]
  name                          = "${var.tag_application}-app-1-blue"
  location                      = "${var.azure_region}"
  resource_group_name           = "${azurerm_resource_group.rg.name}"
  network_interface_ids         = ["${azurerm_network_interface.nic.4.id}"]
  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_application}-app-1-blue-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.tag_application}-app-1-blue-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.tag_application}-app-1-blue"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "habitat" {
    peer         = "${azurerm_public_ip.pip.0.ip_address}"
    use_sudo     = true
    service_type = "systemd"

    service {
      binds    = ["database:np-mongodb.${var.group}"]
      name     = "${var.habitat_origin}/national-parks"
      topology = "standalone"
      group    = "blue"
      channel  = "blue"
      strategy = "at-once"
    }

    connection {
      host     = "${azurerm_public_ip.pip.4.ip_address}"
      user     = "${var.azure_image_user}"
      password = "${var.azure_image_password}"
    }
  }

  tags {
    X-Name        = "${var.tag_application}-${var.habitat_origin}-app-1-blue"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}


# Create web app-2-blue instance
resource "azurerm_virtual_machine" "app-2-blue" {
  depends_on                    = ["azurerm_virtual_machine.mongodb-1"]
  name                          = "${var.tag_application}-app-2-blue"
  location                      = "${var.azure_region}"
  resource_group_name           = "${azurerm_resource_group.rg.name}"
  network_interface_ids         = ["${azurerm_network_interface.nic.5.id}"]
  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_application}-app-2-blue-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.tag_application}-app-2-blue-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.tag_application}-app-2-blue"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "habitat" {
    peer         = "${azurerm_public_ip.pip.0.ip_address}"
    use_sudo     = true
    service_type = "systemd"

    service {
      binds    = ["database:np-mongodb.${var.group}"]
      name     = "${var.habitat_origin}/national-parks"
      topology = "standalone"
      group    = "blue"
      channel  = "blue"
      strategy = "at-once"
    }

    connection {
      host     = "${azurerm_public_ip.pip.5.ip_address}"
      user     = "${var.azure_image_user}"
      password = "${var.azure_image_password}"
    }
  }

  tags {
    X-Name        = "${var.tag_application}-${var.habitat_origin}-app-2-blue"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "azurerm_virtual_machine" "lb-blue" {
  depends_on                    = ["azurerm_virtual_machine.app-1-blue"]
  name                          = "${var.tag_application}-lb-blue"
  location                      = "${var.azure_region}"
  resource_group_name           = "${azurerm_resource_group.rg.name}"
  network_interface_ids         = ["${azurerm_network_interface.nic.6.id}"]
  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_application}-lb-blue-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.tag_application}-lb-blue-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.tag_application}-lb-blue"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "habitat" {
    peer         = "${azurerm_public_ip.pip.0.ip_address}"
    use_sudo     = true
    service_type = "systemd"

    service {
      binds    = ["backend:national-parks.blue"]
      name     = "${var.habitat_origin}/haproxy"
      topology = "standalone"
      group    = "${var.group}"
      channel  = "stable"
      strategy = "${var.update_strategy}"
      user_toml = "${file("files/haproxy.toml")}"
    }

    connection {
      host     = "${azurerm_public_ip.pip.6.ip_address}"
      user     = "${var.azure_image_user}"
      password = "${var.azure_image_password}"
    }
  }

  tags {
    X-Name        = "${var.tag_application}-${var.habitat_origin}-lb-blue"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}