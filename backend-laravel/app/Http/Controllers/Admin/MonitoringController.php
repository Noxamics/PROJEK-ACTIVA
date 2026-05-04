<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MlResult;
use Illuminate\Http\Request;

class MonitoringController extends Controller
{
    /**
     * Show monitoring page
     */
    public function index()
    {
        $metrics = [
            'avg_focus' => 7.8,
            'avg_productivity' => 6.5,
            'avg_dependence' => 5.2,
            'avg_screen' => 4.2,
        ];
        
        return view('admin.monitoring', compact('metrics'));
    }
}
