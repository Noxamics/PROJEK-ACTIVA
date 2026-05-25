@extends('web.layouts.app')
@section('title', 'Kuesioner')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/user-web/kuesioner.css') }}">
@endsection

@section('content')

<div class="kues-bg">
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>
    <div class="blob blob-3"></div>
</div>

{{-- Mobile Top Bar --}}
<div class="mobile-topbar">
    <div class="mobile-tb-row">
        <button class="mobile-back-btn" onclick="history.back()">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
        </button>
        <span class="mobile-page-badge" id="mobilePageBadge">Halaman 1 dari 3</span>
    </div>
    <div class="mobile-title-row">
        <div class="mobile-title">Kuesioner Digital</div>
        <div class="mobile-subtitle" id="mobileSubtitle">Penggunaan Digital</div>
    </div>
    <div class="mobile-steps">
        <div class="mobile-step-item">
            <div class="mobile-step-circle active" id="msc1">1</div>
            <div class="mobile-step-lbl active" id="msl1">Penggunaan<br>Digital</div>
        </div>
        <div class="mobile-step-conn" id="mconn1"></div>
        <div class="mobile-step-item">
            <div class="mobile-step-circle" id="msc2">2</div>
            <div class="mobile-step-lbl" id="msl2">Aktivitas &amp;<br>Tidur</div>
        </div>
        <div class="mobile-step-conn" id="mconn2"></div>
        <div class="mobile-step-item">
            <div class="mobile-step-circle" id="msc3">3</div>
            <div class="mobile-step-lbl" id="msl3">Kondisi<br>Mental</div>
        </div>
    </div>
    <div class="mobile-progress"><div class="mobile-progress-fill" id="mobileProgressFill"></div></div>
</div>

