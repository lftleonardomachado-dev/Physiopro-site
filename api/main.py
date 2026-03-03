from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sqlite3
from pathlib import Path

app = FastAPI()

# --- CORS (allows your website to call this API) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Later restrict to your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH = BASE_DIR / "data" / "crm.db"

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

# --- Request Model ---
class Lead(BaseModel):
    name: str
    phone: str | None = None
    email: str | None = None
    goal: str | None = None
    source: str = "website"

@app.get("/")
def home():
    return {"message": "PhysioPro API running"}

@app.post("/api/leads")
def create_lead(lead: Lead):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO leads (name, phone, source) VALUES (?, ?, ?)",
        (lead.name, lead.phone, lead.source),
    )

    conn.commit()
    conn.close()

    return {"status": "Lead created successfully"}
