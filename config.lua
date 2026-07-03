Config = {}

-- ============================================================
-- FEATURE TOGGLES — set ke false buat disable per-fitur
-- ============================================================
Config.GodModeCheck       = true
Config.WeaponBlacklist    = true
Config.SpeedCheck         = true
Config.ExplosionFilter    = true
Config.SpawnProtection    = true
Config.Honeypots          = true
Config.Heartbeat          = true
Config.CommandScan        = true
Config.PoolScan           = true
Config.EventProtection    = true
Config.FloodProtection    = true
Config.Screenshots        = false   -- set true SETELAH Config.DiscordWebhook diisi

-- ============================================================
-- THRESHOLDS
-- ============================================================
Config.MaxHealth          = 200     -- max HP normal GTA V
Config.MaxOnFootSpeed     = 15.0    -- m/s; naik kalau server lo punya sprint mod

-- ============================================================
-- BLACKLISTS
-- ============================================================
Config.BlacklistedWeapons = {
    `WEAPON_RAILGUN`,
    `WEAPON_MINIGUN`,
    `WEAPON_RPG`,
    `WEAPON_GRENADELAUNCHER`,
    `WEAPON_HOMINGLAUNCHER`,
    `WEAPON_RAYPISTOL`,
    `WEAPON_RAYCARBINE`,
    `WEAPON_RAYMINIGUN`,
}

-- Explosion type IDs yang di-block (server-side, unbypassable)
Config.BlacklistedExplosions = {
    [7]  = true,  -- HI_OCTANE
    [30] = true,  -- RAILGUN
    [36] = true,  -- BLIMP2
}

-- Model entity/kendaraan yang gak boleh di-spawn
Config.BlacklistedModels = {
    `rhino`,
    `lazer`,
    `hydra`,
    `khanjali`,
    `oppressor2`,
}

-- ============================================================
-- HONEYPOT EVENTS
-- PERINGATAN: Jangan tambah event dari framework yang LO PAKAI!
-- Contoh: kalau server lo pakai ESX, JANGAN masukkin 'esx:getSharedObject' di sini.
-- Cuma masukkin event dari framework yang TIDAK lo install di server.
-- ============================================================
Config.HoneypotEvents = {
    'ac:giveMoney',
    'admin:giveAllPerms',
    'bank:deposit_unsecured',
}

-- Export names yang jadi trap — kalau ada yang panggil, langsung kena
Config.TrapExports = {
    'toggle',
    'disable',
    'bypass',
    'stop',
    'setEnabled',
}

-- ============================================================
-- TIMING
-- ============================================================
Config.HeartbeatInterval      = 30000   -- ms antar heartbeat
Config.HeartbeatTimeout       = 10000   -- ms tunggu response sebelum ban
Config.TokenRotationInterval  = 60000   -- ms antar rotasi secure-event token
Config.MaxEntitySpawnsPer10s  = 15      -- entity spawn limit per 10 detik per player

-- ============================================================
-- BEHAVIORAL DETECTION
-- ============================================================
Config.TeleportDistanceThreshold = 500.0   -- meter; jarak on-foot yang trigger teleport ban
Config.MaxWeaponDamage           = 200     -- damage per-hit di atas ini = damage modifier

-- ============================================================
-- DISCORD / EVIDENCE
-- ============================================================
Config.DiscordWebhook = ''   -- isi URL webhook lo buat screenshot evidence, lalu set Screenshots = true

-- ============================================================
-- BAN MESSAGE (Indonesian)
-- ============================================================
Config.BanMessage = 'Lo kena ban karena terdeteksi cheating. Feel free to appeal di Discord kita.'
