(function () {
  window.createDoctorLiveMonitor = function createDoctorLiveMonitor(ctx, ui) {
    const { state, parseDate, prependGlobalAmbulanceHistory, syncActiveAmbulanceRequest, tokenKey } = ctx;
    const { resetLiveVitals, renderEnvironment, renderAlerts, renderSensors, renderPredictions, renderHistory } = ui;

    function refreshGlobalAmbulanceUi() {
      state.latestAmbulanceRequest = syncActiveAmbulanceRequest(state.latestAmbulanceRequest);
      const detail = state.patientDetails.get(String(state.selectedPatientId));
      if (!detail) return;
      renderEnvironment(detail.live_environment || detail.environment_context || {}, state.latestAmbulanceRequest);
      renderAlerts(detail.live_alerts || detail.alerts || []);
      renderPredictions(detail.live_prediction || detail.predictions || {}, detail.live_anomaly || null);
      renderHistory(detail);
    }

    function stopAmbulanceCountdown() {
      if (!state.ambulanceCountdownTimer) return;
      window.clearInterval(state.ambulanceCountdownTimer);
      state.ambulanceCountdownTimer = null;
    }

    function startAmbulanceCountdown() {
      stopAmbulanceCountdown();
      state.ambulanceCountdownTimer = window.setInterval(() => {
        if (!state.latestAmbulanceRequest) return;
        refreshGlobalAmbulanceUi();
      }, 1000);
    }

    function getWebSocketUrl(patientId) {
      const socketUrl = new URL(`/ws/vitals/${encodeURIComponent(patientId)}`, window.DARMON_API_ORIGIN);
      socketUrl.protocol = socketUrl.protocol === "https:" ? "wss:" : "ws:";
      const token = window.localStorage.getItem(tokenKey);
      if (token) {
        socketUrl.searchParams.set("token", token);
      }
      return socketUrl.toString();
    }

    function appendLiveSnapshot(payload) {
      const patientId = String(payload.patient_id);
      const snapshots = state.patientSnapshots.get(patientId) || [];
      snapshots.push({
        timestamp: payload.timestamp || new Date().toISOString(),
        vitals: payload.vitals,
        anomaly: payload.anomaly,
        prediction: payload.prediction,
      });
      state.patientSnapshots.set(patientId, snapshots.slice(-30));

      if (!(payload.alerts || []).length) return;
      const alertRows = state.patientAlerts.get(patientId) || [];
      payload.alerts.forEach((alert) => {
        alertRows.push({ ...alert, timestamp: payload.timestamp || new Date().toISOString() });
      });
      state.patientAlerts.set(patientId, alertRows.slice(-30));
    }

    function disconnectVitals() {
      if (!state.vitalSocket) return;
      state.vitalSocket.close();
      state.vitalSocket = null;
    }

    function connectToPatientVitals(patientId) {
      disconnectVitals();
      state.liveVitalsActive = false;
      resetLiveVitals("Connecting to live vitals...");
      state.vitalSocket = new WebSocket(getWebSocketUrl(patientId));

      state.vitalSocket.onmessage = (event) => {
        const payload = JSON.parse(event.data);
        state.latestAmbulanceRequest = syncActiveAmbulanceRequest(payload.ambulance || null);
        if (state.latestAmbulanceRequest) {
          prependGlobalAmbulanceHistory(state.latestAmbulanceRequest);
        }
        if (Number(payload.patient_id) !== Number(state.selectedPatientId)) return;

        state.liveVitalsActive = true;
        appendLiveSnapshot(payload);
        renderSensors(payload.vitals);
        renderAlerts(payload.alerts);
        renderPredictions(payload.prediction, payload.anomaly);
        renderEnvironment(payload.environment, payload.ambulance || state.latestAmbulanceRequest);

        const detail = state.patientDetails.get(String(state.selectedPatientId));
        if (!detail) return;
        detail.ambulance_request = state.latestAmbulanceRequest;
        detail.live_alerts = payload.alerts || [];
        detail.live_prediction = payload.prediction || null;
        detail.live_anomaly = payload.anomaly || null;
        detail.live_environment = payload.environment || null;
        detail.live_timestamp = parseDate(payload.timestamp) || new Date();
        renderHistory(detail);
      };

      state.vitalSocket.onclose = () => {
        if (Number(patientId) !== Number(state.selectedPatientId) || state.liveVitalsActive) return;
        resetLiveVitals("Connecting to live vitals...");
      };

      state.vitalSocket.onerror = () => {
        if (Number(patientId) !== Number(state.selectedPatientId) || state.liveVitalsActive) return;
        resetLiveVitals("Connecting to live vitals...");
      };
    }

    return {
      appendLiveSnapshot,
      connectToPatientVitals,
      disconnectVitals,
      getWebSocketUrl,
      refreshGlobalAmbulanceUi,
      startAmbulanceCountdown,
      stopAmbulanceCountdown,
    };
  };
})();
