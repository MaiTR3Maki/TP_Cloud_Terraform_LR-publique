
# 1. Resource Group
resource "azurerm_resource_group" "tp" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = {
    environment = "tp"
    managed_by  = "terraform"
  }
}

# 2. Virtual Network (VNET)
resource "azurerm_virtual_network" "tp" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.tp.location
  resource_group_name = azurerm_resource_group.tp.name
  address_space       = ["10.0.0.0/16"]
}

# 3. Subnet
resource "azurerm_subnet" "tp" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.tp.name
  virtual_network_name = azurerm_virtual_network.tp.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Network Security Group (NSG) avec ses règles de filtrage
resource "azurerm_network_security_group" "tp" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.tp.location
  resource_group_name = azurerm_resource_group.tp.name

  # Règle SSH (Administration)
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "82.96.142.195/32"
    destination_address_prefix = "*"
  }

  # Règle HTTP (Web)
  security_rule {
    name                       = "allow-http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Règle de blocage par défaut (Sécurité renforcée)
  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 5. Association du NSG au Subnet
# Sans cette étape, le NSG existe mais ne protège rien !
resource "azurerm_subnet_network_security_group_association" "tp" {
  subnet_id                 = azurerm_subnet.tp.id
  network_security_group_id = azurerm_network_security_group.tp.id
}


# Interfaces Réseau pour VM 1 et VM 2
# On définit les identifiants de nos instances
locals {
  vm_names = ["1", "2"]
}

resource "azurerm_network_interface" "nic" {
  for_each            = toset(local.vm_names)
  name                = "${var.prefix}-nic-${each.key}"
  location            = azurerm_resource_group.tp.location
  resource_group_name = azurerm_resource_group.tp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tp.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = toset(local.vm_names)
  name                = "${var.prefix}-vm-${each.key}"
  resource_group_name = azurerm_resource_group.tp.name
  location            = azurerm_resource_group.tp.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    
    # Création d'une page HTML stylisée
    cat <<HTML > /var/www/html/index.html
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>TP Terraform Azure</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #0078d4, #00188f);
                color: white;
                height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                margin: 0;
            }
            .card {
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255, 255, 255, 0.2);
                padding: 3rem;
                border-radius: 20px;
                box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
                text-align: center;
                max-width: 400px;
            }
            h1 { margin-bottom: 0.5rem; font-weight: 300; }
            .vm-badge {
                background: #00c2ff;
                padding: 5px 15px;
                border-radius: 50px;
                font-weight: bold;
                font-size: 0.9rem;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            .status {
                margin-top: 20px;
                font-size: 0.8rem;
                opacity: 0.8;
            }
        </style>
    </head>
    <body>
        <div class="card">
            <div class="vm-badge">Propulsé par Terraform</div>
            <h1>Bienvenue</h1>
            <p>Le trafic est actuellement géré par :</p>
            <h2 style="color: #00c2ff;">${var.prefix}-vm-${each.key}</h2>
            <div class="status">Statut : Serveur en ligne 🟢</div>
        </div>
    </body>
    </html>
    HTML

    # On s'assure que Nginx utilise bien notre nouveau fichier
    rm -f /var/www/html/index.nginx-debian.html
    systemctl restart nginx
  EOF
  )
}
#5.1 — IP Publique pour le Load Balancer
resource "azurerm_public_ip" "lb_pip" {
  name                = "${var.prefix}-lb-pip"
  location            = azurerm_resource_group.tp.location
  resource_group_name = azurerm_resource_group.tp.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 5.2 — Le Load Balancer
resource "azurerm_lb" "tp" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.tp.location
  resource_group_name = azurerm_resource_group.tp.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

# 5.3 — Backend Address Pool
resource "azurerm_lb_backend_address_pool" "tp" {
  loadbalancer_id = azurerm_lb.tp.id
  name            = "${var.prefix}-backend-pool"
}

# 5.4 — Association des NICs au Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "tp" {
  for_each                = toset(local.vm_names)
  network_interface_id    = azurerm_network_interface.nic[each.key].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.tp.id
}

# 5.5 — Health Probe (Vérifie si Nginx répond sur le port 80)
resource "azurerm_lb_probe" "tp" {
  loadbalancer_id = azurerm_lb.tp.id
  name            = "${var.prefix}-http-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

# 5.6 — Load Balancing Rule (Relie le tout)
resource "azurerm_lb_rule" "tp" {
  loadbalancer_id                = azurerm_lb.tp.id
  name                           = "${var.prefix}-http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.tp.id]
  probe_id                       = azurerm_lb_probe.tp.id
}
