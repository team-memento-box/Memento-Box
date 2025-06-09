from sqlalchemy.ext.asyncio import AsyncSession
from db.models.user import User
from db.models.family import Family
from uuid import uuid4
from datetime import datetime

async def seed_data(db: AsyncSession):
    # 가족 데이터 생성
    family1 = Family(
        id=uuid4(),
        family_code="FAMILY001",
        family_name="김가족",
        created_at=datetime.utcnow()
    )
    
    family2 = Family(
        id=uuid4(),
        family_code="FAMILY002",
        family_name="이가족",
        created_at=datetime.utcnow()
    )
    
    db.add_all([family1, family2])
    await db.commit()
    
    # 사용자 데이터 생성
    users = [
        User(
            id=uuid4(),
            kakao_id="kakao_001",
            username="김할머니",
            gender="여",
            birthday="1940-01-01",
            profile_img="https://example.com/profile1.jpg",
            email="grandma@example.com",
            phone_number="010-1111-1111",
            family_id=family1.id,
            family_role="할머니",
            is_guardian=False,
            family_code=family1.family_code,
            family_name=family1.family_name
        ),
        User(
            id=uuid4(),
            kakao_id="kakao_002",
            username="김손자",
            gender="남",
            birthday="2010-01-01",
            profile_img="https://example.com/profile2.jpg",
            email="grandson@example.com",
            phone_number="010-2222-2222",
            family_id=family1.id,
            family_role="손자",
            is_guardian=False,
            family_code=family1.family_code,
            family_name=family1.family_name
        ),
        User(
            id=uuid4(),
            kakao_id="kakao_003",
            username="이할아버지",
            gender="남",
            birthday="1935-01-01",
            profile_img="https://example.com/profile3.jpg",
            email="grandpa@example.com",
            phone_number="010-3333-3333",
            family_id=family2.id,
            family_role="할아버지",
            is_guardian=False,
            family_code=family2.family_code,
            family_name=family2.family_name
        ),
        User(
            id=uuid4(),
            kakao_id="kakao_004",
            username="이손녀",
            gender="여",
            birthday="2012-01-01",
            profile_img="https://example.com/profile4.jpg",
            email="granddaughter@example.com",
            phone_number="010-4444-4444",
            family_id=family2.id,
            family_role="손녀",
            is_guardian=False,
            family_code=family2.family_code,
            family_name=family2.family_name
        )
    ]
    
    db.add_all(users)
    await db.commit() 