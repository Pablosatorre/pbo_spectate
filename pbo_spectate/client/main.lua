PBO = nil
s = 0

Citizen.CreateThread(
    function()
        while PBO == nil do
            TriggerEvent(
                "esx:getSharedObject",
                function(obj)
                    PBO = obj
                end
            )
            Citizen.Wait(s)
        end
    end
)

local InSpectatorMode = false
local TargetSpectate = nil
local LastPosition = nil
local polarAngleDeg = 0
local azimuthAngleDeg = 90
local radius = 100.0
local cam = nil
local PlayerDate = {}
local ShowInfos = false
local group

function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
    local polarAngleRad = polarAngleDeg * math.pi / 180.0
    local azimuthAngleRad = azimuthAngleDeg * math.pi / 180.0

    local pos = {
        x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
        y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
        z = entityPosition.z - radius * math.cos(azimuthAngleRad)
    }

    return pos
end

function spectate(target)
    PBO.TriggerServerCallback(
        "esx:getPlayerData",
        function(player)
            if not InSpectatorMode then
                LastPosition = GetEntityCoords(GetPlayerPed(-1))
            end

            local playerPed = GetPlayerPed(-1)

            SetEntityCollision(playerPed, false, false)
            SetEntityVisible(playerPed, false)

            PlayerData = player
            if ShowInfos then
                SendNUIMessage(
                    {
                        type = "infos",
                        data = PlayerData
                    }
                )
            end

            Citizen.CreateThread(
                function()
                    if not DoesCamExist(cam) then
                        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                    end

                    SetCamActive(cam, true)
                    RenderScriptCams(true, false, 0, true, true)

                    InSpectatorMode = true
                    TargetSpectate = target
                end
            )
        end,
        target
    )
end

function resetNormalCamera()
    InSpectatorMode = false
    TargetSpectate = nil
    local playerPed = GetPlayerPed(-1)

    SetCamActive(cam, false)
    RenderScriptCams(false, false, 0, true, true)

    SetEntityCollision(playerPed, true, true)
    SetEntityVisible(playerPed, true)
    SetEntityCoords(playerPed, LastPosition.x, LastPosition.y, LastPosition.z)
end

function getPlayersList()
    local players = PBO.Game.GetPlayers()
    local data = {}

    for i = 1, #players, 1 do
        local _data = {
            id = GetPlayerServerId(players[i]),
            name = GetPlayerName(players[i])
        }
        table.insert(data, _data)
    end

    return data
end

function OpenAdminActionMenu(player)
    PBO.TriggerServerCallback(
        "pbo_spectate:getOtherPlayerData",
        function(data)
            local jobLabel = nil
            local sexLabel = nil
            local sex = nil
            local dobLabel = nil
            local heightLabel = nil
            local idLabel = nil
            local Money = 0
            local Bank = 0
            local blackMoney = 0
            local Inventory = nil

            for i = 1, #data.accounts, 1 do
                if data.accounts[i].name == "black_money" then
                    blackMoney = data.accounts[i].money
                end
            end

            if data.job.grade_label ~= nil and data.job.grade_label ~= "" then
                jobLabel = "Trabajo : " .. data.job.label .. " - " .. data.job.grade_label
            else
                jobLabel = "Trabajo : " .. data.job.label
            end

            if data.sex ~= nil then
                if (data.sex == "m") or (data.sex == "M") then
                    sex = "Hombre"
                else
                    sex = "Mujer"
                end
                sexLabel = "Sexo : " .. sex
            else
                sexLabel = "Sexo : Unknown"
            end

            if data.money ~= nil then
                Money = data.money
            else
                Money = "No Data"
            end

            if data.bank ~= nil then
                Bank = data.bank
            else
                Bank = "No Data"
            end

            if data.dob ~= nil then
                dobLabel = "DOB : " .. data.dob
            else
                dobLabel = "DOB : Unknown"
            end

            if data.height ~= nil then
                heightLabel = "Altura : " .. data.height
            else
                heightLabel = "Altura : Unknown"
            end

            if data.name ~= nil then
                idLabel = "Steam ID : " .. data.name
            else
                idLabel = "Steam ID : Unknown"
            end

            local elements = {
                {label = "Steam: " .. data.firstname .. " " .. data.lastname, value = nil},
                {label = "Dinero: " .. data.money, value = nil},
                {label = "Banco: " .. data.bank, value = nil},
                {label = "Dinero Negro: " .. blackMoney, value = nil, itemType = "item_account", amount = blackMoney},
                {label = jobLabel, value = nil},
                {label = idLabel, value = nil}
            }

            table.insert(elements, {label = "--- Inventario ---", value = nil})

            for i = 1, #data.inventory, 1 do
                if data.inventory[i].count > 0 then
                    table.insert(
                        elements,
                        {
                            label = data.inventory[i].label .. " x " .. data.inventory[i].count,
                            value = nil,
                            itemType = "item_standard",
                            amount = data.inventory[i].count
                        }
                    )
                end
            end

            table.insert(elements, {label = "--- Armas ---", value = nil})

            for i = 1, #data.weapons, 1 do
                table.insert(
                    elements,
                    {
                        label = PBO.GetWeaponLabel(data.weapons[i].name),
                        value = nil,
                        itemType = "item_weapon",
                        amount = data.ammo
                    }
                )
            end
            if data.licenses ~= nil then
                table.insert(elements, {label = "--- Licenses ---", value = nil})

                for i = 1, #data.licenses, 1 do
                    table.insert(elements, {label = data.licenses[i].label, value = nil})
                end
            end

            PBO.UI.Menu.Open(
                "default",
                GetCurrentResourceName(),
                "citizen_interaction",
                {
                    title = "Player Control",
                    align = "top-left",
                    elements = elements
                },
                function(data, menu)
                end,
                function(data, menu)
                    menu.close()
                end
            )
        end,
        GetPlayerServerId(player)
    )
