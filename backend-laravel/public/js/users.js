/**
 * public/js/users.js
 * Modal & User Management Interactions
 */

// ═══════════════════════════════════════════════════════════
// MODAL MANAGEMENT
// ═══════════════════════════════════════════════════════════

/**
 * public/js/users.js
 * Modal & User Management Interactions
 */

// ═══════════════════════════════════════════════════════════
// MODAL MANAGEMENT
// ═══════════════════════════════════════════════════════════

/**
 * public/js/users.js
 * Modal & User Management Interactions
 */

// ═══════════════════════════════════════════════════════════
// MODAL MANAGEMENT
// ═══════════════════════════════════════════════════════════

/**
 * Buka modal detail user
 * @param {HTMLElement} button - Button element dengan data attributes
 */
function openModal(button) {
  console.log('🔍 openModal called from button');
  
  const modal = document.getElementById('modal');
  console.log('🔎 Modal element:', modal);
  console.log('🔎 Modal classList sebelum:', modal?.className);
  
  if (!modal) {
    console.error('❌ Modal element tidak ditemukan!');
    return;
  }

  try {
    // Extract data dari button attributes
    const user = {
      id: button.dataset.id,
      name: button.dataset.name,
      email: button.dataset.email,
      focus_score: button.dataset.focus,
      screen_time: button.dataset.screen,
      productivity: button.dataset.productivity,
      digital_dependency: button.dataset.dependency,
      risk: button.dataset.risk,
      created_at: button.dataset.joined,
    };

    console.log('📊 User data:', user);

    // User header
    const userName = user.name || '?';
    const userEmail = user.email || '—';
    const userAvatar = userName.substring(0, 2).toUpperCase();

    document.getElementById('m-av').textContent = userAvatar;
    document.getElementById('m-nm').textContent = userName;
    document.getElementById('m-em').textContent = userEmail;
    document.getElementById('m-jn').textContent = 
      user.created_at ? `Bergabung ${formatDate(user.created_at)}` : '—';

    // Metrics
    document.getElementById('m-f').textContent = user.focus_score || 0;
    document.getElementById('m-s').textContent = user.screen_time || '0j';
    document.getElementById('m-p').textContent = user.productivity || 0;
    document.getElementById('m-d').textContent = user.digital_dependency || 0;

    // Risk level
    const riskElement = document.getElementById('m-risk');
    const riskClass = user.risk === 'low' 
      ? 'pill-teal' 
      : (user.risk === 'high' ? 'pill-red' : 'pill-amber');
    const riskLabel = user.risk === 'low' 
      ? 'Low Risk' 
      : (user.risk === 'high' ? 'High Risk' : 'Moderate');

    riskElement.className = `pill ${riskClass}`;
    riskElement.textContent = riskLabel;

    // Delete button
    const delBtn = document.getElementById('m-del-btn');
    delBtn.onclick = () => {
      if (confirm(`Hapus user "${user.name}"?`)) {
        deleteUser(user.id);
      }
    };

    // Tampilkan modal dengan animasi
    console.log('🎬 Sebelum add modal-show:', modal.className);
    modal.classList.add('modal-show');
    
    // Fallback: force style jika classList tidak bekerja
    modal.style.opacity = '1';
    modal.style.visibility = 'visible';
    modal.style.pointerEvents = 'auto';
    
    console.log('🎬 Sesudah add modal-show:', modal.className);
    console.log('🎬 Modal display:', window.getComputedStyle(modal).display);
    console.log('🎬 Modal visibility:', window.getComputedStyle(modal).visibility);
    console.log('✅ Modal ditampilkan');
  } catch (error) {
    console.error('❌ Error di openModal:', error);
    alert('Error: ' + error.message);
  }
}

/**
 * Tutup modal
 */
function closeModal() {
  const modal = document.getElementById('modal');
  if (!modal) return;

  modal.classList.remove('modal-show');
  
  // Fallback: remove inline styles
  modal.style.opacity = '0';
  modal.style.visibility = 'hidden';
  modal.style.pointerEvents = 'none';
  
  console.log('✅ Modal ditutup');
}

/**
 * Test function untuk debug
 */
function testModal() {
  const modal = document.getElementById('modal');
  console.log('🧪 TEST MODAL');
  console.log('Modal element:', modal);
  console.log('Modal parent:', modal?.parentElement);
  console.log('Computed style display:', window.getComputedStyle(modal).display);
  console.log('Computed style visibility:', window.getComputedStyle(modal).visibility);
  console.log('Computed style z-index:', window.getComputedStyle(modal).zIndex);
  console.log('Computed style position:', window.getComputedStyle(modal).position);
  
  // Force add modal-show
  modal.classList.add('modal-show');
  console.log('✅ Modal-show class added');
  console.log('After add - visibility:', window.getComputedStyle(modal).visibility);
  console.log('After add - opacity:', window.getComputedStyle(modal).opacity);
}

/**
 * Hapus user (POST ke server)
 * @param {number} userId - ID user yang akan dihapus
 */
function deleteUser(userId) {
  const routeData = document.getElementById('route-data');
  const destroyBase = routeData?.dataset.destroyBase;
  const csrfToken = routeData?.dataset.csrf;

  if (!destroyBase || !csrfToken) {
    alert('Error: Missing route data');
    return;
  }

  // Buat form untuk DELETE request
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = `${destroyBase}/${userId}`;
  form.innerHTML = `
    <input type="hidden" name="_token" value="${csrfToken}">
    <input type="hidden" name="_method" value="DELETE">
  `;

  document.body.appendChild(form);
  form.submit();
  document.body.removeChild(form);
}

/**
 * Format tanggal ke format Indonesia
 * @param {string} dateString - Tanggal dari server
 * @returns {string} Tanggal terformat
 */
function formatDate(dateString) {
  if (!dateString) return '—';
  
  try {
    const date = new Date(dateString);
    const options = { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric',
      timeZone: 'Asia/Jakarta'
    };
    return date.toLocaleDateString('id-ID', options);
  } catch (e) {
    return dateString;
  }
}

/**
 * Tutup modal jika klik di luar modal box
 */
document.addEventListener('DOMContentLoaded', () => {
  const modal = document.getElementById('modal');
  console.log('📍 Init - Modal found:', !!modal);
  
  if (modal) {
    // Ensure modal is in body (top-level) untuk avoid stacking context issues
    if (modal.parentElement && modal.parentElement.className !== 'sidebar') {
      console.log('🔧 Moving modal to body level');
      document.body.appendChild(modal);
    }

    modal.addEventListener('click', (e) => {
      // Jika click di overlay (bukan modal-box)
      if (e.target === modal) {
        closeModal();
      }
    });

    // Tutup modal dengan ESC key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && modal.classList.contains('modal-show')) {
        closeModal();
      }
    });

    console.log('✅ Modal event listeners initialized');
  }
});
