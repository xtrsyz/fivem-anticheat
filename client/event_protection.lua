-- client/event_protection.lua
-- Simpan token yang dikirim server, prepend ke setiap secure event.
-- Gunakan TriggerSecureEvent() atau exports['anticheat']:triggerSecure()
-- supaya server bisa validasi event beneran dari client lo.
--
-- CONTOH PENGGUNAAN di resource lain:
--   exports['anticheat']:triggerSecure('bank:withdraw', amount)
--   -- atau kalau lo pakai global (harus di resource yang sama):
--   TriggerSecureEvent('bank:withdraw', amount)
--   -- di server, register dengan RegisterSecureEvent('bank:withdraw', function(src, amount) ... end)

if not Config.EventProtection then return end

local currentToken = ''

-- Terima token baru dari server (dikirim saat join & tiap TokenRotationInterval)
RegisterNetEvent('ac:updateToken', function(token)
    currentToken = token
end)

---Trigger server event dengan token sebagai argumen pertama.
---@param eventName string
---@vararg any
function TriggerSecureEvent(eventName, ...)
    TriggerServerEvent(eventName, currentToken, ...)
end

-- Export supaya resource lain bisa pakai
exports('triggerSecure', function(eventName, ...)
    TriggerSecureEvent(eventName, ...)
end)
