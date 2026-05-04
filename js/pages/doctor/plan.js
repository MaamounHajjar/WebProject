(function () {
  window.createDoctorPlan = function createDoctorPlan(ctx) {
    const { refs, state, doctorApi } = ctx;

    function populatePlanForm(detail) {
      const patient = detail.patient || {};
      refs.patientPlanForm.elements.diagnosis.value = patient.diagnosis && patient.diagnosis !== "Awaiting doctor note" ? patient.diagnosis : "";
      refs.patientPlanForm.elements.medications.value = patient.medications && patient.medications !== "No medication plan saved yet" ? patient.medications : "";
      refs.patientPlanForm.elements.patient_status.value = patient.status || "under_observation";
      refs.patientPlanForm.elements.blood_test_required.checked = Boolean(patient.blood_test_required);
      refs.patientPlanForm.elements.blood_test_note.value = patient.blood_test_note || "";
      refs.patientPlanForm.elements.doctor_note.value = patient.doctor_note || "";
    }

    function resetPlanForm() {
      refs.patientPlanForm.reset();
      refs.patientPlanForm.elements.patient_status.value = "under_observation";
    }

    function bindPlanForm(loadPatientDetail) {
      refs.patientPlanForm.addEventListener("submit", async (event) => {
        event.preventDefault();

        if (!state.selectedPatientId) {
          refs.patientPlanMsg.textContent = "Choose a patient first.";
          return;
        }

        refs.patientPlanMsg.textContent = "Saving...";
        const formData = new FormData(refs.patientPlanForm);
        const response = await doctorApi("doctor_save_patient_plan", {
          patient_id: state.selectedPatientId,
          diagnosis: formData.get("diagnosis"),
          medications: formData.get("medications"),
          patient_status: formData.get("patient_status"),
          blood_test_required: formData.get("blood_test_required") === "on",
          blood_test_note: formData.get("blood_test_note"),
          doctor_note: formData.get("doctor_note"),
        });

        if (!response.ok) {
          refs.patientPlanMsg.textContent = response.error || "Failed to save.";
          return;
        }

        refs.patientPlanMsg.textContent = "Saved.";
        await loadPatientDetail(state.selectedPatientId, {
          populatePlanForm: false,
          preservePlanMessage: true,
        });
        resetPlanForm();
      });
    }

    return { bindPlanForm, populatePlanForm, resetPlanForm };
  };
})();
