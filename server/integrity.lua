-- server/integrity.lua
-- Bangun set resource yang valid setelah 5 detik startup.
-- Ban player yang melaporkan resource yang tidak dikenal server.
-- Ini nangkep executor yang inject resource baru di sisi client.

local serverResources = {}
local resourcesLoaded = false

CreateThread(function()
    Wait(5000)   -- tunggu semua resource selesai start
    for i = 0, GetNumResources() - 1 do
        local res = GetResourceByFindIndex(i)
        if res and res ~= '' then
            serverResources[res] = true
        end
    end
    resourcesLoaded = true
    print(('[AC] ^2Integrity^0 — %d resource(s) diindex.'):format(GetNumResources()))
end)

RegisterNetEvent('ac:resourceCheck', function(clientList)
    local src = source
    if not resourcesLoaded then return end  -- jangan proses kalau server belum ready
    if type(clientList) ~= 'table' then return end

    for _, res in ipairs(clientList) do
        if type(res) == 'string' and res ~= '' then
            if not serverResources[res] then
                banPlayer(src, ('Unknown resource di client: "%s"'):format(res))
                return   -- cukup satu, jangan ban berkali-kali
            end
        end
    end
end)
