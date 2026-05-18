from sqlalchemy import Column
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy import Float
from sqlalchemy import JSON
from sqlalchemy import DateTime

from datetime import datetime

from app.core.database import Base


class ScanHistory(Base):

    __tablename__ = "scan_history"

    id = Column(Integer, primary_key=True, index=True)

    image = Column(String(255))

    food_name = Column(String(100))

    confidence = Column(Float)

    overall_status = Column(String(100))

    result = Column(JSON)

    created_at = Column(DateTime, default=datetime.utcnow)