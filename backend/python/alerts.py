def add_alert(alerts, level, title, message, weight):
    alerts.append({
        "level": level,
        "title": title,
        "message": message,
        "weight": weight,
    })



def analyze_vitals(vitals, ambulance_request=None):
    alerts = []

    heart_rate = int(vitals.get("heart_rate", 0) or 0)
    spo2 = int(vitals.get("spo2", 0) or 0)
    temperature = float(vitals.get("temperature", 0) or 0)
    systolic = int(vitals.get("systolic", 0) or 0)
    diastolic = int(vitals.get("diastolic", 0) or 0)
    respiratory_rate = int(vitals.get("respiratory_rate", 0) or 0)

    if heart_rate >= 135:
        add_alert(alerts, "critical", "Severe tachycardia", f"Heart rate is {heart_rate} bpm.", 28)
    elif heart_rate >= 115:
        add_alert(alerts, "warning", "High heart rate", f"Heart rate is {heart_rate} bpm.", 16)
    elif heart_rate and heart_rate <= 48:
        add_alert(alerts, "critical", "Bradycardia", f"Heart rate is {heart_rate} bpm.", 24)

    if spo2 <= 88:
        add_alert(alerts, "critical", "Critical oxygen drop", f"SpO2 fell to {spo2}%.", 30)
    elif spo2 <= 92:
        add_alert(alerts, "warning", "Low oxygen saturation", f"SpO2 is {spo2}%.", 18)

    if temperature >= 39:
        add_alert(alerts, "critical", "High fever", f"Temperature is {temperature:.1f} C.", 20)
    elif temperature >= 38:
        add_alert(alerts, "warning", "Fever detected", f"Temperature is {temperature:.1f} C.", 12)

    if systolic >= 180 or diastolic >= 120:
        add_alert(alerts, "critical", "Hypertensive crisis risk", f"Blood pressure is {systolic}/{diastolic}.", 28)
    elif systolic >= 150 or diastolic >= 95:
        add_alert(alerts, "warning", "Elevated blood pressure", f"Blood pressure is {systolic}/{diastolic}.", 14)
    elif systolic and systolic <= 90:
        add_alert(alerts, "warning", "Low blood pressure", f"Blood pressure is {systolic}/{diastolic}.", 12)

    if respiratory_rate >= 30:
        add_alert(alerts, "critical", "Respiratory distress", f"Respiratory rate is {respiratory_rate}/min.", 24)
    elif respiratory_rate >= 22:
        add_alert(alerts, "warning", "Fast breathing", f"Respiratory rate is {respiratory_rate}/min.", 10)

    score = min(100, sum(alert["weight"] for alert in alerts))
    if ambulance_request:
        score = min(100, score + 12)

    if score >= 70:
        label = "Critical"
        priority = "Critical"
        eta_minutes = 4
    elif score >= 35:
        label = "Watch"
        priority = "High"
        eta_minutes = 10
    elif score >= 15:
        label = "Guarded"
        priority = "Medium"
        eta_minutes = 18
    else:
        label = "Stable"
        priority = "Low"
        eta_minutes = 25

    confidence = min(98, 55 + score // 2)
    eta_drivers = [alert["title"] for alert in alerts[:3]]
    if not eta_drivers:
        eta_drivers = ["Vitals within expected range"]

    if ambulance_request:
        eta_minutes = float(ambulance_request.get("eta_minutes") or eta_minutes)
        confidence = min(98, max(confidence, 62 + max(0, 18 - int(eta_minutes))))
        if eta_minutes <= 8:
            priority = "Critical"
        elif eta_minutes <= 15:
            priority = "High"
        else:
            priority = "Medium"
        eta_drivers.insert(0, "Ambulance requested")

    environment = [{"label": "Monitoring cadence", "value": "Every 3 seconds"}]
    if ambulance_request:
        environment.append({
            "label": "Ambulance route",
            "value": f"{ambulance_request.get('distance_km', '?')} km to patient",
        })

    return {
        "alerts": alerts,
        "anomaly_score": score,
        "anomaly_label": label,
        "priority": priority,
        "eta_minutes": eta_minutes,
        "confidence": confidence,
        "eta_drivers": eta_drivers,
        "environment": environment,
        "status_class": "critical" if score >= 70 else "watch" if score >= 35 else "stable",
    }



def build_live_payload(snapshot, ambulance_request=None):
    vitals = {
        "heart_rate": int(snapshot.get("heart_rate", 0) or 0),
        "spo2": int(snapshot.get("spo2", 0) or 0),
        "temperature": float(snapshot.get("temp", 0) or 0),
        "systolic": int(snapshot.get("systolic", 0) or 0),
        "diastolic": int(snapshot.get("diastolic", 0) or 0),
        "respiratory_rate": int(snapshot.get("respiratory_rate", 0) or 0),
    }
    analysis = analyze_vitals(vitals, ambulance_request)
    environment = list(analysis["environment"])

    ward = snapshot.get("ward")
    room = snapshot.get("room")
    bed = snapshot.get("bed")
    support_mode = snapshot.get("support_mode")
    mobility = snapshot.get("mobility")
    event_state = snapshot.get("event_state")

    bed_parts = []
    if ward:
        bed_parts.append(f"Ward {ward}")
    if room:
        bed_parts.append(f"Room {room}")
    if bed:
        bed_parts.append(f"Bed {bed}")
    if bed_parts:
        environment.append({"label": "Bed assignment", "value": " / ".join(bed_parts)})

    if support_mode:
        environment.append({"label": "Support mode", "value": str(support_mode)})
    if mobility:
        environment.append({"label": "Mobility", "value": str(mobility)})
    if event_state:
        environment.append({"label": "Patient state", "value": str(event_state).title()})

    return {
        "patient_id": str(snapshot.get("patient_id")),
        "timestamp": snapshot.get("timestamp"),
        "vitals": vitals,
        "alerts": analysis["alerts"],
        "prediction": {
            "eta_minutes": analysis["eta_minutes"],
            "confidence": analysis["confidence"],
            "priority": analysis["priority"],
            "drivers": analysis["eta_drivers"],
        },
        "anomaly": {
            "score": analysis["anomaly_score"],
            "label": analysis["anomaly_label"],
            "status_class": analysis["status_class"],
        },
        "environment": environment,
        "ambulance": ambulance_request,
    }
