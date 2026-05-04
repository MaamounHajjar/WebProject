(function () {
  const apiBase = window.DARMON_API_BASE;
  const apiUrl = new URL("/api", apiBase).toString();
  const defaultTokenKey = "darmon_token";
  const staffTokenKey = "darmon_staff_token";

  function transferToken(fromKey, toKey) {
    const token = localStorage.getItem(fromKey);
    if (!token) return null;
    localStorage.setItem(toKey, token);
    localStorage.removeItem(fromKey);
    return token;
  }

  window.darmonApi = async function darmonApi(action, payload = {}, options = {}) {
    const { includeToken = false, tokenKey = defaultTokenKey } = options;
    const body = { action, ...payload };

    if (includeToken) {
      body.token = localStorage.getItem(tokenKey);
    }

    const response = await fetch(apiUrl, {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    return response.json();
  };

  window.createDarmonSessionController = function createDarmonSessionController(options = {}) {
    const {
      api = window.darmonApi,
      tokenKey = staffTokenKey,
      loginAction = "login",
      otpAction = "verify_login_otp",
      submitMessage = "Signing in...",
      submitErrorMessage = "Login failed",
      otpSteps = ["otp_required"],
      getLoginPayload = (formData, email) => ({
        email,
        password: formData.get("password"),
      }),
      getOtpPayload = (formData, email) => ({
        email,
        otp: formData.get("otp"),
        remember_device: 0,
      }),
      setView = () => {},
      onOtpRequired = () => {},
      onAuthenticated = async () => {},
      onNetworkError = () => {},
    } = options;

    let loginEmail = "";

    function getToken() {
      return localStorage.getItem(tokenKey);
    }

    function storeToken(token) {
      localStorage.setItem(tokenKey, token);
    }

    function clearToken() {
      localStorage.removeItem(tokenKey);
    }

    async function submitLogin(formData, messageEl) {
      if (messageEl) {
        messageEl.textContent = submitMessage;
      }

      try {
        loginEmail = String(formData.get("email") || "").trim();
        const response = await api(loginAction, getLoginPayload(formData, loginEmail));

        if (!response.ok) {
          if (messageEl) {
            messageEl.textContent = response.error || submitErrorMessage;
          }
          return response;
        }

        if (otpSteps.includes(response.step)) {
          if (messageEl) {
            messageEl.textContent = "";
          }
          onOtpRequired(response, formData, loginEmail);
          setView("otp");
          return response;
        }

        storeToken(response.data.token);
        if (messageEl) {
          messageEl.textContent = "";
        }
        await onAuthenticated(response.data.user, response);
        return response;
      } catch (error) {
        onNetworkError(error, messageEl);
        return null;
      }
    }

    async function submitOtp(formData, messageEl) {
      if (messageEl) {
        messageEl.textContent = "Verifying...";
      }

      try {
        const response = await api(otpAction, getOtpPayload(formData, loginEmail), { includeToken: true, tokenKey });

        if (!response.ok) {
          if (messageEl) {
            messageEl.textContent = response.error || "Invalid code";
          }
          return response;
        }

        storeToken(response.data.token);
        if (messageEl) {
          messageEl.textContent = "";
        }
        await onAuthenticated(response.data.user, response);
        return response;
      } catch (error) {
        onNetworkError(error, messageEl);
        return null;
      }
    }

    function goBack(messageEl) {
      if (messageEl) {
        messageEl.textContent = "";
      }
      setView("login");
    }

    async function logout() {
      const token = getToken();
      if (token) {
        await api("logout", {}, { includeToken: true, tokenKey }).catch(() => {});
      }
      clearToken();
    }

    return {
      getToken,
      clearToken,
      logout,
      submitLogin,
      submitOtp,
      goBack,
    };
  };

  window.createDarmonPasswordResetController = function createDarmonPasswordResetController(options = {}) {
    const {
      api = window.darmonApi,
      requestAction = "request_password_reset",
      verifyAction = "verify_password_reset_otp",
      resetAction = "reset_password",
      requestMessage = "Sending verification code...",
      verifyMessage = "Verifying...",
      resetMessage = "Updating password...",
      requestErrorMessage = "Could not send code",
      verifyErrorMessage = "Invalid code",
      resetErrorMessage = "Password update failed",
      setView = () => {},
      onOtpRequired = () => {},
      onPasswordResetReady = () => {},
      onCompleted = async () => {},
      onNetworkError = () => {},
    } = options;

    let recoveryEmail = "";

    function setEmail(email) {
      recoveryEmail = String(email || "").trim();
    }

    function getEmail() {
      return recoveryEmail;
    }

    function clear() {
      recoveryEmail = "";
    }

    async function submitRequest(formData, messageEl) {
      if (messageEl) {
        messageEl.textContent = requestMessage;
      }

      try {
        setEmail(formData.get("email"));
        const response = await api(requestAction, { email: recoveryEmail });

        if (!response.ok) {
          if (messageEl) {
            messageEl.textContent = response.error || requestErrorMessage;
          }
          return response;
        }

        if (messageEl) {
          messageEl.textContent = "";
        }
        onOtpRequired(response, formData, recoveryEmail);
        setView("otp");
        return response;
      } catch (error) {
        onNetworkError(error, messageEl);
        return null;
      }
    }

    async function submitOtp(formData, messageEl) {
      if (messageEl) {
        messageEl.textContent = verifyMessage;
      }

      try {
        const response = await api(verifyAction, {
          email: recoveryEmail,
          otp: formData.get("otp"),
        });

        if (!response.ok) {
          if (messageEl) {
            messageEl.textContent = response.error || verifyErrorMessage;
          }
          return response;
        }

        if (messageEl) {
          messageEl.textContent = "";
        }
        onPasswordResetReady(response, formData, recoveryEmail);
        setView("reset");
        return response;
      } catch (error) {
        onNetworkError(error, messageEl);
        return null;
      }
    }

    async function submitReset(formData, messageEl) {
      if (messageEl) {
        messageEl.textContent = resetMessage;
      }

      try {
        const response = await api(resetAction, {
          email: recoveryEmail,
          password: formData.get("password"),
          confirm_password: formData.get("confirm_password"),
        });

        if (!response.ok) {
          if (messageEl) {
            messageEl.textContent = response.error || resetErrorMessage;
          }
          return response;
        }

        if (messageEl) {
          messageEl.textContent = response.message || "";
        }
        await onCompleted(response, recoveryEmail, formData);
        return response;
      } catch (error) {
        onNetworkError(error, messageEl);
        return null;
      }
    }

    return {
      clear,
      getEmail,
      setEmail,
      submitOtp,
      submitRequest,
      submitReset,
    };
  };

  window.transferDarmonToken = transferToken;
  window.redirectDarmonStaffRole = function redirectDarmonStaffRole(role) {
    window.location.href = role === "doctor" ? "doctors.html" : "admin.html";
  };
  window.DARMON_STAFF_TOKEN_KEY = staffTokenKey;
  window.DARMON_API_ORIGIN = new URL(apiUrl).origin;
})();
