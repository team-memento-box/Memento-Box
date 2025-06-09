from fastapi import FastAPI, Request, Body
from fastapi.responses import JSONResponse
import requests
from dotenv import load_dotenv
from db.database import async_session
from sqlalchemy.future import select
from db.models.user import User
from sqlalchemy.exc import IntegrityError
from db.models.family import Family
from uuid import uuid4
from datetime import datetime
import random, string

load_dotenv()
app = FastAPI()

@app.post("/kakao_login")
async def kakao_login(request: Request):
    data = await request.json()
    access_token = data.get("access_token")
    if not access_token:
        return JSONResponse({"error": "No access token"}, status_code=400)

    user_url = "https://kapi.kakao.com/v2/user/me"
    headers = {"Authorization": f"Bearer {access_token}"}
    user_res = requests.get(user_url, headers=headers)
    user_info = user_res.json()
    
    kakao_id = str(user_info["id"])
    username = user_info["kakao_account"].get("name", "")
    profile_img = user_info["kakao_account"]["profile"].get("profile_image_url", "")
    gender = user_info["kakao_account"].get("gender", "")
    birthday = user_info["kakao_account"].get("birthday", "")
    email = user_info["kakao_account"].get("email", "")
    phone_number = user_info["kakao_account"].get("phone_number", "")

    async with async_session() as session:
        result = await session.execute(select(User).where(User.kakao_id == kakao_id))
        existing_user = result.scalar_one_or_none()
        
        if existing_user:
            # 이미 가입된 사용자인 경우, 모든 정보 반환
            return JSONResponse(
                content={
                    "kakao_id": existing_user.kakao_id,
                    "username": existing_user.username,
                    "profile_img": existing_user.profile_img,
                    "gender": existing_user.gender,
                    "birthday": existing_user.birthday,
                    "email": existing_user.email,
                    "phone_number": existing_user.phone_number,
                    "family_id": str(existing_user.family_id) if existing_user.family_id else None,
                    "family_code": existing_user.family_code,
                    "family_name": existing_user.family_name,
                    "family_role": existing_user.family_role,
                    "created_at": existing_user.created_at.isoformat() if existing_user.created_at else None,
                    "is_guardian": bool(existing_user.is_guardian) if existing_user.is_guardian is not None else None,
                    "is_registered": True
                },
                media_type="application/json; charset=utf-8"
            )
        else:
            # 새로운 사용자인 경우, 카카오에서 받은 정보만 반환
            return JSONResponse(
                content={
                    "kakao_id": kakao_id,
                    "username": username,
                    "profile_img": profile_img,
                    "gender": gender,
                    "birthday": birthday,
                    "email": email,
                    "phone_number": phone_number,
                    "is_registered": False  # 새로운 사용자임을 표시
                },
                media_type="application/json; charset=utf-8"
            )

@app.post("/create_family")
async def create_family(data: dict = Body(...)):
    family_name = data.get("family_name")
    if not family_name:
        return JSONResponse({"error": "No family_name provided"}, status_code=400)
        
    def generate_family_code():
        return 'DA' + ''.join(random.choices(string.digits, k=6))
        
    family_code = generate_family_code()
    new_family = Family(
        id=uuid4(),
        family_code=family_code,
        family_name=family_name,
        created_at=datetime.utcnow()
    )
    
    async with async_session() as session:
        session.add(new_family)
        await session.commit()
        return {
            "family_id": str(new_family.id), 
            "family_code": new_family.family_code,
            "family_name": new_family.family_name
        }

@app.post("/join_family")
async def join_family(data: dict = Body(...)):
    family_code = data.get("family_code")
    if not family_code:
        return JSONResponse({"error": "No family_code provided"}, status_code=400)
    async with async_session() as session:
        result = await session.execute(select(Family).where(Family.family_code == family_code))
        family = result.scalar_one_or_none()
        if not family:
            return JSONResponse({"error": "Invalid family_code"}, status_code=404)
        return {
            "family_id": str(family.id), 
            "family_code": family.family_code,
            "family_name": family.family_name  # 그룹명도 반환
        }

@app.post("/register_user")
async def register_user(user_data: dict = Body(...)):
    kakao_id = user_data.get("kakao_id")
    if not kakao_id:
        return JSONResponse({"error": "No kakao_id provided"}, status_code=400)
    async with async_session() as session:
        result = await session.execute(select(User).where(User.kakao_id == kakao_id))
        user = result.scalar_one_or_none()
        if user:
            user.username = user_data.get("username", user.username)
            user.profile_img = user_data.get("profile_img", user.profile_img)
            user.gender = user_data.get("gender", user.gender)
            user.birthday = user_data.get("birthday", user.birthday)
            user.email = user_data.get("email", user.email)
            user.phone_number = user_data.get("phone_number", user.phone_number)
            user.family_id = user_data.get("family_id", user.family_id)
            user.family_code = user_data.get("family_code", user.family_code)  # family_code도 저장
            user.family_name = user_data.get("family_name", user.family_name)  # family_name도 저장
            user.family_role = user_data.get("family_role", user.family_role)
            user.created_at = user_data.get("created_at", user.created_at)
            user.is_guardian = user_data.get("is_guardian", user.is_guardian)
        else:
            new_user = User(
                kakao_id=user_data.get("kakao_id"),
                username=user_data.get("username"),
                profile_img=user_data.get("profile_img"),
                gender=user_data.get("gender"),
                birthday=user_data.get("birthday"),
                email=user_data.get("email"),
                phone_number=user_data.get("phone_number"),
                family_id=user_data.get("family_id"),
                family_code=user_data.get("family_code"),  # family_code도 저장
                family_name=user_data.get("family_name"),  # family_name도 저장
                family_role=user_data.get("family_role"),
                created_at=user_data.get("created_at"),
                is_guardian=user_data.get("is_guardian")
            )
            session.add(new_user)
        try:
            await session.commit()
        except IntegrityError:
            await session.rollback()
            return JSONResponse({"error": "DB integrity error"}, status_code=500)
    return {"message": "User saved"}