// js/pages/home.js
(function(){
  const counters = Array.from(document.querySelectorAll("[data-count]"));
  function animateCounter(element) {
    const end = parseInt(element.getAttribute("data-count"), 10);
    if (!Number.isFinite(end)) return;

    const duration = 900;
    const startedAt = performance.now();

    function tick(now){
      const progress = Math.min((now - startedAt) / duration, 1);
      element.textContent = Math.floor(end * progress).toLocaleString();
      if (progress < 1) requestAnimationFrame(tick);
    }

    requestAnimationFrame(tick);
  }

  if (counters.length){
    const observer = new IntersectionObserver((entries)=>{
      entries.forEach((entry)=>{
        if (!entry.isIntersecting) return;
        animateCounter(entry.target);
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.3 });

    counters.forEach((counter)=> observer.observe(counter));
  }

  const guide = document.querySelector("[data-open-guide]");
  if (guide){
    guide.addEventListener("click", ()=>{
      alert(
        "Preparation guide (simple):\n\n" +
        "• If your doctor said fasting — don't eat for 8-12 hours.\n" +
        "• Drink water (no sweet drinks).\n" +
        "• Avoid heavy exercise and alcohol the day before.\n" +
        "• Bring your receipt ID for faster processing.\n\n" +
        "If you have diabetes or take regular medication, ask your doctor before fasting."
      );
    });
  }
})();
