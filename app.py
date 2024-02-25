from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from datetime import datetime
from pytz import timezone
import uvicorn

app = FastAPI()

format = "%Y-%m-%d %H:%M:%S"

@app.get("/", response_class=HTMLResponse)
def timezones():
  zones = {
        "Tokyo": "Asia/Tokyo",
        "New-York": "America/New_York",
        "Berlin": "Europe/Berlin"
  }
  
  html = "<html><body>"
  for city, tmz in zones.items():
    now_city = datetime.now(timezone(tmz))
    html += f'Time in {city} is now {now_city.strftime(format)} <br/>'    
  html += '</body></html>'

  return html

@app.get("/health", status_code=200)
def status():
  return {"msg": "I am okay!"}

if __name__ == "__main__":
    uvicorn.run(app, port=8080)