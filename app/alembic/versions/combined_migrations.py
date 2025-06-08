"""Combined migrations for all tables

Revision ID: combined_migrations
Revises: 
Create Date: 2024-03-20 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from datetime import datetime

# revision identifiers, used by Alembic.
revision: str = 'combined_migrations'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade database schema."""
    # Drop existing sequence if exists
    op.execute('DROP SEQUENCE IF EXISTS photos_id_seq CASCADE')
    
    # Create sequence for photos.id
    op.execute('CREATE SEQUENCE photos_id_seq START 1')
    
    # Create families table
    op.create_table(
        'families',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('family_code', sa.String(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
    )
    
    # Create photos table with proper sequence
    op.create_table(
        'photos',
        sa.Column('id', sa.Integer(), sa.Sequence('photos_id_seq'), primary_key=True),
        sa.Column('title', sa.String(), nullable=True),
        sa.Column('description', sa.String(), nullable=True),
        sa.Column('image_url', sa.String(), nullable=False),
        sa.Column('image_path', sa.String(), nullable=True),
        sa.Column('story_year', sa.String(), nullable=True),
        sa.Column('story_season', sa.String(), nullable=True),
        sa.Column('story_nudge', postgresql.JSON(), nullable=True),
        sa.Column('analysis', postgresql.JSON(), nullable=True),
        sa.Column('summary_text', sa.Text(), nullable=True),
        sa.Column('summary_voice', sa.Text(), nullable=True),
        sa.Column('family_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('families.id'), nullable=False),
        sa.Column('uploaded_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
    )
    
    # Create conversations table
    op.create_table(
        'conversations',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('photo_id', sa.Integer(), sa.ForeignKey('photos.id'), nullable=False),
        sa.Column('message', sa.Text(), nullable=False),
        sa.Column('response', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
    )
    
    # Create indexes
    op.create_index('ix_photos_family_id', 'photos', ['family_id'])
    op.create_index('ix_conversations_photo_id', 'conversations', ['photo_id'])

    # Create users table
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('kakao_id', sa.String(), nullable=True),
        sa.Column('username', sa.String(), nullable=True),
        sa.Column('gender', sa.String(), nullable=True),
        sa.Column('birthday', sa.DateTime(), nullable=True),
        sa.Column('profile_img', sa.Text(), nullable=True),
        sa.Column('family_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('family_role', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['family_id'], ['families.id']),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_users_kakao_id', 'users', ['kakao_id'], unique=False)

    # Create anomalies_reports table
    op.create_table(
        'anomalies_reports',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('conv_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('event_report', sa.Text(), nullable=True),
        sa.Column('event_interval', sa.String(), nullable=True),
        sa.ForeignKeyConstraint(['conv_id'], ['conversations.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # Create mentions table
    op.create_table(
        'mentions',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('conv_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('question_answer', sa.JSON(), nullable=True),
        sa.Column('recorded_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['conv_id'], ['conversations.id']),
        sa.PrimaryKeyConstraint('id')
    )


def downgrade() -> None:
    """Downgrade database schema."""
    # Drop indexes
    op.drop_index('ix_conversations_photo_id')
    op.drop_index('ix_photos_family_id')
    
    # Drop tables
    op.drop_table('mentions')
    op.drop_table('anomalies_reports')
    op.drop_table('conversations')
    op.drop_index('ix_users_kakao_id', table_name='users')
    op.drop_table('users')
    op.drop_table('photos')
    op.drop_table('families')
    
    # Drop sequence
    op.execute('DROP SEQUENCE IF EXISTS photos_id_seq') 