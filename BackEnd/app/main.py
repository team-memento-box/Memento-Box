from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import RedirectResponse, HTMLResponse
from pydantic import BaseModel
import requests
import os
from dotenv import load_dotenv
from fastapi.staticfiles import StaticFiles
from app.database import AsyncSessionLocal
#from BackEnd.app.models.olduser import User
from sqlalchemy.future import select
from app.models.user import User
load_dotenv()
app = FastAPI()

KAKAO_CLIENT_ID = os.getenv("KAKAO_CLIENT_ID")
KAKAO_REDIRECT_URI = os.getenv("KAKAO_REDIRECT_URI")  # 예: http://20.75.82.5/oauth

# ✅ 카카오 인증 시작 (클릭 시 이동)
@app.get("/oauth/kakao_start")
async def kakao_start():
    kakao_auth_url = (
        f"https://kauth.kakao.com/oauth/authorize"
        f"?client_id={KAKAO_CLIENT_ID}"
        f"&redirect_uri={KAKAO_REDIRECT_URI}"  # http://20.75.82.5/api/oauth
        f"&response_type=code"
    )
    return RedirectResponse(kakao_auth_url)

# ✅ 인가 코드 콜백 처리
@app.get("/oauth")  # 여기는 그대로 /oauth (Nginx에서 /api/ 붙여서 전달하므로)
async def oauth_callback(request: Request):
    code = request.query_params.get("code")
    if not code:
        return HTMLResponse("<h3>❌ 인가 코드가 없습니다.</h3>", status_code=400)

    token_url = "https://kauth.kakao.com/oauth/token"
    token_data = {
        "grant_type": "authorization_code",
        "client_id": KAKAO_CLIENT_ID,
        "redirect_uri": KAKAO_REDIRECT_URI,  # http://20.75.82.5/api/oauth
        "code": code,
    }
    token_res = requests.post(token_url, data=token_data)
    token_json = token_res.json()
    access_token = token_json.get("access_token")

    if not access_token:
        return HTMLResponse(f"<h3>❌ 액세스 토큰 발급 실패</h3><pre>{token_json}</pre>")

    user_url = "https://kapi.kakao.com/v2/user/me"
    headers = {"Authorization": f"Bearer {access_token}"}
    user_res = requests.get(user_url, headers=headers)
    user_info = user_res.json()

    kakao_id = str(user_info["id"])
    username = user_info["kakao_account"].get("name", "")
    email = user_info["kakao_account"].get("email", "")
    profile_img = user_info["kakao_account"]["profile"].get("profile_image_url", "")

    # 3. DB 저장
    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User).where(User.kakao_id == kakao_id))
        existing_user = result.scalar_one_or_none()

        if not existing_user:
            new_user = User(
                kakao_id=kakao_id,
                username=username,
                email=email,
                profile_img=profile_img
            )
            session.add(new_user)
            await session.commit()

    # 4. Flutter의 /#/intro 화면으로 자동 이동
    return HTMLResponse("""
    <html>
      <head>
        <meta charset="utf-8" />
        <script>
        
        
          setTimeout(() => {
            window.location.href = "http://20.75.82.5/#/intro";
          }, 100);  // 약간의 딜레이를 줘야 브라우저가 이전 해시를 덮어씀
          
          
          
        </script>
      </head>
      <body>
        <p>잠시만 기다려주세요...</p>
      </body>
    </html>
    """)
