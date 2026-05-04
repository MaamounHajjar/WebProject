const baseLocation = { lat: 41.2883, lng: 69.19951 };
const apiBase = window.DARMON_API_BASE || `${window.location.protocol}//${window.location.hostname}:8000`;
const predictArrivalUrl = new URL('/predict_arrival', apiBase).toString();
const apiUrl = new URL('/api', apiBase).toString();

const map = L.map('map').setView([baseLocation.lat, baseLocation.lng], 12);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '&copy; OpenStreetMap contributors'
}).addTo(map);

let patientMarker = null;
let routeLayer = null;

function isValidPhone(phone) {
  return /^\+?[0-9 \-]{7,20}$/.test(String(phone || "").trim());
}

L.marker([baseLocation.lat, baseLocation.lng]).addTo(map).bindPopup('Hospital').openPopup();

async function fetchArrival(address) {
  const response = await fetch(`${predictArrivalUrl}?address=${encodeURIComponent(address)}`);
  return response.json();
}

document.getElementById('searchBtn').addEventListener('click', async () => {
  const address = document.getElementById('locationInput').value.trim();
  if (!address) {
    alert('Please enter an address first.');
    return;
  }

  let data;
  try {
    data = await fetchArrival(address);
  } catch {
    alert(`Could not reach the backend at ${predictArrivalUrl}`);
    return;
  }

  if (data.error) {
    alert(data.error);
    return;
  }

  if (patientMarker) map.removeLayer(patientMarker);
  if (routeLayer) map.removeLayer(routeLayer);

  patientMarker = L.marker(data.patient_coords).addTo(map).bindPopup('You').openPopup();
  routeLayer = L.geoJSON(data.route_geometry, { style: { color: 'red', weight: 5 } }).addTo(map);
  document.getElementById('arrivalInfo').innerText = `Arrival: ${data.arrival_time_min} mins (${data.distance_km} km)`;
  map.fitBounds(L.geoJSON(data.route_geometry).getBounds());
});

document.getElementById('requestAmbulanceBtn').addEventListener('click', async () => {
  const fullName = document.getElementById('emergencyFullName').value.trim();
  const phone = document.getElementById('emergencyPhone').value.trim();
  const address = document.getElementById('locationInput').value.trim();
  const requestInfo = document.getElementById('requestInfo');

  if (!fullName) {
    requestInfo.textContent = 'Enter your full name first.';
    return;
  }

  if (!phone) {
    requestInfo.textContent = 'Enter your phone number first.';
    return;
  }

  if (!isValidPhone(phone)) {
    requestInfo.textContent = 'Enter a valid phone number.';
    return;
  }

  if (!address) {
    requestInfo.textContent = 'Enter the emergency address first.';
    return;
  }

  requestInfo.textContent = 'Requesting ambulance...';

  try {
    const response = await fetch(apiUrl, {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action: 'request_ambulance',
        full_name: fullName,
        phone,
        address,
      }),
    });
    const data = await response.json();
    if (!data.ok) {
      requestInfo.textContent = data.error || 'Could not request ambulance.';
      return;
    }

    requestInfo.textContent = `Ambulance requested for ${data.data.full_name}. ETA ${data.data.arrival_time_min} min from ${data.data.distance_km} km away.`;
  } catch {
    requestInfo.textContent = `Could not reach the backend at ${apiUrl}`;
  }
});

document.getElementById('year').textContent = new Date().getFullYear();
