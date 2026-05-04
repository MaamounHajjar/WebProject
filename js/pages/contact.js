// js/pages/contact.js
(function(){
  const $ = window.$;
  const api = window.darmonApi;

  const callbackForm = $("#callbackForm");
  const callbackMsg  = $("#callbackMsg");
  if (!callbackForm || !api) return;

  function setMessage(message) {
    if (callbackMsg) callbackMsg.textContent = message;
  }

  callbackForm.addEventListener("submit", async (e)=>{
    e.preventDefault();
    setMessage("Sending...");

    const fd = new FormData(callbackForm);
    try{
      const r = await api("callback_request", {
        first_name: fd.get("first_name"),
        last_name: fd.get("last_name"),
        phone: fd.get("phone"),
        preferred_time: fd.get("preferred_time")
      });

      setMessage(r.ok ? "Sent. We'll call you soon." : (r.error || "Failed"));
      if (r.ok) callbackForm.reset();
    }catch{
      setMessage("Backend not running.");
    }
  });
})();
