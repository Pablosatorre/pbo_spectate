PBO = nil
print(
    Config.Prename ..
        ' '..
    Config.Script ..
        ' '..
    Config.PrintConsole
)
scriptname = "^1SPECTATE^7: "
TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        PBO = obj
    end
)

PBO.RegisterServerCallback('mdn_spectate:checkAdmin', function(source, cb)
    local xPlayer = PBO.GetPlayerFromId(source)
    local g = xPlayer.getGroup()
    cb(g)
end)

TriggerEvent(
    "es:addGroupCommand",
    "menuspectate",
    "admin",
    function(source, args, user)
        TriggerClientEvent("pbo_spectate:spectate", source, target)
    end,
    function(source, args, user)
        TriggerClientEvent("chatMessage", source, scriptname, {255, 0, 0}, "Permisos Insuficientes")
    end
)

PBO.RegisterServerCallback(
    "pbo_spectate:getPlayerData",
    function(source, cb, id)
        local xPlayer = PBO.GetPlayerFromId(id)
        if xPlayer ~= nil then
            cb(xPlayer)
        end
    end
)

RegisterServerEvent("pbo_spectate:kick")
AddEventHandler(
    "pbo_spectate:kick",
    function(target, msg)
        local xPlayer = PBO.GetPlayerFromId(source)

        if xPlayer.getGroup() ~= "user" then
            DropPlayer(target, msg)
        else
            print(("pbo_spectate: %s intento kickear a un jugador"):format(xPlayer.identifier))
            DropPlayer(source, "pbo_spectate: no estas autorizado para kickear a un jugador gilipollas!")
        end
    end
)

PBO.RegisterServerCallback(
    "pbo_spectate:getOtherPlayerData",
    function(source, cb, target)
        local xPlayer = PBO.GetPlayerFromId(target)
        if xPlayer ~= nil then
            local identifier = GetPlayerIdentifiers(target)[1]

            local result =
                MySQL.Sync.fetchAll(
                "SELECT * FROM users WHERE identifier = @identifier",
                {
                    ["@identifier"] = identifier
                }
            )

            local user = result[1]
            local firstname = user["firstname"]
            local lastname = user["lastname"]
            local sex = user["sex"]
            local dob = user["dateofbirth"]
            local height = user["height"] .. " Centimetri"
            local money = user["money"]
            local bank = user["bank"]

            local data = {
                name = GetPlayerName(target),
                job = xPlayer.job,
                inventory = xPlayer.inventory,
                accounts = xPlayer.accounts,
                weapons = xPlayer.loadout,
                firstname = firstname,
                lastname = lastname,
                sex = sex,
                dob = dob,
                height = height,
                money = money,
                bank = bank
            }

            TriggerEvent(
                "esx_license:getLicenses",
                target,
                function(licenses)
                    data.licenses = licenses
                    cb(data)
                end
            )
        end
    end
)