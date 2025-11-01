fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'
author 'MaDHouSe79'
description 'MH Parking Lite - A Realistic Vehicle Parking System'
version '2.0.0'

files {'core/images/*.*'}

shared_scripts {
    '@ox_lib/init.lua',
    'locales/locale.lua',
    'locales/en.lua',
    'shared/config.lua',
    'shared/trailers.lua',
    'shared/vehicles.lua',
    'shared/functions.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'core/framework/client.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'core/framework/server.lua',
    --'core/rewrite.lua',
    'server/main.lua',
    'server/update.lua',
}

dependencies {
    'oxmysql',
}

