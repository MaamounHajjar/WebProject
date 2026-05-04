(function () {
  const $ = window.$;
  const api = window.darmonApi;
  const escapeHtml = window.escapeHtml;
  const formatValue = window.formatValue;
  const tokenKey = window.DARMON_STAFF_TOKEN_KEY;

  if (!api) return;

  const loginPanel = $("#loginPanel");
  const otpPanel = $("#otpPanel");
  const recoverPanel = $("#recoverPanel");
  const resetPanel = $("#resetPanel");
  const dashboard = $("#adminDashboard");
  const heading = $("#staffHeading");
  const intro = $("#staffIntro");
  const loginForm = $("#adminLoginForm");
  const otpForm = $("#adminOtpForm");
  const recoverForm = $("#adminRecoverForm");
  const resetForm = $("#adminResetForm");
  const loginMsg = $("#adminLoginMsg");
  const otpMsg = $("#adminOtpMsg");
  const recoverMsg = $("#adminRecoverMsg");
  const resetMsg = $("#adminResetMsg");
  const otpBackBtn = $("#adminOtpBackBtn");
  const forgotPasswordBtn = $("#adminForgotPasswordBtn");
  const recoverBackBtn = $("#adminRecoverBackBtn");
  const resetBackBtn = $("#adminResetBackBtn");
  const logoutBtn = $("#adminLogoutBtn");
  const stats = $("#adminStats");
  const callbacksBody = $("#callbacksBody");
  const appointmentsBody = $("#appointmentsBody");
  const vacanciesRoot = $("#adminVacancies");
  const vacanciesPanel = $("#vacanciesPanel");
  const doctorManagementPanel = $("#doctorManagementPanel");
  const bookingForm = $("#adminBookingForm");
  const bookingMsg = $("#adminBookingMsg");
  const patientSelect = $("#adminPatientSelect");
  const doctorSelect = $("#adminDoctorSelect");
  const patientModeSelect = $("#patientModeSelect");
  const existingPatientFields = $("#existingPatientFields");
  const newPatientFields = $("#newPatientFields");
  const doctorForm = $("#doctorForm");
  const doctorMsg = $("#doctorMsg");
  const doctorResetBtn = $("#doctorResetBtn");
  const doctorRoot = $("#adminDoctors");
  const departmentOptions = $("#departmentOptions");
  const vacancyForm = $("#vacancyForm");
  const vacancyMsg = $("#vacancyMsg");
  const vacancyResetBtn = $("#vacancyResetBtn");

  let currentVacancies = [];
  let currentDoctors = [];
  let currentRole = "";
  let authMode = "login";

  function redirectToRoleWorkspace(role) {
    window.redirectDarmonStaffRole(role);
  }

  function staffApi(action, payload = {}) {
    return api(action, payload, { includeToken: true, tokenKey });
  }

  function setView(view) {
    loginPanel.classList.toggle("hidden", view !== "login");
    otpPanel.classList.toggle("hidden", view !== "otp");
    recoverPanel.classList.toggle("hidden", view !== "recover");
    resetPanel.classList.toggle("hidden", view !== "reset");
    dashboard.classList.toggle("hidden", view !== "dashboard");
    document.body.classList.toggle("staff-only-view", ["dashboard", "otp", "recover", "reset"].includes(view));
  }

  function clearAuthMessages() {
    loginMsg.textContent = "";
    otpMsg.textContent = "";
    recoverMsg.textContent = "";
    resetMsg.textContent = "";
  }

  const session = window.createDarmonSessionController({
    api,
    tokenKey,
    setView,
    onAuthenticated: async (user) => {
      if (user.role === "doctor") {
        redirectToRoleWorkspace(user.role);
        return;
      }

      if (user.role !== "admin" && user.role !== "reception") {
        session.clearToken();
        loginMsg.textContent = "Only staff accounts can sign in here.";
        otpMsg.textContent = "Only staff accounts can sign in here.";
        setView("login");
        return;
      }

      await loadDashboard();
    },
    onNetworkError: (_, messageEl) => {
      if (messageEl) {
        messageEl.textContent = "Backend not running.";
      }
    },
  });

  const passwordResetSession = window.createDarmonPasswordResetController({
    api,
    setView,
    onOtpRequired: () => {
      authMode = "recovery";
    },
    onCompleted: async (response, email) => {
      authMode = "login";
      if (loginForm) {
        loginForm.elements.email.value = email || "";
        loginForm.elements.password.value = "";
      }
      if (otpForm) otpForm.reset();
      if (recoverForm) recoverForm.reset();
      if (resetForm) resetForm.reset();
      setView("login");
      loginMsg.textContent = response.message || "Password updated. Sign in with your new password.";
      passwordResetSession.clear();
    },
    onNetworkError: (_, messageEl) => {
      if (messageEl) {
        messageEl.textContent = "Backend not running.";
      }
    },
  });

  function applyRolePresentation(role) {
    currentRole = role;
    if (heading) heading.textContent = role === "admin" ? "Admin dashboard" : "Reception dashboard";
    if (intro) {
      intro.textContent = role === "admin"
        ? "Review callback requests, appointment bookings, and vacancies."
        : "Reception can book visits, manage callback requests, and update appointment statuses.";
    }
    if (vacanciesPanel) vacanciesPanel.classList.toggle("hidden", role !== "admin");
    if (doctorManagementPanel) doctorManagementPanel.classList.toggle("hidden", role !== "admin");
  }

  function renderStats(data) {
    const thirdLabel = currentRole === "admin" ? "Vacancies" : "Active doctors";
    const thirdValue = currentRole === "admin" ? data.vacancies.length : data.doctors.length;

    stats.innerHTML = `
      <div class="stat-card">
        <span class="note">Callback requests</span>
        <strong>${data.callbacks.length}</strong>
      </div>
      <div class="stat-card">
        <span class="note">Appointments</span>
        <strong>${data.appointments.length}</strong>
      </div>
      <div class="stat-card">
        <span class="note">${thirdLabel}</span>
        <strong>${thirdValue}</strong>
      </div>
    `;
  }

  function renderCallbacks(rows) {
    callbacksBody.innerHTML = rows.length
      ? rows.map((row) => `
          <tr>
            <td>${row.first_name} ${row.last_name}</td>
            <td>${formatValue(row.phone)}</td>
            <td>${formatValue(row.preferred_time)}</td>
            <td>${formatValue(row.created_at)}</td>
          </tr>
        `).join("")
      : `<tr><td colspan="4">No callback requests yet.</td></tr>`;
  }

  function renderSelectOptions(select, rows, emptyLabel, formatter) {
    select.innerHTML = rows.length
      ? rows.map(formatter).join("")
      : `<option value="">${emptyLabel}</option>`;
  }

  function syncPatientMode() {
    const mode = patientModeSelect.value;
    const isExisting = mode === "existing";
    existingPatientFields.classList.toggle("hidden", !isExisting);
    newPatientFields.classList.toggle("hidden", isExisting);
    patientSelect.required = isExisting;
    bookingForm.elements.new_patient_name.required = !isExisting;
    bookingForm.elements.new_patient_phone.required = !isExisting;
    bookingForm.elements.new_patient_email.required = !isExisting;
    bookingForm.elements.new_patient_password.required = !isExisting;
  }

  function renderAppointments(rows) {
    appointmentsBody.innerHTML = rows.length
      ? rows.map((row) => `
          <tr>
            <td>
              <strong>${formatValue(row.patient_name)}</strong><br>
              <span class="note">${formatValue(row.patient_email)}</span>
            </td>
            <td>
              <strong>${formatValue(row.doctor_name)}</strong><br>
              <span class="note">${formatValue(row.doctor_specialty)}</span>
            </td>
            <td>${formatValue(row.appointment_date)}</td>
            <td>${formatValue(row.time_slot)}</td>
            <td>${formatValue(row.status)}</td>
            <td>
              <div class="status-controls">
                <select data-appointment-status="${row.id}">
                  ${["booked", "completed", "canceled"].map((status) => `
                    <option value="${status}" ${row.status === status ? "selected" : ""}>${status}</option>
                  `).join("")}
                </select>
                <button class="btn" type="button" data-appointment-save="${row.id}">Save</button>
              </div>
            </td>
          </tr>
        `).join("")
      : `<tr><td colspan="6">No appointments yet.</td></tr>`;
  }

  function renderVacancies(rows) {
    currentVacancies = rows;
    vacanciesRoot.innerHTML = rows.length
      ? rows.map((row) => {
          const requirements = (row.requirements || "")
            .split("\n")
            .filter(Boolean)
            .map((item) => `<li>${item}</li>`)
            .join("");

          return `
            <article class="vacancy-item">
              <h4>${row.title}</h4>
              <p>${row.description}</p>
              <ul>${requirements}</ul>
              <div class="vacancy-actions">
                <button class="btn" type="button" data-vacancy-edit="${row.id}">Edit</button>
                <button class="btn" type="button" data-vacancy-delete="${row.id}">Delete</button>
              </div>
            </article>
          `;
        }).join("")
      : `<div class="note">No vacancies found.</div>`;
  }

  function renderDepartments(rows) {
    if (!departmentOptions) return;
    departmentOptions.innerHTML = rows.map((row) => `<option value="${escapeHtml(row.name)}"></option>`).join("");
  }

  function renderDoctors(rows) {
    currentDoctors = rows;
    doctorRoot.innerHTML = rows.length
      ? rows.map((row) => `
          <article class="doctor-item">
            <div class="doctor-item-head">
              <div>
                <h4>${escapeHtml(formatValue(row.full_name))}</h4>
                <p class="note">${escapeHtml(formatValue(row.specialty))}${row.department_name ? ` • ${escapeHtml(row.department_name)}` : ""}</p>
              </div>
              <span class="doctor-status ${row.is_active ? "is-active" : "is-inactive"}">${row.is_active ? "Active" : "Inactive"}</span>
            </div>
            <div class="doctor-meta-grid">
              <div><strong>Email:</strong> ${escapeHtml(formatValue(row.account_email))}</div>
              <div><strong>Phone:</strong> ${escapeHtml(formatValue(row.account_phone))}</div>
              <div><strong>Experience:</strong> ${escapeHtml(formatValue(row.experience_years))} years</div>
              <div><strong>Image:</strong> ${escapeHtml(formatValue(row.image_url))}</div>
            </div>
            <p class="doctor-bio">${escapeHtml(formatValue(row.bio))}</p>
            <div class="vacancy-actions">
              <button class="btn" type="button" data-doctor-edit="${row.id}">Edit</button>
              <button class="btn" type="button" data-doctor-disable="${row.id}">Deactivate</button>
            </div>
          </article>
        `).join("")
      : `<div class="note">No doctors found.</div>`;
  }

  function resetDoctorForm() {
    if (!doctorForm) return;
    doctorForm.reset();
    doctorForm.elements.id.value = "";
    doctorForm.elements.experience_years.value = "0";
    doctorForm.elements.is_active.value = "1";
    doctorMsg.textContent = "";
  }

  function resetVacancyForm() {
    if (!vacancyForm) return;
    vacancyForm.reset();
    vacancyForm.elements.id.value = "";
    vacancyMsg.textContent = "";
  }

  async function loadDashboard() {
    const token = session.getToken();
    if (!token) {
      setView("login");
      return;
    }

    const me = await api("me", {}, { includeToken: true, tokenKey });
    if (!me.ok) {
      session.clearToken();
      loginMsg.textContent = me.error || "Staff access failed";
      setView("login");
      return;
    }

    if (me.data.role === "doctor") {
      redirectToRoleWorkspace(me.data.role);
      return;
    }

    if (me.data.role !== "admin" && me.data.role !== "reception") {
      session.clearToken();
      loginMsg.textContent = "Only staff accounts can sign in here.";
      setView("login");
      return;
    }

    applyRolePresentation(me.data.role);

    const response = await staffApi("staff_dashboard");
    if (!response.ok) {
      session.clearToken();
      loginMsg.textContent = response.error || "Staff access failed";
      setView("login");
      return;
    }

    renderStats(response.data);
    renderCallbacks(response.data.callbacks);
    renderAppointments(response.data.appointments);
    if (currentRole === "admin") {
      renderVacancies(response.data.vacancies);
      renderDoctors(response.data.admin_doctors || []);
      renderDepartments(response.data.departments || []);
    }
    renderSelectOptions(
      patientSelect,
      response.data.patients,
      "No patients found",
      (row) => `<option value="${row.id}">${row.name} — ${row.phone}</option>`
    );
    renderSelectOptions(
      doctorSelect,
      response.data.doctors,
      "No doctors found",
      (row) => `<option value="${row.id}">${row.full_name} — ${row.specialty}</option>`
    );
    setView("dashboard");
  }

  loginForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    authMode = "login";
    await session.submitLogin(new FormData(loginForm), loginMsg);
  });

  otpForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const controller = authMode === "recovery" ? passwordResetSession : session;
    await controller.submitOtp(new FormData(otpForm), otpMsg);
  });

  if (otpBackBtn) {
    otpBackBtn.addEventListener("click", () => {
      otpMsg.textContent = "";
      if (authMode === "recovery") {
        setView("recover");
        return;
      }
      session.goBack(otpMsg);
    });
  }

  if (forgotPasswordBtn) {
    forgotPasswordBtn.addEventListener("click", () => {
      clearAuthMessages();
      authMode = "recovery";
      if (recoverForm && loginForm) {
        recoverForm.elements.email.value = loginForm.elements.email.value || "";
      }
      setView("recover");
    });
  }

  if (recoverBackBtn) {
    recoverBackBtn.addEventListener("click", () => {
      clearAuthMessages();
      authMode = "login";
      setView("login");
    });
  }

  if (recoverForm) {
    recoverForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      authMode = "recovery";
      await passwordResetSession.submitRequest(new FormData(recoverForm), recoverMsg);
    });
  }

  if (resetBackBtn) {
    resetBackBtn.addEventListener("click", () => {
      clearAuthMessages();
      authMode = "recovery";
      setView("recover");
    });
  }

  if (resetForm) {
    resetForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      await passwordResetSession.submitReset(new FormData(resetForm), resetMsg);
    });
  }

  logoutBtn.addEventListener("click", async () => {
    await session.logout();
    loginForm.reset();
    otpForm.reset();
    recoverForm.reset();
    resetForm.reset();
    bookingForm.reset();
    syncPatientMode();
    resetDoctorForm();
    resetVacancyForm();
    passwordResetSession.clear();
    window.location.href = "index.html";
  });

  bookingForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    bookingMsg.textContent = "Booking...";

    const formData = new FormData(bookingForm);
    const response = await staffApi("admin_book_appointment", {
      patient_mode: formData.get("patient_mode"),
      patient_id: formData.get("patient_id"),
      new_patient_name: formData.get("new_patient_name"),
      new_patient_phone: formData.get("new_patient_phone"),
      new_patient_email: formData.get("new_patient_email"),
      new_patient_password: formData.get("new_patient_password"),
      doctor_id: formData.get("doctor_id"),
      appointment_date: formData.get("appointment_date"),
      time_slot: formData.get("time_slot"),
    });

    if (!response.ok) {
      bookingMsg.textContent = response.error || "Booking failed";
      return;
    }

    bookingMsg.textContent = "Booked";
    bookingForm.reset();
    syncPatientMode();
    await loadDashboard();
  });

  patientModeSelect.addEventListener("change", syncPatientMode);

  appointmentsBody.addEventListener("click", async (event) => {
    const button = event.target.closest("[data-appointment-save]");
    if (!button) return;

    const appointmentId = button.getAttribute("data-appointment-save");
    const select = appointmentsBody.querySelector(`[data-appointment-status="${appointmentId}"]`);
    if (!select) return;

    const response = await staffApi("admin_update_appointment_status", {
      appointment_id: Number(appointmentId),
      status: select.value,
    });

    if (!response.ok) {
      loginMsg.textContent = response.error || "Status update failed";
      return;
    }

    await loadDashboard();
  });

  doctorForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    if (currentRole !== "admin") return;
    doctorMsg.textContent = "Saving...";

    const formData = new FormData(doctorForm);
    const response = await staffApi("admin_save_doctor", {
      id: Number(formData.get("id") || 0),
      full_name: formData.get("full_name"),
      specialty: formData.get("specialty"),
      department_name: formData.get("department_name"),
      experience_years: Number(formData.get("experience_years") || 0),
      email: formData.get("email"),
      phone: formData.get("phone"),
      password: formData.get("password"),
      image_url: formData.get("image_url"),
      bio: formData.get("bio"),
      is_active: String(formData.get("is_active")) === "1",
    });

    if (!response.ok) {
      doctorMsg.textContent = response.error || "Save failed";
      return;
    }

    doctorMsg.textContent = "Saved";
    resetDoctorForm();
    await loadDashboard();
  });

  doctorResetBtn.addEventListener("click", () => {
    resetDoctorForm();
  });

  doctorRoot.addEventListener("click", async (event) => {
    if (currentRole !== "admin") return;

    const editButton = event.target.closest("[data-doctor-edit]");
    if (editButton) {
      const doctorId = Number(editButton.getAttribute("data-doctor-edit"));
      const doctor = currentDoctors.find((item) => item.id === doctorId);
      if (!doctor) return;

      doctorForm.elements.id.value = doctor.id;
      doctorForm.elements.full_name.value = doctor.full_name || "";
      doctorForm.elements.specialty.value = doctor.specialty || "";
      doctorForm.elements.department_name.value = doctor.department_name || "";
      doctorForm.elements.experience_years.value = String(doctor.experience_years || 0);
      doctorForm.elements.email.value = doctor.account_email || "";
      doctorForm.elements.phone.value = doctor.account_phone || "";
      doctorForm.elements.password.value = "";
      doctorForm.elements.image_url.value = doctor.image_url || "";
      doctorForm.elements.bio.value = doctor.bio || "";
      doctorForm.elements.is_active.value = doctor.is_active ? "1" : "0";
      doctorMsg.textContent = "Editing doctor";
      doctorForm.scrollIntoView({ behavior: "smooth", block: "nearest" });
      return;
    }

    const disableButton = event.target.closest("[data-doctor-disable]");
    if (!disableButton) return;

    const doctorId = Number(disableButton.getAttribute("data-doctor-disable"));
    if (!window.confirm("Deactivate this doctor? They will be removed from active booking lists.")) {
      return;
    }

    const response = await staffApi("admin_delete_doctor", { id: doctorId });
    if (!response.ok) {
      doctorMsg.textContent = response.error || "Deactivate failed";
      return;
    }

    doctorMsg.textContent = "Doctor deactivated";
    if (Number(doctorForm.elements.id.value || 0) === doctorId) {
      resetDoctorForm();
    }
    await loadDashboard();
  });

  vacancyForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    if (currentRole !== "admin") return;
    vacancyMsg.textContent = "Saving...";

    const formData = new FormData(vacancyForm);
    const response = await staffApi("admin_save_vacancy", {
      id: Number(formData.get("id") || 0),
      title: formData.get("title"),
      description: formData.get("description"),
      requirements: formData.get("requirements"),
      is_active: String(formData.get("is_active")) === "1",
    });

    if (!response.ok) {
      vacancyMsg.textContent = response.error || "Save failed";
      return;
    }

    vacancyMsg.textContent = "Saved";
    resetVacancyForm();
    await loadDashboard();
  });

  vacancyResetBtn.addEventListener("click", () => {
    resetVacancyForm();
  });

  vacanciesRoot.addEventListener("click", async (event) => {
    if (currentRole !== "admin") return;

    const editButton = event.target.closest("[data-vacancy-edit]");
    if (editButton) {
      const vacancyId = Number(editButton.getAttribute("data-vacancy-edit"));
      const vacancy = currentVacancies.find((item) => item.id === vacancyId);
      if (!vacancy) return;

      vacancyForm.elements.id.value = vacancy.id;
      vacancyForm.elements.title.value = vacancy.title;
      vacancyForm.elements.description.value = vacancy.description;
      vacancyForm.elements.requirements.value = vacancy.requirements;
      vacancyForm.elements.is_active.value = vacancy.is_active ? "1" : "0";
      vacancyMsg.textContent = "Editing vacancy";
      vacancyForm.scrollIntoView({ behavior: "smooth", block: "nearest" });
      return;
    }

    const deleteButton = event.target.closest("[data-vacancy-delete]");
    if (!deleteButton) return;

    const vacancyId = Number(deleteButton.getAttribute("data-vacancy-delete"));
    if (!window.confirm("Delete this vacancy? This cannot be undone.")) {
      return;
    }

    const response = await staffApi("admin_delete_vacancy", { id: vacancyId });
    if (!response.ok) {
      vacancyMsg.textContent = response.error || "Delete failed";
      return;
    }

    vacancyMsg.textContent = "Deleted";
    if (Number(vacancyForm.elements.id.value || 0) === vacancyId) {
      resetVacancyForm();
    }
    await loadDashboard();
  });

  loadDashboard().catch(() => {
    loginMsg.textContent = "Backend not running.";
    setView("login");
  });

  syncPatientMode();
})();
