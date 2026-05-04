(function () {
  window.createDoctorState = function createDoctorState() {
    const $ = window.$;
    const $$ = window.$$;
    const api = window.darmonApi;
    const escapeHtml = window.escapeHtml;
    const tokenKey = window.DARMON_STAFF_TOKEN_KEY;

    const refs = {
      authSection: $("#doctorAuthSection"), workspace: $("#doctorWorkspace"), loginPanel: $("#doctorLoginPanel"), otpPanel: $("#doctorOtpPanel"), recoverPanel: $("#doctorRecoverPanel"), resetPanel: $("#doctorResetPanel"),
      loginForm: $("#doctorLoginForm"), otpForm: $("#doctorOtpForm"), recoverForm: $("#doctorRecoverForm"), resetForm: $("#doctorResetForm"), loginMsg: $("#doctorLoginMsg"), otpMsg: $("#doctorOtpMsg"), recoverMsg: $("#doctorRecoverMsg"), resetMsg: $("#doctorResetMsg"),
      otpBackBtn: $("#doctorOtpBackBtn"), forgotPasswordBtn: $("#doctorForgotPasswordBtn"), recoverBackBtn: $("#doctorRecoverBackBtn"), resetBackBtn: $("#doctorResetBackBtn"), logoutBtn: $("#doctorLogoutBtn"),
      patientSearchForm: $("#patientSearchForm"), patientSearchInput: $("#patientSearchInput"), patientList: $("#patientList"), environmentList: $("#environmentList"), selectedPatientHeading: $("#selectedPatientHeading"),
      currentSectionHeading: $("#currentSectionHeading"), todayQueueCount: $("#todayQueueCount"), patientInfoList: $("#patientInfoList"), alertList: $("#alertList"), sensorGrid: $("#sensorGrid"), riskScore: $("#riskScore"), riskLabel: $("#riskLabel"), etaMinutes: $("#etaMinutes"), etaDrivers: $("#etaDrivers"), historyContent: $("#historyContent"),
      todayAppointments: $("#todayAppointments"), openSectionScheduleBtn: $("#openSectionScheduleBtn"), scheduleModal: $("#scheduleModal"), scheduleModalList: $("#scheduleModalList"), closeScheduleModalBtn: $("#closeScheduleModalBtn"), patientPlanForm: $("#patientPlanForm"), patientPlanMsg: $("#patientPlanMsg"), apiBase: window.DARMON_API_BASE,
    };
    if (!refs.workspace || !api) return null;

    const state = { activeSection: 'general', patients: [], filteredPatients: [], selectedPatientId: null, liveAppointments: [], vitalSocket: null, latestAmbulanceRequest: null, globalAmbulanceHistory: [], ambulanceCountdownTimer: null, authMode: 'login', liveVitalsActive: false, patientDetails: new Map(), patientSnapshots: new Map(), patientAlerts: new Map() };
    const doctorApi = (action, payload = {}) => api(action, payload, { includeToken: true, tokenKey });
    const normalize = (value) => String(value || '').trim().toLowerCase();
    const parseDate = (value) => { if (!value) return null; const parsed = value instanceof Date ? value : new Date(value); return Number.isNaN(parsed.getTime()) ? null : parsed; };
    const formatDateTime = (value) => { const parsed = parseDate(value); return parsed ? parsed.toLocaleString([], { year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' }) : '-'; };
    const formatEtaMinutes = (value) => { const minutes = Number(value || 0); if (!Number.isFinite(minutes) || minutes <= 0) return '0 min'; return Math.abs(minutes - Math.round(minutes)) < 0.05 ? `${Math.round(minutes)} min` : `${minutes.toFixed(1)} min`; };
    const getRemainingSeconds = (request) => { if (!request) return 0; const expiresAt = parseDate(request.expires_at); if (!expiresAt) return 0; return Math.max(0, Math.floor((expiresAt.getTime() - Date.now()) / 1000)); };
    const formatCountdown = (seconds) => { const safeSeconds = Math.max(0, Number(seconds || 0)); const minutes = Math.floor(safeSeconds / 60); const remainder = safeSeconds % 60; return minutes <= 0 ? `${remainder}s` : `${minutes}m ${String(remainder).padStart(2, '0')}s`; };
    function syncActiveAmbulanceRequest(request) { if (!request) return null; const remainingSeconds = getRemainingSeconds(request); request.remaining_seconds = remainingSeconds; return remainingSeconds > 0 ? request : null; }
    function prependGlobalAmbulanceHistory(request) { if (!request) return; const nextRows = state.globalAmbulanceHistory.filter((row) => Number(row.id) !== Number(request.id)); nextRows.unshift(request); state.globalAmbulanceHistory = nextRows.slice(0, 8); }
    function buildAmbulanceAlert(request) { const activeRequest = syncActiveAmbulanceRequest(request); if (!activeRequest) return null; return { level: activeRequest.remaining_seconds <= 300 ? 'critical' : 'warning', title: 'Ambulance request active', detail: `Requested at ${formatDateTime(activeRequest.created_at)} for ${activeRequest.full_name || 'patient'}. ETA ${formatCountdown(activeRequest.remaining_seconds)} from ${activeRequest.address || 'reported address'}.` }; }
    function mergeAlertsWithAmbulance(alerts) { const rows = (alerts || []).filter((item) => String(item?.title || '').toLowerCase() !== 'ambulance request active'); const ambulanceAlert = buildAmbulanceAlert(state.latestAmbulanceRequest); return ambulanceAlert ? [ambulanceAlert, ...rows] : rows; }
    const formatLabel = (value) => String(value || '').replace(/_/g, ' ').replace(/\b\w/g, (char) => char.toUpperCase());
    const levelClass = (level) => level === 'critical' ? 'critical' : level === 'warning' ? 'warning' : 'normal';

    return { $, $$, api, escapeHtml, tokenKey, refs, state, doctorApi, normalize, parseDate, formatDateTime, formatEtaMinutes, getRemainingSeconds, formatCountdown, syncActiveAmbulanceRequest, prependGlobalAmbulanceHistory, buildAmbulanceAlert, mergeAlertsWithAmbulance, formatLabel, levelClass };
  };
})();
