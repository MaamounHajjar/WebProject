(function () {
  window.createDoctorAuth = function createDoctorAuth(ctx, ui, patients, liveMonitor) {
    const { api, refs, state } = ctx;
    const { setView, clearAuthMessages, resetLiveVitals, renderSectionState } = ui;

    function redirectToStaffLogin() {
      window.location.replace("admin.html");
    }

    const session = window.createDarmonSessionController({
      api,
      tokenKey: ctx.tokenKey,
      setView,
      onAuthenticated: async () => {
        await ensureDoctorAccess();
      },
      onNetworkError: (_, messageEl) => {
        if (!messageEl) return;
        const suffix = messageEl === refs.loginMsg ? ". Start FastAPI first." : ".";
        messageEl.textContent = `Cannot reach API at ${refs.apiBase}${suffix}`;
      },
    });

    const passwordResetSession = window.createDarmonPasswordResetController({
      api,
      setView,
      onOtpRequired: () => {
        state.authMode = "recovery";
      },
      onCompleted: async (response, email) => {
        state.authMode = "login";
        refs.loginForm.elements.email.value = email || "";
        refs.loginForm.elements.password.value = "";
        refs.otpForm.reset();
        refs.recoverForm.reset();
        refs.resetForm.reset();
        setView("login");
        refs.loginMsg.textContent = response.message || "Password updated. Sign in with your new password.";
        passwordResetSession.clear();
      },
      onNetworkError: (_, messageEl) => {
        if (!messageEl) return;
        messageEl.textContent = `Cannot reach API at ${refs.apiBase}. Start FastAPI first.`;
      },
    });

    async function ensureDoctorAccess() {
      if (!session.getToken()) {
        redirectToStaffLogin();
        return;
      }

      const me = await api("me", {}, { includeToken: true, tokenKey: ctx.tokenKey });
      if (!me.ok) {
        session.clearToken();
        redirectToStaffLogin();
        return;
      }

      if (me.data.role === "admin" || me.data.role === "reception") {
        window.location.replace("admin.html");
        return;
      }

      if (me.data.role !== "doctor") {
        session.clearToken();
        redirectToStaffLogin();
        return;
      }

      try {
        await patients.loadWorkspaceData();
      } catch (error) {
        const message = error?.message || "Doctor access failed.";
        if (/Cannot reach API|Failed to fetch|NetworkError/i.test(message)) {
          throw error;
        }

        session.clearToken();
        refs.loginMsg.textContent = message;
        refs.otpMsg.textContent = message;
        setView("login");
        return;
      }

      renderSectionState();
      setView("workspace");
    }

    function bindAuth() {
      refs.loginForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        state.authMode = "login";
        await session.submitLogin(new FormData(refs.loginForm), refs.loginMsg);
      });

      refs.otpForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const controller = state.authMode === "recovery" ? passwordResetSession : session;
        await controller.submitOtp(new FormData(refs.otpForm), refs.otpMsg);
      });

      refs.otpBackBtn.addEventListener("click", () => {
        refs.otpMsg.textContent = "";
        if (state.authMode === "recovery") {
          setView("recover");
          return;
        }
        session.goBack(refs.otpMsg);
      });

      if (refs.forgotPasswordBtn) {
        refs.forgotPasswordBtn.addEventListener("click", () => {
          clearAuthMessages();
          state.authMode = "recovery";
          refs.recoverForm.elements.email.value = refs.loginForm.elements.email.value || "";
          setView("recover");
        });
      }

      if (refs.recoverBackBtn) {
        refs.recoverBackBtn.addEventListener("click", () => {
          clearAuthMessages();
          state.authMode = "login";
          setView("login");
        });
      }

      refs.recoverForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        state.authMode = "recovery";
        await passwordResetSession.submitRequest(new FormData(refs.recoverForm), refs.recoverMsg);
      });

      if (refs.resetBackBtn) {
        refs.resetBackBtn.addEventListener("click", () => {
          clearAuthMessages();
          state.authMode = "recovery";
          setView("recover");
        });
      }

      refs.resetForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        await passwordResetSession.submitReset(new FormData(refs.resetForm), refs.resetMsg);
      });

      refs.logoutBtn.addEventListener("click", async () => {
        await session.logout();
        liveMonitor.disconnectVitals();
        liveMonitor.stopAmbulanceCountdown();
        refs.loginForm.reset();
        refs.otpForm.reset();
        refs.recoverForm.reset();
        refs.resetForm.reset();
        refs.patientPlanForm.reset();
        resetLiveVitals();
        passwordResetSession.clear();
        window.location.replace("index.html");
      });
    }

    function start() {
      ensureDoctorAccess().catch(() => {
        refs.loginMsg.textContent = `Cannot reach API at ${refs.apiBase}. Start FastAPI first.`;
        setView("login");
      });
    }

    return { bindAuth, ensureDoctorAccess, passwordResetSession, session, start };
  };
})();
