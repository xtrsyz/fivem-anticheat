# 🛡️ FiveM Anticheat — FiveGuard-lite style

> Anti-cheat resource buat FiveM, tulis dari nol. Covers the essentials dari godmode sampe injected command scan, plus server-side validation yang literally gak bisa di-bypass dari client. Made by **xtrsyz**.

---

## ✨ Feature List

| Fitur | Keterangan |
|---|---|
| **God Mode Detection** | Deteksi flag invincible & health modifier tiap 5 detik |
| **Weapon Blacklist** | Auto-remove senjata cheat (railgun, minigun, RPG, dll) tiap 3 detik |
| **Speed / Noclip Check** | Deteksi on-foot speed anomali; skip kalau lagi di kendaraan/parasut/fall |
| **Teleport Detection** | Server-side position diff tiap 3 detik (butuh OneSync) |
| **Explosion Filter** | Block & ban explosion type blacklisted (server-side, unbypassable) |
| **Entity Spawn Protection** | Block spawn kendaraan blacklisted (rhino, lazer, hydra, dll) |
| **Entity Flood Protection** | Rate-limit spawn entity; lebih dari limit dalam 10 detik = ban |
| **Honeypots** | Event palsu yang cuma cheater trigger; instant ban kalau kena |
| **Heartbeat / Anti-Unload** | Challenge-response tiap 30 detik; gak bales = AC di-unload → ban |
| **Command Injection Scan** | Deteksi command yang di-inject executor SETELAH resource start |
| **Trap Exports** | Export palsu (toggle/disable/bypass/stop); cheater yang panggil = ban |
| **Local Entity Pool Scan** | Scan CVehicle pool; entity blacklisted yang local-only langsung dihapus |
| **Token-based Event Protection** | Rotating 32-char token per player; proteksi server event dari spoofing |
| **Admin Whitelist** | Bypass via ace permission `ac.bypass` atau runtime setWhitelisted() |
| **Discord Screenshot Evidence** | Screenshot via screenshot-basic + Discord webhook embed saat ban |
| **Resource Integrity Check** | Client kirim resource list; server ban kalau ada resource gak dikenal |
| **Global Injection Watch** | Monitor `_G` buat injected global (limited, tapi berguna) |

---

## 🚀 Installation

```bash
# Clone ke folder resources server lo
cd resources
git clone https://github.com/xtrsyz/anticheat anticheat
```

Tambahkan ke `server.cfg` lo:

```cfg
# ===== ANTICHEAT =====
ensure anticheat

# Kasih izin admin buat ban manual & bypass deteksi
add_ace group.admin ac.ban    allow
add_ace group.admin ac.bypass allow

# Hardening wajib
sv_scriptHookAllowed 0   # block ScriptHookV-based cheats
sv_pureLevel 2           # block modified client files
onesync on               # wajib buat server-side position checks
```

### Opsional: Screenshot Evidence

1. Download & ensure [screenshot-basic](https://github.com/citizenfx/screenshot-basic)
2. Isi `Config.DiscordWebhook` di `config.lua` dengan URL webhook Discord lo
3. Set `Config.Screenshots = true` di `config.lua`

---

## ⚙️ Konfigurasi Penting

Semua ada di `config.lua`. Yang paling sering di-adjust:

- `Config.MaxOnFootSpeed` — naikan kalau server lo punya sprint boost atau similiar biar gak false positive
- `Config.HoneypotEvents` — **JANGAN** masukkan event dari framework yang lo PAKAI (e.g., kalau lo pakai ESX, jangan masukkin `esx:*` events)
- `Config.BlacklistedExplosions` / `Config.BlacklistedModels` — sesuaikan sama setup server lo

---

## 🔐 RegisterSecureEvent / TriggerSecureEvent

Proteksi event penting dari spoofing cheater. Cara pakainya:

**Di resource server lo:**
```lua
-- server/bank.lua
RegisterSecureEvent('bank:withdraw', function(src, amount)
    -- src sudah terverifikasi, amount dikirim dengan token valid
    -- lakukan logika bank di sini
    local cash = exports['oxmysql']:scalar_await(
        'SELECT cash FROM users WHERE identifier = ?',
        { GetPlayerIdentifiers(src)[1] }
    )
    -- dst...
end)

-- Atau pakai export:
exports['anticheat']:registerSecureEvent('bank:withdraw', function(src, amount)
    -- sama seperti di atas
end)
```

**Di resource client lo:**
```lua
-- client/bank.lua
RegisterNetEvent('bank:openUI', function()
    -- Pas player mau withdraw:
    TriggerSecureEvent('bank:withdraw', amount)
    -- Atau pakai export:
    exports['anticheat']:triggerSecure('bank:withdraw', amount)
end)
```

---

## ⚠️ Honest Limitations

Real talk ya, biar lo gak overconfident:

- **Client-side checks itu bypassable.** Cheater dengan executor canggih bisa unload script client. Makanya heartbeat + server-side detection itu yang jadi backbone.
- **Binary-level executor detection** (kayak RedEngine, Eulen) bukan urusan kita — itu job FiveM's own anti-cheat (adhesive). Kita cuma bisa nangkep side-effects-nya.
- **`_G` injection scan** itu terbatas karena tiap resource FiveM punya Lua environment sendiri. Executor canggih jalan di environment terpisah.
- **Resource integrity check** bisa false positive kalau ada resource yang start/stop dinamis. Fine-tune di `server/integrity.lua` sesuai setup lo.
- **Ini raises the bar, bukan silver bullet.** Buat server production yang rame, worth it banget pairing sama FiveM native anti-cheat + txAdmin + game build terbaru.
- **Keep server artifacts updated** — banyak cheat menarget version lama.

---

## 📁 Struktur File

```
fxmanifest.lua
config.lua
client/
├── main.lua              -- godmode, weapon blacklist, speed checks
├── heartbeat.lua         -- challenge-response pong
├── command_scan.lua      -- injected command detection
├── traps.lua             -- trap exports
├── pool_scan.lua         -- local-only entity scan
├── integrity.lua         -- resource list & global injection checks
└── event_protection.lua  -- secure event token client-side
server/
├── main.lua              -- ban system, explosion filter, entity spawn protection, acban command
├── honeypot.lua          -- fake events that only cheaters trigger
├── heartbeat.lua         -- challenge-response token dispatch & timeout ban
├── behavior.lua          -- teleport detection, damage modifier, giveWeaponEvent block
├── event_protection.lua  -- rotating token generation & RegisterSecureEvent wrapper
├── flood_protection.lua  -- entity spawn rate limiting
├── whitelist.lua         -- admin bypass via ace permissions + exports
├── integrity.lua         -- server-side resource list verification
└── screenshot.lua        -- Discord webhook evidence via screenshot-basic
```

---

Made with ❤️ by xtrsyz. Feel free to fork & improve!
