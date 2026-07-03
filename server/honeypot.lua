-- server/honeypot.lua
-- Daftarkan setiap event di Config.HoneypotEvents.
-- Event-event ini TIDAK pernah dipanggil oleh resource legit manapun.
-- Kalau ada yang trigger = cheater. Simple as that.
--
-- PERINGATAN: Pastikan event di Config.HoneypotEvents BUKAN event dari
-- framework yang lo pakai! Misalnya kalau server lo pakai ESX,
-- jangan masukkin 'esx:getSharedObject'. Cek config.lua untuk detail.

if not Config.Honeypots then return end

for _, eventName in ipairs(Config.HoneypotEvents) do
    local name = eventName  -- capture untuk closure
    RegisterNetEvent(name, function(...)
        local src = source
        print(('[AC] ^1HONEYPOT^0 triggered by %s (ID:%s): %s'):format(
            GetPlayerName(src) or '?', src, name))
        banPlayer(src, 'Honeypot triggered: ' .. name)
    end)
end
