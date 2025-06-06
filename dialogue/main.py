from fastapi import FastAPI, HTTPException
import openai
import os
from typing import Optional

app = FastAPI()

# Azure OpenAI 설정
openai.api_type = "azure"
openai.api_version = os.getenv("AZURE_OPENAI_API_VERSION", "2023-05-15")
openai.api_base = os.getenv("AZURE_OPENAI_ENDPOINT")
openai.api_key = os.getenv("AZURE_OPENAI_API_KEY")
deployment_name = os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME", "gpt-4")

# 설정 검증
missing_vars = []
if not openai.api_base:
    missing_vars.append("AZURE_OPENAI_ENDPOINT")
if not openai.api_key:
    missing_vars.append("AZURE_OPENAI_API_KEY")

if missing_vars:
    raise ValueError(f"Azure OpenAI credentials are not properly configured. Missing environment variables: {', '.join(missing_vars)}")

@app.post("/chat")
async def chat(message: str):
    if not message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty")
        
    try:
        response = openai.ChatCompletion.create(
            engine=deployment_name,
            messages=[
                {"role": "system", "content": "You are a helpful assistant for elderly people."},
                {"role": "user", "content": message}
            ],
            temperature=0.7,
            max_tokens=150
        )
        return {"response": response.choices[0].message.content}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Azure OpenAI Error: {str(e)}")

@app.get("/status")
async def get_status():
    return {
        "status": "healthy",
        "azure_openai": {
            "configured": True,
            "endpoint": openai.api_base,
            "api_version": openai.api_version,
            "deployment": deployment_name
        }
    } 