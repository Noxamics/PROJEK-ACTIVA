<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name'            => fake()->name(),
            'email'           => fake()->unique()->safeEmail(),
            'password_hash'   => Hash::make('password'),
            'gender'          => fake()->randomElement(['male', 'female']),
            'age'             => fake()->numberBetween(15, 60),
            'region'          => fake()->randomElement(['Jawa Timur', 'Jawa Barat', 'Jawa Tengah', 'DKI Jakarta', 'Bali']),
            'education_level' => fake()->randomElement(['SMA', 'D3', 'S1', 'S2']),
            'last_login'      => null,
        ];
    }
}
