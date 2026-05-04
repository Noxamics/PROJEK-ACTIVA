/**
 * public/js/users.js
 * Activa Admin — User Management modals & delete
 *
 * Perubahan dari versi sebelumnya:
 *   - openModal() sekarang dipanggil dari data-user attribute di blade:
 *       onclick="openModal(JSON.parse(this.dataset.user))"
 *     sehingga tidak ada json_encode() langsung di onclick="" yang
 *     menyebabkan JS false-positive di VS Code.
 *   - Score bar width diset via JS dari data-width attribute,
 *     bukan dari inline style="width:{{ }}%" yang menyebabkan
 *     CSS false-positive di VS Code.
 */

document.addEventListener('DOMContentLoaded', function () {

    /* ── FIX: Set score bar widths dari data-width attribute ──
       Menggantikan inline style="width:{{ }}%" yang
       menyebabkan CSS false-positive di VS Code.
    ─────────────────────────────────────────────────────────── */
    document.querySelectorAll('[data-width]').forEach(function (el) {
        el.style.width = el.dataset.width + '%';
    });

    const routeEl  = document.getElementById('route-data');
    const BASE_URL = routeEl.dataset.destroyBase;   // "/admin/users"
    const CSRF     = routeEl.dataset.csrf;

    /* ── Risk pill map ────────────────────────────────────── */
    const RISK_MAP = {
        low  : ['pill-teal',  'Low Risk'],
        mid  : ['pill-amber', 'Moderate'],
        high : ['pill-red',   'High Risk'],
    };

    /* ── Open detail modal ────────────────────────────────── */
    window.openModal = function (user) {
        // Avatar & identity
        document.getElementById('m-av').textContent = (user.name ?? '').slice(0, 2).toUpperCase();
        document.getElementById('m-nm').textContent = user.name;
        document.getElementById('m-em').textContent = user.email;
        document.getElementById('m-jn').textContent = 'Bergabung: ' + (user.created_at ?? '-');

        // Metrics
        document.getElementById('m-f').textContent = user.focus_score  ?? '-';
        document.getElementById('m-s').textContent = (user.screen_time ?? '-') + 'j';
        document.getElementById('m-p').textContent = user.productivity  ?? '-';
        document.getElementById('m-d').textContent = user.digital_dep   ?? '-';

        // Risk badge
        const riskEl       = document.getElementById('m-risk');
        const [cls, lbl]   = RISK_MAP[user.risk] ?? ['pill-navy', '—'];
        riskEl.className   = 'pill ' + cls;
        riskEl.textContent = lbl;

        // Delete button
        document.getElementById('m-del-btn').onclick = function () {
            if (!confirm('Hapus ' + user.name + '?')) return;

            const form   = document.createElement('form');
            form.method  = 'POST';
            form.action  = BASE_URL + '/' + user.id;

            const token  = document.createElement('input');
            token.type   = 'hidden';
            token.name   = '_token';
            token.value  = CSRF;

            const method = document.createElement('input');
            method.type  = 'hidden';
            method.name  = '_method';
            method.value = 'DELETE';

            form.appendChild(token);
            form.appendChild(method);
            document.body.appendChild(form);
            form.submit();
        };

        document.getElementById('modal').classList.add('show');
    };

    /* ── Close modal ──────────────────────────────────────── */
    window.closeModal = function () {
        document.getElementById('modal').classList.remove('show');
    };

});