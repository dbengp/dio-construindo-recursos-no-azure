# dio-construindo-recursos-no-azure
projeto de demonstração de criação de recursos no azure.

## Visão Geral dos Recursos Azure Provisionados
- O arquivo Terraform provisiona uma infraestrutura fundamental no Azure, organizando e conectando diversos componentes essenciais. Veja o que cada um representa:

### 1. Grupo de Recursos (Resource Group)
- É um contêiner lógico que agrupa recursos relacionados para fins de gerenciamento, monitoramento e faturamento. Pense nele como uma pasta que organiza todos os seus serviços para um projeto específico no Azure.

### 2. Rede Virtual (Virtual Network - VNet)
- Funciona como sua rede privada isolada na nuvem. Ela permite que os recursos do Azure, como máquinas virtuais, se comuniquem entre si de forma segura, bem como com a internet e redes locais, como se estivessem em um data center físico.

### 3. Sub-rede (Subnet)
- É uma segmentação da sua Rede Virtual (VNet). As sub-redes permitem que você organize e isole os recursos dentro da sua VNet, definindo faixas de endereços IP específicas para diferentes tipos de serviços ou aplicações.

### 4. Conta de Armazenamento (Storage Account)
- É um serviço de armazenamento escalável para dados diversos. Uma Storage Account pode guardar blobs (objetos como arquivos de vídeo, imagens), filas de mensagens, tabelas NoSQL e compartilhamentos de arquivos, sendo a base para muitos cenários de persistência de dados.

### 5. Interfaces de Rede (Network Interfaces - NICs)
- São os "adaptadores de rede" virtuais para suas máquinas virtuais. Cada VM precisa de uma NIC para se conectar à VNet e, consequentemente, à internet ou a outros recursos de rede. É a porta de entrada e saída de tráfego da sua VM.

### 6. Máquinas Virtuais (Virtual Machines - VMs)
- São servidores virtuais que rodam na nuvem, análogos a computadores físicos. Elas fornecem o poder computacional necessário para suas aplicações, com sistemas operacionais (Windows ou Linux), memória, processador e armazenamento configuráveis.

## Com o terraform instalado no host:
### Inicialize o Terraform: Abra o terminal no diretório /terraform que contém o arquivo main.tf e execute:
- `terraform init`
### Planeje a implantação: Visualize o que o Terraform fará sem realmente criar os recursos:
- `terraform plan`
### Aplique a configuração: Para criar os recursos no Azure:
- `terraform apply` 
