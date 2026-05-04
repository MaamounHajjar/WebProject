(function () {
  const ctx = window.createDoctorState && window.createDoctorState();
  if (!ctx) return;

  const ui = window.createDoctorUI(ctx);
  const liveMonitor = window.createDoctorLiveMonitor(ctx, ui);
  const plan = window.createDoctorPlan(ctx);
  const patients = window.createDoctorPatients(ctx, ui, liveMonitor, plan);
  const auth = window.createDoctorAuth(ctx, ui, patients, liveMonitor);

  patients.bindSearch();
  patients.bindPatientSelection();
  patients.bindSections();
  plan.bindPlanForm(patients.loadPatientDetail);
  auth.bindAuth();
  auth.start();
})();
