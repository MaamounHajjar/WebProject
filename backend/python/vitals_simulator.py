import random
import time
from datetime import datetime, timezone

import pymongo

from db import get_db

client = pymongo.MongoClient("mongodb://localhost:27017/")
db = client["darmon_health"]
collection = db["patient_vitals"]

STATE_CONTEXT = {
    "stable": ("Room air", "Walking"),
    "warning": ("Observation", "Assisted"),
    "critical": ("Oxygen 4L", "Bed rest"),
}


def load_patient_profiles():
    with get_db() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, name FROM users WHERE role='patient' ORDER BY id")
            patients = cursor.fetchall()

    profiles = {}
    for index, patient in enumerate(patients):
        profiles[str(patient["id"])] = {
            "name": patient["name"],
            "ward": f"{(index % 3) + 1}",
            "room": f"{201 + index}",
            "bed": f"{(index % 2) + 1}",
        }
    return profiles


def random_vitals():
    return {
        "heart_rate": random.randint(60, 155),
        "spo2": random.randint(82, 100),
        "temp": round(random.uniform(36.0, 40.0), 1),
        "systolic": random.randint(100, 205),
        "diastolic": random.randint(65, 125),
        "respiratory_rate": random.randint(12, 34),
    }


def classify_state(vitals):
    if (
        vitals["heart_rate"] >= 130
        or vitals["spo2"] <= 88
        or vitals["temp"] >= 39.0
        or vitals["systolic"] >= 180
        or vitals["diastolic"] >= 120
        or vitals["respiratory_rate"] >= 30
    ):
        return "critical"
    if (
        vitals["heart_rate"] >= 110
        or vitals["spo2"] <= 93
        or vitals["temp"] >= 38.0
        or vitals["systolic"] >= 150
        or vitals["diastolic"] >= 95
        or vitals["respiratory_rate"] >= 22
    ):
        return "warning"
    return "stable"


def choose_incident(state, vitals):
    if state == "critical":
        if vitals["spo2"] <= 88:
            return "hypoxia"
        if vitals["heart_rate"] >= 130:
            return "arrhythmia"
        if vitals["systolic"] >= 180:
            return "hypertensive_spike"
        return "critical_event"
    if state == "warning":
        if vitals["temp"] >= 38.0:
            return "fever"
        if vitals["spo2"] <= 93:
            return "desaturation"
        if vitals["systolic"] >= 150:
            return "pressure_rise"
        return "under_observation"
    return "baseline"


def build_snapshot(patient_id, profile):
    vitals = random_vitals()
    event_state = classify_state(vitals)
    incident = choose_incident(event_state, vitals)
    support_mode, mobility = STATE_CONTEXT[event_state]
    return {
        "patient_id": patient_id,
        "heart_rate": vitals["heart_rate"],
        "spo2": vitals["spo2"],
        "temp": vitals["temp"],
        "systolic": vitals["systolic"],
        "diastolic": vitals["diastolic"],
        "respiratory_rate": vitals["respiratory_rate"],
        "event_state": event_state,
        "incident": incident,
        "ward": profile["ward"],
        "room": profile["room"],
        "bed": profile["bed"],
        "support_mode": support_mode,
        "mobility": mobility,
        "timestamp": datetime.now(timezone.utc),
    }


def run_simulator():
    patient_profiles = load_patient_profiles()
    print("Simulation started... Pushing vitals to MongoDB.")
    print("Profiles:", ", ".join(f"{pid}:{profile['name']}" for pid, profile in patient_profiles.items()))
    while True:
        for patient_id, profile in patient_profiles.items():
            collection.insert_one(build_snapshot(patient_id, profile))
        time.sleep(3)


if __name__ == "__main__":
    run_simulator()
