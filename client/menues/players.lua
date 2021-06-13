PlayersMenu = {}
PlayersMenu.currentPlayer = nil
PlayersMenu.myPlayer = nil
PlayersMenu.OnlinePlayers = {}
PlayersMenu.myIdentity = NetworkGetEntityOwner(PlayerPedId())
PlayersMenu.integrityPlayer = nil

PlayersMenu.ProccessOnlinePlayers = function()
    PlayersMenu.OnlinePlayers = {}
    NEX.TriggerServerCallback('nex:Admin:GetOnlinePlayers', function(playersOnline)
        for k, player in pairs(serverPlayersOnline) do
            
            local pId = NetworkGetEntityOwner(GetPlayerPed(player))
            local playerId = GetPlayerServerId(player)

            if player == PlayersMenu.myIdentity then
                PlayersMenu.myPlayer = player
            end

            for _, sPlayer in pairs(playersOnline) do
                if sPlayer.id == player then
                    PlayersMenu.OnlinePlayers[player] = {
                        ped = GetPlayerPed(player),
                        name = sPlayer.name,
                        id = player,
                        serverId = player,
                        dbId = sPlayer.dbId,
                        charId = sPlayer.charId,
                        isFreeze = sPlayer.isFreeze,
                    }
                end
            end
        end

        table.sort(PlayersMenu.OnlinePlayers, function(a, b)
            return a.serverId < b.serverId
        end)
    end)
end

PlayersMenu.Main = function()
    local players = PlayersMenu.OnlinePlayers
    local me = PlayersMenu.OnlinePlayers[PlayersMenu.myPlayer]

    if me ~= nil then
        if WarMenu.MenuButton("[YO] [".. me.dbId .."] (".. me.charId ..") " .. me.serverId .." | ".. me.name, "nexadmin_players_inspect") then
            PlayersMenu.currentPlayer = PlayersMenu.myPlayer
        end
    end

    WarMenu.MenuButton('[📛] Punish Player', 'nexadmin_players_punishments')

    if WarMenu.Button('[📛] Generar código CK') then
        NEX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'nex_ck_generator', {
            title = "Ingrese el CharId del jugador:"
        }, function(menuData, dialogHandle)
            local targetCharId = tonumber(menuData.value)
        
            if targetCharId > 0 then

                NEX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'nex_ck_generator_reason', {
                    title = "Especifique la razón, deje constancía del TicketID, nombres y descripción:"
                }, function(menuData2, dialogHandle2)
                    local reason = tostring(menuData2.value)

                    if string.len(reason) > 15 then
                        NEX.TriggerServerCallback('nex:Admin:GenerateCKCode', function(response, code)
                            if response then
                                TriggerEvent('nex:Core:showNotification', '~g~¡Código generado!')
                                NEX.UI.SendAlert('success', 'CK Generado', 'El código se ha genrado: #<b style="color:yellow;">'.. code ..'</b>', 12000)
                            else
                                NEX.UI.SendAlert('error', 'CK', 'El código no pudo ser generado.')
                            end
                        end, targetCharId, reason)
                        dialogHandle2.close()
                    else
                        NEX.UI.SendAlert('error', 'CK', 'Entregue más información de este código.')
                    end
                    
                end, function(menuData2, dialogHandle2)
                    dialogHandle2.close()
                end)

            else
                TriggerEvent('nex:Core:showNotification', "~r~El ID debe ser válido.")
            end

            dialogHandle.close()
        end, function(menuData, dialogHandle)
            dialogHandle.close()
        end)
    end

    WarMenu.Button('——————————————————')

    for k, v in pairs(players) do
        if WarMenu.MenuButton(v.serverId .." | (".. v.charId ..") |" .. "[".. v.dbId .."] | ".. v.name, "nexadmin_players_inspect") then
            PlayersMenu.currentPlayer = k
        end
    end

    WarMenu.End()
end

PlayersMenu.DoPunishmentsDialog = function(method)
    NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ban_target_dialog', {
        title = ('Introduzca el identificador ('.. method ..'):'),
        value = ""
    }, function(data, menu)
        target = tostring(data.value)
        if string.len(target) < 1 then
            return NEX.ShowNotification('~r~Objetivo no válido.')
        end

        NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ban_reason_dialog', {
            title = ('RAZÓN DEL BAN'),
            value = ""
        }, function(data2, menu2)
            reason = tostring(data2.value)
            if string.len(reason) < 3 then
                return NEX.ShowNotification('~r~La razón no es válida.')
            end

            TriggerServerEvent('nex:Admin:ExecutePunishment', target, reason, method)
            menu2.close()
            
        end, function(data2, menu2)
            menu2.close()
        end)
        menu.close()
        
    end, function(data, menu)
        menu.close()
    end)

    
end

