@extends('web.layouts.app')
@section('title', 'Kuesioner')

@section('content')
<div class="wizard-container">
    <div class="page-header anim-fade"><h1>Kuesioner Analisis</h1><p>Jawab 12 pertanyaan tentang gaya hidup digitalmu</p></div>

    @if($errors->any())
    <div style="padding:12px 16px;background:rgba(239,68,68,.06);border:1px solid rgba(239,68,68,.15);border-radius:var(--radius-md);margin-bottom:24px;">
        @foreach($errors->all() as $err)<p style="color:var(--red);font-size:.875rem;">{{ $err }}</p>@endforeach
    </div>
    @endif

    <form method="POST" action="{{ url('/user/kuesioner') }}" id="kuesionerForm">
        @csrf
        <div class="wizard-progress" style="margin-bottom:32px;">
            <div class="wizard-step current" id="wp1"></div>
            <div class="wizard-step" id="wp2"></div>
            <div class="wizard-step" id="wp3"></div>
        </div>

        {{-- STEP 1: Penggunaan Digital --}}
        <div class="wizard-page" id="step1">
            <h3 style="color:var(--teal);margin-bottom:20px;">📱 Penggunaan Digital</h3>

            {{-- Pertanyaan no. 1 disembunyikan; device_type diisi otomatis via JS --}}
            <input type="hidden" name="device_type" id="device_type_input" value="{{ old('device_type', 'Smartphone') }}">

            <div class="q-block"><label class="form-label">1. Berapa lama menggunakan perangkat per hari?</label>
            <div class="opt-group" data-name="device_hours_per_day">
                @foreach([2 => '< 3 jam|Ringan', 5 => '3–6 jam|Sedang', 8 => '6–10 jam|Tinggi', 12 => '> 10 jam|Sangat tinggi'] as $val => $lbl)
                @php [$l,$s] = explode('|',$lbl); @endphp
                <div class="opt-card {{ old('device_hours_per_day')==$val?'selected':'' }}" data-value="{{ $val }}"><div class="opt-radio"></div><div><div style="font-weight:700;">{{ $l }}</div><div style="font-size:.8125rem;color:var(--text-muted);">{{ $s }}</div></div></div>
                @endforeach
            </div>
            <input type="hidden" name="device_hours_per_day" value="{{ old('device_hours_per_day') }}"></div>

            <div class="q-block"><label class="form-label">2. Berapa kali membuka HP per hari?</label>
            <div class="opt-group" data-name="phone_unlocks">
                @foreach([30 => '< 50 kali|Jarang', 75 => '50–100 kali|Cukup sering', 150 => '100–200 kali|Sering', 300 => '> 200 kali|Sangat sering'] as $val => $lbl)
                @php [$l,$s] = explode('|',$lbl); @endphp
                <div class="opt-card {{ old('phone_unlocks')==$val?'selected':'' }}" data-value="{{ $val }}"><div class="opt-radio"></div><div><div style="font-weight:700;">{{ $l }}</div><div style="font-size:.8125rem;color:var(--text-muted);">{{ $s }}</div></div></div>
                @endforeach
            </div>
            <input type="hidden" name="phone_unlocks" value="{{ old('phone_unlocks') }}"></div>

            <div class="q-block"><label class="form-label">3. Jumlah notifikasi per hari?</label>
            <div class="opt-group" data-name="notifications_per_day">
                @foreach([50 => '< 100|Sedikit', 200 => '100–300|Cukup banyak', 400 => '300–500|Banyak', 600 => '> 500|Sangat banyak'] as $val => $lbl)
                @php [$l,$s] = explode('|',$lbl); @endphp
                <div class="opt-card {{ old('notifications_per_day')==$val?'selected':'' }}" data-value="{{ $val }}"><div class="opt-radio"></div><div><div style="font-weight:700;">{{ $l }}</div><div style="font-size:.8125rem;color:var(--text-muted);">{{ $s }}</div></div></div>
                @endforeach
            </div>
            <input type="hidden" name="notifications_per_day" value="{{ old('notifications_per_day') }}"></div>

            <div class="q-block"><label class="form-label">4. Waktu media sosial (menit/hari)</label>
            <div style="display:flex;justify-content:space-between;font-size:.8125rem;color:var(--text-muted);"><span>0</span><span id="smVal" style="font-weight:800;font-size:1rem;color:var(--teal);">{{ old('social_media_mins',60) }} menit</span><span>600</span></div>
            <input type="range" class="range-slider" name="social_media_mins" min="0" max="600" step="10" value="{{ old('social_media_mins',60) }}" oninput="document.getElementById('smVal').textContent=this.value+' menit'"></div>
        </div>

        {{-- STEP 2: Aktivitas & Tidur --}}
        <div class="wizard-page hidden" id="step2">
            <h3 style="color:var(--teal);margin-bottom:20px;">🏃 Aktivitas & Tidur</h3>

            <div class="q-block"><label class="form-label">5. Waktu belajar per hari (menit)</label>
            <div style="display:flex;justify-content:space-between;font-size:.8125rem;color:var(--text-muted);"><span>0</span><span id="stVal" style="font-weight:800;font-size:1rem;color:var(--teal);">{{ old('study_minutes',60) }} menit</span><span>480</span></div>
            <input type="range" class="range-slider" name="study_minutes" min="0" max="480" step="10" value="{{ old('study_minutes',60) }}" oninput="document.getElementById('stVal').textContent=this.value+' menit'"></div>

            <div class="q-block"><label class="form-label">6. Olahraga berapa hari per minggu?</label>
            <div class="opt-group" data-name="physical_activity_days">
                @foreach([0 => '0 hari|Tidak pernah', 2 => '1–3 hari|Kadang', 5 => '4–5 hari|Sering', 7 => '6–7 hari|Setiap hari'] as $val => $lbl)
                @php [$l,$s] = explode('|',$lbl); @endphp
                <div class="opt-card {{ old('physical_activity_days')===$val?'selected':'' }}" data-value="{{ $val }}"><div class="opt-radio"></div><div><div style="font-weight:700;">{{ $l }}</div><div style="font-size:.8125rem;color:var(--text-muted);">{{ $s }}</div></div></div>
                @endforeach
            </div>
            <input type="hidden" name="physical_activity_days" value="{{ old('physical_activity_days') }}"></div>

            <div class="q-block"><label class="form-label">7. Durasi tidur per malam?</label>
            <div class="opt-group" data-name="sleep_hours">
                @foreach([4 => '< 5 jam|Sangat kurang', 6 => '5–6 jam|Kurang', 7 => '7–8 jam|Cukup', 9 => '> 8 jam|Lebih dari cukup'] as $val => $lbl)
                @php [$l,$s] = explode('|',$lbl); @endphp
                <div class="opt-card {{ old('sleep_hours')==$val?'selected':'' }}" data-value="{{ $val }}"><div class="opt-radio"></div><div><div style="font-weight:700;">{{ $l }}</div><div style="font-size:.8125rem;color:var(--text-muted);">{{ $s }}</div></div></div>
                @endforeach
            </div>
            <input type="hidden" name="sleep_hours" value="{{ old('sleep_hours') }}"></div>

            <div class="q-block"><label class="form-label">8. Kualitas tidur (1–5)</label>
            <div style="display:flex;justify-content:space-between;font-size:.8125rem;color:var(--text-muted);"><span>1</span><span id="sqVal" style="font-weight:800;font-size:1rem;color:var(--teal);">{{ old('sleep_quality',3) }}</span><span>5</span></div>
            <input type="range" class="range-slider" name="sleep_quality" min="1" max="5" step="1" value="{{ old('sleep_quality',3) }}" oninput="document.getElementById('sqVal').textContent=this.value"></div>
        </div>

        {{-- STEP 3: Kondisi Mental --}}
        <div class="wizard-page hidden" id="step3">
            <h3 style="color:var(--teal);margin-bottom:20px;">🧠 Kondisi Mental</h3>

            <div class="q-block"><label class="form-label">9. Tingkat kecemasan (0–27)</label>
            <div style="display:flex;justify-content:space-between;font-size:.8125rem;color:var(--text-muted);"><span>0</span><span id="axVal" style="font-weight:800;font-size:1rem;color:var(--teal);">{{ old('anxiety_score',5) }}</span><span>27</span></div>
            <input type="range" class="range-slider" name="anxiety_score" min="0" max="27" step="1" value="{{ old('anxiety_score',5) }}" oninput="document.getElementById('axVal').textContent=this.value"></div>

            <div class="q-block"><label class="form-label">10. Skor depresi (0–27)</label>
            <div style="display:flex;justify-content:space-between;font-size:.8125rem;color:var(--text-muted);"><span>0</span><span id="dpVal" style="font-weight:800;font-size:1rem;color:var(--teal);">{{ old('depression_score',5) }}</span><span>27</span></div>
            <input type="range" class="range-slider" name="depression_score" min="0" max="27" step="1" value="{{ old('depression_score',5) }}" oninput="document.getElementById('dpVal').textContent=this.value"></div>

            <div class="q-block"><label class="form-label">11. Tingkat stres (1–10)</label>
            <div style="display:flex;justify-content:space-between;font-size:.8125rem;color:var(--text-muted);"><span>1</span><span id="slVal" style="font-weight:800;font-size:1rem;color:var(--teal);">{{ old('stress_level',5) }}</span><span>10</span></div>
            <input type="range" class="range-slider" name="stress_level" min="1" max="10" step="1" value="{{ old('stress_level',5) }}" oninput="document.getElementById('slVal').textContent=this.value"></div>

            <div class="q-block"><label class="form-label">12. Skor kebahagiaan (0–10)</label>
            <div style="display:flex;justify-content:space-between;font-size:.8125rem;color:var(--text-muted);"><span>0</span><span id="hpVal" style="font-weight:800;font-size:1rem;color:var(--teal);">{{ old('happiness_score',5) }}</span><span>10</span></div>
            <input type="range" class="range-slider" name="happiness_score" min="0" max="10" step="1" value="{{ old('happiness_score',5) }}" oninput="document.getElementById('hpVal').textContent=this.value"></div>
        </div>

        <div style="display:flex;gap:12px;margin-top:32px;">
            <button type="button" class="btn btn-secondary hidden" id="prevBtn" onclick="wizStep(-1)" style="flex:1;">Kembali</button>
            <button type="button" class="btn btn-primary btn-lg" id="nextBtn" onclick="wizStep(1)" style="flex:1;">Lanjut</button>
            <button type="submit" class="btn btn-primary btn-lg hidden" id="submitBtn" style="flex:1;">🚀 Kirim & Analisis</button>
        </div>
    </form>
