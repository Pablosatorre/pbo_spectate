pbo = nil
scriptname = "^1SPECTATE^7: "
TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        pbo = obj
    end
)

pbo.RegisterServerCallback('mdn_spectate:checkAdmin', function(source, cb)
    local xPlayer = pbo.GetPlayerFromId(source)
    local g = xPlayer.getGroup()
    cb(g)
end)

TriggerEvent(
    "es:addGroupCommand",
    "menuspectate",
    "admin",
    function(source, args, user)
        TriggerClientEvent("pbo_spectateplayers:spectate", source, target)
    end,
    function(source, args, user)
        TriggerClientEvent("chatMessage", source, scriptname, {255, 0, 0}, "Permisos Insuficientes")
    end
)

pbo.RegisterServerCallback(
    "pbo_spectateplayers:getPlayerData",
    function(source, cb, id)
        local xPlayer = pbo.GetPlayerFromId(id)
        if xPlayer ~= nil then
            cb(xPlayer)
        end
    end
)

RegisterServerEvent("pbo_spectateplayers:kick")
AddEventHandler(
    "pbo_spectateplayers:kick",
    function(target, msg)
        local xPlayer = pbo.GetPlayerFromId(source)

        if xPlayer.getGroup() ~= "user" then
            DropPlayer(target, msg)
        else
            print(("pbo_spectateplayers: %s intento kickear a un jugador"):format(xPlayer.identifier))
            -- DropPlayer(source, "pbo_spectateplayers: no estas autorizado para kickear a un jugador gilipollas!")
        end
    end
)

pbo.RegisterServerCallback("pbo_spectateplayers:getOtherPlayerData", function(source, cb, target)
    local xPlayer = pbo.GetPlayerFromId(target)

    if xPlayer then
        local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
            ["@identifier"] = xPlayer.identifier
        })

        local sex = result[1].sex == "m" and "Hombre" or "Mujer"
        local dob = result[1].dateofbirth
        local height = result[1].height

        local data = {
            name = GetPlayerName(target),
            job = xPlayer.job,
            inventory = xPlayer.inventory,
            accounts = xPlayer.accounts,
            weapons = xPlayer.loadout,
            charName = xPlayer.getName(),
            sex = sex,
            dob = dob,
            height = height,
            money = xPlayer.getMoney(),
            bank = xPlayer.getAccount('bank').money
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
end)

pbo.RegisterServerCallback('pbo_spectateplayers:getPlayersList', function(source, cb)
    local xPlayers = pbo.GetPlayers()
    local players = {}

    for i = 1, #xPlayers, 1 do
        local xPlayer = pbo.GetPlayerFromId(xPlayers[i])

        table.insert(players, {
            id = xPlayer.source,
            name = GetPlayerName(xPlayer.source),
        })
    end

    cb(players)
end)

pbo.RegisterServerCallback('spectate:requestPlayerCoords', function(source, cb, target)
    local xPlayer = pbo.GetPlayerFromId(source)
    local coords = GetEntityCoords(GetPlayerPed(target))

    if xPlayer.getGroup() == 'user' then
        return
    end

    cb(coords)
end)
