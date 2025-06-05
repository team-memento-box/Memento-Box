from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
import os
from pathlib import Path

# 데이터베이스와 API 라우터 임포트
from database import create_tables
from api.routes import router as api_router
from config import Config

# FastAPI 앱 생성
app = FastAPI(
    title="치매 진단 대화 시스템 API",
    description="이미지 기반 치매 진단을 위한 대화형 AI 시스템",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 운영에서는 특정 도메인으로 제한
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 필요한 디렉토리 생성
def create_directories():
    """필요한 디렉토리들을 생성"""
    directories = [
        Config.UPLOAD_DIR,
        Config.AUDIO_DIR
    ]
    
    for directory in directories:
        Path(directory).mkdir(exist_ok=True)

# 앱 시작 시 초기화
@app.on_event("startup")
async def startup_event():
    create_directories()
    create_tables()  # 데이터베이스 테이블 생성
    print("🚀 치매 진단 대화 시스템 API 서버가 시작되었습니다.")
    print("📋 API 문서: http://localhost:8000/docs")

# API 라우터 등록
app.include_router(api_router)

# 정적 파일 서빙
app.mount("/uploads", StaticFiles(directory=Config.UPLOAD_DIR), name="uploads")
app.mount("/audio", StaticFiles(directory=Config.AUDIO_DIR), name="audio")

# 메인 페이지
@app.get("/", response_class=HTMLResponse)
async def read_root():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>치매 진단 대화 시스템</title>
        <meta charset="utf-8">
        <style>
            body { 
                font-family: 'Segoe UI', Arial, sans-serif; 
                max-width: 1200px; 
                margin: 0 auto; 
                padding: 20px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .container {
                background: white;
                padding: 40px;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            }
            h1 { 
                color: #2c3e50; 
                text-align: center; 
                margin-bottom: 30px;
                font-size: 2.5em;
            }
            h2 { 
                color: #34495e; 
                border-bottom: 3px solid #3498db; 
                padding-bottom: 10px; 
                margin-top: 40px;
            }
            .endpoint-group {
                margin: 30px 0;
            }
            .endpoint { 
                background: #f8f9fa; 
                padding: 20px; 
                margin: 15px 0; 
                border-radius: 8px;
                border-left: 5px solid #3498db;
                transition: all 0.3s ease;
            }
            .endpoint:hover {
                transform: translateX(5px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }
            .method { 
                font-weight: bold; 
                color: white; 
                padding: 6px 12px; 
                border-radius: 5px; 
                margin-right: 15px;
                font-size: 0.9em;
            }
            .post { background: linear-gradient(135deg, #27ae60, #2ecc71); }
            .get { background: linear-gradient(135deg, #3498db, #5dade2); }
            .description { 
                margin-top: 12px; 
                color: #5a6c7d; 
                font-style: italic;
                line-height: 1.5;
            }
            .links { 
                text-align: center; 
                margin: 40px 0; 
                padding: 20px;
                background: #ecf0f1;
                border-radius: 10px;
            }
            .links a { 
                display: inline-block; 
                margin: 10px 15px; 
                padding: 12px 25px; 
                background: linear-gradient(135deg, #3498db, #2980b9); 
                color: white; 
                text-decoration: none; 
                border-radius: 25px;
                transition: all 0.3s ease;
                font-weight: 500;
            }
            .links a:hover { 
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
            }
            .feature-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 20px;
                margin: 30px 0;
            }
            .feature-card {
                background: #f8f9fa;
                padding: 25px;
                border-radius: 10px;
                border-top: 4px solid #e74c3c;
            }
            .feature-card h3 {
                color: #2c3e50;
                margin-bottom: 15px;
            }
            .api-flow {
                background: #fff;
                border: 2px solid #3498db;
                border-radius: 10px;
                padding: 20px;
                margin: 20px 0;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🧠 치매 진단 대화 시스템 API</h1>
            
            <div class="api-flow">
                <h3>🔄 API 사용 플로우</h3>
                <ol>
                    <li><strong>사진 업로드:</strong> POST /photos/upload</li>
                    <li><strong>첫 질문 생성:</strong> POST /questions/initial</li>
                    <li><strong>TTS 변환:</strong> POST /tts</li>
                    <li><strong>음성 응답:</strong> POST /stt</li>
                    <li><strong>추가 질문:</strong> POST /questions/followup</li>
                    <li><strong>대화 저장:</strong> POST /conversations/save</li>
                    <li><strong>스토리 생성:</strong> POST /stories</li>
                    <li><strong>이상 징후 분석:</strong> POST /reports/anomalies</li>
                </ol>
            </div>
            
            <h2>📋 사용 가능한 API 엔드포인트</h2>
            
            <div class="endpoint-group">
                <h3>📸 사진 관리</h3>
                <div class="endpoint">
                    <span class="method get">GET</span><strong>/api/v1/photos</strong>
                    <div class="description">가족의 업로드된 전체 사진 목록 조회</div>
                </div>
                <div class="endpoint">
                    <span class="method post">POST</span><strong>/api/v1/photos/upload</strong>
                    <div class="description">사진과 메타데이터 업로드</div>
                </div>
                <div class="endpoint">
                    <span class="method get">GET</span><strong>/api/v1/photos/{photoId}</strong>
                    <div class="description">특정 사진 정보 조회</div>
                </div>
            </div>
            
            <div class="endpoint-group">
                <h3>❓ 질문 생성</h3>
                <div class="endpoint">
                    <span class="method post">POST</span><strong>/api/v1/questions/initial</strong>
                    <div class="description">이미지 기반 첫 질문 생성</div>
                </div>
                <div class="endpoint">
                    <span class="method post">POST</span><strong>/api/v1/questions/followup</strong>
                    <div class="description">대화 기반 추가 질문 생성</div>
                </div>
            </div>
            
            <div class="endpoint-group">
                <h3>🎤 음성 처리</h3>
                <div class="endpoint">
                    <span class="method post">POST</span><strong>/api/v1/tts</strong>
                    <div class="description">텍스트를 음성으로 변환</div>
                </div>
                <div class="endpoint">
                    <span class="method post">POST</span><strong>/api/v1/stt</strong>
                    <div class="description">음성을 텍스트로 변환</div>
                </div>
                <div class="endpoint">
                    <span class="method post">POST</span><strong>/api/v1/answers/audio</strong>
                    <div class="description">음성 분석 및 이상 징후 탐지</div>
                </div>
            </div>
            
            <div class="endpoint-group">
                <h3>💬 대화 관리</h3>
                <div class="endpoint">
                    <span class="method post">POST</span><strong>/api/v1/conversations/save</strong>
                    <div class="description">대화 내용 저장</div>
                </div>
                <div class="endpoint">
                    <span class="method get">GET</span><strong>/api/v1/conversations/{mentionId}</strong>
                    <div class="description">대화 내역 조회</div>
                </div>
            </div>
            
            <div class="endpoint-group">
                <h3>📖 스토리 & 분석</h3>
                <div class="endpoint">
                    <span class="method post">POST</span><strong>/api/v1/stories</strong>
                    <div class="description">회상 스토리 생성</div>
                </div>
                <div class="endpoint">
                    <span class="method get">GET</span><strong>/api/v1/stories/{mentionId}</strong>
                    <div class="description">회상 스토리 조회</div>
                </div>
                <div class="endpoint">
                    <span class="method post">POST</span><strong>/api/v1/reports/anomalies</strong>
                    <div class="description">이상 징후 리포트 생성</div>
                </div>
                <div class="endpoint">
                    <span class="method get">GET</span><strong>/api/v1/reports/anomalies/{mentionId}</strong>
                    <div class="description">이상 징후 리포트 조회</div>
                </div>
            </div>
            
            <div class="feature-grid">
                <div class="feature-card">
                    <h3>🖼️ 이미지 분석</h3>
                    <p>GPT-4V를 사용한 사진 내용 분석과 맞춤형 질문 생성</p>
                </div>
                <div class="feature-card">
                    <h3>🎯 개인화 대화</h3>
                    <p>사진과 메타데이터를 기반으로 한 개인화된 회상 치료</p>
                </div>
                <div class="feature-card">
                    <h3>🔍 이상 징후 탐지</h3>
                    <p>대화와 음성 분석을 통한 인지 기능 이상 징후 조기 발견</p>
                </div>
                <div class="feature-card">
                    <h3>📚 자동 스토리 생성</h3>
                    <p>대화 내용을 바탕으로 한 감성적인 회상 스토리 자동 생성</p>
                </div>
            </div>
            
            <div class="links">
                <a href="/docs" target="_blank">📖 API 문서 (Swagger)</a>
                <a href="/redoc" target="_blank">📚 API 문서 (ReDoc)</a>
            </div>
        </div>
    </body>
    </html>
    """

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app", 
        host="0.0.0.0", 
        port=8000, 
        reload=True,
        log_level="info"
    )