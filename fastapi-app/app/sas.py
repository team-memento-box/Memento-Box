import os
from azure.storage.blob import generate_blob_sas, BlobSasPermissions
from datetime import datetime, timedelta

def generate_sas_url(blob_name: str, container_name: str) -> str:
    account_name = os.getenv("AZURE_BLOBSTORAGE_ACCOUNT")
    account_key = os.getenv("AZURE_BLOBSTORAGE_KEY")
    sas_token = generate_blob_sas(
        account_name=account_name,
        container_name=container_name,
        blob_name=blob_name,
        account_key=account_key,
        permission=BlobSasPermissions(read=True),
        expiry=datetime.utcnow() + timedelta(hours=1)  # 1시간 유효
    )
    url = f"https://{account_name}.blob.core.windows.net/{container_name}/{blob_name}?{sas_token}"
    print('쉬발',url)
    return url