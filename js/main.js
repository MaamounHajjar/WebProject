(function(){
  const $ = (sel, root=document) => root.querySelector(sel);
  const $$ = (sel, root=document) => Array.from(root.querySelectorAll(sel));

  const yearEl = $("#year"); // Footer year
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  // Active nav
  const path = (location.pathname.split("/").pop() || "index.html").toLowerCase();
  const navMap = {
    "index.html":"home",
    "about.html":"about",
    "specialists.html":"specialists",
    "results.html":"results",
    "contact.html":"contact",
    "vacancies.html":"vacancies"
  };
  const active = navMap[path];
  $$("[data-nav]").forEach(a=>{
    if(a.getAttribute("data-nav") === active) a.classList.add("active");
  });

  // Mobile menu
  const menuBtn = $("#menuBtn");
  const mobileNav = $("#mobileNav");
  if (menuBtn && mobileNav){
    menuBtn.addEventListener("click", ()=>{
      const shown = mobileNav.style.display === "block";
      mobileNav.style.display = shown ? "none" : "block";
    });
  }

  // Language
  const dict = {
    en: {
      tagline:"24/7 care • Home visit lab",
      nav_home:"Home", nav_about:"About Us", nav_specialists:"Specialists", nav_results:"Lab Results", nav_contact:"Contact", nav_vacancies:"Vacancies",
      fab_call:"Call",
      footer_sub:"Modern clinic & home laboratory service",
      footer_note:"Results, appointments, and friendly support — all in one place.",
      footer_links:"Quick links", footer_contact:"Contact",
      works_247:"Works 24/7",
      hero_badge:"Trusted healthcare in Uzbekistan",
      hero_title:"Care that feels close — even when you are at home.",
      hero_desc:"Darmon Service UZ is a modern clinic with a mobile laboratory service. Book a doctor, request a home blood test, and receive your results online.",
      btn_results:"Get lab results", btn_contact:"Contact & location",
      created_in:"Created in", read_more:"Read more",
      lab_card_title:"Lab results & appointments",
      lab_card_desc:"Log in to download your PDF results, or book an appointment with available specialists. For quick status, use Receipt ID + Date.",
      btn_open_results:"Open Lab Results", btn_quickcheck:"Quick check",
      prep_guide:"How to prepare for your blood test?",
      video_title:"Home visit laboratory",
      video_desc:"See how our mobile lab comes to your doorstep. Professional care, without the commute.",
      video_autoplay_note:"Autoplays on most devices (muted by browser rules). Tap the speaker icon in the player to turn sound on.",
      video_lazy_title:"Watch the process", video_lazy_hint:"Click to load video", play:"Play",
      video_caption:"Our team arrives on time, uses sterile single-use materials, and delivers results to your account.",
      benefits_title:"Our benefits", benefits_sub:"Small details that make patients feel safe and cared for.",
      b1_title:"Working 24/7", b1_desc:"Support, urgent advice, and lab scheduling any day.",
      b2_title:"Family doctors", b2_desc:"Care for adults and children with one trusted team.",
      b3_title:"2,000,000+ patients trust", b3_desc:"Experience built on real stories and results.",
      b4_title:"International qualifications", b4_desc:"Doctors who keep up with global standards.",
      b5_title:"Modern equipment", b5_desc:"Accurate tests and comfortable procedures.",
      b6_title:"Home-provided services", b6_desc:"Mobile lab and nurse visits when you need it.",
      b7_title:"Polite & caring staff", b7_desc:"We explain calmly, listen carefully, and act fast.",
      metrics_title:"Our numbers", m1:"Patients served", m2:"Hours support", m3:"Specialists & partners",
      doctors_preview_title:"Meet some of our doctors", doctors_preview_desc:"A few faces you can book online.", btn_all_specialists:"All specialists",
      cardio:"Cardiology • 9 years", lab:"Laboratory • 7 years", peds:"Pediatrics • 6 years",
      about_badge:"About Darmon Service UZ",
      about_title:"We combine clinic care with a home visit laboratory.",
      about_lead:"Our goal is simple: make diagnostics and doctor consultations easy, fast, and comfortable for every family.",
      about_story_title:"A clinic that respects your time",
      about_story_p1:"We know how busy life can be. That is why we built a service where you can get help in the clinic or at home — without stress.",
      about_story_p2:"For lab tests, our mobile team comes to your address, collects the sample carefully, and you receive results online (PDF) or in person.",
      about_story_p3:"We also keep communication simple: clear instructions, calm explanations, and quick support.",
      about_values_title:"What patients notice",
      about_v1:"Clean environment and modern equipment",
      about_v2:"Polite staff and careful procedures",
      about_v3:"Home visit lab for kids & seniors",
      about_v4:"Online results and easy appointment booking",
      spec_badge:"Our specialists",
      spec_title:"Choose a doctor by department",
      spec_sub:"Use filters to quickly find the right specialist. Then book an appointment from the Lab Results page.",
      filter_dept:"Department", filter_search:"Search", all:"All", btn_book:"Book appointment",
      contact_badge:"Contact us", contact_title:"We are here 24/7", contact_sub:"Call us or leave your number — we will call you back at a convenient time.",
      contact_info:"Clinic info", address_line:"Tashkent, Uzbekistan",
      callback_title:"Request a call", name:"Name", surname:"Surname", phone:"Phone", preferred_time:"Preferred time", send:"Send",
      map_note:"Tip: on mobile, tap “Directions” in the map.",
      vac_badge:"Vacancies", vac_title:"Join our team", vac_sub:"Below are currently open positions. (If backend is running, these load from database.)",
      res_badge:"Lab results & booking", res_title:"Results, quick status, and appointments", res_sub:"Quick Check works without login. Login/Registration is for downloading PDFs and booking appointments.",
      quickcheck_title:"Quick check", quickcheck_note:"Enter Receipt ID and Date to see if your result is Pending or Ready.",
      receipt_id:"Receipt ID", date:"Date", check:"Check",
      tab_login:"Login", tab_register:"Register", tab_account:"My account",
      login_title:"Login", password:"Password", login:"Login",
      register_title:"Create an account", register:"Register",
      account_title:"My account", account_note:"Here you can book appointments and download your results.",
      book_title:"Book appointment", doctor:"Doctor", time_slot:"Time slot", book:"Book",
      my_results:"My results", logout:"Logout", vac_name1:"Laboratory Nurse (Home Visits)",schedule_based: "Schedule-based home sampling, patient care, strict hygiene.", experience: "2+ years experience", communication:"Communication skills", certificate:"Certificate is a plus", vac_name2:"Reception / Call Center Operator", vac2_desc: "24/7 shifts, call routing, appointment confirmations.", desc_1:"Good Uzbek/Russian", desc_2:"Calm under pressure", desc_3:"Basic computer skills"
    },
    ru: {
      tagline:"24/7 помощь • Выездная лаборатория",
      nav_home:"Главная", nav_about:"O нас", nav_specialists:"Специалисты", nav_results:"Результаты", nav_contact:"Контакты", nav_vacancies:"Вакансии",
      fab_call:"Позвонить",
      footer_sub:"Современная клиника и выездная лаборатория",
      footer_note:"Результаты, запись и поддержка — всё в одном месте.",
      footer_links:"Быстрые ссылки", footer_contact:"Контакты",
      works_247:"Работаем 24/7",
      hero_badge:"Надёжная медицина в Узбекистане",
      hero_title:"Забота рядом — даже когда вы дома.",
      hero_desc:"Darmon Service UZ — современная клиника c выездной лабораторией. Запишитесь к врачу, вызовите забор крови на дом и получите результаты онлайн.",
      btn_results:"Получить результаты", btn_contact:"Контакты и адрес",
      created_in:"Основано", read_more:"Подробнее",
      lab_card_title:"Результаты и запись",
      lab_card_desc:"Войдите, чтобы скачать PDF, или запишитесь к специалисту. Для статуса — номер квитанции и дата.",
      btn_open_results:"Открыть результаты", btn_quickcheck:"Быстрая проверка",
      prep_guide:"Как подготовиться к анализу крови?",
      video_title:"Выездная лаборатория",
      video_desc:"Посмотрите, как мы приезжаем к вам домой. Профессионально и без лишних поездок.",
      video_lazy_title:"Посмотреть процесс", video_lazy_hint:"Нажмите, чтобы загрузить видео", play:"Смотреть",
      video_caption:"Мы приезжаем вовремя, используем стерильные одноразовые материалы и отправляем результаты в ваш аккаунт.",
      benefits_title:"Наши преимущества", benefits_sub:"Мелочи, которые дают чувство безопасности.",
      b1_title:"Работаем 24/7", b1_desc:"Поддержка, срочные вопросы и забор анализов каждый день.",
      b2_title:"Семейные врачи", b2_desc:"Одна команда для взрослых и детей.",
      b3_title:"Доверие 2 000 000+ пациентов", b3_desc:"Опыт, проверенный реальными историями.",
      b4_title:"Международная квалификация", b4_desc:"Врачи, следящие за мировыми стандартами.",
      b5_title:"Современное оборудование", b5_desc:"Точность и комфорт.",
      b6_title:"Услуги на дому", b6_desc:"Выездная лаборатория и медсестра при необходимости.",
      b7_title:"Вежливый персонал", b7_desc:"Спокойно объясняем и быстро помогаем.",
      metrics_title:"Наши цифры", m1:"Пациентов обслужено", m2:"Часов поддержки", m3:"Специалистов и партнёров",
      doctors_preview_title:"Познакомьтесь c нашими врачами", doctors_preview_desc:"Несколько специалистов для онлайн-записи.", btn_all_specialists:"Все специалисты",
      cardio:"Кардиология • 9 лет", lab:"Лаборатория • 7 лет", peds:"Педиатрия • 6 лет",
      about_badge:"O Darmon Service UZ",
      about_title:"Клиника + выездная лаборатория в одном сервисе.",
      about_lead:"Наша цель простая: сделать диагностику и консультации удобными для каждой семьи.",
      about_story_title:"Клиника, которая ценит ваше время",
      about_story_p1:"Мы знаем, что жизнь бывает очень занята. Поэтому вы можете получить помощь в клинике или дома — без стресса.",
      about_story_p2:"Для анализов наша команда приезжает по адресу, бережно берёт материал, a вы получаете результаты онлайн (PDF) или лично.",
      about_story_p3:"Мы общаемся просто: понятные инструкции, спокойные объяснения и быстрая поддержка.",
      about_values_title:"Что отмечают пациенты",
      about_v1:"Чистота и современное оборудование",
      about_v2:"Вежливый персонал и аккуратные процедуры",
      about_v3:"Выезд на дом для детей и пожилых",
      about_v4:"Онлайн результаты и удобная запись",
      spec_badge:"Наши специалисты",
      spec_title:"Выберите врача по отделению",
      spec_sub:"Используйте фильтры, чтобы не листать весь список.",
      filter_dept:"Отделение", filter_search:"Поиск", all:"Все", btn_book:"Записаться",
      contact_badge:"Контакты", contact_title:"Мы на связи 24/7", contact_sub:"Позвоните или оставьте номер — мы перезвоним в удобное время.",
      contact_info:"Информация", address_line:"Ташкент, Узбекистан",
      callback_title:"Заказать звонок", name:"Имя", surname:"Фамилия", phone:"Телефон", preferred_time:"Удобное время", send:"Отправить",
      map_note:"Подсказка: на телефоне нажмите «Маршрут» на карте.",
      vac_badge:"Вакансии", vac_title:"Присоединяйтесь к команде", vac_sub:"Открытые вакансии (при включённом backend загружаются из БД).",
      res_badge:"Результаты и запись", res_title:"Результаты, статус и запись к врачу", res_sub:"Быстрая проверка работает без входа. Вход нужен для скачивания PDF и записи.",
      quickcheck_title:"Быстрая проверка", quickcheck_note:"Введите номер квитанции и дату — статус будет «Ожидается» или «Готово».",
      receipt_id:"Номер квитанции", date:"Дата", check:"Проверить",
      tab_login:"Вход", tab_register:"Регистрация", tab_account:"Мой аккаунт",
      login_title:"Вход", password:"Пароль", login:"Войти",
      register_title:"Создать аккаунт", register:"Зарегистрироваться",
      account_title:"Мой аккаунт", account_note:"Запись к врачу и скачивание результатов.",
      book_title:"Запись к врачу", doctor:"Врач", time_slot:"Время", book:"Записаться",
      my_results:"Мои результаты", logout:"Выйти", vac_name1: "Лаборантка (выезды на дом)", schedule_based: "Выбор проб на дому по графику, уход за пациентами, строгая гигиена", experience: "Опыт работы более 2 лет", communication: "Навыки общения", certificate:"Наличие сертификата является преимуществом.", vac_name2:"Оператор приемной/колл-центра", vac2_desc:"Круглосуточная работа, маршрутизация звонков, подтверждение встреч.", desc_1:"Хороший узбекский/русский", desc_2:"Спокойствие в стрессовых ситуациях", desc_3:"Базовые навыки работы c компьютером"
    },
    uz: {
      tagline:"24/7 xizmat • Uyga laboratoriya",
      nav_home:"Bosh sahifa", nav_about:"Biz haqimizda", nav_specialists:"Mutaxassislar", nav_results:"Natijalar", nav_contact:"Aloqa", nav_vacancies:"Vakansiyalar",
      fab_call:"Qo'ng'iroq",
      footer_sub:"Zamonaviy klinika va uyga laboratoriya xizmati",
      footer_note:"Natijalar, qabulga yozilish va yordam — barchasi bir joyda.",
      footer_links:"Tezkor havolalar", footer_contact:"Aloqa",
      works_247:"24/7 ishlaymiz",
      hero_badge:"O'zbekistonda ishonchli tibbiyot",
      hero_title:"G'amxo'rlik yaqin — hatto uyingizda ham.",
      hero_desc:"Darmon Service UZ — zamonaviy klinika va uyga keladigan laboratoriya xizmati. Shifokorga yoziling, uyda qon topshiring va natijani online oling.",
      btn_results:"Natijalarni olish", btn_contact:"Aloqa va manzil",
      created_in:"Tashkil topgan", read_more:"Batafsil",
      lab_card_title:"Natijalar va qabulga yozilish",
      lab_card_desc:"PDF natijalarni yuklab olish uchun kiring yoki mutaxassisga yoziling. Tezkor status: Chek ID + Sana.",
      btn_open_results:"Natijalar sahifasi", btn_quickcheck:"Tez tekshiruv",
      prep_guide:"Qon tahliliga qanday tayyorlanish kerak?",
      video_title:"Uyga laboratoriya",
      video_desc:"Mobil laboratoriyamiz qanday ishlashini ko'ring. Professional va qulay.",
      video_lazy_title:"Jarayonni ko'rish", video_lazy_hint:"Videoni yuklash uchun bosing", play:"Play",
      video_caption:"Jamoamiz o'z vaqtida keladi, steril materiallar ishlatadi va natijalarni akkauntingizga yuboradi.",
      benefits_title:"Afzalliklarimiz", benefits_sub:"Bemorlar o'zini xotirjam his qilishi uchun.",
      b1_title:"24/7 ishlaymiz", b1_desc:"Yordam, maslahat va tahlil jadvali har kuni.",
      b2_title:"Oilaviy shifokorlar", b2_desc:"Kattalar va bolalar uchun bir jamoa.",
      b3_title:"2 000 000+ bemor ishonchi", b3_desc:"Haqiqiy tajriba va natijalar.",
      b4_title:"Xalqaro malaka", b4_desc:"Shifokorlar global standartlarga amal qiladi.",
      b5_title:"Zamonaviy uskunalar", b5_desc:"Aniq tahlil va qulay jarayon.",
      b6_title:"Uyga xizmat", b6_desc:"Mobil laboratoriya va hamshira xizmati.",
      b7_title:"Muloyim xodimlar", b7_desc:"Tinch tushuntiramiz, tez yordam beramiz.",
      metrics_title:"Bizning raqamlar", m1:"Xizmat ko'rsatildi", m2:"Soat yordam", m3:"Mutaxassis va hamkorlar",
      doctors_preview_title:"Shifokorlarimizdan tanishing", doctors_preview_desc:"Online yozilishingiz mumkin bo'lganlar.", btn_all_specialists:"Barcha mutaxassislar",
      cardio:"Kardiologiya • 9 yil", lab:"Laboratoriya • 7 yil", peds:"Pediatriya • 6 yil",
      about_badge:"Darmon Service UZ haqida",
      about_title:"Klinika va uyga laboratoriya — bir xizmatda.",
      about_lead:"Maqsad: diagnostika va konsultatsiyani har bir oila uchun qulay qilish.",
      about_story_title:"Vaqtingizni qadrlaydigan klinika",
      about_story_p1:"Hayot band bo'lishini bilamiz. Shu sabab klinikada ham, uyda ham yordam beramiz.",
      about_story_p2:"Tahlil uchun mobil jamoa manzilingizga keladi, namunani ehtiyotkorlik bilan oladi va natijani online (PDF) yuboradi.",
      about_story_p3:"Aloqa oddiy: aniq ko'rsatma, xotirjam tushuntirish, tez yordam.",
      about_values_title:"Bemorlar nimani sezadi",
      about_v1:"Tozalik va zamonaviy uskunalar",
      about_v2:"Muloyim xodimlar va ehtiyotkor jarayon",
      about_v3:"Bolalar va keksalar uchun uyga tashrif",
      about_v4:"Online natija va oson yozilish",
      spec_badge:"Mutaxassislarimiz",
      spec_title:"Bo'lim bo'yicha tanlang",
      spec_sub:"Filtrlar orqali tez toping va qabulga yoziling.",
      filter_dept:"Bo'lim", filter_search:"Qidiruv", all:"Barchasi", btn_book:"Qabulga yozilish",
      contact_badge:"Aloqaga chiqing", contact_title:"24/7 aloqadamiz", contact_sub:"Qo'ng'iroq qiling yoki raqamingizni qoldiring — qulay vaqtda bog'lanamiz.",
      contact_info:"Ma'lumot", address_line:"Toshkent, O'zbekiston",
      callback_title:"Qo'ng'iroq so'rash", name:"Ism", surname:"Familiya", phone:"Telefon", preferred_time:"Qulay vaqt", send:"Yuborish",
      map_note:"Maslahat: telefoningizda xaritada “Yo'nalish”ni bosing.",
      vac_badge:"Vakansiyalar", vac_title:"Jamoamizga qo'shiling", vac_sub:"Ochiq ish o'rinlari (backend bo'lsa DB dan yuklanadi).",
      res_badge:"Natijalar va yozilish", res_title:"Natijalar, status va qabulga yozilish", res_sub:"Tez tekshiruv kirishsiz ishlaydi. PDF va yozilish uchun login kerak.",
      quickcheck_title:"Tez tekshiruv", quickcheck_note:"Chek ID va sanani kiriting — status “Kutilmoqda” yoki “Tayyor”.",
      receipt_id:"Chek ID", date:"Sana", check:"Tekshirish",
      tab_login:"Kirish", tab_register:"Ro'yxatdan o'tish", tab_account:"Akkountim",
      login_title:"Kirish", password:"Parol", login:"Kirish",
      register_title:"Akkount yaratish", register:"Ro'yxatdan o'tish",
      account_title:"Akkountim", account_note:"Qabulga yozilish va natijalarni yuklab olish.",
      book_title:"Qabulga yozilish", doctor:"Shifokor", time_slot:"Vaqt", book:"Yozilish",
      my_results:"Natijalarim", logout:"Chiqish", vac_name1: "Laboratoriya hamshirasi (uyga tashrif buyurish)", schedule_based: "Jadvalga asoslangan uy namunalarini olish, bemorlarga g'amxo'rlik qilish, qat'iy gigiena.", experience: "2+ yillik tajriba", communication:"Muloqot qobiliyatlari", certificate:"Kerakli sertifikatlar foyda bo'ladi", vac_name2:"Qabulxona / Qo'ng'iroqlar markazi operatori", vac2_desc:"24/7 smenalar, qo'ng'iroqlarni yo'naltirish, uchrashuvlarni tasdiqlash.", desc_1:"Yaxshi O'zbek/Rus tillarini bilish", desc_2:"Bosim ostida xotirjam bo'lish", desc_3:"Boshlang'ich kompyuter ko'nikmalari"
    }
  };

  function applyLang(lang){
    const d = dict[lang] || dict.en;
    $$("[data-i18n]").forEach(el=>{
      const key = el.getAttribute("data-i18n");
      if (d[key]) el.textContent = d[key];
    });
    // some placeholders
    const s = $("#searchDoc"); if (s) s.placeholder = (lang==="ru" ? "Введите имя..." : lang==="uz" ? "Ism yozing..." : "Type a name...");
  }

  const langSelect = $("#langSelect");
  const saved = localStorage.getItem("darmon_lang") || "uz";
  if (langSelect){ langSelect.value = saved; }
  applyLang(saved);
  if (langSelect){
    langSelect.addEventListener("change", ()=>{
      localStorage.setItem("darmon_lang", langSelect.value);
      applyLang(langSelect.value);
    });
  }

  // Counters on scroll
  const counters = $$("[data-count]");
  if (counters.length){
    const io = new IntersectionObserver((entries)=>{
      entries.forEach(entry=>{
        if (!entry.isIntersecting) return;
        const el = entry.target;
        const end = parseInt(el.getAttribute("data-count"), 10);
        let start = 0;
        const duration = 900;
        const t0 = performance.now();
        function tick(now){
          const p = Math.min((now - t0)/duration, 1);
          const val = Math.floor(start + (end-start)*p);
          el.textContent = val.toLocaleString();
          if (p < 1) requestAnimationFrame(tick);
        }
        requestAnimationFrame(tick);
        io.unobserve(el);
      });
    }, {threshold:0.3});
    counters.forEach(c=>io.observe(c));
  }
  // YouTube is embedded directly on Home (autoplay muted).

  // Specialists filtering
  const deptSelect = $("#deptSelect");
  const searchDoc = $("#searchDoc");
  const cards = $$(".doctor-card");
  function filterDocs(){
    if (!deptSelect || !searchDoc) return;
    const dept = deptSelect.value;
    const q = searchDoc.value.trim().toLowerCase();
    cards.forEach(c=>{
      const cd = (c.getAttribute("data-dept") || "").toLowerCase();
      const cn = (c.getAttribute("data-name") || c.innerText).toLowerCase();
      const okDept = dept === "all" || cd === dept.toLowerCase();
      const okQ = !q || cn.includes(q);
      c.style.display = (okDept && okQ) ? "grid" : "none";
    });
  }
  if (deptSelect && searchDoc){
    deptSelect.addEventListener("change", filterDocs);
    searchDoc.addEventListener("input", filterDocs);
  }

  // Prep guide popup (tiny human touch)
  const guide = document.querySelector("[data-open-guide]");
  if (guide){
    guide.addEventListener("click", ()=>{
      alert(
        "Preparation guide (simple):\n\n• If your doctor said fasting — don't eat for 8-12 hours.\n• Drink water (no sweet drinks).\n• Avoid heavy exercise and alcohol the day before.\n• Bring your receipt ID for faster processing.\n\nIf you have diabetes or take regular medication, ask your doctor before fasting."
      );
    });
  }
})();
