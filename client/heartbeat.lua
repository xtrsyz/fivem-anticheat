-- client/heartbeat.lua
-- Dengerin token dari server, langsung pong balik.
-- Kalau AC ini di-unload oleh executor, server gak dapat pong → ban.

if not Config.Heartbeat then return end

RegisterNetEvent('ac:heartbeat', function(token)
    TriggerServerEvent('ac:heartbeat:pong', token)
end)
