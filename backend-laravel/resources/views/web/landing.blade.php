<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="ACTIVA — Platform Analisis Gaya Hidup Digital berbasis Machine Learning dan AI">
    <title>ACTIVA — DigitalLife Analyzer</title>
    <link href="{{ asset('css/web.css') }}" rel="stylesheet">
    <link href="{{ asset('css/landing.css') }}" rel="stylesheet">
</head>
<body>
{{-- ═══ NAVBAR ═══ --}}
<nav class="ln-nav" id="lnNav">
    <div class="ln-nav-inner">
        <a href="{{ url('/user/landing') }}" class="topnav-brand">
            <div class="topnav-logo"><svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round"><path d="M9 11l3 3L22 4"/></svg></div>
            <span class="topnav-brand-text">ACTIVA</span>
        </a>
        <div class="ln-nav-links">
            <a href="#features" class="ln-nav-link">Fitur</a>
            <a href="#announcements" class="ln-nav-link">Pengumuman</a>
            <a href="#stats" class="ln-nav-link">Statistik</a>
            <a href="{{ url('/user/login') }}" class="btn btn-primary btn-sm">Masuk</a>
        </div>
        <button class="topnav-hamburger" id="lnHamburger" onclick="document.getElementById('lnMobile').classList.toggle('open')">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="4" y1="6" x2="20" y2="6"/><line x1="4" y1="12" x2="20" y2="12"/><line x1="4" y1="18" x2="20" y2="18"/></svg>
        </button>
    </div>
    <div class="mobile-menu" id="lnMobile">
        <a href="#features" class="mobile-link">Fitur</a>
        <a href="#announcements" class="mobile-link">Pengumuman</a>
        <a href="#stats" class="mobile-link">Statistik</a>
        <a href="{{ url('/user/login') }}" class="mobile-link" style="color:var(--teal);font-weight:700;">Masuk</a>
        <a href="{{ url('/user/register') }}" class="mobile-link" style="color:var(--teal);">Daftar</a>
    </div>
</nav>

{{-- ═══ HERO ═══ --}}
<section class="ln-hero">
    <div class="ln-hero-bg"></div>
    <div class="ln-hero-content anim-fade">
        <div class="ln-hero-badge">🚀 Platform Analisis Digital #1</div>
        <h1 class="ln-hero-title">Kenali Gaya Hidup<br><span class="ln-gradient-text">Digitalmu</span></h1>
        <p class="ln-hero-sub">Dapatkan analisis mendalam tentang kebiasaan digitalmu menggunakan Machine Learning dan rekomendasi personal dari AI.</p>
        <div class="ln-hero-actions">
            <a href="{{ url('/user/register') }}" class="btn btn-primary btn-lg">Mulai Gratis</a>
            <a href="#features" class="btn btn-outline btn-lg" style="border-color:rgba(255,255,255,.2);color:#fff;">Pelajari Lebih</a>
        </div>
        <div class="ln-hero-stats">
            <div class="ln-hero-stat"><span class="ln-hero-stat-num">{{ number_format($userCount) }}+</span><span class="ln-hero-stat-label">Pengguna</span></div>
            <div class="ln-hero-stat-divider"></div>
            <div class="ln-hero-stat"><span class="ln-hero-stat-num">{{ number_format($surveyCount) }}+</span><span class="ln-hero-stat-label">Analisis</span></div>
            <div class="ln-hero-stat-divider"></div>
            <div class="ln-hero-stat"><span class="ln-hero-stat-num">98%</span><span class="ln-hero-stat-label">Akurasi ML</span></div>
        </div>
    </div>
    <div class="ln-hero-visual anim-up">
        <div class="ln-hero-card">
            <div class="ln-hero-card-header">
                <div class="ln-dots"><span></span><span></span><span></span></div>
                <span style="font-size:.75rem;color:var(--text-secondary);">ACTIVA Dashboard</span>
            </div>
            <div class="ln-hero-card-body">
                <div class="ln-mock-score">
                    <svg viewBox="0 0 120 120" width="120" height="120">
                        <circle cx="60" cy="60" r="50" fill="none" stroke="rgba(13,148,136,.15)" stroke-width="8"/>
                        <circle cx="60" cy="60" r="50" fill="none" stroke="var(--teal)" stroke-width="8" stroke-linecap="round" stroke-dasharray="314" stroke-dashoffset="100" class="ln-score-ring"/>
                    </svg>
                    <div class="ln-mock-score-text"><span style="font-size:2rem;font-weight:900;color:var(--teal);">68</span><span style="font-size:.7rem;color:var(--text-secondary);">/ 100</span></div>
                </div>
                <div class="ln-mock-bars">
                    <div class="ln-mock-bar" style="--w:75%;--c:var(--teal);"><span>Screen Time</span><span>75%</span></div>
                    <div class="ln-mock-bar" style="--w:45%;--c:var(--green);"><span>Sleep Quality</span><span>45%</span></div>
                    <div class="ln-mock-bar" style="--w:60%;--c:var(--amber);"><span>Stress Level</span><span>60%</span></div>
                    <div class="ln-mock-bar" style="--w:30%;--c:var(--blue);"><span>Activity</span><span>30%</span></div>
                </div>
            </div>
        </div>
    </div>
