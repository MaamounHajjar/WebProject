// js/pages/specialists.js
(function(){
  const $ = window.$;
  const $$ = window.$$;
  const deptSelect = $("#deptSelect");
  const searchDoc  = $("#searchDoc");
  const resetBtn   = $("#resetFiltersBtn");
  const doctorCards = $$(".doctor-card");

  if (!deptSelect || !searchDoc) return; // not on specialists page

  function filterDocs(){
    const dept = (deptSelect.value || "all").toLowerCase();
    const q = (searchDoc.value || "").trim().toLowerCase();

    doctorCards.forEach((card)=>{
      const cardDept = (card.getAttribute("data-dept") || "").toLowerCase();
      const cardName = (card.getAttribute("data-name") || card.innerText).toLowerCase();

      const matches = (dept === "all" || cardDept === dept) && (!q || cardName.includes(q));
      card.style.display = matches ? "" : "none";
    });
  }

  deptSelect.addEventListener("change", filterDocs);
  searchDoc.addEventListener("input", filterDocs);

  if (resetBtn){
    resetBtn.addEventListener("click", (e)=>{
      e.preventDefault();
      deptSelect.value = "all";
      searchDoc.value = "";
      filterDocs();
      searchDoc.focus();
    });
  }

  filterDocs();
})();
