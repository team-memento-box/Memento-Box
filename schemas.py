from pydantic import BaseModel
from datetime import datetime, date

class PhotoSchema(BaseModel):
    id: int
    family_id: int
    image_url: str
    recorded_at: datetime
    uploaded_at: date

    class Config:
        orm_mode = True
