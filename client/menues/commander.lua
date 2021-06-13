CommanderMenu = {}
CommanderMenu.GodMode = false
CommanderMenu.AllPlayerBlips = false
CommanderMenu.PlayersBlips = {}
CommanderMenu.PlayersBlipsAux = {}
CommanderMenu.Invisible = false
CommanderMenu.LastVehicleInvincible = nil
CommanderMenu.PlayerId = GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId()))

CommanderMenu.Main = function()

    if WarMenu.CheckBox('BLIPS de Jugadores: ', CommanderMenu.AllPlayerBlips) then
        CommanderMenu.AllPlayerBlips = not CommanderMenu.AllPlayerBlips
        if CommanderMenu.AllPlayerBlips then 
            NEX.UI.SendAlert('success', 'Player Blips', 'Enabled', 2000)
            CommanderMenu.GeneratePlayersBlip()
        else
            NEX.UI.SendAlert('error', 'Player Blips', 'Disabled', 2000)
        end
    end

    if WarMenu.CheckBox('Godmode: ', CommanderMenu.GodMode) then
        CommanderMenu.GodMode = not CommanderMenu.GodMode
        if CommanderMenu.GodMode then 
            NEX.UI.SendAlert('success', 'God Mode', 'Enabled', 2000)
            CommanderMenu.GodModeThreads() 
        else
            NEX.UI.SendAlert('error', 'God Mode', 'Disabled', 2000)
        end
    end

    if WarMenu.Button('Manage Clothes') then
        TriggerEvent('nex:Clothing:OpenClothingMenu', "clothesmenu")
        WarMenu.CloseMenu()
    end

    if WarMenu.Button('Manage Appearance') then
        TriggerEvent('nex:Clothing:OpenStartingMenu')
        WarMenu.CloseMenu()
    end

    if WarMenu.Button('Manage Outfits') then
        TriggerEvent('openOutfitsMenu', true)
        WarMenu.CloseMenu()
    end

    if IsPedInAnyVehicle(PlayerPedId(), false) then

        if WarMenu.Button('LSCustom') then
            TriggerEvent('nex:LSCustom:OpenRemoteMenu')
            WarMenu.CloseMenu()
        end

        if WarMenu.Button('Fix Vehicle') then
            local vehicle = GetVehiclePedIsUsing(PlayerPedId(), false)
            SetVehicleEngineHealth(vehicle, 100)
            SetVehicleEngineOn(vehicle, true, true)
            SetVehicleFixed(vehicle)
            NEX.UI.SendAlert('success', '¡Vehicle Fixed!', '', 1500,  {})
        end
    end

    WarMenu.End()
end

CommanderMenu.GodModeThreads = function()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5)

            if CommanderMenu.GodMode then
                local playerPed = PlayerPedId()
                SetPlayerInvincible(PlayerId(), true)

                if IsPedInAnyVehicle(playerPed, false) then
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    SetEntityInvincible(vehicle, true)
                    CommanderMenu.LastVehicleInvincible = vehicle
                else
                    if CommanderMenu.LastVehicleInvincible ~= nil and DoesEntityExist(CommanderMenu.LastVehicleInvincible) then
                        SetEntityInvincible(vehicle, false)
                        CommanderMenu.LastVehicleInvincible = nil
                    end
                end

            elseif not CommanderMenu.GodMode then
                SetPlayerInvincible(PlayerId(), false)
                if CommanderMenu.LastVehicleInvincible ~= nil and DoesEntityExist(CommanderMenu.LastVehicleInvincible) then
                    SetEntityInvincible(vehicle, false)
                    CommanderMenu.LastVehicleInvincible = nil
                end
                break
            end
        end
    end)
end

CommanderMenu.GeneratePlayersBlip = function()
    Citizen.CreateThread(function()
        while CommanderMenu.AllPlayerBlips do            
             NEX.TriggerServerCallback('nex:Admin:GetOnlinePlayers', function(playersData)
                for _, player in pairs(playersData) do
                    if CommanderMenu.PlayerId ~= player.id then
                        if CommanderMenu.PlayersBlips[player.id] == nil then
                            local playerBlip = AddBlipForCoord(player.playerCoords)
                            SetBlipSprite(playerBlip, 1)
                            Citizen.InvokeNative( 0x5FBCA48327B914DF, playerBlip, true)
                            SetBlipAsShortRange(playerBlip, false)
                            SetBlipColour(playerBlip, 60)
                            SetBlipScale(playerBlip, 1.1)

                            if Config.ShowPlayersName then
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentString(player.name .. " [".. player.dbId .."] (".. player.id ..")")
                                EndTextCommandSetBlipName(playerBlip)
                            end
                            
                            CommanderMenu.PlayersBlips[player.id] = playerBlip
                        else
                            SetBlipCoords(CommanderMenu.PlayersBlips[player.id], player.playerCoords)
                        end
                    end
                end
             end)
            Citizen.Wait(500)
        end

        for _, playerBlip in pairs(CommanderMenu.PlayersBlips) do
            if DoesBlipExist(playerBlip) then
                RemoveBlip(playerBlip)
            end
        end
        CommanderMenu.PlayersBlips = {}
    end)
end