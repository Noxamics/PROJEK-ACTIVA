// ───────────────────────────────────────────────────
// public/js/rules.js
// Rule Management (Add / Edit Modal)
// ───────────────────────────────────────────────────

(function () {
    const modal = document.getElementById("modal");
    const form  = document.getElementById("rule-form");

    // ================================
    // OPEN CREATE
    // ================================
    window.openAdd = function () {
        if (!modal || !form) return;

        form.reset();

        document.getElementById("m-title").innerHTML = `
            <span style="display:inline-flex;align-items:center;gap:7px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                    stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                    <line x1="9" y1="9" x2="15" y2="9"/>
                    <line x1="9" y1="12" x2="15" y2="12"/>
                    <line x1="9" y1="15" x2="11" y2="15"/>
                </svg>
                Tambah Rule Baru
            </span>`;

        document.getElementById("m-method").value = "POST";
        document.getElementById("m-id").value     = "";
        form.action = window.ROUTES.store;

        showModal();
    };

    window.openCreateModal = function () { openAdd(); };

    // ================================
    // OPEN EDIT
    // ================================
    window.openEdit = function (btn) {
        if (!modal || !form || !btn) return;

        form.reset();

        document.getElementById("m-title").innerHTML = `
            <span style="display:inline-flex;align-items:center;gap:7px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                    stroke-linecap="round" stroke-linejoin="round">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                </svg>
                Edit Rule
            </span>`;

        document.getElementById("m-method").value = "PATCH";
        document.getElementById("m-id").value     = btn.dataset.id;
        form.action = window.ROUTES.update.replace(":id", btn.dataset.id);

        // Isi field
        document.getElementById("m-name").value       = btn.dataset.name       || "";
        document.getElementById("m-sm-min").value     = btn.dataset.socialMediaMin || "";
        document.getElementById("m-sm-max").value     = btn.dataset.socialMediaMax || "";
        document.getElementById("m-sleep-min").value  = btn.dataset.sleepMin   || "";
        document.getElementById("m-sleep-max").value  = btn.dataset.sleepMax   || "";
        document.getElementById("m-stress-min").value = btn.dataset.stressMin  || "";
        document.getElementById("m-stress-max").value = btn.dataset.stressMax  || "";
        document.getElementById("m-then").value       = btn.dataset.recommendation || "";
        document.getElementById("m-pri").value        = btn.dataset.priority   || "1";

        // Set radio kategori
        const kategori = btn.dataset.kategori || "";
        document.querySelectorAll('input[name="kategori"]').forEach(radio => {
            radio.checked = (radio.value === kategori);
        });

        showModal();
    };

    // ================================
    // SHOW / CLOSE
    // ================================
    function showModal() {
        modal.classList.add("modal-show");
        document.body.style.overflow = "hidden";
        setTimeout(() => {
            const input = document.getElementById("m-name");
            if (input) input.focus();
        }, 100);
    }

    window.closeModal = function () {
        modal.classList.remove("modal-show");
        document.body.style.overflow = "auto";
    };

    document.addEventListener("keydown", function (e) {
        if (e.key === "Escape") closeModal();
    });

    window.addEventListener("click", function (e) {
        if (e.target === modal) closeModal();
    });
})();