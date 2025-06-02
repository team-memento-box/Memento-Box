from fastapi import FastAPI

app = FastAPI()

@app.get("/")
@app.head("/")
async def root():
    return {"message": "Hello from FastAPI + Docker!"}


@app.get("/test")
async def test():
    return {"this": "is test"}
