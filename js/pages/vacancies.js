// js/pages/vacancies.js
(function(){
  const vacGrid = document.getElementById("vacGrid");
  const api = window.darmonApi;
  if (!vacGrid || !api) return;

  function requirementsList(text) {
    return (text || "")
      .split("\n")
      .filter(Boolean)
      .map((item) => `<li>${item}</li>`)
      .join("");
  }

  function renderFallback(){
    vacGrid.innerHTML = `
      <div class="card vac-card">
        <h3>Laboratory Nurse (Home Visits)</h3>
        <p>Schedule-based home sampling, patient care, strict hygiene.</p>
        <ul>
          <li>2+ years experience</li>
          <li>Communication skills</li>
          <li>Certificate is a plus</li>
        </ul>
      </div>
      <div class="card vac-card">
        <h3>Reception / Call Center Operator</h3>
        <p>24/7 shifts, call routing, appointment confirmations.</p>
        <ul>
          <li>Good Uzbek/Russian</li>
          <li>Calm under pressure</li>
          <li>Basic computer skills</li>
        </ul>
      </div>
    `;
  }

  api("vacancies", {})
    .then(r=>{
      if (!r.ok || !r.data || !r.data.length) {
        renderFallback();
        return;
      }

      vacGrid.innerHTML = r.data.map((vacancy) => `
        <div class="card vac-card">
          <h3>${vacancy.title}</h3>
          <p>${vacancy.description}</p>
          <ul>${requirementsList(vacancy.requirements)}</ul>
        </div>
      `).join("");
    })
    .catch(()=>{ renderFallback(); });
})();
