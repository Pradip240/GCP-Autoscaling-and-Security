import asyncio
import aiohttp
import time

TARGET_URL = "http://localhost:8080/cpu"
REQUESTS_PER_SECOND = 10


async def send_request(session):
    try:
        async with session.get(TARGET_URL) as response:
            await response.text()
            return response.status
    except Exception:
        return None


async def generate_load():
    async with aiohttp.ClientSession() as session:
        for _idx in range(10): # run for 10 sec
            start_time = time.time()

            tasks = [
                asyncio.create_task(send_request(session))
                for _ in range(REQUESTS_PER_SECOND)
            ]

            results = await asyncio.gather(*tasks)

            success = sum(1 for r in results if r == 200)
            failed = len(results) - success

            elapsed = time.time() - start_time
            # Wait for 1 sec max
            sleep_time = max(0, 1 - elapsed)

            print(
                f"Sent: {len(results)} | "
                f"Success: {success} | "
                f"Failed: {failed} | "
                f"Time: {elapsed:.2f}s"
            )

            await asyncio.sleep(sleep_time)


if __name__ == "__main__":
    asyncio.run(generate_load())
