<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="ACTIVA — Sistem Analisis Gaya Hidup Digital">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'ACTIVA') — DigitalLife Analyzer</title>
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Crect width='32' height='32' rx='8' fill='%230D9488'/%3E%3Cpath d='M9 16.5l4.5 4.5L23 11' stroke='%23fff' stroke-width='3' stroke-linecap='round' fill='none'/%3E%3C/svg%3E">
    <link href="{{ asset('css/web.css') }}" rel="stylesheet">
    @yield('styles')
</head>
<body>
    @php $user = Auth::user(); $initials = $user ? strtoupper(substr($user->name,0,2)) : '?'; @endphp

    {{-- ═══ Top Navbar ═══ --}}
    <nav class="topnav" id="topnav">
        <div class="topnav-inner">
            {{-- Brand --}}
            <a href="{{ url('/user/dashboard') }}" class="topnav-brand">
                <div class="topnav-logo">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round"><path d="M9 11l3 3L22 4"/></svg>
                </div>
                <span class="topnav-brand-text">ACTIVA</span>
            </a>

            {{-- Desktop Nav Links --}}
            <div class="topnav-links" id="navLinks">
                <a href="{{ url('/user/dashboard') }}" class="topnav-link {{ request()->is('user/dashboard') ? 'active' : '' }}">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                    Dashboard
                </a>
                <a href="{{ url('/user/kuesioner') }}" class="topnav-link {{ request()->is('user/kuesioner*') ? 'active' : '' }}">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                    Kuesioner
                </a>
                <a href="{{ url('/user/histori') }}" class="topnav-link {{ request()->is('user/histori*') ? 'active' : '' }}">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    Histori
                </a>
                <a href="{{ url('/user/grafik') }}" class="topnav-link {{ request()->is('user/grafik*') ? 'active' : '' }}">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                    Grafik
                </a>
                <a href="{{ url('/user/laporan') }}" class="topnav-link {{ request()->is('user/laporan*') ? 'active' : '' }}">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                    Laporan
                </a>
            </div>

            {{-- Right Side --}}
            <div class="topnav-right">
                <a href="{{ url('/user/profil') }}" class="topnav-user {{ request()->is('user/profil*') ? 'active' : '' }}">
                    <div class="avatar avatar-sm">{{ $initials }}</div>
                    <span class="topnav-user-name">{{ explode(' ', $user->name ?? 'User')[0] }}</span>
                </a>
                <button class="topnav-hamburger" id="hamburgerBtn" onclick="toggleMobileMenu()">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" id="hamburgerIcon"><line x1="4" y1="6" x2="20" y2="6"/><line x1="4" y1="12" x2="20" y2="12"/><line x1="4" y1="18" x2="20" y2="18"/></svg>
                </button>
            </div>
        </div>

        {{-- Mobile Menu --}}
        <div class="mobile-menu" id="mobileMenu">
            <a href="{{ url('/user/dashboard') }}" class="mobile-link {{ request()->is('user/dashboard') ? 'active' : '' }}">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                Dashboard
            </a>
            <a href="{{ url('/user/kuesioner') }}" class="mobile-link {{ request()->is('user/kuesioner*') ? 'active' : '' }}">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                Kuesioner
            </a>
            <a href="{{ url('/user/histori') }}" class="mobile-link {{ request()->is('user/histori*') ? 'active' : '' }}">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                Histori
            </a>
            <a href="{{ url('/user/grafik') }}" class="mobile-link {{ request()->is('user/grafik*') ? 'active' : '' }}">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                Grafik
            </a>
            <a href="{{ url('/user/laporan') }}" class="mobile-link {{ request()->is('user/laporan*') ? 'active' : '' }}">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                Laporan
            </a>
            <a href="{{ url('/user/profil') }}" class="mobile-link {{ request()->is('user/profil*') ? 'active' : '' }}">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                Profil
            </a>
            <div style="border-top:1px solid var(--border-card);margin-top:8px;padding-top:8px;">
                <form method="POST" action="{{ url('/user/logout') }}">@csrf
                    <button type="submit" class="mobile-link" style="width:100%;text-align:left;color:var(--red);">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--red)" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                        Keluar
                    </button>
                </form>
            </div>
        </div>
    </nav>

    {{-- ═══ Main Content ═══ --}}
    <main class="main-content">
        <div class="page-container">
            @yield('content')
        </div>
    </main>

    {{-- ═══ Footer ═══ --}}
    <footer class="site-footer">
        <div class="footer-inner">
            <div style="display:flex;align-items:center;gap:10px;">
                <div class="topnav-logo" style="width:28px;height:28px;">
                    <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round"><path d="M9 11l3 3L22 4"/></svg>
                </div>
                <span style="font-weight:700;color:var(--text-dark);">ACTIVA</span>
            </div>
            <p style="color:var(--text-muted);font-size:.8125rem;">© {{ date('Y') }} ACTIVA DigitalLife Analyzer. All rights reserved.</p>
        </div>
    </footer>

    {{-- Toast --}}
    <div class="toast-container" id="toastContainer"></div>

    @if(session('success'))<script>document.addEventListener('DOMContentLoaded',()=>showToast("{{ session('success') }}",'success'))</script>@endif
    @if(session('error'))<script>document.addEventListener('DOMContentLoaded',()=>showToast("{{ session('error') }}",'error'))</script>@endif
    @if(session('warning'))<script>document.addEventListener('DOMContentLoaded',()=>showToast("{{ session('warning') }}",'warning'))</script>@endif

    <script>
    function showToast(msg,type='info'){const c=document.getElementById('toastContainer');const d=document.createElement('div');d.className='toast toast-'+type;d.innerHTML='<span>'+msg+'</span>';c.appendChild(d);setTimeout(()=>{d.style.opacity='0';d.style.transform='translateX(100%)';d.style.transition='all .3s';setTimeout(()=>d.remove(),300)},3500)}
    function toggleMobileMenu(){const m=document.getElementById('mobileMenu');m.classList.toggle('open');document.getElementById('hamburgerBtn').classList.toggle('active')}
    // Navbar scroll effect
    window.addEventListener('scroll',()=>{document.getElementById('topnav').classList.toggle('scrolled',window.scrollY>20)});
    </script>
    @yield('scripts')
</body>
</html>
