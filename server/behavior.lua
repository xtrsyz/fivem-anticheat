-- server/behavior.lua
-- Behavioral detection server-side (unbypassable):
--   • Teleport detection (butuh OneSync)
--   • weaponDamageEvent — damage modifier ban
--   • giveWeaponEvent — block + ban
--     (kalau server lo kasih senjata via native/export server-side, gak kena ini)

local lastPositions    = {}   -- [playerId] = vector3
local positionInitialized = {} -- [playerId] = bool; skip sample pertama

-- Bersihkan data saat player disconnect
AddEventHandler('playerDropped', function()
    lastPositions[source]       = nil
    positionInitialized[source] = nil
end)

-- ============================================================
-- TELEPORT DETECTION (tiap 3 detik)
-- ============================================================
CreateThread(function()
    while true do
        Wait(3000)
        for _, playerId in ipairs(GetPlayers()) do
            local id  = tonumber(playerId)
            local ped = GetPlayerPed(id)
            if ped and ped > 0 then
                local pos = GetEntityCoords(ped)

                if not positionInitialized[id] then
                    -- Sample pertama — simpan posisi, skip pengecekan
                    lastPositions[id]       = pos
                    positionInitialized[id] = true
                else
                    local prev = lastPositions[id]
                    if prev then
                        local dist = #(pos - prev)
                        -- On-foot saja (bukan dalam kendaraan)
                        if dist > Config.TeleportDistanceThreshold
                            and GetVehiclePedIsIn(ped, false) == 0
                        then
                            banPlayer(id,
                                ('Teleport terdeteksi: %.0fm dalam 3 detik'):format(dist))
                        end
                    end
                    lastPositions[id] = pos
                end
            end
        end
    end
end)

-- ============================================================
-- WEAPON DAMAGE MODIFIER DETECTION
-- ============================================================
AddEventHandler('weaponDamageEvent', function(sender, ev)
    if ev.weaponDamage and ev.weaponDamage > Config.MaxWeaponDamage then
        CancelEvent()
        banPlayer(sender,
            ('Damage modifier terdeteksi: %d dmg/hit'):format(ev.weaponDamage))
    end
end)

-- ============================================================
-- GIVE WEAPON EVENT BLOCK
-- Semua giveWeaponEvent dari client di-cancel.
-- Kalau server lo perlu kasih senjata, pakai GiveWeaponToPed() di server-side
-- atau exports dari resource inventory lo — gak akan kena event ini.
-- ============================================================
AddEventHandler('giveWeaponEvent', function(sender, ev)
    CancelEvent()
    banPlayer(sender, 'Illegal giveWeaponEvent (client-side weapon giving)')
end)
