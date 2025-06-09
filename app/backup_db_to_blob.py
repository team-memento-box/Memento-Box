'''
매일 새벽 2시 postgresql DB로 백업
crontab -e
0 2 * * * /usr/bin/python3 /home/azureuser/backup_postgres_to_blob.py >> /home/azureuser/pg_backup.log 2>&1
필요하시면 이 스크립트를 Dockerfile에 포함하거나, 자동화된 cron 등록 방법도 도와드릴게요.
# 도커파일 등록 필요
# 이 Python 스크립트는 **VM(호스트)**에서 실행해야 합니다.python ./app/backup_db_to_blob.py 
'''
import os
import subprocess
from datetime import datetime
from azure.storage.blob import BlobServiceClient
from dotenv import load_dotenv

load_dotenv(dotenv_path="./.env")

# 설정(postgresql & azure blob storage)
POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
POSTGRES_DB = os.getenv("POSTGRES_DB")
POSTGRES_CONTAINER = os.getenv("POSTGRES_CONTAINER")
CONTAINER_NAME = "rdbms-backup" #os.getenv("RDBMS_CONTAINER_NAME")로 가져올 시 오류생김
AZURE_BLOBSTORAGE_KEY = os.getenv("AZURE_BLOBSTORAGE_KEY")


# 환경 변수 누락 검사
required_vars = {
    "POSTGRES_USER": POSTGRES_USER,
    "POSTGRES_PASSWORD": POSTGRES_PASSWORD,
    "POSTGRES_DB": POSTGRES_DB,
    "CONTAINER_NAME": CONTAINER_NAME,
    "AZURE_BLOBSTORAGE_KEY": AZURE_BLOBSTORAGE_KEY
}

for var, val in required_vars.items():
    if not val:
        raise EnvironmentError(f"[ERROR] Required environment variable not set: {var}")


# 백업 파일 이름 및 경로 생성
timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
backup_filename = f"postgres_backup_{timestamp}.sql"
backup_path = f"/tmp/{backup_filename}"
archive_path = f"{backup_path}.tar.gz"


try:
    # 1. PostgreSQL 백업 (docker exec pg_dump)
    dump_cmd = [
        "docker", "exec", "-e", f"PGPASSWORD={POSTGRES_PASSWORD}",
        POSTGRES_CONTAINER,
        "pg_dump", "-U", POSTGRES_USER, POSTGRES_DB
    ]
    with open(backup_path, "w") as f:
        subprocess.run(dump_cmd, stdout=f, check=True)

    # 2. 백업 압축
    subprocess.run(["tar", "czf", archive_path, "-C", "/tmp", backup_filename], check=True)
    os.remove(backup_path)

    # 3. Azure Blob Storage 업로드
    blob_service = BlobServiceClient.from_connection_string(AZURE_BLOBSTORAGE_KEY)
    container_client = blob_service.get_container_client(CONTAINER_NAME)

    with open(archive_path, "rb") as data:
        container_client.upload_blob(name=os.path.basename(archive_path), data=data)

    print(f"[INFO] ✅ Backup uploaded: {os.path.basename(archive_path)}")

finally:
    # 4. 임시 파일 정리
    if os.path.exists(archive_path):
        os.remove(archive_path)

 

'''

window 로컬 환경 테스트 코드: 확인 완료

'''
# import os
# import subprocess
# from datetime import datetime
# from azure.storage.blob import BlobServiceClient
# from dotenv import load_dotenv
# import tempfile

# load_dotenv(dotenv_path="./.env")

# # 설정
# POSTGRES_USER = os.getenv("POSTGRES_USER")
# POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
# POSTGRES_DB = os.getenv("POSTGRES_DB")
# POSTGRES_CONTAINER = os.getenv("POSTGRES_CONTAINER")

# # Azure Storage 설정
# CONTAINER_NAME = "rdbms-backup"
# AZURE_BLOBSTORAGE_KEY = os.getenv("AZURE_BLOBSTORAGE_KEY")

# required_vars = {
#     "POSTGRES_USER": POSTGRES_USER,
#     "POSTGRES_PASSWORD": POSTGRES_PASSWORD,
#     "POSTGRES_DB": POSTGRES_DB,
#     "CONTAINER_NAME": CONTAINER_NAME,
#     "AZURE_BLOBSTORAGE_KEY": AZURE_BLOBSTORAGE_KEY
# }

# for var, val in required_vars.items():
#     if not val:
#         raise EnvironmentError(f"[ERROR] Required environment variable not set: {var}")

# # 경로 설정
# timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
# backup_filename = f"postgres_backup_{timestamp}.sql"
# tmp_dir = tempfile.gettempdir()
# backup_path = os.path.join(tmp_dir, backup_filename)
# archive_path = f"{backup_path}.tar.gz"

# try:
#     # PostgreSQL 백업
#     dump_cmd = [
#         "docker", "exec", "-e", f"PGPASSWORD={POSTGRES_PASSWORD}",
#         POSTGRES_CONTAINER,
#         "pg_dump", "-U", POSTGRES_USER, POSTGRES_DB
#     ]
#     with open(backup_path, "w") as f:
#         subprocess.run(dump_cmd, stdout=f, check=True)

#     # 압축 (Windows 호환 경로로 변경)
#     subprocess.run(["tar", "czf", archive_path, "-C", tmp_dir, backup_filename], check=True)
#     os.remove(backup_path)

#     # Azure 업로드
#     conn_str = AZURE_BLOBSTORAGE_KEY
#     blob_service = BlobServiceClient.from_connection_string(conn_str)
#     container_client = blob_service.get_container_client(CONTAINER_NAME)

#     with open(archive_path, "rb") as data:
#         container_client.upload_blob(name=os.path.basename(archive_path), data=data)

#     print(f"[INFO] ✅ Backup uploaded: {os.path.basename(archive_path)}")

# finally:
#     if os.path.exists(archive_path):
#         os.remove(archive_path)

