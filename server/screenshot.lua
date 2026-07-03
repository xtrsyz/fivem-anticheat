-- server/screenshot.lua
-- Tangkap screenshot player sebagai bukti sebelum di-ban.
-- Butuh resource 'screenshot-basic' (opsional).
-- https://github.com/citizenfx/screenshot-basic
--
-- Setup:
--   1. Download & ensure screenshot-basic di server.cfg
--   2. Isi Config.DiscordWebhook dengan URL webhook Discord lo
--   3. Set Config.Screenshots = true di config.lua

---Kirim embed Discord dengan screenshot player yang kena ban.
---@param playerId number
---@param reason string
function captureEvidence(playerId, reason)
    if not Config.Screenshots then return end
    if Config.DiscordWebhook == '' then return end

    -- pcall supaya missing screenshot-basic gak crash ban system
    local ok, err = pcall(function()
        exports['screenshot-basic']:requestClientScreenshot(playerId, {
            encoding = 'jpg',
            quality  = 0.85,
        }, function(err2, data)
            if err2 or not data then
                print(('[AC] Screenshot gagal untuk player %s: %s'):format(
                    playerId, tostring(err2)))
                return
            end

            local name   = GetPlayerName(playerId) or 'Unknown'
            local embed  = {
                {
                    title       = '🚨 Anti-Cheat: Player Banned',
                    color       = 16711680,   -- merah
                    description = ('**Player:** %s\n**ID:** %s\n**Reason:** %s'):format(
                        name, playerId, reason),
                    image       = { url = data },
                    footer      = { text = os.date('%Y-%m-%d %H:%M:%S') },
                }
            }

            PerformHttpRequest(Config.DiscordWebhook, function(statusCode, response, headers)
                if statusCode ~= 204 and statusCode ~= 200 then
                    print(('[AC] Discord webhook error: %d'):format(statusCode))
                end
            end, 'POST', json.encode({ embeds = embed }), {
                ['Content-Type'] = 'application/json',
            })
        end)
    end)

    if not ok then
        print(('[AC] screenshot-basic tidak tersedia, skip evidence capture: %s'):format(
            tostring(err)))
    end
end