end

RegisterKeyMapping("menuspectate", "Abre el Menu de Spectear (Only Staffs)", "keyboard", "F11")
RegisterCommand(
    "menuspectate",
    function(source)
        PBO.TriggerServerCallback('pbo_spectate:checkAdmin', function(x)
            if x == "admin" or x == "superadmin" or x == "soporte" then
                print("Spectate Abierto.")
                TriggerEvent("pbo_spectate:spectate")
            else
                PBO.ShowNotification('~r~No eres admin')
            end
        end)
    end
)

RegisterNetEvent("es_admin:setGroup")
AddEventHandler(
    "es_admin:setGroup",
    function(g)
        print("Admin puesto " .. g)
        group = g
    end
)

RegisterNetEvent("pbo_spectate:spectate")
AddEventHandler(
    "pbo_spectate:spectate",
    function()
        SetNuiFocus(true, true)

        SendNUIMessage(
            {
                type = "show",
                data = getPlayersList(),
                player = GetPlayerServerId(PlayerId())
            }
        )
    end
)

RegisterNUICallback(
    "select",
    function(data, cb)
        print("Jugador Seleccionado " .. json.encode(data))
        spectate(data.id)
        SetNuiFocus(false)
    end
)

RegisterNUICallback(
    "close",
    function(data, cb)
        print('Panel: ~b~cerrado')
        SetNuiFocus(false)
    end
)
RegisterNUICallback(
    "minimize",
    function(data, cb)
        print('Panel: ~b~minimizado')
        SetNuiFocus(false)
    end
)

RegisterNUICallback(
    "quit",
    function(data, cb)
        SetNuiFocus(false)
        resetNormalCamera()
    end
)

RegisterNUICallback(
    "kick",
    function(data, cb)
        SetNuiFocus(false)
        TriggerServerEvent("pbo_spectate:kick", data.id, data.reason)
        TriggerEvent("pbo_spectate:spectate")
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(s)

            if InSpectatorMode then
                local targetPlayerId = GetPlayerFromServerId(TargetSpectate)
                local playerPed = GetPlayerPed(-1)
                local targetPed = GetPlayerPed(targetPlayerId)
                local coords = GetEntityCoords(targetPed)

                for i = 0, 32, 1 do
                    if i ~= PlayerId() then
                        local otherPlayerPed = GetPlayerPed(i)
                        SetEntityNoCollisionEntity(playerPed, otherPlayerPed, true)
                        SetEntityVisible(playerPed, false)
                    end
                end

                if IsControlPressed(2, 241) then
                    radius = radius + 2.0
                end

                if IsControlPressed(2, 242) then
                    radius = radius - 2.0
                end

                if radius > -1 then
                    radius = -1
                end

                local xMagnitude = GetDisabledControlNormal(0, 1)
                local yMagnitude = GetDisabledControlNormal(0, 2)

                polarAngleDeg = polarAngleDeg + xMagnitude * 10

                if polarAngleDeg >= 360 then
                    polarAngleDeg = 0
                end

                azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10

                if azimuthAngleDeg >= 360 then
                    azimuthAngleDeg = 0
                end

                local nextCamLocation = polar3DToWorld3D(coords, radius, polarAngleDeg, azimuthAngleDeg)

                SetCamCoord(cam, nextCamLocation.x, nextCamLocation.y, nextCamLocation.z)
                PointCamAtEntity(cam, targetPed)
                SetEntityCoords(playerPed, coords.x, coords.y, coords.z + 10)

                if IsControlPressed(2, 47) then
                    OpenAdminActionMenu(targetPlayerId)
                end

                local text = {}
                -- Cheques de Hacks
                local targetGod = GetPlayerInvincible(targetPlayerId)
                if targetGod then
                    table.insert(text, "Godmode: ~r~Encontrado~w~")
                else
                    table.insert(text, "Godmode: ~g~No lleva Godmode.~w~")
                end
                if
                    not CanPedRagdoll(targetPed) and not IsPedInAnyVehicle(targetPed, false) and
                        (GetPedParachuteState(targetPed) == -1 or GetPedParachuteState(targetPed) == 0) and
                        not IsPedInParachuteFreeFall(targetPed)
                 then
                    table.insert(text, "~r~Anti-Ragdoll~w~")
                end
                -- Informacion de la Vida
                table.insert(text,"Vida" .. ": " .. GetEntityHealth(targetPed) .. "/" .. GetEntityMaxHealth(targetPed))
                table.insert(text, "Escudo" .. ": " .. GetPedArmour(targetPed))

                for i, theText in pairs(text) do
                    SetTextFont(0)
                    SetTextProportional(1)
                    SetTextScale(0.0, 0.30)
                    SetTextDropshadow(0, 0, 0, 0, 255)
                    SetTextEdge(1, 0, 0, 0, 255)
                    SetTextDropShadow()
                    SetTextOutline()
                    SetTextEntry("STRING")
                    AddTextComponentString(theText)
                    EndTextCommandDisplayText(0.3, 0.7 + (i / 30))
                end
            end
        end
    end
)
