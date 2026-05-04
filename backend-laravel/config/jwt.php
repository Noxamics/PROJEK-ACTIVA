<?php

return [

    /*
    |--------------------------------------------------------------------------
    | JWT Authentication Secret
    |--------------------------------------------------------------------------
    |
    | Don't forget to set this in your .env file, as it will be used to sign
    | your tokens. A helper command is provided for this:
    | `php artisan jwt:secret`
    |
    | The secret key used to sign and verify JWT tokens
    |
    */

    'secret' => env('JWT_SECRET'),

    /*
    |--------------------------------------------------------------------------
    | JWT time to live
    |--------------------------------------------------------------------------
    |
    | Specify the length of time (in minutes) that the token will be valid for.
    | Defaults to 1 hour.
    |
    | You can also set this to null, to yield a never expiring token.
    | Some people may want this behaviour for stuff like api tokens / ssh keys.
    |
    */

    'ttl' => env('JWT_TTL', 60),

    /*
    |--------------------------------------------------------------------------
    | Refresh time to live
    |--------------------------------------------------------------------------
    |
    | Specify the length of time (in minutes) that the token can be refreshed
    | within. I.E. The user can refresh their token within this time frame.
    | Don't put a number higher than the ttl of first token, this doesn't make sense.
    | Defaults to 2 weeks.
    |
    */

    'refresh_ttl' => env('JWT_REFRESH_TTL', 20160),

    /*
    |--------------------------------------------------------------------------
    | JWT hashing algorithm
    |--------------------------------------------------------------------------
    |
    | Set the algorithm used to sign the tokens.
    |
    | See here: https://github.com/namshi/jose/tree/master/src/Namshi/JOSE/Signer
    | for possible values
    |
    */

    'algo' => env('JWT_ALGO', 'HS256'),

    /*
    |--------------------------------------------------------------------------
    | Blacklist Enabled
    |--------------------------------------------------------------------------
    |
    | In order to invalidate tokens, you must have the blacklist enabled.
    | If you do not want or need this functionality, set this to false.
    |
    */

    'blacklist_enabled' => env('JWT_BLACKLIST_ENABLED', true),

    /*
    |--------------------------------------------------------------------------
    | Blacklist Grace Period
    |--------------------------------------------------------------------------
    |
    | When multiple requests are made by the same user in quick succession only
    | the first request will set a new token. The other requests will come back
    | with the previous token. The blacklist grace period is the number of
    | seconds that the token can be used again before it is forced to be
    | refreshed / invalidated.
    |
    */

    'blacklist_grace_period' => env('JWT_BLACKLIST_GRACE_PERIOD', 0),

    /*
    |--------------------------------------------------------------------------
    | Cookies encryption
    |--------------------------------------------------------------------------
    |
    | By default Laravel encrypts cookies for security reasons.
    | If you decide to use cookies to store the JWT token. You will have to
    | set the below to true as Laravel serializes the request after.
    |
    */

    'decrypt_cookies' => false,

    /*
    |--------------------------------------------------------------------------
    | Claim Checks
    |--------------------------------------------------------------------------
    |
    | The following claims will be used to verify the token if the
    | verification (checks) are enabled (see below).
    |
    */

    'claims' => [

        /*
        |----------------------------------------------------------------------
        | Leeway in seconds
        |----------------------------------------------------------------------
        |
        | This property gives the jwt timestamp claims some slack.
        | Meaning that if you have any late arrivals and the
        | allowed clock skew in seconds is 30, then your valid JWT tokens
        | will still be valid for 30 seconds after the "exp" claim time.
        |
        */

        'leeway' => env('JWT_LEEWAY', 0),
    ],

    /*
    |--------------------------------------------------------------------------
    | Claim Checker Flags
    |--------------------------------------------------------------------------
    |
    | The following settings allow you to configure which of the above claims
    | will be checked/verified when this CIA and your JWT tokens
    |
    */

    'verify' => [
        'alg' => true,
        'iss' => false,
        'nbf' => true,
        'iat' => true,
        'exp' => true,
        'signature' => true,
    ],

];
