-- server/main.lua
-- Core: ban system (JSON file), playerConnecting check, ac:detection handler,
-- explosionEvent filter, entityCreating block, /acban command.

local bans = {}

-- ============================================================
-- BAN STORAGE (lazy load — bans.json dibuat saat runtime, gak di-commit)
-- ============================================================
local function loadBans()
    local data = LoadResourceFile(GetCurrentResourceName(), 'bans.json')
    if data then
        local ok, decoded = pcall(json.decode, data)
        bans = (ok and type(decoded) == 'table') and decoded or {}
    else
        bans = {}
    end
end

local function saveBans()
    local ok, encoded = pcall(json.encode, bans)
    if ok then
        SaveResourceFile(GetCurrentResourceName(), 'bans.json', encoded, -1)
    end
end

local function getIdentifiers(src)
    local ids = {}
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        ids[#ids + 1] = id
    end
    return ids
end

-- ============================================================
-- banPlayer — GLOBAL, dipakai semua server script lain
-- ============================================================
---Ban player dan drop mereka dari server.
---@param src number  server ID
---@param reason string  alasan ban
function banPlayer(src, reason)
    -- Cek whitelist dulu (fungsi dari server/whitelist.lua)
    if isWhitelisted and isWhitelisted(src) then
        print(('[AC] ^3SKIP BAN^0 — player %s (%s) is whitelisted'):format(
            GetPlayerName(src) or '?', src))
        return
    end

    local name = GetPlayerName(src) or 'Unknown'
    local entry = {
        name        = name,
        reason      = reason,
        identifiers = getIdentifiers(src),
        date        = os.date('%Y-%m-%d %H:%M:%S'),
    }
    bans[#bans + 1] = entry
    saveBans()

    print(('[AC] ^1BANNED^0 %s (ID:%s) | Reason: %s'):format(name, src, reason))

    -- Coba ambil screenshot evidence (server/screenshot.lua)
    if captureEvidence then
        captureEvidence(src, reason)
    end

    -- Drop SETELAH screenshot request (screenshot async, jadi ini kasih waktu sebentar)
    SetTimeout(1500, function()
        DropPlayer(src, Config.BanMessage .. '\nReason: ' .. reason)
    end)
end

-- ============================================================
-- LOAD BANS ON START
-- ============================================================
loadBans()

-- ============================================================
-- PLAYER CONNECTING — cek apakah identifier sudah di-ban
-- ============================================================
AddEventHandler('playerConnecting', function(_, _, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)

    local connectingIds = getIdentifiers(src)
    for _, ban in ipairs(bans) do
        if type(ban.identifiers) == 'table' then
            for _, bannedId in ipairs(ban.identifiers) do
                for _, id in ipairs(connectingIds) do
                    if id == bannedId then
                        deferrals.done(
                            Config.BanMessage .. '\nReason: ' .. (ban.reason or 'N/A'))
                        return
                    end
                end
            end
        end
    end

    deferrals.done()
end)

-- ============================================================
-- ac:detection — terima laporan dari client
-- Sanitasi reason supaya cheater gak bisa inject payload gede/aneh
-- ============================================================
RegisterNetEvent('ac:detection', function(reason)
    local src = source
    -- Validasi tipe & panjang
    if type(reason) ~= 'string' then
        reason = 'Invalid detection payload (non-string reason)'
    end
    if #reason > 200 then
        reason = reason:sub(1, 200) .. '...[truncated]'
    end
    banPlayer(src, reason)
end)

-- ============================================================
-- EXPLOSION FILTER — server-side, unbypassable
-- ============================================================
AddEventHandler('explosionEvent', function(sender, ev)
    if not Config.ExplosionFilter then return end
    if Config.BlacklistedExplosions[ev.explosionType] then
        CancelEvent()
        banPlayer(sender,
            ('Blacklisted explosionType: %d'):format(ev.explosionType))
    end
end)

-- ============================================================
-- ENTITY CREATING — block spawn model blacklisted
-- Tidak ban di sini (bisa false positive dari server script sendiri),
-- cukup block dan log. Ban dilakukan oleh flood_protection.lua kalau banyak.
-- ============================================================
local blacklistedModelSet = {}
AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, model in ipairs(Config.BlacklistedModels) do
        blacklistedModelSet[model] = true
    end
end)

-- Inisialisasi langsung juga buat jaga-jaga
for _, model in ipairs(Config.BlacklistedModels) do
    blacklistedModelSet[model] = true
end

AddEventHandler('entityCreating', function(handle)
    if not Config.SpawnProtection then return end
    local model = GetEntityModel(handle)
    if blacklistedModelSet[model] then
        CancelEvent()
        print(('[AC] ^3BLOCKED^0 spawn of blacklisted model hash: %d'):format(model))
    end
end)

-- ============================================================
-- /acban <id> <reason...> — command admin
-- Restricted via ace permission 'ac.ban'
-- ============================================================
RegisterCommand('acban', function(src, args)
    -- src == 0 = server console (selalu allow)
    if src ~= 0 and not IsPlayerAceAllowed(src, 'ac.ban') then
        TriggerClientEvent('chat:addMessage', src, {
            args = { '^1[AC]', 'Lo gak punya permission buat itu.' }
        })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        local msg = '[AC] Usage: /acban <id> <reason>'
        if src == 0 then
            print(msg)
        else
            TriggerClientEvent('chat:addMessage', src,
                { args = { '^3[AC]', 'Usage: /acban <id> <reason>' } })
        end
        return
    end

    local reason = (#args > 1)
        and table.concat(args, ' ', 2)
        or 'Banned by admin'

    banPlayer(targetId, 'Admin ban: ' .. reason)
end, true)
