-- server/event_protection.lua
-- Token-based event protection supaya cheater gak bisa spoof server events.
--
-- HOW TO USE di resource server lo:
--   RegisterSecureEvent('bank:withdraw', function(src, amount)
--       -- amount sudah divalidasi, src sudah verified
--       -- lakukan logika bank di sini
--   end)
--
-- Di resource client lo:
--   TriggerSecureEvent('bank:withdraw', amount)
--   -- atau: exports['anticheat']:triggerSecure('bank:withdraw', amount)

if not Config.EventProtection then return end

local playerTokens = {}   -- [playerId] = string token

-- ============================================================
-- GENERATE TOKEN — 32 karakter alphanumeric
-- ============================================================
local charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

local function generateToken()
    local t = {}
    for _ = 1, 32 do
        local idx = math.random(1, #charset)
        t[#t + 1] = charset:sub(idx, idx)
    end
    return table.concat(t)
end

local function issueToken(src)
    local token = generateToken()
    playerTokens[src] = token
    TriggerClientEvent('ac:updateToken', src, token)
end

-- ============================================================
-- TOKEN DISPATCH ON JOIN
-- ============================================================
AddEventHandler('playerSpawned', function()
    issueToken(source)
end)

-- Fallback: kirim juga pas playerConnecting selesai (tidak semua server pakai playerSpawned)
AddEventHandler('playerJoining', function()
    issueToken(source)
end)

-- ============================================================
-- TOKEN ROTATION (tiap TokenRotationInterval)
-- ============================================================
CreateThread(function()
    while true do
        Wait(Config.TokenRotationInterval)
        for _, playerId in ipairs(GetPlayers()) do
            local id = tonumber(playerId)
            if GetPlayerName(id) then
                issueToken(id)
            end
        end
    end
end)

-- ============================================================
-- CLEANUP ON DROP
-- ============================================================
AddEventHandler('playerDropped', function()
    playerTokens[source] = nil
end)

-- ============================================================
-- RegisterSecureEvent — GLOBAL wrapper
-- Validate token sebagai argumen pertama; ban kalau mismatch.
-- ============================================================
---Register event yang diproteksi token.
---@param eventName string
---@param handler function  dipanggil dengan (src, ...) tanpa token
function RegisterSecureEvent(eventName, handler)
    RegisterNetEvent(eventName, function(token, ...)
        local src = source
        local expected = playerTokens[src]

        if expected == nil then
            -- Token belum di-issue (player baru connect) — tolak saja
            return
        end

        if token ~= expected then
            banPlayer(src,
                ('Secure event token mismatch: event="%s"'):format(eventName))
            return
        end

        handler(src, ...)
    end)
end

-- Expose sebagai export supaya resource lain bisa pakai
exports('registerSecureEvent', function(eventName, handler)
    RegisterSecureEvent(eventName, handler)
end)

-- Expose getter token (untuk keperluan internal antar-script)
exports('getPlayerToken', function(src)
    return playerTokens[src]
end)