PlayersMenu.DoPunishments = function()

    if WarMenu.Button('[❌] Banear por Licencia') then
        PlayersMenu.DoPunishmentsDialog("license")
    -- elseif WarMenu.Button('[❌] Banear por SteamID') then
    --     PlayersMenu.DoPunishmentsDialog("steam")
    elseif WarMenu.Button('[❌] Banear por DB ID') then
        PlayersMenu.DoPunishmentsDialog("db")
    elseif WarMenu.Button('[❌] Banear por Game ID') then
        PlayersMenu.DoPunishmentsDialog("id")
    end

    WarMenu.End()
end

PlayersMenu.PlayerIntegrity = function()
    local playerData = PlayersMenu.OnlinePlayers[PlayersMenu.currentPlayer]

    if PlayersMenu.integrityPlayer ~= nil then
        if WarMenu.Button('Nombre:', PlayersMenu.integrityPlayer.firstname.." "..PlayersMenu.integrityPlayer.lastname) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_firstname', {
                title = ('INGRESA EL NOMBRE:'),
                value = PlayersMenu.integrityPlayer.firstname
            }, function(data, menu)
                name = tostring(data.value)
                if name == nil or name == "" then
                    NEX.ShowNotification('Nombre Inválido')
                else
                    if string.len(name) >= 4 then
                        PlayersMenu.integrityPlayer.firstname = name
                        menu.close()
                        NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_lastname', {
                            title = ('INGRESA EL APELLIDO:'),
                            value = PlayersMenu.integrityPlayer.lastname
                        }, function(data2, menu2)
                            lname = tostring(data2.value)
                            if lname == nil or lname == "" then
                                return NEX.ShowNotification('Apellido Inválido')
                            end

                            PlayersMenu.integrityPlayer.lastname = lname
                            menu2.close()
                            
                        end, function(data2, menu2)
                            menu2.close()
                        end)
                    else
                        return NEX.ShowNotification('Ingresa un nombre válido.')
                    end
                end
            end, function(data, menu)
                menu.close()
            end)
        end

        if WarMenu.Button('Fecha Nacimiento:', PlayersMenu.integrityPlayer.dob) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_dob', {
                title = ('FECHA NACIMIENTO: (Formato: dd-mm-yyyy'),
                value = PlayersMenu.integrityPlayer.dob
            }, function(data2, menu2)
                dob = tostring(data2.value)
                if dob == nil or dob == "" or not string.match(dob, "-") then
                    return NEX.ShowNotification('Fecha Inválida')
                end

                PlayersMenu.integrityPlayer.dob = dob
                menu2.close()
                
            end, function(data2, menu2)
                menu2.close()
            end)
        end

        if WarMenu.Button('Modelo (sexo):', PlayersMenu.integrityPlayer.sex) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_sex', {
                title = ('SEXO: (Formato: "f": Femenino | "m": Masculino'),
                value = PlayersMenu.integrityPlayer.sex
            }, function(data, menu)
                sex = tostring(data.value)
                if sex ~= "f" or sex ~= "m" then
                    return NEX.ShowNotification('Sexo Inválido')
                end

                PlayersMenu.integrityPlayer.sex = sex
                menu.close()
                
            end, function(data, menu)
                menu.close()
            end)
        end

        if WarMenu.Button('Altura:', PlayersMenu.integrityPlayer.height) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_hei', {
                title = ('ALTURA: (Formato: centímetros)'),
                value = PlayersMenu.integrityPlayer.height
            }, function(data, menu)
                hei = tonumber(data.value)
                if hei and hei < 150 and hei > 200 then
                    return NEX.ShowNotification('Altura Inválida')
                end

                PlayersMenu.integrityPlayer.height = hei
                menu.close()
                
            end, function(data, menu)
                menu.close()
            end)
        end

        WarMenu.Button('~y~OPCIONES AVANZADAS')
        if WarMenu.Button('Establecer VIP', PlayersMenu.integrityPlayer.vip) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_vip', {
                title = ('VIP: (Formato: 0 a 6)'),
                value = PlayersMenu.integrityPlayer.vip
            }, function(data, menu)
                vip = tonumber(data.value)
                if hei and vip < 0 and vip > 6 then
                    return NEX.ShowNotification('VIP Inválido')
                end

                PlayersMenu.integrityPlayer.vip = vip
                menu.close()
                
            end, function(data, menu)
                menu.close()
            end)
        end

        if WarMenu.Button('Desbloquear Personajes', PlayersMenu.integrityPlayer.unlocked) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_unlocked', {
                title = ('VIP: (Formato: 0 a 4)'),
                value = PlayersMenu.integrityPlayer.unlocked
            }, function(data, menu)
                unl = tonumber(data.value)
                if unl and unl < 0 and unl > 4 then
                    return NEX.ShowNotification('Monto Inválido')
                end

                PlayersMenu.integrityPlayer.unlocked = unl
                menu.close()
                
            end, function(data, menu)
                menu.close()
            end)
        end

        if WarMenu.Button('[✅] ~g~GUARDAR CAMBIOS') then
            NEX.TriggerServerCallback('nex:Admin:ChangeGameData', function(result)
                if result then
                    print("Successfully player saved.")
                end
            end, playerData.serverId, PlayersMenu.integrityPlayer)
        end

    else
        WarMenu.Button('== [❌] ERROR AL CARGAR')
    end

    --TODO 
    -- => Change custom data like phone number
    -- => 

    WarMenu.Display()
