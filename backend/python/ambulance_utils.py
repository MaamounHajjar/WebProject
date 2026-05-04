from datetime import datetime
from math import atan2, cos, radians, sin, sqrt

import joblib
import requests
from geopy.geocoders import Nominatim

from config import BASE_DIR

geolocator = Nominatim(user_agent="hospital_app")
HOSPITAL_COORDS = (41.2883, 69.19951)
model = joblib.load(BASE_DIR / "backend" / "files" / "ambulance_model.pkl")

def get_road_distance(lat1, lon1, lat2, lon2):
    url = (
        "http://router.project-osrm.org/route/v1/driving/"
        f"{lon1},{lat1};{lon2},{lat2}?overview=full&geometries=geojson"
    )
    response = requests.get(url, timeout=10).json()
    distance_meters = response["routes"][0]["distance"]
    return {
        "km": round(distance_meters / 1000, 2),
        "geometry": response["routes"][0]["geometry"],
    }


def predict_arrival_for_address(address: str):
    address = (address or "").strip()
    if not address:
        return {"ok": False, "error": "Address is required."}

    location = None
    patient_coords = None
    try:
        location = geolocator.geocode(address)
        if location:
            patient_coords = (location.latitude, location.longitude)
    except Exception:
        location = None

    if not patient_coords:
        lowered = address.lower()
        for key, coords in FALLBACK_LOCATIONS.items():
            if key in lowered:
                patient_coords = coords
                break
    distance = get_road_distance(
        HOSPITAL_COORDS[0],
        HOSPITAL_COORDS[1],
        patient_coords[0],
        patient_coords[1], )
    
    current_hour = datetime.now().hour
    arrival_time = model.predict([[distance["km"], current_hour]])[0]

    return {
        "ok": True,
        "data": {
            "arrival_time_min": round(float(arrival_time), 1),
            "distance_km": round(distance["km"], 2),
            "patient_coords": [patient_coords[0], patient_coords[1]],
            "hospital_coords": HOSPITAL_COORDS,
            "route_geometry": distance["geometry"],
        },
    }