</section>

{{-- ═══ FEATURES ═══ --}}
<section class="ln-section" id="features">
    <div class="ln-container">
        <div class="ln-section-header anim-fade">
            <div class="ln-section-badge">Fitur Unggulan</div>
            <h2 class="ln-section-title">Analisis Digital yang<br><span class="ln-gradient-text">Cerdas & Personal</span></h2>
            <p class="ln-section-sub">Didukung oleh teknologi Machine Learning dan AI untuk memberikan insight yang akurat dan actionable.</p>
        </div>
        <div class="ln-features-grid">
            <div class="ln-feature-card anim-up">
                <div class="ln-feature-icon" style="background:rgba(13,148,136,.08);"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg></div>
                <h3>Kuesioner Interaktif</h3>
                <p>12 pertanyaan terstruktur untuk mengukur kebiasaan digital, pola tidur, dan kondisi mental.</p>
            </div>
            <div class="ln-feature-card anim-up d1">
                <div class="ln-feature-icon" style="background:rgba(139,92,246,.08);"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg></div>
                <h3>Prediksi Machine Learning</h3>
                <p>Model Random Forest menganalisis data dan memberikan skor ketergantungan digital dengan confidence tinggi.</p>
            </div>
            <div class="ln-feature-card anim-up d2">
                <div class="ln-feature-icon" style="background:rgba(59,130,246,.08);"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></div>
                <h3>Visualisasi Data</h3>
                <p>Grafik interaktif menampilkan tren dan pola dari waktu ke waktu untuk memahami perkembanganmu.</p>
            </div>
            <div class="ln-feature-card anim-up d3">
                <div class="ln-feature-icon" style="background:rgba(245,158,11,.08);"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--amber)" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
                <h3>Rekomendasi AI</h3>
                <p>Saran personal dari AI chatbot untuk memperbaiki kebiasaan digital dan meningkatkan kesejahteraan.</p>
            </div>
        </div>
    </div>
</section>

{{-- ═══ ANNOUNCEMENTS ═══ --}}
<section class="ln-section ln-section-alt" id="announcements">
    <div class="ln-container">
        <div class="ln-section-header anim-fade">
            <div class="ln-section-badge">Info Terbaru</div>
            <h2 class="ln-section-title">Pengumuman</h2>
            <p class="ln-section-sub">Informasi terbaru dan update dari tim ACTIVA.</p>
        </div>
        @if(count($announcements) > 0)
        <div class="ln-ann-grid">
            @foreach($announcements as $ann)
            <div class="ln-ann-card anim-up">
                <div class="ln-ann-top">
                    <span class="ln-ann-badge ln-ann-badge--{{ $ann['type'] }}">
                        {{ $ann['type'] === 'info' ? 'Informasi' : ($ann['type'] === 'warning' ? 'Peringatan' : 'Update') }}
                    </span>
                    <span class="ln-ann-date">{{ $ann['created_at_relative'] }}</span>
                </div>
                <h4 class="ln-ann-title">{{ $ann['title'] }}</h4>
                <p class="ln-ann-content">{{ Str::limit($ann['content'], 150) }}</p>
                <div class="ln-ann-footer">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    {{ $ann['created_at_formatted'] }}
                </div>
            </div>
            @endforeach
        </div>
        @else
        <div class="ln-ann-empty anim-up">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--text-disabled)" stroke-width="1.5"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
            <p>Belum ada pengumuman saat ini.</p>
        </div>
        @endif
    </div>
