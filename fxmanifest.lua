fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'smrkec_jailsystem'
author 'Smrkec'
description 'Simple ESX police jail system'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_script 'config.lua'
client_script 'client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'oxmysql'
}
