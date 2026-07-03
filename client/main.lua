-- client/main.lua
-- Core detection: godmode, weapon blacklist, speed/noclip check
-- Semua detection dikirim ke server via 'ac:detection' dengan cooldown 10 detik

local detectionCooldown = false

---Kirim laporan deteksi ke server (dengan cooldown supaya gak spam).
local function report(reason)
    if detectionCooldown then return end
    detectionCooldown = true
    TriggerServerEvent('ac:detection', reason)
    SetTimeout(10000, function() detectionCooldown = false end)
end

-- ============================================================
-- GOD MODE CHECK (tiap 5 detik)
-- ============================================================
CreateThread(function()
    while Config.GodModeCheck do
        Wait(5000)
        local ped = PlayerPedId()
        if GetPlayerInvincible(PlayerId()) then
            report('God Mode terdeteksi (invincible flag)')
        end
        if GetEntityMaxHealth(ped) > Config.MaxHealth then
            report(('Health modifier: maxHP=%d'):format(GetEntityMaxHealth(ped)))
        end
    end
end)

-- ============================================================
-- WEAPON BLACKLIST CHECK (tiap 3 detik)
-- ============================================================
CreateThread(function()
    while Config.WeaponBlacklist do
        Wait(3000)
        local ped = PlayerPedId()
        for _, weapon in ipairs(Config.BlacklistedWeapons) do
            if HasPedGotWeapon(ped, weapon, false) then
                RemoveWeaponFromPed(ped, weapon)
                report('Blacklisted weapon: ' .. tostring(weapon))
            end
        end
    end
end)

-- ============================================================
-- SPEED / NOCLIP CHECK (tiap 2 detik)
-- Skip kalau lagi di kendaraan, parasut, falling, atau ragdoll
-- ============================================================
CreateThread(function()
    while Config.SpeedCheck do
        Wait(2000)
        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false)
            and GetPedParachuteState(ped) == -1
            and not IsPedFalling(ped)
            and not IsPedRagdoll(ped)
        then
            local speed = GetEntitySpeed(ped)
            if speed > Config.MaxOnFootSpeed then
                report(('Speed anomaly: %.1f m/s on-foot'):format(speed))
            end
        end
    end
end)