end

PlayersMenu.PlayersOptions = function()

    local playerData = PlayersMenu.OnlinePlayers[PlayersMenu.currentPlayer]

    WarMenu.Button('[💠] IDENTIFICADORES')

    if WarMenu.IsItemHovered() then
        WarMenu.ToolTip('DB: ' .. playerData.dbId .. "\nCharId: " .. playerData.charId ..'\nServerId: '..playerData.serverId)
    end

    if WarMenu.MenuButton('[🔰] Gestión de integridad', 'nexadmin_player_integrity') then
        NEX.TriggerServerCallback('nex:Admin:GetGameData', function(gameData)
            PlayersMenu.integrityPlayer = gameData
        end, playerData.serverId)
    end
    

    -- if WarMenu.MenuButton('[💰] Gestor economico') then
    -- end

    -- if WarMenu.MenuButton('[🚘] Gestor vehícular') then
    -- end

    -- if WarMenu.MenuButton('[🧍🏽‍♂️] Gestor Outift') then
    -- end

    WarMenu.Button('------------ [ OPCIONES ] ------------')

    if WarMenu.Button("Solicitar Screenshot:") then
        TriggerServerEvent('nex:Admin:Reports:RequetsPlayerScreenshot', playerData.serverId)
        NEX.UI.SendAlert('inform', 'Staff Action', 'Estamos procesando la solicitud...', 4000, {})
        WarMenu.CloseMenu()
    end
    if WarMenu.IsItemHovered() then
        WarMenu.ToolTip('Envia una imagen de la pantalla del jugador al registro del discord.')
    end

    if WarMenu.CheckBox("Congelar:", playerData.isFreeze) then
        playerData.isFreeze = not playerData.isFreeze
        TriggerServerEvent("nex:Admin:ToggleFreeze", playerData.serverId, playerData.isFreeze)
    end

    WarMenu.Button('------------ [ SANCIONES ] ------------')

    SetTextEntryToFunction('Ingrese su motivo de expulsión:')
    local pressed, inputTextKick = WarMenu.InputButton('[🚨] Expulsar Jugador', "FMMC_MPM_NA")
    if pressed then
        if inputTextKick and string.len(inputTextKick) > 3 then
            NEX.TriggerServerCallback('nex:Admin:RegisterNewPunish', function(success)
                if success then
                    NEX.UI.SendAlert('success', '¡Sanción ejecutada!', '', 5000, {})
                else
                    NEX.UI.SendAlert('error', '¡Whoops! 🔴 No autorizado.', '', 5000, {})
                end
            end, "KICK", playerData.serverId, inputTextKick, nil, false)
        end
    end

    SetTextEntryToFunction('Ingrese su motivo de advertencia:')
    local pressed, inputText = WarMenu.InputButton('[🚨] Advertir jugador', "FMMC_MPM_NA")
    
    if pressed then
        if inputText and string.len(inputText) > 3 then
            NEX.TriggerServerCallback('nex:Admin:RegisterNewPunish', function(success)
                if success then
                    NEX.UI.SendAlert('success', '¡Sanción ejecutada!', '', 5000, {})
                else
                    NEX.UI.SendAlert('error', '¡Whoops! 🔴 No autorizado.', '', 5000, {})
                end
            end, "WARN", playerData.serverId, inputText, nil, false)
        end
    end

    SetTextEntryToFunction('Ingrese su motivo de baneo:')
    local pressed, inputText = WarMenu.InputButton('[🚨] Banear jugador', "FMMC_MPM_NA")
    
    if pressed then
        if inputText and string.len(inputText) > 3 then
            NEX.TriggerServerCallback('nex:Admin:RegisterNewPunish', function(success)
                if success then
                    NEX.UI.SendAlert('success', '¡Sanción ejecutada!', '', 5000, {})
                else
                    NEX.UI.SendAlert('error', '¡Whoops! 🔴 No autorizado.', '', 5000, {})
                end
            end, "BAN", playerData.serverId, inputText, nil, false)
        end
    end

    -- TODO
    -- if WarMenu.MenuButton("Give Clothing Menu", PlayersMenu.currentPlayer) then
    --     
    -- end
    -- if WarMenu.MenuButton("Open Inventory", PlayersMenu.currentPlayer) then
    --     
    -- end

    WarMenu.Display()
end