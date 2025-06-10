import os
from azure.storage.blob import BlobServiceClient
from datetime import datetime
from typing import Optional, Literal
from core.config import settings

ContainerType = Literal["photo", "voice", "summary-voice"]

class BlobStorageService:
    def __init__(self, container_type: ContainerType = "photo"):
        # 환경 변수에서 설정 가져오기
        self.account_name = os.getenv("AZURE_BLOBSTORAGE_ACCOUNT")
        self.account_key = os.getenv("AZURE_BLOBSTORAGE_KEY")
        
        # 컨테이너 타입에 따라 다른 컨테이너 이름 사용
        self.container_name = container_type
        
        # 연결 문자열 생성
        connection_string = f"DefaultEndpointsProtocol=https;AccountName={self.account_name};AccountKey={self.account_key};EndpointSuffix=core.windows.net"
        
        # Blob Service Client 생성
        self.blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        self.container_client = self.blob_service_client.get_container_client(self.container_name)

    async def upload_file(self, file_data: bytes, filename: str) -> tuple[str, str]:
        """
        파일을 Azure Blob Storage에 업로드하고 URL과 blob_name을 반환합니다.
        """
        # 타임스탬프를 포함한 고유한 파일명 생성
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        blob_name = f"{timestamp}_{filename}"
        
        # Blob 클라이언트 생성
        blob_client = self.container_client.get_blob_client(blob_name)
        
        # 파일 업로드
        blob_client.upload_blob(file_data, overwrite=True)
        
        # Blob URL 생성
        blob_url = blob_client.url
        
        return blob_url, blob_name

    async def delete_file(self, blob_name: str) -> bool:
        """
        Azure Blob Storage에서 파일을 삭제합니다.
        """
        try:
            blob_client = self.container_client.get_blob_client(blob_name)
            blob_client.delete_blob()
            return True
        except Exception as e:
            print(f"Error deleting blob: {str(e)}")
            return False

def get_blob_service_client(container_type: ContainerType = "photo") -> BlobStorageService:
    """
    BlobStorageService의 인스턴스를 생성하여 반환합니다.
    """
    return BlobStorageService(container_type) 