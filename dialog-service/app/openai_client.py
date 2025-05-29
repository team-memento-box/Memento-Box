import os
import httpx
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("AZURE_OPENAI_KEY")
ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT")
DEPLOYMENT = os.getenv("AZURE_OPENAI_DEPLOYMENT")

async def ask_openai(messages):
    headers = {
        "api-key": API_KEY,
        "Content-Type": "application/json",
    }
    body = {
        "messages": messages,
        "max_tokens": 512,
        "temperature": 0.7,
        "top_p": 0.9,
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{ENDPOINT}/openai/deployments/{DEPLOYMENT}/chat/completions?api-version=2023-05-15",
            headers=headers,
            json=body
        )
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]
