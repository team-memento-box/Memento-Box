from uuid import UUID
from pydantic import BaseModel
from datetime import datetime
from typing import Optional, Dict, Any, List

class PhotoAnalysis(BaseModel):
    people: List[str] = []
    relationships: str = ""
    location: str = ""
    mood: str = ""
    key_objects: List[str] = []
    keywords: List[str] = []
    situation: str = ""