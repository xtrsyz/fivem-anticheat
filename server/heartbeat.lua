-- server/heartbeat.lua
-- Kirim token acak ke setiap player tiap HeartbeatInterval.
-- Kalau dalam HeartbeatTimeout detik player belum pong balik → ban
-- (kemungkinan AC client di-unload oleh executor).
-- Token mismatch → ban (spoofing attempt).

if not Config.Heartbeat then return end

local pending = {}   -- [playerId] = token yang dikirim

-- Bersihkan pending kalau player disconnect
AddEventHandler('playerDropped', function()
    pending[source] = nil
end)

CreateThread(function()
    while true do
        Wait(Config.HeartbeatInterval)

        -- Kirim token ke semua player yang online
        for _, playerId in ipairs(GetPlayers()) do
            local id     = tonumber(playerId)
            local token  = math.random(100000, 999999)
            pending[id]  = token
            TriggerClientEvent('ac:heartbeat', id, token)
        end

        -- Tunggu timeout buat player respond
        Wait(Config.HeartbeatTimeout)

        -- Cek siapa yang belum balas
        for playerId, _ in pairs(pending) do
            if GetPlayerName(playerId) then   -- masih online?
                banPlayer(playerId,
                    'Anti-cheat client tidak merespon (kemungkinan di-unload oleh executor)')
            end
            pending[playerId] = nil
        end
    end
end)

-- ============================================================
-- TERIMA PONG DARI CLIENT
-- ============================================================
RegisterNetEvent('ac:heartbeat:pong', function(token)
    local src = source
    local expected = pending[src]
    if expected == nil then return end  -- pong diluar window — abaikan

    if expected == token then
        pending[src] = nil   -- valid, aman
    else
        banPlayer(src,
            ('Heartbeat token mismatch (spoofing): expected=%s got=%s'):format(
                tostring(expected), tostring(token)))
    end
end)
