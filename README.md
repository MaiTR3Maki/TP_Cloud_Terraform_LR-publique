# TP_Cloud_Terraform_LR

TP réalisé sous Linux Ubuntu 22.04 LTS

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


Version de azure et terraform utilisé pour le tp
<p>
    <img src="/document/Image/version-terraform.png" alt="il doit y avoir une image ici :)" width="500"/>
  </a>
</p>


voici l'architecuture du dossier de travail pour le tp terraform
<p align="center">
    <img src="/document/Image/Tree_terraform.png" alt="il doit y avoir une image ici :)" width="500"/>
  </a>
</p>


le providers.tf permet a terraform comment de se connecter a azure grâce à l'id de l'abonnement
<p align="center">
    <img src="/document/Image/1_providers_conf.png" alt="il doit y avoir une image ici :)" width="500"/>
  </a>
</p>

## Partie 1 — Structure du projet et configuration du provider (10 pts)
Premiére initialisation de terraform :
creation du fichier .terraform.lock.hcl qui contient les providers utilisés et leurs versions

<p align="center">
    <img src="/document/Image/2_init_terraform.png" alt="il doit y avoir une image ici :)" width="500"/>
  </a>
</p>

## Partie 2 — Réseau : Resource Group, VNET et Subnet (15 pts)

terraform plan : permet de voir les actions qui seront effectuées par terraform avant de les appliquer
ont peut voir qu'il a creer le :
ressource-group
sous réseaux
virtual network
<p align="center">
    <img src="/document/Image/3_Terraform_plan.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>

<p align="center">
    <img src="/document/Image/4_Terraform_plan.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>


## Partie 3 — Sécurité : Network Security Group et règles firewall (15 pts)

mise en place des groupes de sécurité 

ssh
j'ai remplacer le addresse prexies * par mon adresse ip pour plus de sécurité

<p align="center">
Erreur : "*"
</p>
<p align="center">
    <img src="/document/Image/5_sécurity_plan.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>

<p align="center">
Bonne pratique : "addresse ip perso"
</p>
<p align="center">
    <img src="/document/Image/changement_*_par_ip_perso.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>


<p align="center">
tcp 
</p>
<p align="center">
    <img src="/document/Image/6_sécurity_plan.png.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>

<p align="center">
deny all
</p>
<p align="center">
    <img src="/document/Image/7_sécurity_plan.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>

<p>
    <img src="/document/Image/8_sécurity_plan.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>

## Partie 4 — Machines virtuelles (25 pts)

Creation de machine virtuelle :

- taille de la machine virtuelle : Standard_B1s pour une consommation minimale
- resource_group_name : tp-limayrac-rg

<p>
    <img src="/document/Image/9_VM_creer.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>


après la création de la machine virtuelle, j'ai mis en place un script d'init pour installer nginx et afficher une page web simple

  ```
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    
    # Création d'une page HTML moderne
    cat <<HTML > /var/www/html/index.html
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>TP Cloud - Lucas RAUZY</title>
        <style>
            body {
                font-family: 'Segoe UI', sans-serif;
                background: linear-gradient(135deg, #0078d4 0%, #00188f 100%);
                color: white;
                height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                margin: 0;
            }
            .glass-card {
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(15px);
                -webkit-backdrop-filter: blur(15px);
                border: 1px solid rgba(255, 255, 255, 0.2);
                padding: 40px;
                border-radius: 25px;
                box-shadow: 0 10px 40px rgba(0,0,0,0.3);
                text-align: center;
                animation: fadeIn 1s ease-in;
            }
            h1 { font-weight: 300; margin-bottom: 10px; }
            .badge {
                background: #00c2ff;
                padding: 6px 16px;
                border-radius: 50px;
                font-size: 0.8rem;
                font-weight: bold;
                letter-spacing: 1px;
            }
            .vm-id { color: #00c2ff; font-size: 2.5rem; margin: 20px 0; }
            @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        </style>
    </head>
    <body>
        <div class="glass-card">
            <div class="badge">INFRASTRUCTURE TERRAFORM</div>
            <h1>Bienvenue</h1>
            <p>Requête traitée dynamiquement par :</p>
            <div class="vm-id">${var.prefix}-vm-${each.key}</div>
            <p style="opacity: 0.7;">Statut : Serveur Opérationnel 🟢</p>
        </div>
    </body>
    </html>
    HTML

    # Nettoyage de la page par défaut d'Azure/Nginx
    rm -f /var/www/html/index.nginx-debian.html
    systemctl restart nginx
  EOF
  )
  ```


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
<p>
    <img src="/document/Image/Page_presentation_vm1.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>

- VM2
<p>
    <img src="/document/Image/page presentation_vm2.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>



## Bonus/correction :  

j'ai remplacer count par foreach :

<p>
    <img src="/document/Image/replace_count_foreach.png" alt="il doit y avoir une image ici :)" width="750"/>
  </a>
</p>