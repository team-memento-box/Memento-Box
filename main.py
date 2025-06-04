from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import RedirectResponse, HTMLResponse
from pydantic import BaseModel
import requests
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

KAKAO_CLIENT_ID = os.getenv("KAKAO_CLIENT_ID")
KAKAO_REDIRECT_URI = os.getenv("KAKAO_REDIRECT_URI")


@app.get("/")
async def root():
    kakao_auth_url = (
        "https://kauth.kakao.com/oauth/authorize"
        f"?client_id={KAKAO_CLIENT_ID}"
        f"&redirect_uri={KAKAO_REDIRECT_URI}"
        "&response_type=code"
    )
    html = f'''
        <h1>🔐 FastAPI 카카오 로그인 테스트</h1>
        <a href="{kakao_auth_url}">➡ 카카오 로그인</a><br><br>
        <a href="/logout">⛔ 카카오 로그아웃 (카카오 세션까지)</a>
    '''
    return HTMLResponse(content=html)


@app.get("/oauth")
async def oauth_callback(request: Request):
    code = request.query_params.get("code")

    # 1. 인가 코드로 토큰 요청
    token_url = "https://kauth.kakao.com/oauth/token"
    token_data = {
        "grant_type": "authorization_code",
        "client_id": KAKAO_CLIENT_ID,
        "redirect_uri": KAKAO_REDIRECT_URI,
        "code": code,
    }

    token_res = requests.post(token_url, data=token_data)
    token_json = token_res.json()
    access_token = token_json.get("access_token")

    if not access_token:
        return {"error": "Access token not received", "detail": token_json}

    # 2. 액세스 토큰으로 사용자 정보 요청
    user_url = "https://kapi.kakao.com/v2/user/me"
    headers = {"Authorization": f"Bearer {access_token}"}
    user_res = requests.get(user_url, headers=headers)
    user_info = user_res.json()

    return {
        "access_token": access_token,
        "user_info": user_info
    }


# ✅ 서버 로그아웃용 엔드포인트
class LogoutRequest(BaseModel):
    access_token: str

@app.post("/logout-server")
async def logout_server(req: LogoutRequest):
    kakao_logout_url = "https://kapi.kakao.com/v1/user/logout"
    headers = {
        "Authorization": f"Bearer {req.access_token}"
    }
    response = requests.post(kakao_logout_url, headers=headers)

    if response.status_code == 200:
        return {
            "message": "카카오 로그아웃 성공",
            "response": response.json()
        }
    else:
        raise HTTPException(status_code=response.status_code, detail=response.json())


# ✅ 카카오 인증 서버 세션 로그아웃 (자동 로그인 막기용)
@app.get("/logout")
async def kakao_logout_redirect():
    kakao_logout_url = (
        "https://kauth.kakao.com/oauth/logout"
        f"?client_id={KAKAO_CLIENT_ID}"
        f"&logout_redirect_uri=http://localhost:8000/"
    )
    return RedirectResponse(url=kakao_logout_url)
