{{--
═══════════════════════════════════════════════
resources/views/layouts/app.blade.php
Layout utama Activa Admin Panel
═══════════════════════════════════════════════
--}}
<!DOCTYPE html>
<html lang="id">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <link rel="icon" type="image/svg+xml" href="{{ asset('../images/NewLogoEmblem2.svg') }}">
  <link rel="icon" type="image/png" href="{{ asset('images/favicon.png') }}">
  <title>@yield('title', 'Activa Admin')</title>
  <link
    href="https://fonts.googleapis.com/css2?family=DM+Serif+Display:ital@0;1&family=DM+Sans:wght@300;400;500;600;700&display=swap"
    rel="stylesheet">
  <link rel="stylesheet" href="{{ asset('css/dashboard.css') }}">
  <link rel="stylesheet" href="{{ asset('css/rules.css') }}">
  @stack('head-scripts')
  <style>
    :root {
      --navy: #1E3A5F;
      --navy-dk: #162D4A;
      --navy-lt: #264875;
      --navy-xlt: rgba(30, 58, 95, 0.08);
      --teal: #0D9488;
      --teal-dk: #0A7A6F;
      --teal-lt: rgba(13, 148, 136, 0.10);
      --teal-md: rgba(13, 148, 136, 0.18);
      --ice: #F0F9FF;
      --white: #FFFFFF;
      --border: #E2EAF2;
      --border2: #C8D8EA;
      --red: #E05252;
      --red-lt: rgba(224, 82, 82, 0.10);
      --amber: #D97706;
      --amber-lt: rgba(217, 119, 6, 0.10);
      --green: #059669;
      --green-lt: rgba(5, 150, 105, 0.10);
      --blue: #2563EB;
      --blue-lt: rgba(37, 99, 235, 0.10);
      --violet: #7C3AED;
      --violet-lt: rgba(124, 58, 237, 0.10);
      --text: #0F1F35;
      --text2: #4A6180;
      --text3: #8BA3BE;
      --serif: 'DM Serif Display', serif;
      --sans: 'DM Sans', sans-serif;
      --sidebar-w: 248px;
      --radius: 12px;
      --radius-lg: 16px;
      --shadow: 0 1px 3px rgba(30, 58, 95, 0.06), 0 4px 16px rgba(30, 58, 95, 0.05);
      --shadow-md: 0 2px 8px rgba(30, 58, 95, 0.08), 0 8px 24px rgba(30, 58, 95, 0.07);
    }

    *,
    *::before,
    *::after {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    html {
      font-size: 15px;
    }

    body {
      background: var(--ice);
      color: var(--text);
      font-family: var(--sans);
      min-height: 100vh;
      display: flex;
    }

    /* SIDEBAR */
    .sidebar {
      width: var(--sidebar-w);
      background: var(--navy);
      display: flex;
      flex-direction: column;
      position: fixed;
      top: 0;
      left: 0;
      bottom: 0;
      z-index: 100;
      padding-bottom: 20px;
    }

    .logo-img {
      width: 130px;
      height: 100px;
      object-fit: contain;
      margin-bottom: 20px;
      margin-left: 30px;
    }

    .sidebar-logo {
      padding: 15px 20px 20px;
      border-bottom: 1px solid rgba(255, 255, 255, 0.08);
      margin-bottom: 10px;
      display: flex;
      align-items: center;
      gap: 11px;
    }

    .logo-icon {
      width: 38px;
      height: 38px;
      background: var(--teal);
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 18px;
      flex-shrink: 0;
      box-shadow: 0 4px 12px rgba(13, 148, 136, 0.35);
    }

    .logo-name {
      font-family: var(--serif);
      font-size: 20px;
      color: #fff;
      letter-spacing: -0.3px;
    }

    .logo-name em {
      color: #5EEAD4;
      font-style: italic;
    }

    .logo-sub {
      font-size: 10px;
      color: rgba(255, 255, 255, 0.4);
      letter-spacing: 0.1em;
      text-transform: uppercase;
      margin-top: 1px;
    }

    .nav-group {
      padding: 0 10px;
      margin-bottom: 4px;
    }

    .nav-group-label {
      font-size: 9px;
      font-weight: 700;
      letter-spacing: 0.14em;
      text-transform: uppercase;
      color: rgba(255, 255, 255, 0.3);
      padding: 0 10px;
      margin: 10px 0 4px;
    }

    .nav-link {
      display: flex;
      align-items: center;
      gap: 9px;
      padding: 9px 10px;
      border-radius: 10px;
      color: rgba(255, 255, 255, 0.55);
      font-size: 13px;
      text-decoration: none;
      transition: all .15s;
      position: relative;
    }

    .nav-link:hover {
      background: rgba(255, 255, 255, 0.07);
      color: rgba(255, 255, 255, 0.85);
    }

    .nav-link.active {
      background: rgba(255, 255, 255, 0.12);
      color: #fff;
      font-weight: 500;
    }

    .nav-link.active::before {
      content: '';
      position: absolute;
      left: 0;
      top: 20%;
      bottom: 20%;
      width: 3px;
      background: var(--teal);
      border-radius: 0 3px 3px 0;
    }

    .nav-icon {
      width: 30px;
      height: 30px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 15px;
      flex-shrink: 0;
      background: rgba(255, 255, 255, 0.07);
    }

    .nav-link.active .nav-icon {
      background: var(--teal-md);
    }

    .sidebar-footer {
      margin-top: auto;
      padding: 14px 10px 0;
      border-top: 1px solid rgba(255, 255, 255, 0.08);
    }

    .admin-pill {
      display: flex;
      align-items: center;
      gap: 9px;
      padding: 10px;
      border-radius: 10px;
      background: rgba(255, 255, 255, 0.07);
    }

    .admin-av {
      width: 32px;
      height: 32px;
      border-radius: 50%;
      background: var(--teal);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      font-weight: 700;
      color: #fff;
      flex-shrink: 0;
    }

    .admin-name {
      font-size: 12px;
      font-weight: 600;
      color: #fff;
    }

    .admin-role {
      font-size: 10px;
      color: rgba(255, 255, 255, 0.4);
    }

    .logout-btn {
      margin-left: auto;
      background: none;
      border: none;
      color: rgba(255, 255, 255, 0.35);
      cursor: pointer;
      font-size: 15px;
      transition: color .2s;
    }

    .logout-btn:hover {
      color: var(--red);
    }

    /* MAIN */
    .main {
      margin-left: var(--sidebar-w);
      flex: 1;
      display: flex;
      flex-direction: column;
    }

    /* TOPBAR */
    .topbar {
      background: var(--white);
      border-bottom: 1px solid var(--border);
      padding: 0 28px;
      height: 60px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      position: sticky;
      top: 0;
      z-index: 50;
      box-shadow: 0 1px 0 var(--border);
    }

    .topbar-title {
      font-family: var(--serif);
      font-size: 20px;
      color: var(--navy);
    }

    .topbar-sub {
      font-size: 11px;
      color: var(--text3);
      margin-top: 1px;
    }

    .topbar-right {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .topbar-badge {
      display: flex;
      align-items: center;
      gap: 6px;
      background: var(--teal-lt);
      border: 1px solid rgba(13, 148, 136, 0.2);
      padding: 5px 12px;
      border-radius: 99px;
      font-size: 11px;
      color: var(--teal);
      font-weight: 600;
    }

    .topbar-badge::before {
      content: '';
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: var(--teal);
      animation: blink 2s infinite;
    }

    @keyframes blink {
      0%, 100% { opacity: 1 }
      50% { opacity: .3 }
    }

    .content {
      padding: 28px;
    }

    /* ALERT BANNERS */
    .alert {
      border-radius: var(--radius);
      padding: 12px 16px;
      font-size: 13px;
      line-height: 1.6;
      margin-bottom: 16px;
      display: flex;
      align-items: flex-start;
      gap: 10px;
      border: 1px solid;
    }

    .alert-info {
      background: rgba(13, 148, 136, 0.06);
      border-color: rgba(13, 148, 136, 0.18);
      color: var(--teal);
    }

    .alert-warning {
      background: var(--amber-lt);
      border-color: rgba(217, 119, 6, 0.2);
      color: var(--amber);
    }

    /* SCROLLBAR */
    ::-webkit-scrollbar { width: 5px; height: 5px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: var(--border2); border-radius: 3px; }

    /* RESPONSIVE */
    @media(max-width:768px) {
      .sidebar { display: none; }
      .main { margin-left: 0; }
      .content { padding: 16px; }
    }
  </style>
  @stack('styles')
</head>

<body>

  {{-- ═══ SIDEBAR ═══ --}}
  <aside class="sidebar">
    <div class="sidebar-logo">
      <div>
        <div class="brand-icon">
          <img src="../images/NewLogoPutih.svg" alt="Logo" class="logo-img">
        </div>
        <div class="logo-sub">Admin Panel</div>
      </div>
    </div>

    <nav>
      <div class="nav-group">
        <div class="nav-group-label">Utama</div>
        <a href="{{ route('admin.dashboard') }}"
          class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
          <div class="nav-icon">◈</div> Dashboard
        </a>
        <a href="{{ route('admin.users') }}" class="nav-link {{ request()->routeIs('admin.users*') ? 'active' : '' }}">
          <div class="nav-icon">⊞</div> User Management
        </a>
      </div>

      <div class="nav-group">
        <div class="nav-group-label">Analitik</div>
        <a href="{{ route('admin.monitoring') }}"
          class="nav-link {{ request()->routeIs('admin.monitoring') ? 'active' : '' }}">
          <div class="nav-icon">◎</div> Monitoring ML
        </a>
        <a href="{{ route('admin.kuesioner') }}"
          class="nav-link {{ request()->routeIs('admin.kuesioner*') ? 'active' : '' }}">
          <div class="nav-icon">≡</div> Data Kuesioner
        </a>
      </div>

      <div class="nav-group">
        <div class="nav-group-label">Konfigurasi</div>
        <a href="{{ route('admin.rules') }}" class="nav-link {{ request()->routeIs('admin.rules*') ? 'active' : '' }}">
          <div class="nav-icon">⌘</div> Rule Rekomendasi
        </a>
      </div>
    </nav>

    <div class="sidebar-footer">
      <div class="admin-pill">
        <div class="admin-av">
          {{ strtoupper(substr(auth()->user()->name ?? 'AD', 0, 2)) }}
        </div>
        <div>
          <div class="admin-name">{{ auth()->user()->name ?? 'Admin' }}</div>
          <div class="admin-role">Super Admin</div>
        </div>
        <form method="POST" action="{{ route('admin.logout') }}" style="margin-left:auto">
          @csrf
          <button type="submit" class="logout-btn" title="Logout">⏻</button>
        </form>
      </div>
    </div>
  </aside>

  {{-- ═══ MAIN ═══ --}}
  <main class="main">
    <div class="topbar">
      <div>
        <div class="topbar-title">@yield('page-title', 'Dashboard')</div>
        <div class="topbar-sub" id="topbar-date"></div>
      </div>
      <div class="topbar-right">
        @yield('topbar-actions')
        <div class="topbar-badge">System Online</div>
      </div>
    </div>

    <div class="content">

      {{-- Flash messages --}}
      @if(session('success'))
        <div class="alert alert-info" style="margin-bottom:20px">
          <span>✅</span> {{ session('success') }}
        </div>
      @endif
      @if(session('error'))
        <div class="alert alert-warning" style="margin-bottom:20px">
          <span>⚠️</span> {{ session('error') }}
        </div>
      @endif

      @yield('content')
    </div>
  </main>

  <script>
    document.getElementById('topbar-date').textContent =
      new Date().toLocaleDateString('id-ID', {
        weekday: 'long', day: 'numeric',
        month: 'long', year: 'numeric'
      });
  </script>
  @stack('scripts')

</body>

</html>