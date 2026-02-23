# TP_Cloud_Terraform_LR

# 1. Installer l'Azure CLI
Linux : 
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

Se connecter 
Bash

    az login

Ouvrez votre terminal local et tapez :
Bash

    az login


Installer Terraform : https://developer.hashicorp.com/terraform/downloads


le providers.tf permet a terraform comment de se connecter a azure grâce à l'id de l'abonnement


<p align="center">
    <img src="/document/Image/1_providers_conf.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>

## Partie 1 — Structure du projet et configuration du provider (10 pts)
Premiére initialisation de terraform :
creation du fichier .terraform.lock.hcl qui contient les providers utilisés et leurs versions

<p align="center">
    <img src="/document/Image/2_init_terraform.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>

## Partie 2 — Réseau : Resource Group, VNET et Subnet (15 pts)

terraform plan : permet de voir les actions qui seront effectuées par terraform avant de les appliquer
ont peut voir qu'il a creer le :
ressource-group
sous réseaux
virtual network
<p align="center">
    <img src="/document/Image/3_Terraform_plan.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>

<p align="center">
    <img src="/document/Image/4_Terraform_plan.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>


## Partie 3 — Sécurité : Network Security Group et règles firewall (15 pts)

mise en place des groupes de sécurité 

ssh
j'ai remplacer le addresse prexies * par mon adresse ip pour plus de sécurité

"*"
<p align="center">
    <img src="/document/Image/5_sécurity_plan.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>

"addresse ip perso"
<p align="center">
    <img src="/document/Image/changement_*_par_ip_perso.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>


tcp 
<p align="center">
    <img src="/document/Image/6_sécurity_plan.png.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>

deny all
<p align="center">
    <img src="/document/Image/7_sécurity_plan.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>

<p align="center">
    <img src="/document/Image/8_sécurity_plan.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>

## Partie 4 — Machines virtuelles (25 pts)

creation de machine virtuelle :

- taille de la machine virtuelle : Standard_B1s pour une consommation minimale
- resource_group_name : tp-limayrac-rg

<p align="center">
    <img src="/document/Image/9_VM_creer.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>


après la création de la machine virtuelle, j'ai mis en place un script d'init pour installer nginx et afficher une page web simple

  #!/bin/bash
  apt-get update
  apt-get install -y nginx
  echo "<h1>Hello from VM-X</h1>" > /var/www/html/index.html
  systemctl start nginx
  systemctl enable nginx


## Partie 5 — Load Balancer (25 pts)

modifier le main pour créer un load balancer et ajouter les machines virtuelles au backend pool

output.tf : permet d'afficher des informations après l'execution de terraform apply


Validation : 
  terraform validate

Planification :
  terraform plan

Application : 
  terraform apply

Page de présentation du load balancer 

- VM1
<p align="center">
    <img src="/document/Image/Page_presentation_vm1.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>

- VM2
<p align="center">
    <img src="/document/Image/page presentation_vm2.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>



## Bonus/correction :  

j'ai remplacer count par foreach :

<p align="center">
    <img src="/document/Image/replace_count_foreach.png" alt="il doit y avoir une image ici :)" width="250"/>
  </a>
</p>