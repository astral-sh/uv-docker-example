from fastapi import FastAPI

app = FastAPI()


def hello():
    print("Hello world")


@app.get("/")
async def root():
    return "Hello world"
