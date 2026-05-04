<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

/** @noinspection PhpUndefinedClassInspection */
class RuleController extends Controller
{
    private function toObjectId($id)
    {
        $objectIdClass = '\MongoDB\BSON\ObjectId';
        return new $objectIdClass($id);
    }

    public function index()
    {
        $rulesArray = DB::connection('mongodb')
            ->collection('recommendation_rules')
            ->get();

        $rules = collect($rulesArray)->map(function ($item) {
            return (object) [
                '_id'              => $item['_id'] ?? null,
                'name'             => $item['name'] ?? 'Untitled',
                'kategori'         => $item['kategori'] ?? '',
                'social_media_min' => $item['social_media_min'] ?? null,
                'social_media_max' => $item['social_media_max'] ?? null,
                'sleep_min'        => $item['sleep_min'] ?? null,
                'sleep_max'        => $item['sleep_max'] ?? null,
                'stress_min'       => $item['stress_min'] ?? null,
                'stress_max'       => $item['stress_max'] ?? null,
                'recommendation'   => $item['recommendation'] ?? '',
                'priority'         => $item['priority'] ?? 1,
                'is_active'        => $item['is_active'] ?? false,
                'created_at'       => $item['created_at'] ?? null,
            ];
        });

        return view('admin.rules', compact('rules'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'             => 'required|string|max:255',
            'kategori'         => 'required|in:rendah,sedang,tinggi',
            'social_media_min' => 'nullable|numeric|min:0',
            'social_media_max' => 'nullable|numeric|min:0',
            'sleep_min'        => 'nullable|numeric|min:0|max:24',
            'sleep_max'        => 'nullable|numeric|min:0|max:24',
            'stress_min'       => 'nullable|numeric|min:0',
            'stress_max'       => 'nullable|numeric|min:0',
            'recommendation'   => 'required|string',
            'priority'         => 'required|integer|min:1',
        ]);

        $validated['is_active']  = true;
        $validated['created_at'] = now();

        DB::connection('mongodb')
            ->collection('recommendation_rules')
            ->insert($validated);

        return redirect()->route('admin.rules')->with('success', 'Rule berhasil ditambahkan');
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'name'             => 'required|string|max:255',
            'kategori'         => 'required|in:rendah,sedang,tinggi',
            'social_media_min' => 'nullable|numeric|min:0',
            'social_media_max' => 'nullable|numeric|min:0',
            'sleep_min'        => 'nullable|numeric|min:0|max:24',
            'sleep_max'        => 'nullable|numeric|min:0|max:24',
            'stress_min'       => 'nullable|numeric|min:0',
            'stress_max'       => 'nullable|numeric|min:0',
            'recommendation'   => 'required|string',
            'priority'         => 'required|integer|min:1',
        ]);

        $objectId = $this->toObjectId($id);

        DB::connection('mongodb')
            ->collection('recommendation_rules')
            ->where('_id', $objectId)
            ->update($validated);

        return redirect()->route('admin.rules')->with('success', 'Rule berhasil diperbarui');
    }

    public function toggle(Request $request, $id)
    {
        $objectId = $this->toObjectId($id);

        $rule = DB::connection('mongodb')
            ->collection('recommendation_rules')
            ->where('_id', $objectId)
            ->first();

        if ($rule) {
            DB::connection('mongodb')
                ->collection('recommendation_rules')
                ->where('_id', $objectId)
                ->update(['is_active' => !($rule['is_active'] ?? false)]);
        }

        return back();
    }

    public function destroy($id)
    {
        $objectId = $this->toObjectId($id);

        DB::connection('mongodb')
            ->collection('recommendation_rules')
            ->where('_id', $objectId)
            ->delete();

        return redirect()->route('admin.rules')->with('success', 'Rule berhasil dihapus');
    }
}