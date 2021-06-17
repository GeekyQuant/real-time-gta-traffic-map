from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from aiokafka import AIOKafkaConsumer
from starlette.websockets import WebSocket
import re
import json
import motor.motor_asyncio
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import Optional, List
from datetime import datetime
import pymongo
import os
from dotenv import load_dotenv, find_dotenv


# Finding our .env in the file-directory
dotenv_path = find_dotenv()
load_dotenv(dotenv_path)


app = FastAPI()
# api-related
db_user = os.environ.get("MONGO_USER")
db_admin = os.environ.get("MONGO_ADMIN")
client = motor.motor_asyncio.AsyncIOMotorClient(f"mongodb://{db_user}:{db_user}@mongo:27017/?authSource={db_admin}")
db = client.traffic_db
# We are building the api for the traffic_incident
collection = db.traffic_incident


# static css/js
app.mount("/static", StaticFiles(directory="static"), name="static")

# html jinja2
templates = Jinja2Templates(directory="templates")


# Pydantic
class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")


class TrafficIncidentModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    insertedTS: datetime = Field(alias="_insertedTS")
    TRAFFIC_ITEMS: Optional[dict]

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}


# mongoapi
@app.get(
    "/incident/latest", response_description="Get latest incident", response_model=TrafficIncidentModel
)
async def latest_incident():
    incident = await collection.find_one({"TRAFFIC_ITEMS": {"$ne": None}}, sort=[("_insertedTS", pymongo.DESCENDING)])
    return incident


@app.get(
    "/incident", response_description="Get all incidents", response_model=List[TrafficIncidentModel]
)
async def list_incidents(skip: int = 0, limit: int = 10):
    cursor = collection.find({"TRAFFIC_ITEMS": {"$ne": None}})
    cursor.sort("_insertedTS", pymongo.DESCENDING).skip(skip).limit(limit)
    return [doc async for doc in cursor]


@app.get(
    "/incident/{start_ts}/{end_ts}", response_description="Get all incidents within a time period",
    response_model=List[TrafficIncidentModel]
)
async def list_incidents_ts(start_ts: str, end_ts: str, skip: int = 0, limit: int = 10):
    datetime_start = datetime.strptime(start_ts, "%Y%m%d%H%M")
    datetime_end = datetime.strptime(end_ts, "%Y%m%d%H%M")
    cursor = collection.find({"TRAFFIC_ITEMS": {"$ne": None},
                              "_insertedTS": {"$gt": datetime_start, "$lt": datetime_end}})
    cursor.sort("_insertedTS", pymongo.DESCENDING).skip(skip).limit(limit)
    return [doc async for doc in cursor]


# Real-time map with websocket
@app.get("/", response_class=HTMLResponse)
def traffic_map(request: Request):
    return templates.TemplateResponse("map.html", {"request": request})


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    consumer = AIOKafkaConsumer(
        "traffic_flow", "traffic_incident",
        bootstrap_servers=['kafka:9092'],
        max_partition_fetch_bytes=20970000,
    )

    await consumer.start()

    while True:
        async for message in consumer:
            topic = message.topic
            message = message.value
            message = message.decode("latin1")
            message = re.search('{.*}', message).group(0)
            message = json.loads(message)
            message['TOPIC'] = str(topic)
            await websocket.send_json(message)
