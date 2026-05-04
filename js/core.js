// js/core.js
(function(){
  const $ = (sel, root=document) => root.querySelector(sel);
  const $$ = (sel, root=document) => Array.from(root.querySelectorAll(sel));
  const escapeHtml = (value) => String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
  const formatValue = (value) => value || "—";
  const langSelect = $("#langSelect");
  const dict = window.DARMON_I18N;
  const searchField = $("#searchDoc");
  const searchPlaceholders = {
    en: "Type a name...",
    ru: "Введите имя...",
    uz: "Ism yozing...",
  };

  const yearEl = $("#year");
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  const path = (location.pathname.split("/").pop() || "index.html").toLowerCase();
  const navMap = {
    "index.html":"home",
    "about.html":"about",
    "specialists.html":"specialists",
    "doctors.html":"doctors",
    "results.html":"results",
    "contact.html":"contact",
    "vacancies.html":"vacancies",
    "emergency.html":"emergency"
  };
  const active = navMap[path];
  $$("[data-nav]").forEach(a=>{
    if (a.getAttribute("data-nav") === active) a.classList.add("active");
  });

  const menuBtn = $("#menuBtn");
  const mobileNav = $("#mobileNav");
  if (menuBtn && mobileNav){
    menuBtn.addEventListener("click", ()=>{
      mobileNav.style.display = mobileNav.style.display === "block" ? "none" : "block";
    });
  }

  function applyLang(lang){
    if (!dict) return;
    const d = dict[lang] || dict.en;
    $$("[data-i18n]").forEach(el=>{
      const key = el.getAttribute("data-i18n");
      if (d[key]) el.textContent = d[key];
    });

    if (searchField) searchField.placeholder = searchPlaceholders[lang] || searchPlaceholders.en;
  }

  const saved = localStorage.getItem("darmon_lang") || "uz";
  if (langSelect) langSelect.value = saved;
  applyLang(saved);

  if (langSelect){
    langSelect.addEventListener("change", ()=>{
      localStorage.setItem("darmon_lang", langSelect.value);
      applyLang(langSelect.value);
    });
  }

  window.$ = $;
  window.$$ = $$;
  window.escapeHtml = escapeHtml;
  window.formatValue = formatValue;
})();
