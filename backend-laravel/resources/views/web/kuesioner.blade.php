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
                    <div class="k-step-sub">Pertanyaan 1–5</div>
                </div>
            </div>
            <div class="k-step locked" id="ss2">
                <div class="k-step-icon">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
                </div>
                <div>
                    <div class="k-step-label">Aktivitas &amp; Tidur</div>
                    <div class="k-step-sub">Pertanyaan 6–8</div>
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

            {{-- ══ STEP 1 — Penggunaan Digital ══ --}}
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
                        Berapa lama kamu menggunakan perangkat digital hari ini?
                    </label>
                    <div class="k-opt-group" data-name="device_hours_per_day">
                        @foreach(['1.5'=>'Sangat Sedikit|Kurang dari 2 jam total penggunaan perangkat.', '3.0'=>'Sedikit|Sekitar 2–4 jam penggunaan perangkat.', '5.5'=>'Sedang|Sekitar 4–7 jam penggunaan perangkat.', '8.5'=>'Lama|Sekitar 7–10 jam penggunaan perangkat.', '12.0'=>'Sangat Lama|Lebih dari 10 jam penggunaan perangkat.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('device_hours_per_day') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="device_hours_per_day" id="input-device_hours_per_day" value="{{ old('device_hours_per_day') }}">
                </div>

                {{-- Q2 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">2</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2"/><path d="M12 18h.01"/></svg></span>
                        Seberapa sering kamu membuka HP hari ini?
                    </label>
                    <div class="k-opt-group" data-name="phone_unlocks">
                        @foreach(['10'=>'Jarang|Kurang dari 20 kali membuka HP hari ini.', '35'=>'Kadang-kadang|Sekitar 20–50 kali membuka HP.', '75'=>'Cukup Sering|Sekitar 50–100 kali membuka HP.', '150'=>'Sering|Sekitar 100–200 kali membuka HP.', '250'=>'Sangat Sering|Lebih dari 200 kali membuka HP.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('phone_unlocks') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="phone_unlocks" id="input-phone_unlocks" value="{{ old('phone_unlocks') }}">
                </div>

                {{-- Q3 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">3</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg></span>
                        Berapa banyak notifikasi yang kamu terima hari ini?
                    </label>
                    <div class="k-opt-group" data-name="notifications_per_day">
                        @foreach(['30'=>'Hampir Tidak Ada|Kurang dari 50 notifikasi sepanjang hari.', '100'=>'Sedikit|Sekitar 50–200 notifikasi hari ini.', '300'=>'Lumayan|Sekitar 200–500 notifikasi hari ini.', '700'=>'Banyak|Sekitar 500–1000 notifikasi hari ini.', '1100'=>'Sangat Banyak|Lebih dari 1000 notifikasi hari ini.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('notifications_per_day') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="notifications_per_day" id="input-notifications_per_day" value="{{ old('notifications_per_day') }}">
                </div>

                {{-- Q4 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">4</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 2H7a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2z"/><rect x="9" y="11" width="6" height="4" rx="1"/></svg></span>
                        Berapa lama kamu menggunakan media sosial hari ini?
                    </label>
                    <div class="k-opt-group" data-name="social_media_mins">
                        @foreach(['0'=>'Tidak Pakai|Hampir tidak pernah membuka media sosial.', '30'=>'Kurang dari 1 Jam|Sekitar 30 menit di media sosial.', '120'=>'1–3 Jam|Sekitar 2 jam per hari di media sosial.', '240'=>'3–5 Jam|Sekitar 4 jam per hari di media sosial.', '400'=>'Lebih dari 5 Jam|Sangat banyak waktu dihabiskan di sosmed.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('social_media_mins') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="social_media_mins" id="input-social_media_mins" value="{{ old('social_media_mins') }}">
                </div>
                
                {{-- Q5 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">5</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg></span>
                        Seberapa produktif kamu belajar atau bekerja hari ini?
                    </label>
                    <div class="k-opt-group" data-name="study_minutes">
                        @foreach(['10'=>'Hampir Tidak Ada|Kurang dari 30 menit waktu fokus hari ini.', '60'=>'Sedikit|Sekitar 30 menit hingga 1 jam waktu fokus.', '150'=>'Cukup|Sekitar 1–3 jam waktu belajar atau kerja fokus.', '300'=>'Produktif|Sekitar 3–5 jam waktu belajar atau kerja fokus.', '400'=>'Sangat Produktif|Lebih dari 5 jam waktu fokus penuh hari ini.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('study_minutes') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="study_minutes" id="input-study_minutes" value="{{ old('study_minutes') }}">
                </div>
            </div>

            {{-- ══ STEP 2 — Aktivitas & Tidur ══ --}}
            <div class="wizard-page hidden" id="step2">
                <div class="k-step-header">
                    <h2>
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
                        Aktivitas &amp; Tidur
                    </h2>
                    <p>Seberapa aktif kamu secara fisik dan kualitas istirahatmu</p>
                </div>

                {{-- Q6 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">6</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg></span>
                        Berapa jam kamu tidur per malam?
                    </label>
                    <div class="k-range-wrap">
                        <div class="k-range-labels">
                            <span>3 Jam</span>
                            <div class="k-range-val-wrap">
                                <span class="k-range-val" id="slpHoursVal">{{ old('sleep_hours',7) }}</span>
                                <span class="k-range-unit">jam</span>
                            </div>
                            <span>11 Jam</span>
                        </div>
                        <input type="range" class="k-range-slider" name="sleep_hours"
                               min="3" max="11" step="0.5" value="{{ old('sleep_hours',7) }}"
                               oninput="kRange(this,'slpHoursVal')">
                    </div>
                </div>

                {{-- Q7 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">7</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
                        Berapa hari kamu berolahraga minggu ini?
                    </label>
                    <div class="k-range-wrap">
                        <div class="k-range-labels">
                            <span>0 Hari</span>
                            <div class="k-range-val-wrap">
                                <span class="k-range-val" id="physActVal">{{ old('physical_activity_days',3) }}</span>
                                <span class="k-range-unit">hari</span>
                            </div>
                            <span>7 Hari</span>
                        </div>
                        <input type="range" class="k-range-slider" name="physical_activity_days"
                               min="0" max="7" step="1" value="{{ old('physical_activity_days',3) }}"
                               oninput="kRange(this,'physActVal')">
                    </div>
                </div>

                {{-- Q8 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">8</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                        Bagaimana kualitas tidurmu secara umum?
                    </label>
                    <div class="k-opt-group" data-name="sleep_quality">
                        @foreach(['1.0'=>'Sangat Buruk|Sering terbangun dan tidak merasa segar pagi ini.', '2.0'=>'Buruk|Kadang terbangun, kurang segar saat bangun.', '3.0'=>'Cukup|Tidur cukup namun belum terasa optimal.', '4.0'=>'Baik|Tidur nyenyak dan merasa segar saat bangun.', '5.0'=>'Sangat Baik|Tidur sangat nyenyak dan berkualitas tinggi.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('sleep_quality') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="sleep_quality" id="input-sleep_quality" value="{{ old('sleep_quality') }}">
                </div>
            </div>

            {{-- ══ STEP 3 — Kondisi Mental ══ --}}
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
                        Seberapa sering kamu merasa cemas atau gelisah hari ini?
                    </label>
                    <div class="k-opt-group" data-name="anxiety_score">
                        @foreach(['1.0'=>'Sangat Jarang|Hampir tidak pernah merasa cemas.', '7.0'=>'Jarang|Sesekali muncul rasa cemas.', '14.0'=>'Sedang|Kadang-kadang merasa cemas.', '21.0'=>'Sering|Cukup sering merasa cemas atau gelisah.', '27.0'=>'Sangat Sering|Hampir setiap saat merasa cemas.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('anxiety_score') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="anxiety_score" id="input-anxiety_score" value="{{ old('anxiety_score') }}">
                </div>

                {{-- Q10 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">10</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M16 16s-1.5-2-4-2-4 2-4 2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg></span>
                        Seberapa sering kamu merasa sedih atau tidak bersemangat hari ini?
                    </label>
                    <div class="k-opt-group" data-name="depression_score">
                        @foreach(['1.0'=>'Sangat Jarang|Hampir tidak pernah merasa sedih.', '7.0'=>'Jarang|Sesekali merasa kurang bersemangat.', '14.0'=>'Sedang|Kadang-kadang merasa sedih atau lesu.', '21.0'=>'Sering|Cukup sering merasa sedih atau tidak berenergi.', '27.0'=>'Sangat Sering|Hampir setiap saat merasa sedih atau putus asa.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('depression_score') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="depression_score" id="input-depression_score" value="{{ old('depression_score') }}">
                </div>

                {{-- Q11 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">11</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></span>
                        Seberapa tinggi tingkat stresmu minggu ini?
                    </label>
                    <div class="k-opt-group" data-name="stress_level">
                        @foreach(['1.0'=>'Sangat Rendah|Merasa tenang dan hampir tidak ada tekanan.', '3.0'=>'Rendah|Sedikit tekanan namun masih terkendali dengan baik.', '5.0'=>'Sedang|Ada tekanan yang terasa namun masih bisa diatasi.', '7.0'=>'Tinggi|Merasa cukup tertekan dan sulit untuk rileks.', '10.0'=>'Sangat Tinggi|Tekanan sangat berat dan mengganggu aktivitas sehari-hari.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('stress_level') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="stress_level" id="input-stress_level" value="{{ old('stress_level') }}">
                </div>

                {{-- Q12 --}}
                <div class="k-q-block">
                    <label class="k-form-label">
                        <span class="k-q-num">12</span>
                        <span class="k-q-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M8 13s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg></span>
                        Seberapa bahagia perasaanmu?
                    </label>
                    <div class="k-opt-group" data-name="happiness_score">
                        @foreach(['1.0'=>'Sangat Sedih|Merasa sangat tidak bahagia atau hampa hari ini.', '3.0'=>'Sedih|Suasana hati kurang baik dan kurang bersemangat.', '5.0'=>'Biasa|Perasaan netral, tidak sedih namun tidak gembira.', '7.0'=>'Bahagia|Merasa cukup bahagia dan bersemangat hari ini.', '10.0'=>'Sangat Bahagia|Merasa sangat gembira dan penuh energi positif.'] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class="k-opt-card {{ old('happiness_score') == $val ? 'selected' : '' }}" data-value="{{ $val }}">
                            <div class="k-opt-radio"></div>
                            <div class="k-opt-body">
                                <div class="k-opt-main">{{ $l }}</div>
                                <div class="k-opt-sub">{{ $d }}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    <input type="hidden" name="happiness_score" id="input-happiness_score" value="{{ old('happiness_score') }}">
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
        if (d === 1) {
            var currentStepEl = document.getElementById('step' + step);
            var hiddenInputs = currentStepEl.querySelectorAll('input[type="hidden"]');
            var allFilled = true;
            for (var i = 0; i < hiddenInputs.length; i++) {
                if (hiddenInputs[i].name && !hiddenInputs[i].value) {
                    allFilled = false;
                    break;
                }
            }
            if (!allFilled) {
                alert('Silakan pilih salah satu jawaban untuk setiap pertanyaan sebelum melanjutkan.');
                return;
            }
        }

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

    var formEl = document.getElementById('kuesionerForm');
    if (formEl) {
        formEl.addEventListener('submit', function(e) {
            var currentStepEl = document.getElementById('step' + step);
            if (!currentStepEl) return;
            var hiddenInputs = currentStepEl.querySelectorAll('input[type="hidden"]');
            var allFilled = true;
            for (var i = 0; i < hiddenInputs.length; i++) {
                if (hiddenInputs[i].name && !hiddenInputs[i].value) {
                    allFilled = false;
                    break;
                }
            }
            if (!allFilled) {
                e.preventDefault();
                alert('Silakan pilih salah satu jawaban untuk setiap pertanyaan sebelum mengirim.');
            }
        });
    }

    /* ── k-opt-card click handler (Modern Grid Style) ── */
    document.querySelectorAll('.k-opt-card').forEach(function(card){
        card.addEventListener('click',function(){
            var group = card.closest('.k-opt-group');
            var name = group.dataset.name;
            /* deselect siblings */
            group.querySelectorAll('.k-opt-card').forEach(function(x){ x.classList.remove('selected'); });
            card.classList.add('selected');
            /* set hidden input value */
            var input = document.getElementById('input-' + name);
            if(input) input.value = card.dataset.value;
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