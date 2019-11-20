import os
import sslkeylog
from fastapi import FastAPI, File, UploadFile

sslkeylog.set_keylog("sslkeylog.txt")

BASE_PATH = os.getenv("BASE_PATH", "/")
app = FastAPI()


@app.get(f"{BASE_PATH}")
async def home():
    return {"hello": "world"}


@app.put(f"{BASE_PATH}uploadfile/")
async def create_upload_file(file: UploadFile = File(...)):
    await file.read()
    return
