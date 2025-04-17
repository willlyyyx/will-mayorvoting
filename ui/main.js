window.addEventListener("message", function (event) {
    if (event.data.action === "show") {
      document.body.style.display = "flex";
      loadCandidates(event.data.candidates);
    } else if (event.data.action === "hide") {
      document.body.style.display = "none";
    }
  });
  
  let currentPage = 0;
  let allCandidates = [];
  
  function loadCandidates(candidates) {
    allCandidates = candidates;
    currentPage = 0;
    renderPage();
  }
  
  function renderPage() {
    const grid = document.getElementById("candidateGrid");
    grid.innerHTML = "";
  
    const perPage = 3;
    const start = currentPage * perPage;
    const visible = allCandidates.slice(start, start + perPage);
  
    visible.forEach(c => {
      const div = document.createElement("div");
      div.className = "candidate";
      const imgPath = `images/${c.image}`;
      div.innerHTML = `
        <img src="${imgPath}" alt="${c.name}" onerror="this.src='images/default.png'" />
        <div class="candidate-name">${c.name}</div>
      `;
      div.onclick = () => submitVote(c.name);
      grid.appendChild(div);
    });
  
    // next and back buttons
    document.getElementById("prevBtn").style.display = currentPage > 0 ? "block" : "none";
    document.getElementById("nextBtn").style.display = (currentPage + 1) * 3 < allCandidates.length ? "block" : "none";    
  }
  
  function changePage(direction) {
    const maxPages = Math.ceil(allCandidates.length / 3);
    currentPage = Math.min(Math.max(0, currentPage + direction), maxPages - 1);
    renderPage();
  }
    
  function submitVote(name) {
    fetch(`https://${GetParentResourceName()}/vote`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name })
    });
    closeUI();
  }
  
  function closeUI() {
    fetch(`https://${GetParentResourceName()}/close`, {
      method: "POST"
    });
    document.body.style.display = "none";
  }
  
  document.addEventListener("keydown", function(event){
    if (event.key == "Escape") {
      closeUI();
    }
  });

  function scrollCandidates(direction) {
    const grid = document.getElementById("candidateGrid");
    const scrollAmount = 200;
    grid.scrollBy({ left: direction * scrollAmount, behavior: "smooth" });
  }
  