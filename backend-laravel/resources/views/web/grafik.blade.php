@extends('web.layouts.app')
@section('title', 'Grafik')

@section('content')
@php
    $labels = $surveys->map(fn($s) => $s->created_at ? $s->created_at->format('d M') : '-')->toArray();
    $scores = $surveys->map(fn($s) => $s->score ?? 0)->toArray();
    $screen = $surveys->map(fn($s) => $s->device_hours_per_day ?? 0)->toArray();
    $social = $surveys->map(fn($s) => $s->social_media_mins ?? 0)->toArray();
    $sleepQ = $surveys->map(fn($s) => $s->sleep_quality ?? 0)->toArray();
    $low = count(array_filter($scores, fn($s) => $s < 33.47));
    $med = count(array_filter($scores, fn($s) => $s >= 33.47 && $s <= 61.34));
    $high = count(array_filter($scores, fn($s) => $s > 61.34));
@endphp

<div class="page-header anim-fade"><h1>Grafik & Visualisasi</h1><p>Lihat tren perkembangan gaya hidup digitalmu</p></div>

<div class="period-sel anim-up">
    @foreach([7 => '7 Hari', 30 => 'Bulanan', 90 => '3 Bulan'] as $d => $label)
    <a href="{{ url('/user/grafik?days='.$d) }}" class="period-btn {{ $days==$d?'active':'' }}">{{ $label }}</a>
    @endforeach
</div>

@if($surveys->isEmpty())
<div class="card card-p-lg anim-up" style="text-align:center;">
    <div style="font-size:3rem;margin-bottom:12px;">📊</div><h3>Belum Cukup Data</h3><p style="color:var(--text-muted);margin-top:8px;">Isi kuesioner untuk melihat grafik.</p>
</div>
@else
<div style="display:grid;grid-template-columns:1fr 1fr;gap:24px;">
    <div class="card card-p anim-up d1" style="grid-column:1/-1;">
        <h3 style="margin-bottom:4px;">Trend Skor Dependensi</h3><p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Perubahan skor dari waktu ke waktu</p>
        <div class="chart-wrap"><canvas id="chartScore"></canvas></div>
    </div>
    <div class="card card-p anim-up d2">
        <h3 style="margin-bottom:4px;">Screen Time</h3><p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Jam/hari</p>
        <div class="chart-wrap"><canvas id="chartScreen"></canvas></div>
    </div>
    <div class="card card-p anim-up d3">
        <h3 style="margin-bottom:4px;">Media Sosial</h3><p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Menit/hari</p>
        <div class="chart-wrap"><canvas id="chartSocial"></canvas></div>
    </div>
    <div class="card card-p anim-up d4">
        <h3 style="margin-bottom:4px;">Kualitas Tidur</h3><p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Skala 1-5</p>
        <div class="chart-wrap"><canvas id="chartSleep"></canvas></div>
    </div>
    <div class="card card-p anim-up d5">
        <h3 style="margin-bottom:4px;">Distribusi Kategori</h3><p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Persebaran tingkat</p>
        <div class="chart-wrap"><canvas id="chartDist"></canvas></div>
    </div>
</div>
@endif
@endsection

@section('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>
<script>
const labels={!! json_encode($labels) !!};
const dark={fontColor:'#64748B',gridColor:'rgba(226,232,240,.5)'};
function mkLine(id,data,color,label){
    new Chart(document.getElementById(id),{type:'line',data:{labels,datasets:[{label,data,borderColor:color,backgroundColor:color+'18',fill:true,tension:.4,pointRadius:3,pointBackgroundColor:color,borderWidth:2.5}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{x:{ticks:{color:dark.fontColor,font:{size:11}},grid:{display:false}},y:{ticks:{color:dark.fontColor,font:{size:11}},grid:{color:dark.gridColor}}}}});
}
function mkBar(id,data,color,label){
    new Chart(document.getElementById(id),{type:'bar',data:{labels,datasets:[{label,data,backgroundColor:color+'88',borderColor:color,borderWidth:1.5,borderRadius:6}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{x:{ticks:{color:dark.fontColor,font:{size:11}},grid:{display:false}},y:{ticks:{color:dark.fontColor,font:{size:11}},grid:{color:dark.gridColor}}}}});
}
@if(!$surveys->isEmpty())
mkLine('chartScore',{!! json_encode($scores) !!},'#0D9488','Skor');
mkLine('chartScreen',{!! json_encode($screen) !!},'#3B82F6','Jam');
mkBar('chartSocial',{!! json_encode($social) !!},'#8B5CF6','Menit');
mkBar('chartSleep',{!! json_encode($sleepQ) !!},'#F59E0B','Kualitas');
new Chart(document.getElementById('chartDist'),{type:'doughnut',data:{labels:['Rendah','Sedang','Tinggi'],datasets:[{data:[{{ $low }},{{ $med }},{{ $high }}],backgroundColor:['#22C55E','#F59E0B','#EF4444'],borderWidth:0}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'bottom',labels:{color:'#64748B',font:{size:12,weight:600},padding:20}}},cutout:'65%'}});
@endif
</script>
@endsection
