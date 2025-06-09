import asyncio
from db.database import async_session
from db.seed import seed_data

async def main():
    async with async_session() as db:
        try:
            print("더미 데이터 생성을 시작합니다...")
            await seed_data(db)
            print("더미 데이터 생성이 완료되었습니다!")
        except Exception as e:
            print(f"오류가 발생했습니다: {str(e)}")

if __name__ == "__main__":
    asyncio.run(main()) 