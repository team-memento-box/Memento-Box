from pydantic import BaseModel
from typing import List

class Item(BaseModel):
    name: str
    value: int

class StoryNudge(BaseModel):
    mood: str
    keywords: List[str] 