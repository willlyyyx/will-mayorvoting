fx_version 'cerulean'
game 'gta5'

author 'willlyyy'
description 'Mayor Voting System'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
} 

client_scripts {
    'client/client.lua'
} 
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/main.js',
    'ui/images/*.*'
}

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql'
}

lua54 'yes'
