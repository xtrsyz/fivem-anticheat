-- server/whitelist.lua
-- Admin bypass untuk ban system.
-- Player bisa di-whitelist secara runtime ATAU via ace permission 'ac.bypass'.
--
-- Tambahkan di server.cfg:
--   add_ace group.admin ac.bypass allow
--
-- EXPORTS:
--   exports['anticheat']:setWhitelisted(src, true/false)
--   exports['anticheat']:isWhitelisted(src)   → boolean

local whitelistedPlayers = {}   -- [playerId] = true

---Cek apakah player di-bypass dari ban system.
---@param src number
---@return boolean
function isWhitelisted(src)
    if whitelistedPlayers[tonumber(src)] then return true end
    if IsPlayerAceAllowed(src, 'ac.bypass') then return true end
    return false
end

---Set status whitelist runtime untuk player tertentu.
---@param src number
---@param state boolean
local function setWhitelisted(src, state)
    whitelistedPlayers[tonumber(src)] = state and true or nil
end

-- Bersihkan whitelist runtime saat player disconnect
AddEventHandler('playerDropped', function()
    whitelistedPlayers[source] = nil
end)

-- ============================================================
-- EXPORTS
-- ============================================================
exports('isWhitelisted', isWhitelisted)
exports('setWhitelisted', setWhitelisted)
