"""photo & family keys errors

Revision ID: 3fc56a19f537
Revises: 798cf5b92723
Create Date: 2025-06-01 11:55:30.422018

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql  # 여기서 postgresql을 임포트해야 합니다.


# revision identifiers, used by Alembic.
revision: str = '3fc56a19f537'
down_revision: Union[str, None] = '798cf5b92723'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    # 외래 키 제약 추가
    op.create_foreign_key(
        'fk_photos_family_id',  # 외래 키 이름
        'photos',  # 테이블 이름
        'families',  # 참조할 테이블 이름
        ['family_id'],  # 외래 키 컬럼
        ['id']  # 참조 대상 컬럼
    )

def downgrade():
    # 외래 키 제거
    op.drop_constraint('fk_photos_family_id', 'photos', type_='foreignkey')
