fx_version 'cerulean'
game 'gta5'

author 'Ol Man'
description 'Hillbilly Grand Theft Auto Script for QBCore'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',  -- Only needed if using a MySQL database
    'server/server.lua'
}

dependencies {
    'qb-core',
    'qb-target',  
    'qb-policejob' -- For police alerts
}
