"""Fix relationship with backref between Family and Photo

Revision ID: 798cf5b92723
Revises: a40d970462b2
Create Date: 2025-06-01 11:51:26.745284

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql # 홍원 추가

# revision identifiers, used by Alembic.
revision: str = '798cf5b92723'
down_revision: Union[str, None] = 'a40d970462b2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    # 외래 키 추가
    op.add_column('photos', sa.Column('family_id', postgresql.UUID(), nullable=True))
    op.create_foreign_key(
        'fk_photos_family_id',  # 외래 키 이름
        'photos',  # 테이블 이름
        'families',  # 참조할 테이블 이름
        ['family_id'],  # 외래 키가 참조할 컬럼
        ['id']  # 참조 대상 컬럼
    )

def downgrade():
    # 외래 키 제거
    op.drop_constraint('fk_photos_family_id', 'photos', type_='foreignkey')
    op.drop_column('photos', 'family_id')