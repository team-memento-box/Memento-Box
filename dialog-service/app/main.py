from fastapi import FastAPI, Request
from openai_client import ask_openai

app = FastAPI()

@app.post("/chat")
async def chat_endpoint(request: Request):
    data = await request.json()
    messages = data.get("messages", [])
    response = await ask_openai(messages)
    return {"response": response}
