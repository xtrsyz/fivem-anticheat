fx_version 'cerulean'
game 'gta5'

author 'xtrsyz'
description 'FiveM Anticheat'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/heartbeat.lua',
    'client/command_scan.lua',
    'client/traps.lua',
    'client/pool_scan.lua',
    'client/integrity.lua',
    'client/event_protection.lua',
}

server_scripts {
    'server/main.lua',
    'server/honeypot.lua',
    'server/heartbeat.lua',
    'server/behavior.lua',
    'server/event_protection.lua',
    'server/flood_protection.lua',
    'server/whitelist.lua',
    'server/integrity.lua',
    'server/screenshot.lua',
}