</section>

{{-- ═══ STATS ═══ --}}
<section class="ln-section" id="stats">
    <div class="ln-container">
        <div class="ln-stats-row anim-up">
            <div class="ln-stat-card">
                <div class="ln-stat-icon" style="background:rgba(13,148,136,.08);"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
                <div class="ln-stat-num">{{ number_format($userCount) }}</div>
                <div class="ln-stat-label">Pengguna Aktif</div>
            </div>
            <div class="ln-stat-card">
                <div class="ln-stat-icon" style="background:rgba(139,92,246,.08);"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg></div>
                <div class="ln-stat-num">{{ number_format($surveyCount) }}</div>
                <div class="ln-stat-label">Kuesioner Selesai</div>
            </div>
            <div class="ln-stat-card">
                <div class="ln-stat-icon" style="background:rgba(59,130,246,.08);"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></div>
                <div class="ln-stat-num">98%</div>
                <div class="ln-stat-label">Akurasi Prediksi</div>
            </div>
            <div class="ln-stat-card">
                <div class="ln-stat-icon" style="background:rgba(34,197,94,.08);"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--green)" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
                <div class="ln-stat-num">100%</div>
                <div class="ln-stat-label">Data Terenkripsi</div>
            </div>
        </div>
    </div>
</section>

{{-- ═══ CTA ═══ --}}
<section class="ln-cta">
    <div class="ln-container" style="text-align:center;">
        <h2 class="anim-fade" style="color:#fff;font-size:2.25rem;margin-bottom:16px;">Siap Menganalisis Gaya Hidup Digitalmu?</h2>
        <p class="anim-fade" style="color:rgba(255,255,255,.7);font-size:1.125rem;margin-bottom:32px;max-width:500px;margin-left:auto;margin-right:auto;">Daftar gratis dan dapatkan insight berbasis AI dalam hitungan menit.</p>
        <div class="anim-up" style="display:flex;gap:16px;justify-content:center;flex-wrap:wrap;">
            <a href="{{ url('/user/register') }}" class="btn btn-primary btn-lg" style="box-shadow:0 8px 32px rgba(13,148,136,.4);">Daftar Sekarang</a>
            <a href="{{ url('/user/login') }}" class="btn btn-lg" style="background:rgba(255,255,255,.1);color:#fff;border:1px solid rgba(255,255,255,.2);">Sudah Punya Akun</a>
        </div>
    </div>
</section>

{{-- ═══ FOOTER ═══ --}}
<footer class="ln-footer">
    <div class="ln-container">
        <div class="ln-footer-inner">
            <div class="ln-footer-brand">
                <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px;">
                    <div class="topnav-logo" style="width:28px;height:28px;"><svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round"><path d="M9 11l3 3L22 4"/></svg></div>
                    <span style="font-weight:800;color:var(--text-dark);font-size:1.1rem;">ACTIVA</span>
                </div>
                <p style="color:var(--text-muted);font-size:.8125rem;">DigitalLife Analyzer — Platform analisis gaya hidup digital berbasis AI.</p>
            </div>
            <div class="ln-footer-links">
                <a href="{{ url('/user/login') }}">Masuk</a>
                <a href="{{ url('/user/register') }}">Daftar</a>
                <a href="#features">Fitur</a>
                <a href="#announcements">Pengumuman</a>
            </div>
        </div>
        <div class="ln-footer-bottom">
            <p>&copy; {{ date('Y') }} ACTIVA DigitalLife Analyzer. All rights reserved.</p>
        </div>
    </div>
</footer>

<script>
window.addEventListener('scroll',()=>{document.getElementById('lnNav').classList.toggle('scrolled',window.scrollY>20)});
// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(a=>{a.addEventListener('click',e=>{e.preventDefault();const t=document.querySelector(a.getAttribute('href'));if(t)t.scrollIntoView({behavior:'smooth',block:'start'});document.getElementById('lnMobile').classList.remove('open');})});
// Intersection Observer for animations
const obs=new IntersectionObserver((entries)=>{entries.forEach(e=>{if(e.isIntersecting){e.target.classList.add('ln-visible');obs.unobserve(e.target);}})},{threshold:0.1});
document.querySelectorAll('.anim-fade,.anim-up').forEach(el=>obs.observe(el));
</script>
</body>
</html>
