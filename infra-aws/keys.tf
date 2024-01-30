resource "tls_private_key" "ec2" {
    algorithm = "RSA"
    rsa_bits = 2048
}

data "azurerm_key_vault" "shared" {
  name                = "sharedsw0ho"
  resource_group_name = "shared"
}
resource "azurerm_key_vault_secret" "ec2_private" {
  name = "private-key-aws-${terraform.workspace}"
  value = tls_private_key.ec2.private_key_pem
  key_vault_id = data.azurerm_key_vault.shared.id
}

resource "azurerm_key_vault_secret" "ec2_public" {
    name = "public-key-aws-${terraform.workspace}"
    value = tls_private_key.ec2.public_key_openssh
     key_vault_id = data.azurerm_key_vault.shared.id
}
resource "local_file" "private_key" {
    content = tls_private_key.ec2.private_key_pem
    filename = "${path.module}/integration.pem"
    file_permission = "0600"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.ec2.public_key_openssh
}