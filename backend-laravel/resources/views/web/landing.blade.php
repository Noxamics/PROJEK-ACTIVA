<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="ACTIVA — Platform Analisis Gaya Hidup Digital berbasis Machine Learning dan AI">
    <title>ACTIVA — DigitalLife Analyzer</title>
    <link href="{{ asset('css/web.css') }}" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;1,9..40,400&display=swap" rel="stylesheet">
    <style>
    /* ════════════════════════════════════════════
       ACTIVA Landing — Mixed Light/Dark Theme
       Matching Flutter app palette + UI style
    ════════════════════════════════════════════ */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
        /* Core palette from Flutter app */
        --navy:          #0A1628;
        --navy-mid:      #0F1F3D;
        --navy-card:     #162040;
        --navy-glass:    rgba(15,31,61,0.75);
        --teal:          #0D9488;
        --teal-light:    #5EEAD4;
        --teal-glow:     rgba(13,148,136,0.28);
        --yellow:        #FACC15;
        --yellow-dim:    rgba(250,204,21,0.14);
        --purple:        #7C83FD;
        --purple-dim:    rgba(124,131,253,0.14);
        --subtitle-dark: #8BBFD4;
        /* Light section palette */
        --light-bg:      #F0F4F8;
        --light-card:    #FFFFFF;
        --light-border:  rgba(13,148,136,0.12);
        --light-text:    #0A1628;
        --light-sub:     #4A6580;
        /* Universal */
        --white:         #FFFFFF;
        --border-dark:   rgba(94,234,212,0.13);
        --font-head:     'Sora', sans-serif;
        --font-body:     'DM Sans', sans-serif;
        --r-xl: 24px; --r-lg: 18px; --r-md: 14px; --r-sm: 10px;
    }

    html { scroll-behavior: smooth; }
    body {
        font-family: var(--font-body);
        background: var(--navy);
        color: var(--white);
        overflow-x: hidden;
        -webkit-font-smoothing: antialiased;
    }
    ::-webkit-scrollbar { width: 5px; }
    ::-webkit-scrollbar-track { background: var(--navy); }
    ::-webkit-scrollbar-thumb { background: var(--teal); border-radius: 3px; }

    /* ── NOISE on dark sections ── */
    .dark-noise::after {
        content: '';
        position: absolute;
        inset: 0;
        background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.035'/%3E%3C/svg%3E");
        pointer-events: none;
        z-index: 0;
    }

    /* ════════ NAVBAR ════════ */
    .ln-nav {
        position: fixed; top: 0; left: 0; right: 0;
        z-index: 200;
        height: 66px;
        display: flex;
        align-items: center;
        padding: 0 32px;
        transition: background .35s, box-shadow .35s;
    }
    .ln-nav.scrolled {
        background: rgba(9,18,36,0.88);
        backdrop-filter: blur(22px);
        -webkit-backdrop-filter: blur(22px);
        box-shadow: 0 1px 0 var(--border-dark);
    }
    .ln-nav-inner {
        max-width: 1180px; margin: 0 auto; width: 100%;
        display: flex; align-items: center; justify-content: space-between;
    }
    /* Brand */
    .ln-brand { display: flex; align-items: center; gap: 9px; text-decoration: none; }
    .ln-brand-logo-img { width: 32px; height: 32px; object-fit: contain; }
    .ln-brand-text {
        font-family: var(--font-head); font-weight: 800; font-size: 1.1rem;
        color: var(--white); letter-spacing: 0.05em;
    }
    /* Nav links */
    .ln-nav-links { display: flex; align-items: center; gap: 4px; }
    .ln-nav-link {
        color: rgba(255,255,255,0.6); text-decoration: none;
        font-size: 0.875rem; font-weight: 500;
        padding: 6px 14px; border-radius: 8px;
        transition: color .2s, background .2s;
    }
    .ln-nav-link:hover { color: var(--white); background: rgba(255,255,255,0.08); }
    .btn-nav-login {
        background: rgba(255,255,255,0.1);
        border: 1px solid rgba(255,255,255,0.18);
        color: var(--white);
        padding: 7px 18px; border-radius: 9px;
        text-decoration: none;
        font-family: var(--font-head); font-weight: 600; font-size: 0.85rem;
        transition: background .2s, transform .2s;
        margin-left: 4px;
    }
    .btn-nav-login:hover { background: rgba(255,255,255,0.18); transform: translateY(-1px); }
    .btn-nav-cta {
        background: linear-gradient(135deg, var(--teal), #0bbdae);
        color: var(--white);
        padding: 8px 20px; border-radius: 10px;
        text-decoration: none;
        font-family: var(--font-head); font-weight: 700; font-size: 0.875rem;
        box-shadow: 0 4px 18px var(--teal-glow);
        transition: transform .2s, box-shadow .2s;
        margin-left: 4px;
    }
    .btn-nav-cta:hover { transform: translateY(-1px); box-shadow: 0 7px 26px rgba(13,148,136,.45); }
    /* Hamburger */
    .ln-hamburger {
        display: none; background: none; border: none;
        cursor: pointer; color: var(--white); padding: 6px;
        border-radius: 8px;
    }
    .ln-mobile-menu {
        display: none; position: fixed;
        top: 66px; left: 0; right: 0;
        background: rgba(9,18,36,0.97);
        backdrop-filter: blur(24px);
        padding: 16px 24px 28px;
        border-bottom: 1px solid var(--border-dark);
        z-index: 199; flex-direction: column; gap: 2px;
    }
    .ln-mobile-menu.open { display: flex; }
    .ln-mobile-link {
        color: rgba(255,255,255,0.65); text-decoration: none;
        font-size: 1rem; font-weight: 500;
        padding: 12px 16px; border-radius: 10px;
        transition: color .2s, background .2s;
    }
    .ln-mobile-link:hover { color: var(--white); background: rgba(255,255,255,0.08); }
    .ln-mobile-link.teal { color: var(--teal-light); font-weight: 700; }
    .ln-mobile-divider { height: 1px; background: var(--border-dark); margin: 8px 0; }

    /* ════════ HERO — dark bg ════════ */
    .ln-hero {
        min-height: 100vh;
        background: var(--navy);
        display: flex; align-items: center;
        padding: 96px 32px 80px;
        position: relative; overflow: hidden;
    }
    /* Ambient blobs */
    .blob { position: absolute; border-radius: 50%; filter: blur(90px); pointer-events: none; }
    .blob-1 { width:640px;height:640px; background:radial-gradient(circle,rgba(13,148,136,.2) 0%,transparent 70%); top:-160px;left:-120px; }
    .blob-2 { width:520px;height:520px; background:radial-gradient(circle,rgba(124,131,253,.14) 0%,transparent 70%); bottom:-100px;right:-100px; }
    .blob-3 { width:340px;height:340px; background:radial-gradient(circle,rgba(250,204,21,.07) 0%,transparent 70%); top:35%;left:42%; }
    /* Grid */
    .hero-grid {
        position:absolute;inset:0;pointer-events:none;
        background-image:
            linear-gradient(rgba(94,234,212,.035) 1px,transparent 1px),
            linear-gradient(90deg,rgba(94,234,212,.035) 1px,transparent 1px);
        background-size:64px 64px;
    }
    .ln-hero-inner {
        max-width:1180px;margin:0 auto;width:100%;
        display:grid;grid-template-columns:1fr 1fr;gap:60px;
        align-items:center;position:relative;z-index:1;
    }
    /* Left */
    .ln-hero-badge {
        display:inline-flex;align-items:center;gap:8px;
        background:rgba(13,148,136,.12);
        border:1px solid rgba(94,234,212,.28);
        color:var(--teal-light);
        font-size:.76rem;font-weight:600;font-family:var(--font-head);
        padding:6px 14px;border-radius:100px;
        margin-bottom:26px;letter-spacing:.03em;
    }
    .ln-hero-badge .dot {
        width:7px;height:7px;background:var(--teal-light);border-radius:50%;
        box-shadow:0 0 8px var(--teal-light);
        animation:pulse-dot 2.2s ease-in-out infinite;
    }
    @keyframes pulse-dot {
        0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.4;transform:scale(.75)}
    }
    .ln-hero-title {
        font-family:var(--font-head);
        font-size:clamp(2.3rem,4.8vw,3.7rem);
        font-weight:800;line-height:1.1;
        margin-bottom:20px;
    }
    .ln-hero-title .grad {
        background:linear-gradient(135deg,var(--teal-light) 0%,var(--teal) 100%);
        -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
    }
    .ln-hero-sub {
        color:var(--subtitle-dark);font-size:1.05rem;line-height:1.72;
        max-width:480px;margin-bottom:38px;
    }
    .ln-hero-actions { display:flex;gap:14px;flex-wrap:wrap;margin-bottom:48px; }
    .btn-primary-lg {
        display:inline-flex;align-items:center;gap:8px;
        background:linear-gradient(135deg,var(--teal),#0bbdae);
        color:var(--white);font-family:var(--font-head);font-weight:700;font-size:1rem;
        padding:14px 28px;border-radius:14px;text-decoration:none;
        box-shadow:0 8px 30px rgba(13,148,136,.42);
        transition:transform .22s,box-shadow .22s;
    }
    .btn-primary-lg:hover { transform:translateY(-2px);box-shadow:0 14px 40px rgba(13,148,136,.55); }
    .btn-outline-lg {
        display:inline-flex;align-items:center;gap:8px;
        background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.2);
        color:var(--white);font-family:var(--font-head);font-weight:600;font-size:1rem;
        padding:14px 28px;border-radius:14px;text-decoration:none;
        transition:background .22s,transform .22s;
    }
    .btn-outline-lg:hover { background:rgba(255,255,255,.14);transform:translateY(-2px); }
    /* Stats pill */
    .ln-hero-stats {
        display:flex;align-items:stretch;
        background:var(--navy-glass);
        border:1px solid var(--border-dark);
        border-radius:18px;backdrop-filter:blur(14px);
        overflow:hidden;width:fit-content;
    }
    .ln-hs { display:flex;flex-direction:column;align-items:center;padding:14px 26px; }
    .ln-hs+.ln-hs { border-left:1px solid var(--border-dark); }
    .ln-hs-num { font-family:var(--font-head);font-weight:800;font-size:1.35rem;color:var(--teal-light); }
    .ln-hs-lbl { font-size:.7rem;color:var(--subtitle-dark);margin-top:2px;white-space:nowrap; }

    /* ── PHONE MOCKUP (Result ML style) ── */
    .ln-hero-right { display:flex;justify-content:center;align-items:center;position:relative; }
    .phone-wrap { position:relative;animation:float 5.5s ease-in-out infinite; }
    @keyframes float { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-16px)} }
    .phone-glow-shadow {
        position:absolute;bottom:-48px;left:50%;transform:translateX(-50%);
        width:180px;height:44px;
        background:var(--teal);border-radius:50%;
        filter:blur(36px);opacity:.28;pointer-events:none;
    }
    /* Phone frame */
    .phone-frame {
        width:280px;
        background:linear-gradient(170deg,#0D1B38 0%,#0A1628 100%);
        border-radius:40px;
        border:1.5px solid rgba(94,234,212,.18);
        box-shadow:
            0 0 0 7px rgba(13,148,136,.07),
            0 36px 80px rgba(0,0,0,.55),
            0 0 80px rgba(13,148,136,.18);
        overflow:hidden;
        position:relative;
    }
    .phone-notch {
        height:30px;background:#080f1e;
        display:flex;align-items:center;justify-content:center;
    }
    .phone-notch span { width:72px;height:9px;background:#0D1B38;border-radius:100px; }
    .phone-body { padding:18px 16px 20px; }

    /* ── Result ML UI ── */
    .pr-topbar {
        display:flex;align-items:center;justify-content:space-between;
        margin-bottom:22px;
    }
    .pr-topbar-left {}
    .pr-topbar-title {
        font-family:var(--font-head);font-size:.9rem;font-weight:800;
        color:var(--white);line-height:1;
    }
    .pr-topbar-sub { font-size:.62rem;color:var(--subtitle-dark);margin-top:2px; }
    .pr-mascot-small {
        width:48px;height:48px;object-fit:contain;
        filter:drop-shadow(0 0 8px rgba(94,234,212,.35));
    }

    /* Big score ring */
    .pr-score-wrap {
        display:flex;flex-direction:column;align-items:center;
        margin-bottom:20px;position:relative;
    }
    .pr-ring-container {
        position:relative;width:150px;height:150px;margin-bottom:14px;
    }
    .pr-ring-container svg { transform:rotate(-105deg); }
    .pr-ring-track { fill:none;stroke:rgba(255,255,255,.07);stroke-width:10; }
    .pr-ring-dots {
        fill:none;stroke:rgba(94,234,212,.2);
        stroke-width:10;stroke-dasharray:2 10;stroke-linecap:round;
    }
    .pr-ring-fill {
        fill:none;stroke:var(--teal-light);stroke-width:10;
        stroke-linecap:round;
        stroke-dasharray:376;
        stroke-dashoffset:263; /* 30% filled */
        filter:drop-shadow(0 0 8px rgba(94,234,212,.7));
        animation:ring-draw 1.4s ease forwards;
    }
    @keyframes ring-draw {
        from { stroke-dashoffset: 376; }
        to   { stroke-dashoffset: 263; }
    }
    /* Mascot inside ring */
    .pr-mascot-inside {
        position:absolute;top:50%;left:50%;
        transform:translate(-50%,-52%);
        width:44px;height:44px;
        object-fit:contain;
        filter:drop-shadow(0 2px 12px rgba(94,234,212,.4));
    }
    .pr-score-num-wrap {
        text-align:center;
    }
    .pr-score-big {
        font-family:var(--font-head);font-size:2.6rem;font-weight:900;
        color:var(--teal-light);line-height:1;
        text-shadow:0 0 24px rgba(94,234,212,.5);
    }
    .pr-score-badge {
        display:inline-block;margin-top:6px;
        background:rgba(13,148,136,.25);border:1px solid rgba(94,234,212,.3);
        color:var(--teal-light);font-family:var(--font-head);
        font-size:.62rem;font-weight:700;
        padding:3px 12px;border-radius:100px;
        letter-spacing:.06em;text-transform:uppercase;
    }

    /* Result label */
    .pr-result-label {
        text-align:center;margin-bottom:14px;
    }
    .pr-result-title {
        font-family:var(--font-head);font-size:1rem;font-weight:800;
        color:var(--white);margin-bottom:4px;
    }
    .pr-result-desc {
        font-size:.67rem;color:var(--subtitle-dark);
        line-height:1.5;max-width:200px;margin:0 auto;
    }

    /* AI chat bubble */
    .pr-chat-bubble {
        background:rgba(255,255,255,.07);
        border:1px solid rgba(255,255,255,.1);
        border-radius:14px;
        padding:10px 12px;
        display:flex;gap:10px;align-items:flex-start;
    }
    .pr-chat-avatar {
        width:26px;height:26px;flex-shrink:0;
        object-fit:contain;
        filter:drop-shadow(0 0 6px rgba(94,234,212,.3));
    }
    .pr-chat-text {
        font-size:.62rem;color:rgba(255,255,255,.8);
        line-height:1.55;
    }
    .pr-chat-dots {
        display:flex;gap:3px;margin-top:4px;
    }
    .pr-chat-dots span {
        width:4px;height:4px;border-radius:50%;
        background:var(--teal-light);opacity:.6;
        animation:chat-dot 1.2s ease-in-out infinite;
    }
    .pr-chat-dots span:nth-child(2){animation-delay:.2s}
    .pr-chat-dots span:nth-child(3){animation-delay:.4s}
    @keyframes chat-dot { 0%,80%,100%{opacity:.25;transform:scale(.8)} 40%{opacity:1;transform:scale(1)} }

    /* ════════ HOW-IT-WORKS — LIGHT (enriched) ════════ */
    .ln-section-light {
        background: var(--light-bg);
        padding: 100px 32px;
        position: relative;
        overflow: hidden;
    }
    /* Dot-grid pattern overlay */
    .ln-section-light::after {
        content: '';
        position: absolute;
        inset: 0;
        background-image: radial-gradient(circle, rgba(13,148,136,.12) 1px, transparent 1px);
        background-size: 32px 32px;
        pointer-events: none;
        z-index: 0;
    }
    /* Large teal blob top-right */
    .ln-section-light::before {
        content:'';position:absolute;
        top:-140px;right:-140px;
        width:480px;height:480px;
        background:radial-gradient(circle,rgba(13,148,136,.11) 0%,transparent 65%);
        pointer-events:none;
        z-index: 0;
    }
    /* Extra decorative blobs for light sections */
    .light-blob-bl {
        position: absolute;
        bottom: -80px; left: -80px;
        width: 360px; height: 360px;
        background: radial-gradient(circle, rgba(124,131,253,.09) 0%, transparent 65%);
        border-radius: 50%;
        pointer-events: none;
        z-index: 0;
    }
    .light-blob-center {
        position: absolute;
        top: 50%; left: 50%;
        transform: translate(-50%,-50%);
        width: 600px; height: 300px;
        background: radial-gradient(ellipse, rgba(250,204,21,.04) 0%, transparent 70%);
        pointer-events: none;
        z-index: 0;
    }
    /* Diagonal accent lines */
    .light-accent-lines {
        position: absolute;
        inset: 0;
        pointer-events: none;
        z-index: 0;
        overflow: hidden;
    }
    .light-accent-lines svg {
        position: absolute;
        width: 100%; height: 100%;
    }

    .ln-container { max-width:1180px;margin:0 auto;position:relative;z-index:1; }
    .ln-section-header { text-align:center;margin-bottom:60px; }
    .ln-badge-light {
        display:inline-flex;align-items:center;gap:6px;
        background:rgba(13,148,136,.1);
        border:1px solid rgba(13,148,136,.22);
        color:var(--teal);
        font-size:.72rem;font-weight:700;font-family:var(--font-head);
        padding:5px 14px;border-radius:100px;
        margin-bottom:18px;letter-spacing:.07em;text-transform:uppercase;
    }
    .ln-title-light {
        font-family:var(--font-head);
        font-size:clamp(1.75rem,3.8vw,2.7rem);
        font-weight:800;line-height:1.15;
        color:var(--light-text);margin-bottom:14px;
    }
    .ln-title-light .grad-teal {
        background:linear-gradient(135deg,var(--teal),var(--purple));
        -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
    }
    .ln-sub-light { color:var(--light-sub);font-size:.97rem;line-height:1.7;max-width:520px;margin:0 auto; }

    /* Steps */
    .ln-steps { display:grid;grid-template-columns:repeat(3,1fr);gap:28px; }
    .ln-step-card {
        background:var(--light-card);
        border:1px solid var(--light-border);
        border-radius:var(--r-xl);
        padding:36px 28px;
        text-align:center;
        box-shadow:0 4px 20px rgba(13,148,136,.07);
        transition:transform .25s,box-shadow .25s;
        position:relative;overflow:hidden;
    }
    .ln-step-card::before {
        content:'';position:absolute;inset:0;
        background:linear-gradient(135deg,var(--step-c,rgba(13,148,136,.04)) 0%,transparent 60%);
        pointer-events:none;
    }
    .ln-step-card:hover { transform:translateY(-4px); border-color: rgba(0,229,200,0.4); box-shadow: 0 12px 40px rgba(0,229,200,0.15), 0 4px 12px rgba(0,0,0,0.1); }
    .ln-step-num {
        width:60px;height:60px;
        border-radius:50%;
        background:var(--step-bg,linear-gradient(135deg,var(--teal),#0bbdae));
        display:flex;align-items:center;justify-content:center;
        font-family:var(--font-head);font-size:1.4rem;font-weight:900;color:#fff;
        margin:0 auto 20px;
        box-shadow:0 8px 22px var(--step-shadow,rgba(13,148,136,.3));
    }
    .ln-step-card h3 { font-family:var(--font-head);font-size:1rem;font-weight:700;color:var(--light-text);margin-bottom:10px; }
    .ln-step-card p { color:var(--light-sub);font-size:.875rem;line-height:1.65; }

    /* ════════ FEATURES — DARK ════════ */
    .ln-section-dark {
        background:var(--navy);
        padding:100px 32px;
        position:relative;overflow:hidden;
    }
    .ln-section-dark::before {
        content:'';position:absolute;
        bottom:-80px;left:-80px;
        width:480px;height:480px;
        background:radial-gradient(circle,rgba(124,131,253,.1) 0%,transparent 70%);
        pointer-events:none;
    }
    .ln-badge-dark {
        display:inline-flex;align-items:center;gap:6px;
        background:var(--yellow-dim);
        border:1px solid rgba(250,204,21,.28);
        color:var(--yellow);
        font-size:.72rem;font-weight:700;font-family:var(--font-head);
        padding:5px 14px;border-radius:100px;
        margin-bottom:18px;letter-spacing:.07em;text-transform:uppercase;
    }
    .ln-title-dark {
        font-family:var(--font-head);
        font-size:clamp(1.75rem,3.8vw,2.7rem);
        font-weight:800;line-height:1.15;
        color:var(--white);margin-bottom:14px;
    }
    .ln-title-dark .grad-mix {
        background:linear-gradient(135deg,var(--teal-light),var(--purple));
        -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
    }
    .ln-sub-dark { color:var(--subtitle-dark);font-size:.97rem;line-height:1.7;max-width:520px;margin:0 auto; }
    /* Feature grid */
    .ln-feat-grid { display:grid;grid-template-columns:repeat(2,1fr);gap:20px; }
    .ln-feat-card {
        background:var(--navy-card);
        border:1px solid var(--border-dark);
        border-radius:var(--r-xl);
        padding:32px;
        position:relative;overflow:hidden;
        transition:transform .3s,border-color .3s,box-shadow .3s;
    }
    .ln-feat-card::before {
        content:'';position:absolute;inset:0;
        background:linear-gradient(135deg,var(--fc,rgba(13,148,136,.06)) 0%,transparent 55%);
        pointer-events:none;
    }
    .ln-feat-card:hover {
        transform:translateY(-4px);
        border-color:rgba(0,229,200,0.4);
        box-shadow:0 12px 40px rgba(0,229,200,0.15), 0 4px 12px rgba(0,0,0,0.3);
    }
    .ln-feat-num {
        position:absolute;top:22px;right:22px;
        font-family:var(--font-head);font-size:2.8rem;font-weight:900;
        color:rgba(255,255,255,.04);line-height:1;
    }
    .ln-feat-icon {
        width:50px;height:50px;border-radius:14px;
        display:flex;align-items:center;justify-content:center;
        margin-bottom:18px;
    }
    .ln-feat-card h3 { font-family:var(--font-head);font-size:1.05rem;font-weight:700;margin-bottom:9px; }
    .ln-feat-card p { color:var(--subtitle-dark);font-size:.88rem;line-height:1.65; }

    /* ════════ ANNOUNCEMENTS — LIGHT ════════ */
    .ln-ann-grid { display:grid;grid-template-columns:repeat(auto-fit,minmax(290px,1fr));gap:20px; }
    .ln-ann-card {
        background:var(--light-card);
        border:1px solid var(--light-border);
        border-radius:var(--r-xl);padding:24px;
        box-shadow:0 2px 12px rgba(13,148,136,.06);
        transition:transform .25s,box-shadow .25s;
    }
    .ln-ann-card:hover { transform:translateY(-3px);box-shadow:0 10px 30px rgba(13,148,136,.12); }
    .ln-ann-top { display:flex;align-items:center;justify-content:space-between;margin-bottom:14px; }
    .ln-ann-badge {
        font-size:.67rem;font-weight:700;font-family:var(--font-head);
        padding:4px 12px;border-radius:100px;text-transform:uppercase;letter-spacing:.05em;
    }
    .ln-ann-badge--info { background:rgba(13,148,136,.1);color:var(--teal); }
    .ln-ann-badge--warning { background:rgba(250,204,21,.12);color:#b45309; }
    .ln-ann-badge--update { background:rgba(124,131,253,.12);color:var(--purple); }
    .ln-ann-date { font-size:.7rem;color:var(--light-sub); }
    .ln-ann-title { font-family:var(--font-head);font-size:.97rem;font-weight:700;color:var(--light-text);margin-bottom:8px; }
    .ln-ann-content { color:var(--light-sub);font-size:.87rem;line-height:1.6;margin-bottom:14px; }
    .ln-ann-footer {
        display:flex;align-items:center;gap:6px;
        font-size:.7rem;color:rgba(74,101,128,.6);
        border-top:1px solid var(--light-border);padding-top:12px;
    }
    .ln-ann-empty { text-align:center;padding:60px 24px;color:var(--light-sub); }
    .ln-ann-empty p { margin-top:14px;font-size:.9rem; }

    /* ════════════════════════════════════
       STATS GRID — redesigned
       Icon kiri + teks kanan, lebih kaya
    ════════════════════════════════════ */
    .ln-stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 20px;
    }
    .ln-stat-card {
        background: var(--navy-card);
        border: 1px solid var(--border-dark);
        border-radius: var(--r-xl);
        padding: 26px 24px;
        position: relative;
        overflow: hidden;
        transition: transform .25s, box-shadow .25s, border-color .25s;
        display: flex;
        align-items: center;
        gap: 18px;
    }
    /* Top accent line */
    .ln-stat-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 2px;
        background: var(--st-line, linear-gradient(90deg, var(--teal), var(--teal-light)));
    }
    /* Corner glow */
    .ln-stat-card::after {
        content: '';
        position: absolute;
        top: -40px; right: -40px;
        width: 120px; height: 120px;
        background: var(--st-glow, radial-gradient(circle, rgba(13,148,136,.12) 0%, transparent 70%));
        border-radius: 50%;
        pointer-events: none;
    }
    .ln-stat-card:hover {
        transform: translateY(-4px);
        border-color: rgba(0,229,200,0.4);
        box-shadow: 0 12px 40px rgba(0,229,200,0.15), 0 4px 12px rgba(0,0,0,0.3);
    }

    /* Icon wrapper — left side */
    .ln-stat-icon {
        width: 52px;
        height: 52px;
        border-radius: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        position: relative;
        z-index: 1;
    }
    .ln-stat-icon svg {
        width: 26px;
        height: 26px;
    }

    /* Text — right side */
    .ln-stat-body {
        display: flex;
        flex-direction: column;
        gap: 3px;
        position: relative;
        z-index: 1;
        min-width: 0;
    }
    .ln-stat-num {
        font-family: var(--font-head);
        font-size: 1.85rem;
        font-weight: 900;
        line-height: 1;
        letter-spacing: -0.02em;
    }
    .ln-stat-lbl {
        font-size: .76rem;
        color: var(--subtitle-dark);
        font-weight: 500;
        white-space: nowrap;
    }
    /* Small decorative tag */
    .ln-stat-tag {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        font-size: .62rem;
        font-weight: 600;
        font-family: var(--font-head);
        padding: 2px 8px;
        border-radius: 100px;
        margin-top: 4px;
        width: fit-content;
    }
    .ln-stat-tag svg {
        width: 10px;
        height: 10px;
    }

    /* ════════ MASCOT SECTION — LIGHT (enriched) ════════ */
    .ln-mascot-section {
        background: var(--light-bg);
        padding: 80px 32px;
        position: relative;
        overflow: hidden;
    }
    /* Cross-hatch / grid pattern */
    .ln-mascot-section::after {
        content: '';
        position: absolute;
        inset: 0;
        background-image:
            linear-gradient(rgba(13,148,136,.07) 1px, transparent 1px),
            linear-gradient(90deg, rgba(13,148,136,.07) 1px, transparent 1px);
        background-size: 48px 48px;
        pointer-events: none;
        z-index: 0;
    }
    .ln-mascot-section::before {
        content: '';
        position: absolute;
        top: -100px; right: -60px;
        width: 500px; height: 500px;
        background: radial-gradient(circle, rgba(124,131,253,.1) 0%, transparent 65%);
        pointer-events: none;
        z-index: 0;
    }
    /* Fade edges so pattern doesn't hit section border harshly */
    .ln-mascot-fade {
        position: absolute;
        inset: 0;
        background:
            radial-gradient(ellipse 70% 50% at 50% 50%, transparent 40%, var(--light-bg) 100%);
        pointer-events: none;
        z-index: 1;
    }
    .ln-mascot-inner {
        max-width:1180px;margin:0 auto;
        display:grid;grid-template-columns:1fr auto;gap:60px;align-items:center;
        position: relative;
        z-index: 2;
    }
    .ln-mascot-text {}
    .ln-mascot-text h2 {
        font-family:var(--font-head);
        font-size:clamp(1.6rem,3.5vw,2.4rem);
        font-weight:800;color:var(--light-text);margin-bottom:14px;
    }
    .ln-mascot-text p { color:var(--light-sub);font-size:1rem;line-height:1.7;max-width:460px;margin-bottom:28px; }
    .ln-mascot-img { width:200px;height:200px;object-fit:contain;filter:drop-shadow(0 12px 28px rgba(13,148,136,.2)); }

    /* ════════ CTA — DARK gradient ════════ */
    .ln-cta-wrap { padding:0 32px 80px;background:var(--navy); }
    .ln-cta-box {
        max-width:1180px;margin:0 auto;
        background:linear-gradient(135deg,rgba(13,148,136,.18),rgba(124,131,253,.12));
        border:1px solid rgba(94,234,212,.22);
        border-radius:28px;
        padding:72px 48px;text-align:center;
        position:relative;overflow:hidden;
    }
    .ln-cta-box::before {
        content:'';position:absolute;top:-80px;right:-80px;
        width:320px;height:320px;
        background:radial-gradient(circle,rgba(13,148,136,.22) 0%,transparent 70%);
        pointer-events:none;
    }
    .ln-cta-box::after {
        content:'';position:absolute;bottom:-60px;left:-60px;
        width:260px;height:260px;
        background:radial-gradient(circle,rgba(124,131,253,.16) 0%,transparent 70%);
        pointer-events:none;
    }
    .ln-cta-title {
        font-family:var(--font-head);
        font-size:clamp(1.6rem,4vw,2.5rem);
        font-weight:800;margin-bottom:14px;
        position:relative;z-index:1;
    }
    .ln-cta-sub {
        color:var(--subtitle-dark);font-size:1rem;
        max-width:440px;margin:0 auto 34px;line-height:1.7;
        position:relative;z-index:1;
    }
    .ln-cta-actions { display:flex;gap:14px;justify-content:center;flex-wrap:wrap;position:relative;z-index:1; }

    /* ════════ FOOTER ════════ */
    .ln-footer {
        background:var(--navy-mid);
        border-top:1px solid var(--border-dark);
        padding:48px 32px 32px;
    }
    .ln-footer-inner {
        max-width:1180px;margin:0 auto;
        display:flex;align-items:flex-start;justify-content:space-between;
        gap:32px;flex-wrap:wrap;margin-bottom:30px;
    }
    .ln-footer-brand-desc { color:var(--subtitle-dark);font-size:.8rem;margin-top:8px;max-width:260px;line-height:1.6; }
    .ln-footer-links { display:flex;gap:6px;flex-wrap:wrap; }
    .ln-footer-links a {
        color:var(--subtitle-dark);text-decoration:none;font-size:.87rem;
        padding:6px 6.5px;border-radius:8px;transition:color .2s,background .2s;
    }
    .ln-footer-links a:hover { color:var(--white);background:rgba(255,255,255,.08); }
    .ln-footer-bottom {
        max-width:1180px;margin:0 auto;
        border-top:1px solid var(--border-dark);
        padding-top:22px;text-align:center;
        color:rgba(139,191,212,.45);font-size:.77rem;
    }

    /* ════════ ANIMATIONS ════════ */
    .anim-fade, .anim-up {
        opacity:0;transition:opacity .75s ease,transform .75s ease;
    }
    .anim-fade { transform:none; }
    .anim-up { transform:translateY(30px); }
    .anim-fade.visible, .anim-up.visible { opacity:1;transform:none; }
    .d1{transition-delay:.1s!important} .d2{transition-delay:.2s!important}
    .d3{transition-delay:.3s!important} .d4{transition-delay:.4s!important}

    /* ════════ RESPONSIVE ════════ */
    @media(max-width:1024px){
        .ln-stats-grid{grid-template-columns:repeat(2,1fr)}
        .ln-feat-grid{grid-template-columns:1fr}
    }
    @media(max-width:900px){
        .ln-hero-inner{grid-template-columns:1fr;text-align:center;gap:48px}
        .ln-hero-sub,.ln-hero-stats{margin-left:auto;margin-right:auto}
        .ln-hero-actions{justify-content:center}
        .ln-hero-right{order:-1}
        .ln-steps{grid-template-columns:1fr}
        .ln-mascot-inner{grid-template-columns:1fr;text-align:center}
        .ln-mascot-img{width:160px;height:160px;margin:0 auto}
        .ln-mascot-text p{margin-left:auto;margin-right:auto}
    }
    @media(max-width:640px){
        .ln-nav-links{display:none}
        .ln-hamburger{display:flex}
        .ln-hero{padding:90px 20px 64px}
        .ln-section-light,.ln-section-dark,.ln-mascot-section{padding:72px 20px}
        .ln-cta-wrap{padding:0 20px 60px}
        .ln-cta-box{padding:48px 24px}
        .ln-stats-grid{grid-template-columns:repeat(2,1fr)}
        .ln-hero-stats{flex-direction:column;width:100%}
        .ln-hs+.ln-hs{border-left:none;border-top:1px solid var(--border-dark)}
        .ln-hs{width:100%;flex-direction:row;justify-content:space-between}
        .phone-frame{width:250px}
    }
    @media(max-width:420px){
        .ln-stats-grid{grid-template-columns:1fr}
    }
    </style>
</head>
<body>

{{-- ═══ NAVBAR ═══ --}}
<nav class="ln-nav" id="lnNav">
    <div class="ln-nav-inner">
        <a href="{{ url('/user/landing') }}" class="ln-brand">
            <img src="{{ asset('images/NewLogoEmblem2.svg') }}" alt="ACTIVA Logo" class="ln-brand-logo-img">
            <span class="ln-brand-text">ACTIVA</span>
        </a>
        <div class="ln-nav-links">
            <a href="#how" class="ln-nav-link">Cara Kerja</a>
            <a href="#features" class="ln-nav-link">Fitur</a>
            <a href="#stats" class="ln-nav-link">Statistik</a>
            <a href="{{ url('/user/login') }}" class="btn-nav-login">Masuk</a>
            <a href="{{ url('/user/register') }}" class="btn-nav-cta">Daftar Gratis</a>
        </div>
        <button class="ln-hamburger" id="lnHamburger" aria-label="Menu"
            onclick="document.getElementById('lnMobile').classList.toggle('open')">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="4" y1="6" x2="20" y2="6"/><line x1="4" y1="12" x2="20" y2="12"/><line x1="4" y1="18" x2="20" y2="18"/>
            </svg>
        </button>
    </div>
</nav>
<div class="ln-mobile-menu" id="lnMobile">
    <a href="#how" class="ln-mobile-link" onclick="closeMobile()">Cara Kerja</a>
    <a href="#features" class="ln-mobile-link" onclick="closeMobile()">Fitur</a>
    <a href="#stats" class="ln-mobile-link" onclick="closeMobile()">Statistik</a>
    <div class="ln-mobile-divider"></div>
    <a href="{{ url('/user/login') }}" class="ln-mobile-link" onclick="closeMobile()">Masuk</a>
    <a href="{{ url('/user/register') }}" class="ln-mobile-link teal" onclick="closeMobile()">Daftar Gratis</a>
</div>

{{-- ═══ HERO — Dark ═══ --}}
<section class="ln-hero dark-noise">
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>
    <div class="blob blob-3"></div>
    <div class="hero-grid"></div>
    <div class="ln-hero-inner">
        {{-- Left text --}}
        <div class="ln-hero-left">
            <div class="ln-hero-badge anim-fade">
                <span class="dot"></span>
                Platform Analisis Digital 
            </div>
            <h1 class="ln-hero-title anim-fade d1">
                Kenali Gaya Hidup<br>
                <span class="grad">Digitalmu</span>
            </h1>
            <p class="ln-hero-sub anim-fade d2">
                Dapatkan analisis mendalam tentang kebiasaan digitalmu menggunakan Machine Learning dan rekomendasi personal dari AI.
            </p>
            <div class="ln-hero-actions anim-up d2" style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                <a href="{{ url('/user/register') }}" class="btn-primary-lg" style="text-align: center; display: inline-flex; align-items: center; justify-content: center; gap: 8px;">
                    Mulai Gratis
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                </a>
                <a href="#how" class="btn-outline-lg" style="text-align: center; display: inline-flex; align-items: center; justify-content: center; gap: 8px;">
                    Pelajari Lebih
                </a>
            </div>
            <div class="ln-hero-stats anim-up d3">
                @if($userCount > 100)
                    <div class="ln-hs">
                        <span class="ln-hs-num">{{ number_format($userCount) }}+</span>
                        <span class="ln-hs-lbl">Pengguna Aktif</span>
                    </div>
                    <div class="ln-hs">
                        <span class="ln-hs-num">{{ number_format($surveyCount) }}+</span>
                        <span class="ln-hs-lbl">Analisis Selesai</span>
                    </div>
                @else
                    <div class="ln-hs">
                        <span class="ln-hs-num">12</span>
                        <span class="ln-hs-lbl">Pertanyaan Kuesioner</span>
                    </div>
                    <div class="ln-hs">
                        <span class="ln-hs-num">&lt; 1 Menit</span>
                        <span class="ln-hs-lbl">Waktu Analisis</span>
                    </div>
                @endif
                <div class="ln-hs">
                    <span class="ln-hs-num">R² 0.87</span>
                    <span class="ln-hs-lbl">Akurasi Model</span>
                </div>
            </div>
        </div>

        {{-- Right — Phone mockup (Result ML style) --}}
        <div class="ln-hero-right anim-up d2">
            <div class="phone-wrap">
                <div class="phone-glow-shadow"></div>
                <div class="phone-frame">
                    <div class="phone-notch"><span></span></div>
                    <div class="phone-body">

                        {{-- Topbar --}}
                        <div class="pr-topbar">
                            <div class="pr-topbar-left">
                                <div class="pr-topbar-title">Hasil Analisis</div>
                                <div class="pr-topbar-sub">Machine Learning AI</div>
                            </div>
                            <img src="{{ asset('images/Maskot.png') }}" alt="Maskot" class="pr-mascot-small">
                        </div>

                        {{-- Big score ring --}}
                        <div class="pr-score-wrap">
                            <div class="pr-ring-container">
                                <svg width="150" height="150" viewBox="0 0 150 150">
                                    <circle class="pr-ring-track" cx="75" cy="75" r="60"/>
                                    <circle class="pr-ring-dots" cx="75" cy="75" r="60"/>
                                    <circle class="pr-ring-fill" cx="75" cy="75" r="60"/>
                                </svg>
                                <img src="{{ asset('images/Maskot3.png') }}" alt="" class="pr-mascot-inside">
                            </div>
                            <div class="pr-score-num-wrap">
                                <div class="pr-score-big">30</div>
                                <span class="pr-score-badge">Rendah</span>
                            </div>
                        </div>

                        {{-- Result label --}}
                        <div class="pr-result-label">
                            <div class="pr-result-title">Digital Balance: Excellent</div>
                            <div class="pr-result-desc">Kamu memiliki hubungan digital yang sangat sehat dan seimbang.</div>
                        </div>

                        {{-- AI chat bubble --}}
                        <div class="pr-chat-bubble">
                            <img src="{{ asset('images/Maskot1.png') }}" alt="AI" class="pr-chat-avatar">
                            <div>
                                <div class="pr-chat-text">Hai! Saya melihat kebiasaan digitalmu sangat baik. Pertahankan pola sehat ini untuk...</div>
                                <div class="pr-chat-dots">
                                    <span></span><span></span><span></span>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

{{-- ═══ HOW IT WORKS — Light ═══ --}}
<section class="ln-section-light" id="how">
    <div class="light-blob-bl"></div>
    <div class="light-blob-center"></div>
    <div class="light-accent-lines">
        <svg viewBox="0 0 1180 520" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
            <line x1="0" y1="520" x2="320" y2="0" stroke="rgba(13,148,136,.06)" stroke-width="1"/>
            <line x1="200" y1="520" x2="520" y2="0" stroke="rgba(13,148,136,.04)" stroke-width="1"/>
            <line x1="860" y1="520" x2="1180" y2="0" stroke="rgba(124,131,253,.06)" stroke-width="1"/>
            <line x1="1000" y1="520" x2="1180" y2="120" stroke="rgba(124,131,253,.04)" stroke-width="1"/>
            <circle cx="80" cy="80" r="60" fill="none" stroke="rgba(13,148,136,.07)" stroke-width="1"/>
            <circle cx="1100" cy="420" r="80" fill="none" stroke="rgba(124,131,253,.07)" stroke-width="1"/>
        </svg>
    </div>
    <div class="ln-container">
        <div class="ln-section-header anim-fade">
            <div class="ln-badge-light">Cara Kerja</div>
            <h2 class="ln-title-light">3 Langkah Menuju<br><span class="grad-teal">Digital Wellness</span></h2>
            <p class="ln-sub-light">Dari kuesioner hingga rekomendasi AI — semuanya selesai dalam hitungan menit.</p>
        </div>
        <div class="ln-steps">
            <div class="ln-step-card anim-up" style="--step-c:rgba(13,148,136,.05);">
                <div class="ln-step-num" style="--step-bg:linear-gradient(135deg,var(--teal),#0bbdae);--step-shadow:rgba(13,148,136,.3);">1</div>
                <h3>Isi Kuesioner</h3>
                <p>Jawab 12 pertanyaan terstruktur tentang kebiasaan digital, pola tidur, dan kondisi mentalmu. Mudah & cepat.</p>
            </div>
            <div class="ln-step-card anim-up d1" style="--step-c:rgba(124,131,253,.05);">
                <div class="ln-step-num" style="--step-bg:linear-gradient(135deg,var(--purple),#6b5ce7);--step-shadow:rgba(124,131,253,.3);">2</div>
                <h3>Analisis ML</h3>
                <p>Model Multiple Linear Regression kami memproses jawaban dan menghasilkan skor ketergantungan digital dengan akurasi tinggi.</p>
            </div>
            <div class="ln-step-card anim-up d2" style="--step-c:rgba(250,204,21,.04);">
                <div class="ln-step-num" style="--step-bg:linear-gradient(135deg,#f59e0b,var(--yellow));--step-shadow:rgba(250,204,21,.3);">3</div>
                <h3>Rekomendasi AI</h3>
                <p>Dapatkan insight dan langkah-langkah praktis yang dirumuskan oleh AI generatif berdasarkan hasil analisis skormu.</p>
            </div>
        </div>
    </div>
</section>

{{-- ═══ FEATURES — Dark ═══ --}}
<section class="ln-section-dark" id="features">
    <div class="ln-container">
        <div class="ln-section-header anim-fade">
            <div class="ln-badge-dark">Fitur Unggulan</div>
            <h2 class="ln-title-dark">Analisis Digital yang<br><span class="grad-mix">Cerdas & Personal</span></h2>
            <p class="ln-sub-dark">Didukung teknologi Machine Learning dan AI untuk insight yang akurat dan actionable.</p>
        </div>
        <div class="ln-feat-grid">
            <div class="ln-feat-card anim-up" style="--fc:rgba(13,148,136,.07);">
                <span class="ln-feat-num">01</span>
                <div class="ln-feat-icon" style="background:rgba(13,148,136,.12);">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="var(--teal-light)" stroke-width="2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                </div>
                <h3>Kuesioner Interaktif</h3>
                <p>12 pertanyaan terstruktur untuk mengukur kebiasaan digital, pola tidur, dan kondisi mental. Dengan slider interaktif dan feedback real-time.</p>
            </div>
            <div class="ln-feat-card anim-up d1" style="--fc:rgba(124,131,253,.07);">
                <span class="ln-feat-num">02</span>
                <div class="ln-feat-icon" style="background:rgba(124,131,253,.12);">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
                </div>
                <h3>Prediksi Machine Learning</h3>
                <p>Model Multiple Linear Regression menganalisis data dan memberikan skor ketergantungan digital.</p>
            </div>
            <div class="ln-feat-card anim-up d2" style="--fc:rgba(250,204,21,.05);">
                <span class="ln-feat-num">03</span>
                <div class="ln-feat-icon" style="background:rgba(250,204,21,.1);">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="var(--yellow)" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                </div>
                <h3>Visualisasi Data</h3>
                <p>Grafik interaktif menampilkan tren dan pola dari waktu ke waktu untuk memahami perkembangan digitalmu secara visual.</p>
            </div>
            <div class="ln-feat-card anim-up d3" style="--fc:rgba(94,234,212,.05);">
                <span class="ln-feat-num">04</span>
                <div class="ln-feat-icon" style="background:rgba(94,234,212,.1);">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="var(--teal-light)" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                </div>
                <h3>Insight & Rekomendasi AI</h3>
                <p>Laporan komprehensif dengan saran personalisasi dari AI — mencakup manajemen waktu layar hingga rutinitas digital detox.</p>
            </div>
        </div>
    </div>
</section>

{{-- ═══ STATS — Dark ═══ --}}
<section class="ln-section-dark" id="stats">
    <div class="ln-container">
        <div class="ln-section-header anim-fade">
            <div class="ln-badge-dark">Angka Bicara</div>
            <h2 class="ln-title-dark">Dipercaya Ribuan<br><span class="grad-mix">Pengguna ACTIVA</span></h2>
        </div>

        {{-- Stats grid: icon kiri, teks kanan --}}
        <div class="ln-stats-grid">

            {{-- Card 1: Pengguna Aktif — Teal --}}
            <div class="ln-stat-card anim-up"
                 style="--st-line:linear-gradient(90deg,var(--teal),var(--teal-light));
                        --st-glow:radial-gradient(circle,rgba(13,148,136,.15) 0%,transparent 70%);">
                <div class="ln-stat-icon" style="background:rgba(13,148,136,.12);">
                    <svg viewBox="0 0 24 24" fill="none" stroke="#5EEAD4" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                </div>
                <div class="ln-stat-body">
                    @if($userCount > 100)
                        <div class="ln-stat-num" style="color:var(--teal-light);">{{ number_format($userCount) }}+</div>
                        <div class="ln-stat-lbl">Pengguna Aktif</div>
                        <span class="ln-stat-tag" style="background:rgba(13,148,136,.15);color:var(--teal-light);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
                            Terus bertumbuh
                        </span>
                    @else
                        <div class="ln-stat-num" style="color:var(--teal-light);">12</div>
                        <div class="ln-stat-lbl">Aspek Analisis</div>
                        <span class="ln-stat-tag" style="background:rgba(13,148,136,.15);color:var(--teal-light);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
                            Kuesioner Terstruktur
                        </span>
                    @endif
                </div>
            </div>

            {{-- Card 2: Kuesioner Selesai — Purple --}}
            <div class="ln-stat-card anim-up d1"
                 style="--st-line:linear-gradient(90deg,var(--purple),#a5b4fc);
                        --st-glow:radial-gradient(circle,rgba(124,131,253,.15) 0%,transparent 70%);">
                <div class="ln-stat-icon" style="background:rgba(124,131,253,.12);">
                    <svg viewBox="0 0 24 24" fill="none" stroke="#7C83FD" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                        <polyline points="14 2 14 8 20 8"/>
                        <line x1="16" y1="13" x2="8" y2="13"/>
                        <line x1="16" y1="17" x2="8" y2="17"/>
                        <polyline points="10 9 9 9 8 9"/>
                    </svg>
                </div>
                <div class="ln-stat-body">
                    @if($surveyCount > 100)
                        <div class="ln-stat-num" style="color:var(--purple);">{{ number_format($surveyCount) }}+</div>
                        <div class="ln-stat-lbl">Kuesioner Selesai</div>
                        <span class="ln-stat-tag" style="background:rgba(124,131,253,.15);color:var(--purple);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            Dianalisis ML
                        </span>
                    @else
                        <div class="ln-stat-num" style="color:var(--purple);">&lt; 1 Menit</div>
                        <div class="ln-stat-lbl">Kecepatan Prediksi</div>
                        <span class="ln-stat-tag" style="background:rgba(124,131,253,.15);color:var(--purple);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            Real-time Processing
                        </span>
                    @endif
                </div>
            </div>

            {{-- Card 3: Akurasi Prediksi — Yellow --}}
            <div class="ln-stat-card anim-up d2"
                 style="--st-line:linear-gradient(90deg,var(--yellow),#fde68a);
                        --st-glow:radial-gradient(circle,rgba(250,204,21,.12) 0%,transparent 70%);">
                <div class="ln-stat-icon" style="background:rgba(250,204,21,.1);">
                    <svg viewBox="0 0 24 24" fill="none" stroke="#FACC15" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="22" y1="12" x2="18" y2="12"/>
                        <line x1="6" y1="12" x2="2" y2="12"/>
                        <line x1="12" y1="6" x2="12" y2="2"/>
                        <line x1="12" y1="22" x2="12" y2="18"/>
                        <circle cx="12" cy="12" r="3" fill="rgba(250,204,21,.3)" stroke="#FACC15"/>
                    </svg>
                </div>
                <div class="ln-stat-body">
                    <div class="ln-stat-num" style="color:var(--yellow);">R² 0.87</div>
                    <div class="ln-stat-lbl">Skor Evaluasi ML</div>
                    <span class="ln-stat-tag" style="background:rgba(250,204,21,.12);color:var(--yellow);">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        Multiple Linear Regression
                    </span>
                </div>
            </div>

            {{-- Card 4: Data Terenkripsi — Green --}}
            <div class="ln-stat-card anim-up d3"
                 style="--st-line:linear-gradient(90deg,#22c55e,#86efac);
                        --st-glow:radial-gradient(circle,rgba(34,197,94,.12) 0%,transparent 70%);">
                <div class="ln-stat-icon" style="background:rgba(34,197,94,.1);">
                    <svg viewBox="0 0 24 24" fill="none" stroke="#86efac" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        <circle cx="12" cy="16" r="1" fill="#86efac"/>
                    </svg>
                </div>
                <div class="ln-stat-body">
                    <div class="ln-stat-num" style="color:#86efac;">100%</div>
                    <div class="ln-stat-lbl">Data Terenkripsi</div>
                    <span class="ln-stat-tag" style="background:rgba(34,197,94,.12);color:#86efac;">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        Aman & Privat
                    </span>
                </div>
            </div>

        </div>
    </div>
</section>

{{-- ═══ MASCOT + CTA combined — Light ═══ --}}
<section class="ln-mascot-section">
    <div class="ln-mascot-fade"></div>
    <div class="ln-mascot-inner">
        <div class="ln-mascot-text anim-fade">
            <div class="ln-badge-light" style="margin-bottom:18px;">Mulai Sekarang</div>
            <h2>Siap Menganalisis Gaya Hidup<br><span style="background:linear-gradient(135deg,var(--teal),var(--purple));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;">Digitalmu?</span></h2>
            <p>Daftar gratis dan dapatkan insight berbasis AI dalam hitungan menit. Tidak perlu download aplikasi.</p>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                <a href="{{ url('/user/register') }}" class="btn-primary-lg" style="text-align: center; display: inline-flex; align-items: center; justify-content: center; gap: 8px;">
                    Daftar Sekarang
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                </a>
                <a href="{{ url('/user/login') }}" style="display:inline-flex;align-items:center;justify-content:center;gap:8px;background:transparent;border:2px solid var(--teal);color:var(--teal);font-family:var(--font-head);font-weight:600;font-size:1rem;padding:13px 26px;border-radius:14px;text-decoration:none;transition:background .2s,color .2s; text-align: center;" onmouseover="this.style.background='var(--teal)';this.style.color='#fff'" onmouseout="this.style.background='transparent';this.style.color='var(--teal)'">
                    Sudah Punya Akun
                </a>
            </div>
        </div>
        <div class="anim-up d1">
            <img src="{{ asset('images/Maskot4.png') }}" alt="ACTIVA Maskot" class="ln-mascot-img">
        </div>
    </div>
</section>

{{-- ═══ FOOTER ═══ --}}
<footer class="ln-footer">
    <div class="ln-footer-inner">
        <div>
            <a href="{{ url('/user/landing') }}" class="ln-brand" style="margin-bottom:4px;">
                <img src="{{ asset('images/NewLogoPutih.svg') }}" alt="ACTIVA Logo" class="ln-brand-logo-img">
                <span class="ln-brand-text">ACTIVA</span>
            </a>
            <p class="ln-footer-brand-desc">DigitalLife Analyzer — Platform analisis gaya hidup digital berbasis Machine Learning dan AI.</p>
        </div>
        <div class="ln-footer-links">
            <a href="{{ url('/user/login') }}">Masuk</a>
            <a href="{{ url('/user/register') }}">Daftar</a>
            <a href="#features">Fitur</a>
            <a href="#how">Cara Kerja</a>
            <a href="#stats">Statistik</a>
        </div>
    </div>
    <div class="ln-footer-bottom">
        <p>&copy; {{ date('Y') }} ACTIVA DigitalLife Analyzer. All rights reserved.</p>
    </div>
</footer>

<script>
function closeMobile(){ document.getElementById('lnMobile').classList.remove('open'); }
window.addEventListener('scroll',()=>{
    document.getElementById('lnNav').classList.toggle('scrolled', window.scrollY > 20);
});
document.querySelectorAll('a[href^="#"]').forEach(a=>{
    a.addEventListener('click',e=>{
        e.preventDefault();
        const t=document.querySelector(a.getAttribute('href'));
        if(t) t.scrollIntoView({behavior:'smooth',block:'start'});
        closeMobile();
    });
});
const obs=new IntersectionObserver((entries)=>{
    entries.forEach(e=>{ if(e.isIntersecting){ e.target.classList.add('visible'); obs.unobserve(e.target); } });
},{threshold:0.1});
document.querySelectorAll('.anim-fade,.anim-up').forEach(el=>obs.observe(el));
</script>
</body>
</html>