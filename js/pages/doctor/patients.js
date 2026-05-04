(function () {
  window.createDoctorPatients = function createDoctorPatients(ctx, ui, liveMonitor, plan) {
    const { $, $$, refs, state, doctorApi, normalize, syncActiveAmbulanceRequest } = ctx;
    const { renderEnvironment, renderSectionState, renderPatientList, renderAppointments, renderPatientInfo, renderAlerts, renderPredictions, renderHistory, resetLiveVitals } = ui;

    async function loadPatientDetail(patientId, options = {}) {
      const { populatePlanForm = true, preservePlanMessage = false } = options;
      if (!preservePlanMessage) refs.patientPlanMsg.textContent = "";
      const response = await doctorApi("doctor_patient_detail", { patient_id: patientId });
      if (!response.ok) {
        refs.patientPlanMsg.textContent = response.error || "Failed to load patient.";
        return;
      }

      state.selectedPatientId = Number(patientId);
      response.data.live_alerts = null;
      response.data.live_prediction = null;
      response.data.live_anomaly = null;
      response.data.live_environment = null;
      state.patientDetails.set(String(patientId), response.data);
      state.latestAmbulanceRequest = syncActiveAmbulanceRequest(response.data.ambulance_request || null);
      state.globalAmbulanceHistory = response.data.ambulance_history || [];

      renderPatientList();
      renderAppointments();
      renderEnvironment(response.data.environment_context || {}, state.latestAmbulanceRequest);
      renderPatientInfo(response.data);
      renderAlerts(response.data.alerts || []);
      renderPredictions(response.data.predictions || {});
      renderHistory(response.data);
      if (populatePlanForm) plan.populatePlanForm(response.data);
      liveMonitor.startAmbulanceCountdown();
      liveMonitor.connectToPatientVitals(patientId);
    }

    function applySearch() {
      const query = normalize(refs.patientSearchInput.value);
      state.filteredPatients = state.patients.filter((patient) => {
        const haystack = `${patient.name || ""} ${patient.email || ""} ${patient.phone || ""}`;
        return !query || normalize(haystack).includes(query);
      });
      renderPatientList();
    }

    async function loadWorkspaceData() {
      const dashboard = await doctorApi("doctor_dashboard");
      if (!dashboard.ok) {
        throw new Error(dashboard.error || "Failed to load doctor dashboard.");
      }

      state.liveAppointments = dashboard.data.appointments || [];
      state.latestAmbulanceRequest = syncActiveAmbulanceRequest(dashboard.data.latest_ambulance_request || null);
      renderEnvironment(dashboard.data.environment_context || {}, state.latestAmbulanceRequest);
      renderAppointments();

      const patientResponse = await doctorApi("doctor_patients");
      if (!patientResponse.ok) {
        throw new Error(patientResponse.error || "Failed to load patients.");
      }

      state.patients = patientResponse.data || [];
      state.filteredPatients = state.patients.slice();
      renderPatientList();
      state.liveVitalsActive = false;
      resetLiveVitals();

      const initialPatientId = state.liveAppointments[0]?.patient_id || state.filteredPatients[0]?.id;
      if (initialPatientId) {
        await loadPatientDetail(initialPatientId);
      }
    }

    function bindSearch() {
      refs.patientSearchForm.addEventListener("submit", (event) => {
        event.preventDefault();
        applySearch();
      });
      refs.patientSearchInput.addEventListener("input", applySearch);
    }

    function bindPatientSelection() {
      refs.patientList.addEventListener("click", async (event) => {
        const button = event.target.closest("[data-patient-id]");
        if (!button) return;
        await loadPatientDetail(button.getAttribute("data-patient-id"));
      });

      if (refs.todayAppointments) {
        refs.todayAppointments.addEventListener("click", async (event) => {
          const button = event.target.closest("[data-patient-id]");
          if (!button) return;
          await loadPatientDetail(button.getAttribute("data-patient-id"));
        });
      }

      if (refs.scheduleModalList && refs.scheduleModal) {
        refs.scheduleModalList.addEventListener("click", async (event) => {
          const button = event.target.closest("[data-patient-id]");
          if (!button) return;
          refs.scheduleModal.classList.add("hidden");
          await loadPatientDetail(button.getAttribute("data-patient-id"));
        });
      }
    }

    function bindSections() {
      $$(".section-tab").forEach((button) => {
        const isEnabled = button.getAttribute("data-section") === "general";
        if (!isEnabled) button.disabled = true;

        button.addEventListener("click", () => {
          if (!isEnabled) return;
          state.activeSection = button.getAttribute("data-section");
          $$(".section-tab").forEach((item) => item.classList.remove("active"));
          button.classList.add("active");
          renderSectionState();
        });
      });

      if (refs.openSectionScheduleBtn && refs.scheduleModal) {
        refs.openSectionScheduleBtn.addEventListener("click", () => {
          if (state.activeSection !== "general") return;
          refs.scheduleModal.classList.remove("hidden");
        });
      }

      if (refs.closeScheduleModalBtn && refs.scheduleModal) {
        refs.closeScheduleModalBtn.addEventListener("click", () => {
          refs.scheduleModal.classList.add("hidden");
        });
      }

      if (refs.scheduleModal) {
        refs.scheduleModal.addEventListener("click", (event) => {
          if (event.target === refs.scheduleModal) {
            refs.scheduleModal.classList.add("hidden");
          }
        });
      }
    }

    return {
      applySearch,
      bindPatientSelection,
      bindSearch,
      bindSections,
      loadPatientDetail,
      loadWorkspaceData,
    };
  };
})();
