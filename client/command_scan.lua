-- client/command_scan.lua
-- Deteksi command yang di-inject oleh executor SETELAH resource started.
-- Command legit punya owning resource yang statusnya 'started'.
-- Command tanpa owner / resource-nya gak 'started' = injected = report.

if not Config.CommandScan then return end

local baseline = {}   -- set command yang sudah ada pas snapshot pertama
local warmupDone = false

local function snapshotCommands()
    local snap = {}
    -- GetRegisteredCommands() tersedia di FiveM cfx runtime (client-side)
    local cmds = GetRegisteredCommands()
    for _, cmd in ipairs(cmds) do
        snap[cmd.name] = cmd.resource or ''
    end
    return snap
end

-- Warmup 10 detik — tunggu semua resource selesai load dulu
SetTimeout(10000, function()
    baseline = snapshotCommands()
    warmupDone = true
end)

-- Scan tiap 15 detik
CreateThread(function()
    while true do
        Wait(15000)
        if warmupDone then
            local current = snapshotCommands()
            for name, res in pairs(current) do
                if not baseline[name] then
                    -- Command baru; cek apakah resource-nya valid
                    local isLegit = false
                    if res ~= '' then
                        local state = GetResourceState(res)
                        isLegit = (state == 'started')
                    end
                    if not isLegit then
                        TriggerServerEvent('ac:detection',
                            ('Injected command detected: /%s (resource: "%s")'):format(name, res))
                        -- Tambahkan ke baseline supaya gak spam
                        baseline[name] = res
                    end
                end
            end
        end
    end
end)

-- Refresh baseline tiap kali ada resource yang start (dengan delay kecil)
AddEventHandler('onClientResourceStart', function(resName)
    SetTimeout(2000, function()
        if warmupDone then
            local fresh = snapshotCommands()
            for name, res in pairs(fresh) do
                baseline[name] = res
            end
        end
    end)
end)
