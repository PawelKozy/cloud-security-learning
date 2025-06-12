# 🔧 Azure CLI Example: User with Scoped Role Assignment to Storage

This example shows how to:
- Create an Azure AD user
- Create a resource group and a Storage Account
- Assign a custom role to the user with access to the storage account
- Scope the access to specific resources

---

## 📦 Resources Created

- Azure AD user (with password)
- Resource group
- Storage account
- Custom role definition (optional)
- Role assignment to the user scoped to the storage account

---

## ⚙️ Azure CLI Commands

```bash
# Variables
USER_NAME="example-user"
USER_PASSWORD="StrongP@ssw0rd1234!"
RESOURCE_GROUP="example-rg"
STORAGE_ACCOUNT="examplestorage$RANDOM"
LOCATION="eastus"

# 1. Create a resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# 2. Create a Storage Account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

# 3. Create a new Azure AD user
az ad user create \
  --display-name $USER_NAME \
  --user-principal-name "$USER_NAME@$(az account show --query user.name -o tsv)" \
  --password $USER_PASSWORD \
  --force-change-password-next-login false

# 4. Assign built-in role (e.g., Storage Blob Data Reader)
STORAGE_ID=$(az storage account show \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

USER_ID=$(az ad user show --id "$USER_NAME@$(az account show --query user.name -o tsv)" --query objectId -o tsv)

az role assignment create \
  --assignee-object-id $USER_ID \
  --assignee-principal-type User \
  --role "Storage Blob Data Reader" \
  --scope $STORAGE_ID
