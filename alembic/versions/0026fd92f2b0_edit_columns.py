"""edit columns

Revision ID: 0026fd92f2b0
Revises: 23070993a7e4
Create Date: 2025-05-31 12:31:27.858975

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0026fd92f2b0'
down_revision: Union[str, None] = '23070993a7e4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 'speak_vector' 컬럼을 삭제
    op.drop_column('users', 'speak_vector')


def downgrade() -> None:
    # 'speak_vector' 컬럼을 복원 (예시로, 컬럼의 데이터 유형과 속성을 복원합니다)
    op.add_column('users', sa.Column('speak_vector', sa.JSON(), nullable=True))


