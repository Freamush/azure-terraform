# Secure Landing Zone on Azure (Terraform)

Hub-and-spoke landing zone in Azure, built with Terraform, deployed through
GitHub Actions (OIDC, no stored credentials) and monitored with Azure Monitor.

<img width="1405" height="1203" alt="azurediagram" src="https://github.com/user-attachments/assets/6cc912fc-f9a5-4f5b-b339-0c75ad4171b0" />

## Architecture
- **Hub**: Azure Firewall, Bastion.
- **Spoke 1**: app subnet with a Linux VM (SSH key only, access via Bastion)
- **Spoke 2**: storage account reachable only through a private endpoint (PE)
- **Routing**: UDRs force spoke traffic through the firewall; only HTTPS
  spoke1 -> spoke2 and a short FQDN allow-list for egress are permitted
- **DNS**: one private DNS zone (`privatelink.blob.core.windows.net`) linked to all three VNets
- **Storage security**: public network access disabled, shared keys disabled,
  access via Entra ID and the VM's managed identity (RBAC)
- **Governance**: deny resources without `env`/`project`/`owner`
  tags, deny public IPs on NICs

## The view from Resource visualizer

<img width="1280" height="955" alt="image" src="https://github.com/user-attachments/assets/7374a218-674c-48d6-b2b0-c89d98c04cde" />


  ## CI/CD
- Pull request: `fmt`, `validate`, `tflint`, `checkov`, `plan` (summary in the run)
- Apply: manual, behind an approval environment
- Authentication: GitHub OIDC -> Entra app registration with a federated credential
- State: remote backend in a separate resource group stored in Blob container

## Monitoring
- **Log Analytics workspace**: 30-day retention, 1 GB daily cap to control cost
- **Diagnostic settings**: Firewall (network rule, application rule, DNS, threat intel)
  in resource-specific tables; blob service (read/write/delete)
- **Alert**: more than 3 firewall `Deny` events from one source IP within
  15 minutes (evaluated every 5 minutes, severity 2)
- Email of the recipient is passed as a sensitive variable from a GitHub secret
  (nothing hardcoded in a public repo)
  <img width="1280" height="716" alt="image" src="https://github.com/user-attachments/assets/8ae7c8c1-a0d0-4da1-8c3a-d7d45d276aa3" />

## Example of Blob creation using identity bassed access to the Storage in Private Endpoint.

<img width="1280" height="416" alt="image" src="https://github.com/user-attachments/assets/227ab486-dc7c-4fa6-b3d0-bacba4700328" />

<img width="1280" height="466" alt="image" src="https://github.com/user-attachments/assets/ad68be6c-9727-4b25-8599-57878dae02a0" />

## Compliance
All resources comply with the custom policies defined in this project

<img width="1234" height="72" alt="image" src="https://github.com/user-attachments/assets/b5f0a07a-0fef-4d3d-afe9-a2d05f140d0b" />

## Diagnostic settings of the Firewall
<img width="1181" height="733" alt="image" src="https://github.com/user-attachments/assets/0d70e537-0d26-4d7f-9d30-24b70abd318d" />

## Diagnostic settings of the Storage
<img width="1257" height="831" alt="image" src="https://github.com/user-attachments/assets/b6d4d3c2-a1ba-40a5-85d6-2979364ec779" />

## Alert example
<img width="933" height="797" alt="image" src="https://github.com/user-attachments/assets/007e2b81-b0fe-489f-a0c4-0b969a6d6baa" />

## Website Howest.be (that is not in allowed FQDNs is being blocked by firewall)
<img width="1280" height="191" alt="image" src="https://github.com/user-attachments/assets/68d200fd-9917-43f7-a663-6db110c3ed9e" />
