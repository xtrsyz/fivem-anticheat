-- client/pool_scan.lua
-- Scan pool CVehicle tiap 10 detik.
-- Kendaraan blacklisted yang LOCAL ONLY (gak di-networked ke server) langsung dihapus.
-- Server-side entityCreating gak bisa nangkep entity non-networked,
-- makanya perlu scan sisi client juga.

if not Config.PoolScan then return end

-- Buat lookup cepat dari Config.BlacklistedModels
local blacklistedSet = {}
for _, model in ipairs(Config.BlacklistedModels) do
    blacklistedSet[model] = true
end

CreateThread(function()
    while true do
        Wait(10000)
        local vehicles = GetGamePool('CVehicle')
        for _, vehicle in ipairs(vehicles) do
            local model = GetEntityModel(vehicle)
            if blacklistedSet[model] and not NetworkGetEntityIsNetworked(vehicle) then
                -- Entity ini cuma ada di lokal, gak keliatan server → hapus
                DeleteEntity(vehicle)
                TriggerServerEvent('ac:detection',
                    ('Local-only blacklisted vehicle: model=%d'):format(model))
            end
        end
    end
end)
