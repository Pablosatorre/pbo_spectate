fx_version 'adamant'
game 'gta5'
author 'pabio'
version '1.2.0'
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
server_scripts ({'server/*.lua','@oxmysql/lib/MySQL.lua'})
