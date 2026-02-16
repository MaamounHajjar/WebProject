(function(){
  const $ = (sel, root=document) => root.querySelector(sel);
  const $$ = (sel, root=document) => Array.from(root.querySelectorAll(sel));

  const API = "backend/php/api.php"; // one simple router endpoint

  const tokenKey = "darmon_token";

  async function api(action, payload={}){
    const res = await fetch(API, {
      method:"POST",
      headers:{ "Content-Type":"application/json" },
      body: JSON.stringify({ action, token: localStorage.getItem(tokenKey), ...payload })
    });
    return res.json();
  }

  // Tabs (results page)
  const tabs = $$(".tab");
  function showTab(name){
    tabs.forEach(t=>t.classList.toggle("active", t.dataset.tab === name));
    ["login","register","account"].forEach(k=>{
      const el = $("#tab-"+k);
      if (el) el.classList.toggle("hidden", k !== name);
    });
  }
  if (tabs.length){
    tabs.forEach(t=>t.addEventListener("click", ()=>showTab(t.dataset.tab)));
    showTab("login");
  }

  // Quick check
  const qcForm = $("#quickCheckForm");
  if (qcForm){
    qcForm.addEventListener("submit", async (e)=>{
      e.preventDefault();
      const msg = $("#quickCheckMsg");
      const out = $("#quickCheckResult");
      msg.textContent = "Checking...";
      out.innerHTML = "";
      const fd = new FormData(qcForm);
      const receipt_id = fd.get("receipt_id");
      const date = fd.get("date");
      try{
        const r = await api("quick_check", { receipt_id, date });
        if (!r.ok){ msg.textContent = r.error || "Not found"; return; }
        msg.textContent = "";
        out.innerHTML = `
          <div class="item">
            <div class="top">
              <strong>${r.data.receipt_id}</strong>
              <span class="tag">${r.data.status}</span>
            </div>
            <div style="color:var(--muted);font-weight:700;margin-top:6px">
              Test: ${r.data.test_name} • Date: ${r.data.sample_date}
            </div>
          </div>`;
      }catch(err){
        msg.textContent = "Backend not running. (Demo) Try receipt DS-2026-00021.";
        out.innerHTML = `
          <div class="item">
            <div class="top">
              <strong>DS-2026-00021</strong>
              <span class="tag">Pending</span>
            </div>
            <div style="color:var(--muted);font-weight:700;margin-top:6px">
              Test: Blood panel • Date: 2026-01-10
            </div>
          </div>`;
      }
    });
  }

  // Login / register
  const loginForm = $("#loginForm");
  const registerForm = $("#registerForm");
  const loginMsg = $("#loginMsg");
  const registerMsg = $("#registerMsg");

  async function refreshAccount(){
    const doctorSelect = $("#doctorSelect");
    const myResults = $("#myResults");
    if (!doctorSelect || !myResults) return;

    // doctors
    doctorSelect.innerHTML = "<option>Loading...</option>";
    try{
      const d = await api("list_doctors", {});
      if (d.ok){
        doctorSelect.innerHTML = d.data.map(x=>`<option value="${x.id}">${x.full_name} — ${x.specialty}</option>`).join("");
      }else{
        doctorSelect.innerHTML = "<option>Backend error</option>";
      }
    }catch{
      doctorSelect.innerHTML = "<option>Backend not running</option>";
    }

    // results
    myResults.innerHTML = "";
    try{
      const r = await api("my_results", {});
      if (!r.ok){ myResults.innerHTML = `<div class="note">${r.error || "No data"}</div>`; return; }
      if (!r.data.length){ myResults.innerHTML = `<div class="note">No results yet.</div>`; return; }
      myResults.innerHTML = r.data.map(x=>`
        <div class="item">
          <div class="top">
            <strong>${x.test_name}</strong>
            <a class="btn" href="${x.download_url}" target="_blank" rel="noreferrer">⬇ PDF</a>
          </div>
          <div class="note">Receipt: ${x.receipt_id} • Uploaded: ${x.upload_date}</div>
        </div>
      `).join("");
    }catch{
      myResults.innerHTML = `<div class="note">Backend not running.</div>`;
    }
  }

  function isLoggedIn(){
    return !!localStorage.getItem(tokenKey);
  }

  function updateAuthUI(){
    if (!tabs.length) return;
    if (isLoggedIn()){
      showTab("account");
      refreshAccount();
    }else{
      showTab("login");
    }
  }

  if (loginForm){
    loginForm.addEventListener("submit", async (e)=>{
      e.preventDefault();
      loginMsg.textContent = "Signing in...";
      const fd = new FormData(loginForm);
      try{
        const r = await api("login", { email: fd.get("email"), password: fd.get("password") });
        if (!r.ok){ loginMsg.textContent = r.error || "Login failed"; return; }
        localStorage.setItem(tokenKey, r.data.token);
        loginMsg.textContent = "Welcome!";
      
  // Vacancies load (if backend running)
  const vacGrid = $("#vacGrid");
  if (vacGrid){
    api("vacancies", {}).then(r=>{
      if (!r.ok) return;
      if (!r.data.length) return;
      vacGrid.innerHTML = r.data.map(v=>{
        const req = (v.requirements || "").split("\n").filter(Boolean).map(x=>`<li>${x}</li>`).join("");
        return `
          <div class="card vac-card">
            <h3>${v.title}</h3>
            <p>${v.description}</p>
            <ul>${req}</ul>
          </div>
        `;
      }).join("");
    }).catch(()=>{});
  }

  updateAuthUI();
      }catch{
        loginMsg.textContent = "Backend not running (demo only).";
      }
    });
  }

  if (registerForm){
    registerForm.addEventListener("submit", async (e)=>{
      e.preventDefault();
      registerMsg.textContent = "Creating account...";
      const fd = new FormData(registerForm);
      try{
        const r = await api("register", {
          name: fd.get("name"), phone: fd.get("phone"),
          email: fd.get("email"), password: fd.get("password")
        });
        if (!r.ok){ registerMsg.textContent = r.error || "Register failed"; return; }
        localStorage.setItem(tokenKey, r.data.token);
        registerMsg.textContent = "Account created!";
      
  // Vacancies load (if backend running)
  const vacGrid = $("#vacGrid");
  if (vacGrid){
    api("vacancies", {}).then(r=>{
      if (!r.ok) return;
      if (!r.data.length) return;
      vacGrid.innerHTML = r.data.map(v=>{
        const req = (v.requirements || "").split("\n").filter(Boolean).map(x=>`<li>${x}</li>`).join("");
        return `
          <div class="card vac-card">
            <h3>${v.title}</h3>
            <p>${v.description}</p>
            <ul>${req}</ul>
          </div>
        `;
      }).join("");
    }).catch(()=>{});
  }

  updateAuthUI();
      }catch{
        registerMsg.textContent = "Backend not running (demo only).";
      }
    });
  }

  const logoutBtn = $("#logoutBtn");
  if (logoutBtn){
    logoutBtn.addEventListener("click", ()=>{
      localStorage.removeItem(tokenKey);
    
  // Vacancies load (if backend running)
  const vacGrid = $("#vacGrid");
  if (vacGrid){
    api("vacancies", {}).then(r=>{
      if (!r.ok) return;
      if (!r.data.length) return;
      vacGrid.innerHTML = r.data.map(v=>{
        const req = (v.requirements || "").split("\n").filter(Boolean).map(x=>`<li>${x}</li>`).join("");
        return `
          <div class="card vac-card">
            <h3>${v.title}</h3>
            <p>${v.description}</p>
            <ul>${req}</ul>
          </div>
        `;
      }).join("");
    }).catch(()=>{});
  }

  updateAuthUI();
    });
  }

  // Appointment

  const apptForm = $("#appointmentForm");
  const apptMsg = $("#apptMsg");
  if (apptForm){
    apptForm.addEventListener("submit", async (e)=>{
      e.preventDefault();
      apptMsg.textContent = "Booking...";
      const fd = new FormData(apptForm);
      try{
        const r = await api("book_appointment", {
          doctor_id: fd.get("doctor_id"),
          appointment_date: fd.get("appointment_date"),
          time_slot: fd.get("time_slot")
        });
        if (!r.ok){ apptMsg.textContent = r.error || "Failed"; return; }
        apptMsg.textContent = "Booked ✅";
      }catch{
        apptMsg.textContent = "Backend not running (demo only).";
      }
    });
  }

  // Callback request (contact page)
  const callbackForm = $("#callbackForm");
  const callbackMsg = $("#callbackMsg");
  if (callbackForm){
    callbackForm.addEventListener("submit", async (e)=>{
      e.preventDefault();
      callbackMsg.textContent = "Sending...";
      const fd = new FormData(callbackForm);
      try{
        const r = await api("callback_request", {
          first_name: fd.get("first_name"),
          last_name: fd.get("last_name"),
          phone: fd.get("phone"),
          preferred_time: fd.get("preferred_time")
        });
        callbackMsg.textContent = r.ok ? "Sent ✅ We'll call you soon." : (r.error || "Failed");
        if (r.ok) callbackForm.reset();
      }catch{
        callbackMsg.textContent = "Backend not running (demo only).";
      }
    });
  }


  // Vacancies load (if backend running)
  const vacGrid = $("#vacGrid");
  if (vacGrid){
    api("vacancies", {}).then(r=>{
      if (!r.ok) return;
      if (!r.data.length) return;
      vacGrid.innerHTML = r.data.map(v=>{
        const req = (v.requirements || "").split("\n").filter(Boolean).map(x=>`<li>${x}</li>`).join("");
        return `
          <div class="card vac-card">
            <h3>${v.title}</h3>
            <p>${v.description}</p>
            <ul>${req}</ul>
          </div>
        `;
      }).join("");
    }).catch(()=>{});
  }

  updateAuthUI();
})();
