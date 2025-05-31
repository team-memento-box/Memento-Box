"""Add conversation model

Revision ID: 23070993a7e4
Revises: 74a6a60cac78
Create Date: 2025-05-31 08:53:58.363870

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = '23070993a7e4'
down_revision: Union[str, None] = '74a6a60cac78'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    # 1. conversations 테이블 생성
    op.create_table(
        'conversations',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('photo_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('photos.id')),
        sa.Column('created_at', sa.DateTime),
        mysql_charset='utf8mb4',
        mysql_collate='utf8mb4_general_ci'
    )

    # 2. mentions 테이블 컬럼 변경 (photo_id → conv_id)
    op.add_column('mentions', sa.Column('conv_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('conversations.id')))
    op.drop_column('mentions', 'photo_id')

    # 3. anomalies_reports 테이블 컬럼 변경 (mention_id → conv_id) 및 event_report 추가
    op.add_column('anomalies_reports', sa.Column('conv_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('conversations.id')))
    op.add_column('anomalies_reports', sa.Column('event_report', sa.Text(), nullable=True))
    op.drop_column('anomalies_reports', 'mention_id')

def downgrade():
    # 되돌리기 - mentions 테이블
    op.add_column('mentions', sa.Column('photo_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('photos.id')))
    op.drop_column('mentions', 'conv_id')

    # 되돌리기 - anomalies_reports 테이블
    op.add_column('anomalies_reports', sa.Column('mention_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('mentions.id')))
    op.drop_column('anomalies_reports', 'conv_id')
    op.drop_column('anomalies_reports', 'event_report')

    # 되돌리기 - conversations 테이블 제거
    op.drop_table('conversations')