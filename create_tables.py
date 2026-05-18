from app.core.database import engine
from app.models.scan_history import Base

Base.metadata.create_all(bind=engine)

print("TABLE CREATED")