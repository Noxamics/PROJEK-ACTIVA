<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$request = Illuminate\Http\Request::create('/api/analytics/history', 'GET', ['days'=>30]);
$request->headers->set('Accept', 'application/json');

$user = App\Models\User::first();
if ($user) {
    auth()->login($user);
} else {
    echo "NO USER FOUND";
    exit;
}

$response = $kernel->handle($request);
echo $response->getContent();
