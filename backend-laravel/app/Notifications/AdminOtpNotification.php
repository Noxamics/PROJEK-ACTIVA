<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Contracts\Queue\ShouldQueue;

class AdminOtpNotification extends Notification implements ShouldQueue
{
    use Queueable;

    private $otp_code;
    private $admin_name;

    public function __construct($otp_code, $admin_name)
    {
        $this->otp_code = $otp_code;
        $this->admin_name = $admin_name;
        $this->onQueue('default');
    }

    public function via($notifiable)
    {
        return ['mail'];
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('Kode OTP Login Admin - NoMoreScroll')
            ->greeting("Halo {$this->admin_name},")
            ->line('Anda telah meminta kode OTP untuk login ke panel admin NoMoreScroll.')
            ->line('Jangan bagikan kode ini ke siapapun!')
            ->line('')
            ->line('Kode OTP Anda:')
            ->line($this->otp_code)
            ->line('')
            ->line('Kode OTP ini berlaku selama 10 menit.')
            ->line('Jika Anda tidak melakukan permintaan ini, abaikan pesan ini.')
            ->salutation('Regards, NoMoreScroll Team');
    }

    public function toArray($notifiable)
    {
        return [
            'otp_code' => $this->otp_code,
        ];
    }
}
