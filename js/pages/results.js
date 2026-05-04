// js/pages/results.js
(function () {
  const $ = window.$;
  const $$ = window.$$;
  const api = window.darmonApi;
  const escapeHtml = window.escapeHtml;
  const apiOrigin = window.DARMON_API_ORIGIN;
  const tokenKey = "darmon_token";
  const staffTokenKey = window.DARMON_STAFF_TOKEN_KEY;
  const transferToken = window.transferDarmonToken;
  const redirectStaffRole = window.redirectDarmonStaffRole;

  let otpContext = "login";
  let authUiRequest = null;
  let accountRefreshRequest = null;

  if (!api) return;

  function isLoggedIn() {
    return !!localStorage.getItem(tokenKey);
  }

  function clearPatientToken() {
    localStorage.removeItem(tokenKey);
  }

  function promoteStaffToken() {
    transferToken(tokenKey, staffTokenKey);
  }

  function setTabVisibility(loggedIn) {
    const loginTabBtn = $('.tab[data-tab="login"]');
    const registerTabBtn = $('.tab[data-tab="register"]');
    const accountTabBtn = $('.tab[data-tab="account"]');

    if (loginTabBtn) loginTabBtn.classList.toggle("hidden", loggedIn);
    if (registerTabBtn) registerTabBtn.classList.toggle("hidden", loggedIn);
    if (accountTabBtn) accountTabBtn.classList.toggle("hidden", !loggedIn);
  }

  function handleAuthenticatedUser(user, options = {}) {
    const { redirectAdmin = false } = options;

    if (user.role === "admin" || user.role === "doctor" || user.role === "reception") {
      promoteStaffToken();
      setTabVisibility(false);
      const accountTabBtn = $('.tab[data-tab="account"]');
      if (accountTabBtn) accountTabBtn.classList.add("hidden");
      showTab("login");
      if (redirectAdmin) {
        redirectStaffRole(user.role);
      }
      return false;
    }

    setTabVisibility(true);
    showTab("account");
    return true;
  }

  function renderAccountOverview(data) {
    const doctorSelect = $("#doctorSelect");
    const myResults = $("#myResults");
    if (!doctorSelect || !myResults) return;

    doctorSelect.innerHTML = data.doctors.length
      ? data.doctors
        .map((doctor) => `<option value="${doctor.id}">${escapeHtml(doctor.full_name)} — ${escapeHtml(doctor.specialty)}</option>`)
        .join("")
      : "<option>No doctors found</option>";

    if (!data.results.length) {
      myResults.innerHTML = `<div class="note">No results yet.</div>`;
      return;
    }

    myResults.innerHTML = data.results.map((result) => {
      const tok = localStorage.getItem(tokenKey);
      const downloadUrl = new URL(result.download_url, apiOrigin).toString();
      const sep = downloadUrl.includes("?") ? "&" : "?";
      const url = tok ? `${downloadUrl}${sep}token=${encodeURIComponent(tok)}` : downloadUrl;
      return `
        <div class="item">
          <div class="top">
            <strong>${escapeHtml(result.test_name)}</strong>
            <a class="btn" href="${url}" target="_blank" rel="noreferrer">⬇ PDF</a>
          </div>
          <div class="note">Receipt: ${escapeHtml(result.receipt_id)} • Uploaded: ${escapeHtml(result.upload_date)}</div>
        </div>
      `;
    }).join("");
  }

  const tabs = $$(".tab");
  const tabButtons = tabs.filter((tab) => tab.dataset.tab);
  const tabsBar = $(".tabs");

  function showTab(name) {
    if (isLoggedIn() && ["login", "register", "recover", "reset", "otp"].includes(name)) {
      name = "account";
    }

    tabButtons.forEach((tab) => tab.classList.toggle("active", tab.dataset.tab === name));
    if (tabsBar) tabsBar.classList.toggle("hidden", ["otp", "recover", "reset"].includes(name));

    ["login", "register", "otp", "account", "recover", "reset"].forEach((key) => {
      const el = $("#tab-" + key);
      if (el) el.classList.toggle("hidden", key !== name);
    });
  }

  if (tabButtons.length) {
    tabButtons.forEach((tab) => tab.addEventListener("click", () => showTab(tab.dataset.tab)));
  }

  const loginForm = $("#loginForm");
  const registerForm = $("#registerForm");
  const loginMsg = $("#loginMsg");
  const registerMsg = $("#registerMsg");
  const otpForm = $("#otpForm");
  const otpMsg = $("#otpMsg");
  const otpBackBtn = $("#otpBackBtn");
  const forgotPasswordBtn = $("#forgotPasswordBtn");
  const recoverForm = $("#recoverForm");
  const recoverMsg = $("#recoverMsg");
  const recoverBackBtn = $("#recoverBackBtn");
  const resetForm = $("#resetPasswordForm");
  const resetMsg = $("#resetMsg");
  const resetBackBtn = $("#resetBackBtn");
  const rememberDevice = $("#rememberDevice");

  function clearAuthMessages() {
    if (loginMsg) loginMsg.textContent = "";
    if (registerMsg) registerMsg.textContent = "";
    if (otpMsg) otpMsg.textContent = "";
    if (recoverMsg) recoverMsg.textContent = "";
    if (resetMsg) resetMsg.textContent = "";
  }

  function resetAuthForms() {
    if (loginForm) loginForm.reset();
    if (registerForm) registerForm.reset();
    if (otpForm) otpForm.reset();
    if (recoverForm) recoverForm.reset();
    if (resetForm) resetForm.reset();
  }

  function resetLoggedOutUi() {
    clearAuthMessages();
    resetAuthForms();
    otpContext = "login";
    if (passwordResetSession) passwordResetSession.clear();
    setTabVisibility(false);
    showTab("login");
  }

  async function handlePatientAuthenticated(user) {
    if (!handleAuthenticatedUser(user, { redirectAdmin: true })) {
      return;
    }
    await refreshAccount();
  }

  function setOfflineMessage(messageEl) {
    if (messageEl) {
      messageEl.textContent = "Backend not running (demo only).";
    }
  }

  const loginSession = window.createDarmonSessionController({
    api,
    tokenKey,
    setView: showTab,
    onOtpRequired: () => {
      otpContext = "login";
    },
    getOtpPayload: (formData, email) => ({
      email,
      otp: formData.get("otp"),
      remember_device: rememberDevice && rememberDevice.checked ? 1 : 0,
    }),
    onAuthenticated: async (user) => {
      await handlePatientAuthenticated(user);
    },
    onNetworkError: (_, messageEl) => {
      setOfflineMessage(messageEl);
    },
  });

  const registerSession = window.createDarmonSessionController({
    api,
    tokenKey,
    loginAction: "register",
    otpAction: "verify_register_otp",
    submitMessage: "Sending verification code...",
    submitErrorMessage: "Register failed",
    otpSteps: ["otp_sent"],
    setView: showTab,
    onOtpRequired: () => {
      otpContext = "register";
    },
    getLoginPayload: (formData, email) => ({
      name: formData.get("name"),
      phone: formData.get("phone"),
      email,
      password: formData.get("password"),
    }),
    getOtpPayload: (formData, email) => ({
      email,
      otp: formData.get("otp"),
      remember_device: rememberDevice && rememberDevice.checked ? 1 : 0,
    }),
    onAuthenticated: async (user) => {
      await handlePatientAuthenticated(user);
    },
    onNetworkError: (_, messageEl) => {
      setOfflineMessage(messageEl);
    },
  });

  const passwordResetSession = window.createDarmonPasswordResetController({
    api,
    setView: showTab,
    onOtpRequired: () => {
      otpContext = "recovery";
    },
    onCompleted: async (response, email) => {
      otpContext = "login";
      if (loginForm) {
        loginForm.elements.email.value = email || "";
        loginForm.elements.password.value = "";
      }
      if (otpForm) otpForm.reset();
      if (recoverForm) recoverForm.reset();
      if (resetForm) resetForm.reset();
      showTab("login");
      if (loginMsg) {
        loginMsg.textContent = response.message || "Password updated. Sign in with your new password.";
      }
      passwordResetSession.clear();
    },
    onNetworkError: (_, messageEl) => {
      setOfflineMessage(messageEl);
    },
  });

  const qcForm = $("#quickCheckForm");
  if (qcForm) {
    qcForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      const msg = $("#quickCheckMsg");
      const out = $("#quickCheckResult");
      if (!msg || !out) return;

      msg.textContent = "Checking...";
      out.innerHTML = "";

      const formData = new FormData(qcForm);

      try {
        const response = await api("quick_check", {
          receipt_id: formData.get("receipt_id"),
          date: formData.get("date"),
        });
        if (!response.ok) {
          msg.textContent = response.error || "Not found";
          return;
        }

        msg.textContent = "";
        out.innerHTML = `
          <div class="item">
            <div class="top">
              <strong>${escapeHtml(response.data.receipt_id)}</strong>
              <span class="tag">${escapeHtml(response.data.status)}</span>
            </div>
            <div style="color:var(--muted);font-weight:700;margin-top:6px">
              Test: ${escapeHtml(response.data.test_name)} • Date: ${escapeHtml(response.data.sample_date)}
            </div>
          </div>`;
      } catch {
        msg.textContent = "Backend not running. (Demo) Try receipt DS-2026-00021.";
      }
    });
  }

  async function refreshAccount() {
    if (accountRefreshRequest) {
      return accountRefreshRequest;
    }

    const doctorSelect = $("#doctorSelect");
    const myResults = $("#myResults");
    if (!doctorSelect || !myResults) return;

    accountRefreshRequest = (async () => {
      doctorSelect.innerHTML = "<option>Loading...</option>";
      myResults.innerHTML = "";

      try {
        const response = await api("account_overview", {}, { includeToken: true });
        if (!response.ok) {
          doctorSelect.innerHTML = "<option>Backend error</option>";
          if (response.error === "Not logged in.") {
            clearPatientToken();
            resetLoggedOutUi();
            return;
          }
          myResults.innerHTML = `<div class="note">${escapeHtml(response.error || "No data")}</div>`;
          return;
        }

        if (!handleAuthenticatedUser(response.data.user)) {
          return;
        }
        renderAccountOverview(response.data);
      } catch {
        doctorSelect.innerHTML = "<option>Backend not running</option>";
        myResults.innerHTML = `<div class="note">Backend not running.</div>`;
      }
    })();

    try {
      await accountRefreshRequest;
    } finally {
      accountRefreshRequest = null;
    }
  }

  async function updateAuthUI() {
    if (authUiRequest) {
      return authUiRequest;
    }

    authUiRequest = (async () => {
      if (!tabs.length) return;
      if (!isLoggedIn()) {
        resetLoggedOutUi();
        return;
      }

      await refreshAccount();
      if (!isLoggedIn()) {
        resetLoggedOutUi();
      }
    })();

    try {
      await authUiRequest;
    } finally {
      authUiRequest = null;
    }
  }

  window.addEventListener("pageshow", (event) => {
    if (event.persisted) {
      updateAuthUI();
    }
  });

  if (otpBackBtn) {
    otpBackBtn.addEventListener("click", () => {
      otpMsg.textContent = "";
      if (otpContext === "register") {
        showTab("register");
        return;
      }
      if (otpContext === "recovery") {
        showTab("recover");
        return;
      }
      showTab("login");
    });
  }

  if (otpForm) {
    otpForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      const activeSession = otpContext === "register"
        ? registerSession
        : otpContext === "recovery"
          ? passwordResetSession
          : loginSession;
      await activeSession.submitOtp(new FormData(otpForm), otpMsg);
    });
  }

  if (loginForm) {
    loginForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      await loginSession.submitLogin(new FormData(loginForm), loginMsg);
    });
  }

  if (registerForm) {
    registerForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      await registerSession.submitLogin(new FormData(registerForm), registerMsg);
    });
  }

  if (forgotPasswordBtn) {
    forgotPasswordBtn.addEventListener("click", () => {
      clearAuthMessages();
      otpContext = "recovery";
      if (recoverForm && loginForm) {
        recoverForm.elements.email.value = loginForm.elements.email.value || "";
      }
      showTab("recover");
    });
  }

  if (recoverBackBtn) {
    recoverBackBtn.addEventListener("click", () => {
      clearAuthMessages();
      otpContext = "login";
      showTab("login");
    });
  }

  if (recoverForm) {
    recoverForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      await passwordResetSession.submitRequest(new FormData(recoverForm), recoverMsg);
    });
  }

  if (resetBackBtn) {
    resetBackBtn.addEventListener("click", () => {
      clearAuthMessages();
      showTab("recover");
    });
  }

  if (resetForm) {
    resetForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      await passwordResetSession.submitReset(new FormData(resetForm), resetMsg);
    });
  }

  const logoutBtn = $("#logoutBtn");
  if (logoutBtn) {
    logoutBtn.addEventListener("click", async () => {
      await loginSession.logout();
      resetLoggedOutUi();
    });
  }

  const apptForm = $("#appointmentForm");
  const apptMsg = $("#apptMsg");
  if (apptForm) {
    apptForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      if (apptMsg) apptMsg.textContent = "Booking...";

      const formData = new FormData(apptForm);
      try {
        const response = await api("book_appointment", {
          doctor_id: formData.get("doctor_id"),
          appointment_date: formData.get("appointment_date"),
          time_slot: formData.get("time_slot"),
        }, { includeToken: true });

        if (!response.ok) {
          if (apptMsg) apptMsg.textContent = response.error || "Failed";
          return;
        }
        if (apptMsg) apptMsg.textContent = "Booked";
      } catch {
        if (apptMsg) apptMsg.textContent = "Backend not running (demo only).";
      }
    });
  }

  updateAuthUI();
})();
