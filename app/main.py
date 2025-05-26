from fastapi import FastAPI

app = FastAPI()

@app.get("/")
@app.head("/")
async def root():
    return {"message": "Hello from FastAPI + Docker!"}
