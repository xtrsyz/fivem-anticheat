-- server/flood_protection.lua
-- Rate-limit entity spawning per player.
-- Lebih dari MaxEntitySpawnsPer10s spawn dalam 10 detik → CancelEvent + ban.

if not Config.FloodProtection then return end

local spawnCounts = {}   -- [playerId] = jumlah spawn dalam window saat ini

-- Reset counter tiap 10 detik
CreateThread(function()
    while true do
        Wait(10000)
        spawnCounts = {}
    end
end)

AddEventHandler('entityCreating', function(handle)
    -- Cari owner dari entity yang mau di-spawn
    -- NetworkGetFirstEntityOwner belum tersedia di entityCreating hook,
    -- jadi kita pakai routing bucket owner via source (available via global)
    local src = source   -- player yang trigger spawn (kalau ada)
    if not src or src == 0 then return end

    local id = tonumber(src)
    spawnCounts[id] = (spawnCounts[id] or 0) + 1

    if spawnCounts[id] > Config.MaxEntitySpawnsPer10s then
        CancelEvent()
        banPlayer(id,
            ('Entity spawn flood: %d spawns dalam 10 detik'):format(spawnCounts[id]))
        spawnCounts[id] = 0   -- reset biar gak double-ban sebelum disconnect
    end
end)
