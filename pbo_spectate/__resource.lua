fx_version 'adamant'
game 'gta5'

name 'PBO SPECTATE PLAYERS'
author '! pablosatorre#3470'
version '1.0.0'


ui_page ('html/index.html')

files (

    {

      '**/*.html',

      '**/**/*.css',

      '**/**/*.ttf','**/**/*.otf',

      '**/**/*.js'

    }

)

client_scripts ({'client/*.lua'})
shared_scripts ({'config/*.lua'})
server_scripts ({'server/*.lua','@mysql-async/lib/MySQL.lua'})