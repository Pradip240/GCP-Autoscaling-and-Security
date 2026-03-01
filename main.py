from fastapi import FastAPI
import socket

app = FastAPI()

@app.get("/")
def root():
    return {
        "message": "Server is running",
        "hostname": socket.gethostname()
    }


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/cpu")
def cpu_stress():
    # Simulate CPU load for testing autoscaling
    for i in range(5000000):
        # 10 Mil ops
        i = i + 1
        i = i - 1
    return {"status": "CPU load API responded"}