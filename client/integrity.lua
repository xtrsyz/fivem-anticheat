-- client/integrity.lua
-- 1. Tiap 60 detik kirim daftar resource yang jalan di client ke server.
--    Server bakal bandingkan dengan resource list-nya sendiri.
-- 2. Snapshot _G di awal, pantau global injection tiap 10 detik.
--    CATATAN: ini terbatas karena tiap resource FiveM punya environment sendiri.
--    Executor canggih yang jalan di environment terpisah gak akan kedetect sini,
--    tapi berguna buat nangkep injeksi yang nempel di resource ini secara langsung.

-- ============================================================
-- RESOURCE LIST CHECK
-- ============================================================
CreateThread(function()
    while true do
        Wait(60000)
        local resources = {}
        for i = 0, GetNumResources() - 1 do
            resources[#resources + 1] = GetResourceByFindIndex(i)
        end
        TriggerServerEvent('ac:resourceCheck', resources)
    end
end)

-- ============================================================
-- GLOBAL INJECTION WATCH
-- ============================================================
local globalBaseline = {}

-- Snapshot semua key _G yang ada saat ini
CreateThread(function()
    for k in pairs(_G) do
        globalBaseline[k] = true
    end

    while true do
        Wait(10000)
        for k in pairs(_G) do
            if not globalBaseline[k] then
                TriggerServerEvent('ac:detection',
                    ('Injected global detected: %s'):format(tostring(k)))
                globalBaseline[k] = true   -- jangan spam event yang sama
            end
        end
    end
end)
