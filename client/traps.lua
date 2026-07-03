-- client/traps.lua
-- Export-export ini sengaja di-expose sebagai "API" palsu buat AC ini.
-- Cheater yang nyoba disable/bypass AC via exported function langsung kena.
-- Semua nama diambil dari Config.TrapExports.

for _, exportName in ipairs(Config.TrapExports) do
    -- Bungkus di closure supaya exportName ter-capture dengan benar
    local name = exportName
    exports(name, function(...)
        TriggerServerEvent('ac:detection',
            ('Trap export triggered: exports["%s"]::%s()'):format(
                GetCurrentResourceName(), name))
        return true   -- pura-pura berhasil supaya cheater gak tau dia ketangkep
    end)
end
