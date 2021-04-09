fx_version 'adamant'
author 'AlexBanPer'
game 'gta5'
version '1.00'

dependencies {
    'nex_core',
    'warmenu'
}

client_scripts {
    '@warmenu/warmenu.lua',
    'config.lua',
    'client/main.lua',
    'client/menues/*.lua',
    'client/adminMenu.lua',
    'client/adminMenuEvents.lua',
    'client/punish.lua',
    'client/reports.lua'
    
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'config_s.lua',
    'server/functions.lua',
    'server/main.lua',
    'server/menuEvents.lua',
    'server/reports.lua',
    'server/commander.lua'
}
