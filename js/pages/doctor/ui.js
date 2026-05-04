(function () {
  window.createDoctorUI = function createDoctorUI(ctx) {
    const { refs, state, escapeHtml, normalize, formatDateTime, formatCountdown, formatEtaMinutes, getRemainingSeconds, syncActiveAmbulanceRequest, mergeAlertsWithAmbulance, formatLabel, levelClass } = ctx;

    const setView = (view) => {
      refs.authSection.classList.toggle('hidden', view === 'workspace');
      refs.workspace.classList.toggle('hidden', view !== 'workspace');
      refs.loginPanel.classList.toggle('hidden', view !== 'login');
      refs.otpPanel.classList.toggle('hidden', view !== 'otp');
      refs.recoverPanel.classList.toggle('hidden', view !== 'recover');
      refs.resetPanel.classList.toggle('hidden', view !== 'reset');
    };
    const clearAuthMessages = () => { refs.loginMsg.textContent = ''; refs.otpMsg.textContent = ''; refs.recoverMsg.textContent = ''; refs.resetMsg.textContent = ''; };
    const resetLiveVitals = (message = 'Sensor not working. Waiting for a fresh reading from the monitor.') => { refs.sensorGrid.innerHTML = `<div class="history-item">${escapeHtml(message)}</div>`; };

    function renderEnvironment(context, ambulance = state.latestAmbulanceRequest) {
      const rows = Array.isArray(context) ? context.filter((item) => !['ambulance route', 'dispatch', 'requested', 'route', 'ambulance eta'].includes(normalize(item?.label))) : Object.entries(context || {}).filter(([key]) => !['ambulance_eta', 'ambulance_route'].includes(key)).map(([key, value]) => ({ label: formatLabel(key), value }));
      const activeRequest = syncActiveAmbulanceRequest(ambulance);
      if (activeRequest) {
        rows.push({ label: 'Dispatch', value: `ETA ${formatCountdown(activeRequest.remaining_seconds)} from ${activeRequest.address}` });
        rows.push({ label: 'Requested', value: formatDateTime(activeRequest.created_at) });
        rows.push({ label: 'Route', value: `${activeRequest.distance_km || '?'} km to patient` });
      }
      refs.environmentList.innerHTML = rows.length ? rows.map((item) => `<div class="environment-item"><span>${escapeHtml(item.label)}</span><strong>${escapeHtml(item.value)}</strong></div>`).join('') : '<div class="environment-item"><span>Context</span><strong>--</strong></div>';
    }

    function renderSectionState() {
      refs.currentSectionHeading.textContent = formatLabel(state.activeSection);
      const isGeneral = state.activeSection === 'general';
      if (refs.openSectionScheduleBtn) {
        refs.openSectionScheduleBtn.disabled = !isGeneral;
        refs.openSectionScheduleBtn.classList.toggle('ghost', !isGeneral);
      }
    }

    function renderPatientList() {
      refs.patientList.innerHTML = state.filteredPatients.length ? state.filteredPatients.map((patient) => `
        <button class="patient-card ${Number(patient.id) === Number(state.selectedPatientId) ? 'active' : ''}" type="button" data-patient-id="${patient.id}">
          <div><strong>${escapeHtml(patient.name)}</strong><span>${escapeHtml(patient.email || patient.phone || 'No contact info')}</span></div>
          <span class="patient-status ${escapeHtml(patient.status_class || 'stable')}">${escapeHtml(String(patient.appointments_count || 0))} visits</span>
        </button>`).join('') : '<div class="history-item">No patients match this search.</div>';
    }

    function renderAppointments() {
      refs.todayQueueCount.textContent = `${state.liveAppointments.length} scheduled`;
      if (!refs.todayAppointments && !refs.scheduleModalList) return;
      const html = state.liveAppointments.length ? state.liveAppointments.map((appointment) => `
        <button class="appointment-item ${Number(appointment.patient_id) === Number(state.selectedPatientId) ? 'active' : ''}" type="button" data-patient-id="${appointment.patient_id}">
          <span class="appointment-time">${escapeHtml(appointment.time_slot)}</span>
          <div><strong>${escapeHtml(appointment.patient_name)}</strong><span>${escapeHtml(appointment.status)} ? ${escapeHtml(appointment.patient_email || appointment.patient_phone || '')}</span></div>
        </button>`).join('') : '<div class="history-item">No scheduled appointments for this shift.</div>';
      if (refs.todayAppointments) refs.todayAppointments.innerHTML = html;
      if (refs.scheduleModalList) refs.scheduleModalList.innerHTML = html;
    }

    function renderPatientInfo(detail) {
      const patient = detail.patient || {};
      refs.selectedPatientHeading.textContent = patient.name || 'Choose a patient';
      refs.patientInfoList.innerHTML = [['Name', patient.name || '-'], ['Email', patient.email || '-'], ['Phone', patient.phone || '-'], ['Registered', patient.created_at || '-'], ['Status', formatLabel(patient.status || 'under_observation')], ['Diagnosis', patient.diagnosis || '-'], ['Medications', patient.medications || '-'], ['Blood Test', patient.blood_test_required ? patient.blood_test_note || 'Requested' : 'Not requested']].map(([label, value]) => `<div class="key-value-item"><span>${escapeHtml(label)}</span><strong>${escapeHtml(value)}</strong></div>`).join('');
    }

    function renderAlerts(alerts) {
      const rows = mergeAlertsWithAmbulance(alerts);
      refs.alertList.innerHTML = rows.length ? rows.map((item) => `<div class="alert-item ${levelClass(item.level)}"><strong>${escapeHtml(item.title)}</strong><span>${escapeHtml(item.message || item.detail || '')}</span></div>`).join('') : '<div class="history-item">No alerts available.</div>';
    }

    function renderSensors(vitals) {
      if (!vitals) return resetLiveVitals();
      refs.sensorGrid.innerHTML = [
        { label: 'Heart rate', value: `${vitals.heart_rate} bpm`, alert: vitals.heart_rate >= 115 || vitals.heart_rate <= 48 },
        { label: 'SpO2', value: `${vitals.spo2}%`, alert: vitals.spo2 <= 92 },
        { label: 'Temperature', value: `${vitals.temperature} C`, alert: vitals.temperature >= 38 },
        { label: 'Blood pressure', value: `${vitals.systolic}/${vitals.diastolic}`, alert: vitals.systolic >= 150 || vitals.diastolic >= 95 },
        { label: 'Respiratory rate', value: `${vitals.respiratory_rate}/min`, alert: vitals.respiratory_rate >= 22 },
      ].map((item) => `<div class="sensor-item ${item.alert ? 'alert' : ''}"><span>${item.label}</span><strong>${item.value}</strong></div>`).join('');
    }

    function renderPredictions(predictions, anomaly = null) {
      const activeRequest = syncActiveAmbulanceRequest(state.latestAmbulanceRequest);
      const etaLabel = activeRequest ? formatCountdown(activeRequest.remaining_seconds) : `${predictions.eta_minutes || 0} min`;
      const drivers = (predictions.drivers || []).filter((driver) => activeRequest || driver !== 'Ambulance requested');
      refs.riskScore.textContent = `${(anomaly ? anomaly.score : predictions.risk_score) || 0}%`;
      refs.riskLabel.textContent = (anomaly ? anomaly.label : predictions.risk_label) || '-';
      refs.etaMinutes.textContent = etaLabel;
      refs.etaDrivers.innerHTML = drivers.map((driver) => `<span class="driver-chip">${escapeHtml(driver)}</span>`).join('') || '<span class="driver-chip">No active risk drivers</span>';
    }

    function renderHistory(detail) {
      const appointmentRows = (detail.appointments || []).map((row) => `<div class="history-item"><strong>${escapeHtml(`${row.appointment_date} ${row.time_slot}`)}</strong><br>${escapeHtml(`${row.status} • ${row.doctor_name}`)}</div>`);
      const resultRows = (detail.lab_results || []).map((row) => `<div class="history-item"><strong>${escapeHtml(`${row.test_name} • ${row.status}`)}</strong><br>${escapeHtml(`Sample: ${row.sample_date}${row.upload_date ? ` • Uploaded: ${row.upload_date}` : ''}`)}</div>`);
      const noteRows = (detail.notes || []).map((row) => `<div class="history-item"><strong>${escapeHtml(`${row.created_at} • ${formatLabel(row.patient_status)}`)}</strong><br>${escapeHtml(`Diagnosis: ${row.diagnosis}`)}<br>${escapeHtml(`Medications: ${row.medications}`)}<br>${escapeHtml(`Blood test: ${row.blood_test_required ? row.blood_test_note || 'Requested' : 'Not requested'}`)}<br>${escapeHtml(`Note: ${row.doctor_note || '-'}`)}</div>`);
      const ambulanceRows = state.globalAmbulanceHistory.map((row) => { const remainingSeconds = getRemainingSeconds(row); const status = remainingSeconds > 0 ? `Active • ${formatCountdown(remainingSeconds)} remaining` : 'Alert expired'; return `<div class="history-item"><strong>${escapeHtml(`Ambulance request • ${formatDateTime(row.created_at)}`)}</strong><br>${escapeHtml(`${status} • ${row.full_name || 'Patient'} • ${row.phone || '-'} • ${row.address || 'reported address'} • Original ETA ${formatEtaMinutes(row.eta_minutes)}`)}</div>`; });
      const blocks = noteRows.concat(ambulanceRows, appointmentRows, resultRows);
      refs.historyContent.innerHTML = blocks.length ? blocks.join('') : '<div class="history-item">No patient history yet.</div>';
    }

    return { setView, clearAuthMessages, resetLiveVitals, renderEnvironment, renderSectionState, renderPatientList, renderAppointments, renderPatientInfo, renderAlerts, renderSensors, renderPredictions, renderHistory };
  };
})();