<div class="kues-shell">


    {{-- SIDEBAR --}}
    <aside class="kues-card kues-sidebar">
        {{-- Decorative circles --}}
        <span class="k-circle k-circle-ring"        style="width:170px;height:170px;top:-35px;left:-45px;"></span>
        <span class="k-circle k-circle-ring"        style="width:90px;height:90px;top:55px;right:-15px;border-color:rgba(13,148,136,.15);"></span>
        <span class="k-circle k-circle-ring"        style="width:55px;height:55px;top:15px;right:35px;border-color:rgba(255,255,255,.04);"></span>
        <span class="k-circle k-circle-fill"        style="width:210px;height:210px;top:-75px;right:-90px;"></span>
        <span class="k-circle k-circle-ring"        style="width:130px;height:130px;top:200px;left:-40px;border-color:rgba(13,148,136,.1);"></span>
        <span class="k-circle k-circle-fill-indigo" style="width:160px;height:160px;bottom:200px;left:-60px;"></span>
        <span class="k-circle k-circle-ring"        style="width:60px;height:60px;bottom:230px;right:18px;border-color:rgba(99,102,241,.2);"></span>
        <span class="k-circle k-circle-ring"        style="width:100px;height:100px;bottom:150px;right:-25px;border-color:rgba(13,148,136,.1);"></span>
        <span class="k-circle k-circle-fill-teal-lt" style="width:90px;height:90px;bottom:80px;left:10px;"></span>
        <span class="k-circle k-circle-ring"        style="width:40px;height:40px;bottom:55px;right:40px;border-color:rgba(255,255,255,.06);"></span>

        <div class="k-sidebar-brand" style="position:relative;z-index:1;">
            <div class="k-brand-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 20V10"/><path d="M12 20V4"/><path d="M6 20v-6"/></svg>
            </div>
            <div>
                <div class="k-brand-name">Analisis Digital</div>
                <div class="k-brand-sub">3 langkah mudah</div>
            </div>
        </div>

        <nav class="k-sidebar-nav">
            <div class="k-step current" id="ss1">
                <div class="k-step-icon">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2"/><path d="M12 18h.01"/></svg>
                </div>
                <div>
                    <div class="k-step-label">Penggunaan Digital</div>
                    <div class="k-step-sub">Pertanyaan 1–4</div>
                </div>
            </div>
            <div class="k-step locked" id="ss2">
                <div class="k-step-icon">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
                </div>
                <div>
                    <div class="k-step-label">Aktivitas &amp; Tidur</div>
                    <div class="k-step-sub">Pertanyaan 5–8</div>
                </div>
            </div>
            <div class="k-step locked" id="ss3">
                <div class="k-step-icon">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><circle cx="12" cy="12" r="10"/><path d="M12 17h.01"/></svg>
                </div>
                <div>
                    <div class="k-step-label">Kondisi Mental</div>
                    <div class="k-step-sub">Pertanyaan 9–12</div>
                </div>
            </div>
        </nav>

        <div class="k-sidebar-mascot">
            <img src="{{ asset('images/Maskot2.png') }}" alt="Maskot">
            <div class="k-mascot-text">Isi dengan jujur ya! Hasilnya untuk kamu</div>
        </div>
    </aside>

    {{-- MAIN PANEL --}}
    <main class="kues-card kues-main">
       
        <div class="k-topbar">
            <span class="k-page-badge">
                <span class="k-badge-dot"></span>
                <span id="desktopPageBadge">Halaman 1 dari 3</span>
            </span>
        </div>

        <div class="k-progress-wrap">
            <div class="k-progress-bg"><div class="k-progress-fill" id="progressFill"></div></div>
            <div class="k-progress-pct" id="progressPct">33%</div>
        </div>

        @if($errors->any())
        <div class="k-error-box">
            @foreach($errors->all() as $err)<p>{{ $err }}</p>@endforeach
        </div>
        @endif

        <form method="POST" action="{{ url('/user/kuesioner') }}" id="kuesionerForm">
            @csrf
            <input type="hidden" name="device_type" id="device_type_input" value="{{ old('device_type','Smartphone') }}">

            {{-- ══ STEP 1 ══ --}}
            <div class="wizard-page" id="step1">
                <div class="k-step-header">
                    <h2>
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2"/><path d="M12 18h.01"/></svg>
                        Penggunaan Digital
                    </h2>
                    <p>Ceritakan bagaimana kamu menggunakan perangkat sehari-hari</p>
                </div>

                {{-- Q1 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">1</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
                        Berapa lama menggunakan perangkat per hari?
                    </label>
                    <div class="k-opt-group" data-name="device_hours_per_day">
                        @foreach([2=>'< 3 jam|Ringan|Penggunaan minimal',5=>'3–6 jam|Sedang|Penggunaan wajar',8=>'6–10 jam|Tinggi|Cukup intensif',12=>'> 10 jam|Sangat tinggi|Sangat intensif'] as $val=>$lbl)
                        @php [$l,$s,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('device_hours_per_day')==$val?'selected':'' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $s }} — {{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="device_hours_per_day" value="{{ old('device_hours_per_day') }}">
                </div>

                {{-- Q2 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">2</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2"/><path d="M12 18h.01"/></svg></span>
                        Berapa kali membuka HP per hari?
                    </label>
                    <div class="k-opt-group" data-name="phone_unlocks">
                        @foreach([30=>'< 50 kali|Jarang|Sangat terkontrol',75=>'50–100 kali|Cukup sering|Normal',150=>'100–200 kali|Sering|Perlu diperhatikan',300=>'> 200 kali|Sangat sering|Ketergantungan tinggi'] as $val=>$lbl)
                        @php [$l,$s,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('phone_unlocks')==$val?'selected':'' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $s }} — {{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="phone_unlocks" value="{{ old('phone_unlocks') }}">
                </div>

                {{-- Q3 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">3</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg></span>
                        Jumlah notifikasi per hari?
                    </label>
                    <div class="k-opt-group" data-name="notifications_per_day">
                        @foreach([50=>'< 100|Sedikit|Fokus terjaga',200=>'100–300|Cukup banyak|Mulai mengganggu',400=>'300–500|Banyak|Distraksi tinggi',600=>'> 500|Sangat banyak|Overload informasi'] as $val=>$lbl)
                        @php [$l,$s,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('notifications_per_day')==$val?'selected':'' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $s }} — {{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="notifications_per_day" value="{{ old('notifications_per_day') }}">
                </div>

                {{-- Q4 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">4</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 2H7a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2z"/><rect x="9" y="11" width="6" height="4" rx="1"/></svg></span>
                        Waktu media sosial per hari
                    </label>
                    <div class="k-range-wrap">
                        <div class="k-range-labels">
                            <span>0 menit</span>
                            <div class="k-range-val-wrap">
                                <span class="k-range-val" id="smVal">{{ old('social_media_mins',60) }}</span>
                                <span class="k-range-unit">menit / hari</span>
                            </div>
                            <span>600 menit</span>
                        </div>
                        <input type="range" class="k-range-slider" name="social_media_mins"
                               min="0" max="600" step="10" value="{{ old('social_media_mins',60) }}"
                               oninput="kRange(this,'smVal')">
                    </div>
                </div>
            </div>

            {{-- ══ STEP 2 ══ --}}
            <div class="wizard-page hidden" id="step2">
                <div class="k-step-header">
                    <h2>
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
                        Aktivitas &amp; Tidur
                    </h2>
                    <p>Seberapa aktif kamu secara fisik dan kualitas istirahatmu</p>
                </div>

                {{-- Q5 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">5</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg></span>
                        Waktu belajar per hari
                    </label>
                    <div class="k-range-wrap">
                        <div class="k-range-labels">
                            <span>0 menit</span>
                            <div class="k-range-val-wrap">
                                <span class="k-range-val" id="stVal">{{ old('study_minutes',60) }}</span>
                                <span class="k-range-unit">menit / hari</span>
                            </div>
                            <span>480 menit</span>
                        </div>
                        <input type="range" class="k-range-slider" name="study_minutes"
                               min="0" max="480" step="10" value="{{ old('study_minutes',60) }}"
                               oninput="kRange(this,'stVal')">
                    </div>
                </div>

                {{-- Q6 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">6</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
                        Olahraga berapa hari per minggu?
                    </label>
                    <div class="k-opt-group" data-name="physical_activity_days">
                        @foreach([0=>'0 hari|Tidak pernah|Sangat sedentari',2=>'1–3 hari|Kadang|Aktif ringan',5=>'4–5 hari|Sering|Aktif moderat',7=>'6–7 hari|Setiap hari|Sangat aktif'] as $val=>$lbl)
                        @php [$l,$s,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('physical_activity_days')===$val?'selected':'' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $s }} — {{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="physical_activity_days" value="{{ old('physical_activity_days') }}">
                </div>

                {{-- Q7 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">7</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg></span>
                        Durasi tidur per malam?
                    </label>
                    <div class="k-opt-group" data-name="sleep_hours">
                        @foreach([4=>'< 5 jam|Sangat kurang|Risiko kesehatan',6=>'5–6 jam|Kurang|Di bawah ideal',7=>'7–8 jam|Cukup|Durasi ideal',9=>'> 8 jam|Lebih dari cukup|Istirahat panjang'] as $val=>$lbl)
                        @php [$l,$s,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('sleep_hours')==$val?'selected':'' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $s }} — {{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="sleep_hours" value="{{ old('sleep_hours') }}">
                </div>

                {{-- Q8 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">8</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                        Kualitas tidur (1 = buruk, 5 = sangat baik)
                    </label>
                    <div class="k-range-wrap">
                        <div class="k-range-labels">
                            <span>1 — Buruk</span>
                            <div class="k-range-val-wrap">
                                <span class="k-range-val" id="sqVal">{{ old('sleep_quality',3) }}</span>
                                <span class="k-range-unit">dari 5</span>
                            </div>
                            <span>5 — Sangat baik</span>
                        </div>
                        <input type="range" class="k-range-slider" name="sleep_quality"
                               min="1" max="5" step="1" value="{{ old('sleep_quality',3) }}"
                               oninput="kRange(this,'sqVal')">
                    </div>
                </div>
            </div>

            {{-- ══ STEP 3 ══ --}}
            <div class="wizard-page hidden" id="step3">
                <div class="k-step-header">
                    <h2>
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><circle cx="12" cy="12" r="10"/><path d="M12 17h.01"/></svg>
                        Kondisi Mental
                    </h2>
                    <p>Jawab dengan jujur untuk hasil analisis yang akurat</p>
                </div>

                {{-- Q9 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">9</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                        Tingkat kecemasan (skor GAD-7, 0–27)
                    </label>
                    <div class="k-range-wrap">
                        <div class="k-range-labels">
                            <span>0 — Tidak ada</span>
                            <div class="k-range-val-wrap">
                                <span class="k-range-val" id="axVal">{{ old('anxiety_score',5) }}</span>
                                <span class="k-range-unit">skor</span>
                            </div>
                            <span>27 — Berat</span>
                        </div>
                        <input type="range" class="k-range-slider" name="anxiety_score"
                               min="0" max="27" step="1" value="{{ old('anxiety_score',5) }}"
                               oninput="kRange(this,'axVal')">
                    </div>
                </div>

                {{-- Q10 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">10</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M16 16s-1.5-2-4-2-4 2-4 2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg></span>
                        Skor depresi (skor PHQ-9, 0–27)
                    </label>
                    <div class="k-range-wrap">
                        <div class="k-range-labels">
                            <span>0 — Tidak ada</span>
                            <div class="k-range-val-wrap">
                                <span class="k-range-val" id="dpVal">{{ old('depression_score',5) }}</span>
                                <span class="k-range-unit">skor</span>
                            </div>
                            <span>27 — Berat</span>
                        </div>
                        <input type="range" class="k-range-slider" name="depression_score"
                               min="0" max="27" step="1" value="{{ old('depression_score',5) }}"
                               oninput="kRange(this,'dpVal')">
                    </div>
                </div>

                {{-- Q11 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">11</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></span>
                        Tingkat stres saat ini (1–10)
                    </label>
                    <div class="k-range-wrap">
                        <div class="k-range-labels">
                            <span>1 — Sangat rendah</span>
                            <div class="k-range-val-wrap">
                                <span class="k-range-val" id="slVal">{{ old('stress_level',5) }}</span>
                                <span class="k-range-unit">dari 10</span>
                            </div>
                            <span>10 — Sangat tinggi</span>
                        </div>
                        <input type="range" class="k-range-slider" name="stress_level"
                               min="1" max="10" step="1" value="{{ old('stress_level',5) }}"
                               oninput="kRange(this,'slVal')">
                    </div>
                </div>

                {{-- Q12 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">12</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M8 13s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg></span>
                        Skor kebahagiaan kamu (0–10)
                    </label>
                    <div class="k-range-wrap">
                        <div class="k-range-labels">
                            <span>0 — Sangat rendah</span>
                            <div class="k-range-val-wrap">
                                <span class="k-range-val" id="hpVal">{{ old('happiness_score',5) }}</span>
                                <span class="k-range-unit">dari 10</span>
                            </div>
                            <span>10 — Sangat bahagia</span>
                        </div>
                        <input type="range" class="k-range-slider" name="happiness_score"
                               min="0" max="10" step="1" value="{{ old('happiness_score',5) }}"
                               oninput="kRange(this,'hpVal')">
                    </div>
                </div>
            </div>

            <div class="k-nav">
                <button type="button" class="k-btn k-btn-back hidden" id="prevBtn" onclick="kWizStep(-1)">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                    Kembali
                </button>
                <button type="button" class="k-btn k-btn-next" id="nextBtn" onclick="kWizStep(1)">
                    Lanjut
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                </button>
                <button type="submit" class="k-btn k-btn-submit hidden" id="submitBtn">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 2L11 13"/><path d="M22 2L15 22 11 13 2 9l20-7z"/></svg>
                    Kirim &amp; Analisis
                </button>
            </div>
        </form>

    </main>


</div>{{-- .kues-shell --}}

@endsection

@section('scripts')
<script>
(function(){
    'use strict';
    var step=1, TOTAL=3;
    var stepTitles=['Penggunaan Digital','Aktivitas & Tidur','Kondisi Mental'];
    var pcts=['33%','66%','100%'];

    window.kRange = function(el, valId) {
        document.getElementById(valId).textContent = el.value;
        var min=parseFloat(el.min), max=parseFloat(el.max), val=parseFloat(el.value);
        var pct=((val-min)/(max-min))*100;
        el.style.background='linear-gradient(to right,#0D9488 0%,#0D9488 '+pct+'%,#e2e8f0 '+pct+'%)';
    };

    document.querySelectorAll('.k-range-slider').forEach(function(el){
        var min=parseFloat(el.min),max=parseFloat(el.max),val=parseFloat(el.value);
        var pct=((val-min)/(max-min))*100;
        el.style.background='linear-gradient(to right,#0D9488 0%,#0D9488 '+pct+'%,#e2e8f0 '+pct+'%)';
    });

    window.kWizStep = function(d) {
        step=Math.max(1,Math.min(TOTAL,step+d));
        document.querySelectorAll('.wizard-page').forEach(function(p){p.classList.add('hidden');});
        document.getElementById('step'+step).classList.remove('hidden');
        document.getElementById('prevBtn').classList.toggle('hidden',step===1);
        document.getElementById('nextBtn').classList.toggle('hidden',step===TOTAL);
        document.getElementById('submitBtn').classList.toggle('hidden',step!==TOTAL);
        for(var i=1;i<=TOTAL;i++){
            document.getElementById('ss'+i).className='k-step '+(i<step?'done':i===step?'current':'locked');
        }
        document.getElementById('progressFill').style.width=pcts[step-1];
        document.getElementById('progressPct').textContent=pcts[step-1];
        document.getElementById('desktopPageBadge').textContent='Halaman '+step+' dari '+TOTAL;
        document.getElementById('mobilePageBadge').textContent='Halaman '+step+' dari '+TOTAL;
        document.getElementById('mobileSubtitle').textContent=stepTitles[step-1];
        for(var j=1;j<=TOTAL;j++){
            document.getElementById('msc'+j).className='mobile-step-circle'+(j<step?' done':j===step?' active':'');
            document.getElementById('msl'+j).className='mobile-step-lbl'+(j===step?' active':'');
        }
        for(var k=1;k<TOTAL;k++){
            document.getElementById('mconn'+k).className='mobile-step-conn'+(k<step?' done':'');
        }
        document.getElementById('mobileProgressFill').style.width=pcts[step-1];
        window.scrollTo({top:0,behavior:'smooth'});
    };

    document.querySelectorAll('.k-opt-card').forEach(function(c){
        c.addEventListener('click',function(){
            var group=c.closest('.k-opt-group');
            group.querySelectorAll('.k-opt-card').forEach(function(x){x.classList.remove('selected');});
            c.classList.add('selected');
            var input=document.querySelector('input[name="'+group.dataset.name+'"]');
            if(input) input.value=c.dataset.value;
        });
    });

    (function(){
        var ua=navigator.userAgent||'';
        var isMobile=/Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(ua);
        var isDesktop=/Windows NT|Macintosh|Linux/i.test(ua)&&!/Android/i.test(ua);
        var el=document.getElementById('device_type_input');
        if(el) el.value=(isMobile&&isDesktop)?'Both':isDesktop?'Laptop':'Smartphone';
    })();
})();
</script>
@endsection