</div>

<style>.q-block{margin-bottom:24px}.opt-group{display:flex;flex-direction:column;gap:10px;margin-top:8px}</style>

@endsection

@section('scripts')
<script>
let step=1;
function wizStep(d){
    step+=d;
    if(step<1)step=1;if(step>3)step=3;
    document.querySelectorAll('.wizard-page').forEach(p=>p.classList.add('hidden'));
    document.getElementById('step'+step).classList.remove('hidden');
    document.getElementById('prevBtn').classList.toggle('hidden',step===1);
    document.getElementById('nextBtn').classList.toggle('hidden',step===3);
    document.getElementById('submitBtn').classList.toggle('hidden',step!==3);
    ['wp1','wp2','wp3'].forEach((id,i)=>{
        const el=document.getElementById(id);
        el.className='wizard-step'+(i<step-1?' done':'')+(i===step-1?' current':'');
    });
    window.scrollTo({top:0,behavior:'smooth'});
}
document.querySelectorAll('.opt-card').forEach(c=>{
    c.addEventListener('click',()=>{
        const group=c.closest('.opt-group');
        const name=group.dataset.name;
        group.querySelectorAll('.opt-card').forEach(x=>x.classList.remove('selected'));
        c.classList.add('selected');
        const input=document.querySelector('input[name="'+name+'"]');
        if(input)input.value=c.dataset.value;
    });
});
// ── Auto-detect device type dari User-Agent ──────────────────────────
(function(){
    var ua = navigator.userAgent || '';
    var isMobile = /Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(ua);
    var isDesktop = /Windows NT|Macintosh|Linux/i.test(ua) && !/Android/i.test(ua);
    var type = 'Smartphone';
    if (isMobile && isDesktop) type = 'Both';
    else if (isDesktop) type = 'Laptop';
    else type = 'Smartphone';
    var el = document.getElementById('device_type_input');
    if (el && !el.value) el.value = type;
    else if (el) el.value = type; // selalu timpa agar akurat
})();
</script>
@endsection
