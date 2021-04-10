PlayersMenu = {}
PlayersMenu.currentPlayer = nil
PlayersMenu.myPlayer = nil
PlayersMenu.OnlinePlayers = {}
PlayersMenu.myIdentity = NetworkGetEntityOwner(PlayerPedId())
PlayersMenu.integrityPlayer = nil

PlayersMenu.ProccessOnlinePlayers = function()
    PlayersMenu.OnlinePlayers = {}
    NEX.TriggerServerCallback('nex:Admin:GetOnlinePlayers', function(playersOnline)
        for k, player in pairs(GetActivePlayers()) do
            local playerId = GetPlayerServerId(player)
            if player == PlayersMenu.myIdentity then
                PlayersMenu.myPlayer = player
            end

            for _, sPlayer in pairs(playersOnline) do
                if sPlayer.id == playerId then
                    PlayersMenu.OnlinePlayers[player] = {
                        ped = GetPlayerPed(player),
                        name = sPlayer.name,
                        id = player,
                        serverId = playerId,
                        dbId = sPlayer.dbId,
                        charId = sPlayer.charId,
                        isFreeze = sPlayer.isFreeze
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
        if WarMenu.MenuButton("[ME] [".. me.dbId .."] (".. me.charId ..") " .. me.serverId .." | ".. me.name, "nexadmin_players_inspect") then
            PlayersMenu.currentPlayer = PlayersMenu.myPlayer
        end
    end

    WarMenu.MenuButton('[📛] Punish Player', 'nexadmin_players_punishments')

    -- if WarMenu.Button('[📛] Sanciones') then
    --     TriggerEvent("nex:Admin:ShowPADInterface", "punishlist")
    --     WarMenu.CloseMenu()
    -- end

    if WarMenu.Button('[📛] Generate CK code') then
        NEX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'nex_ck_generator', {
            title = "Enter the player's CharId:"
        }, function(menuData, dialogHandle)
            local targetCharId = tonumber(menuData.value)
        
            if targetCharId > 0 then

                NEX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'nex_ck_generator_reason', {
                    title = "Specify the reason, state the TicketID, names and description:"
                }, function(menuData2, dialogHandle2)
                    local reason = tostring(menuData2.value)

                    if string.len(reason) > 15 then
                        NEX.TriggerServerCallback('nex:Admin:GenerateCKCode', function(response, code)
                            if response then
                                TriggerEvent('nex:Core:showNotification', '~g~Generated code!')
                                NEX.UI.SendAlert('success', 'CK Generated', 'The code has been generated: #<b style="color:yellow;">'.. code ..'</b>', 12000)
                            else
                                NEX.UI.SendAlert('error', 'CK', 'The code could not be generated.')
                            end
                        end, targetCharId, reason)
                        dialogHandle2.close()
                    else
                        NEX.UI.SendAlert('error', 'CK', 'Give more information about this code.')
                    end
                    
                end, function(menuData2, dialogHandle2)
                    dialogHandle2.close()
                end)

            else
                TriggerEvent('nex:Core:showNotification', "~r~ID must be valid.")
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
        title = ('Enter the identifier ('.. method ..'):'),
        value = ""
    }, function(data, menu)
        target = tostring(data.value)
        if string.len(target) < 1 then
            return NEX.ShowNotification('~r~Invalid target.')
        end

        NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ban_reason_dialog', {
            title = ('REASON FOR BAN'),
            value = ""
        }, function(data2, menu2)
            reason = tostring(data2.value)
            if string.len(reason) < 3 then
                return NEX.ShowNotification('~r~The reason is not valid.')
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

    if WarMenu.Button('[❌] Ban by license') then
        PlayersMenu.DoPunishmentsDialog("license")
    -- elseif WarMenu.Button('[❌] Banear por SteamID') then
    --     PlayersMenu.DoPunishmentsDialog("steam")
    elseif WarMenu.Button('[❌] Ban by DB ID') then
        PlayersMenu.DoPunishmentsDialog("db")
    elseif WarMenu.Button('[❌] Ban by Game ID') then
        PlayersMenu.DoPunishmentsDialog("id")
    end

    WarMenu.End()
end

PlayersMenu.PlayerIntegrity = function()
    local playerData = PlayersMenu.OnlinePlayers[PlayersMenu.currentPlayer]

    if PlayersMenu.integrityPlayer ~= nil then
        if WarMenu.Button('Surname:', PlayersMenu.integrityPlayer.firstname.." "..PlayersMenu.integrityPlayer.lastname) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_firstname', {
                title = ('ENTER THE NAME:'),
                value = PlayersMenu.integrityPlayer.firstname
            }, function(data, menu)
                name = tostring(data.value)
                if name == nil or name == "" then
                    NEX.ShowNotification('Invalid name')
                else
                    if string.len(name) >= 4 then
                        PlayersMenu.integrityPlayer.firstname = name
                        menu.close()
                        NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_lastname', {
                            title = ('ENTER LAST NAME:'),
                            value = PlayersMenu.integrityPlayer.lastname
                        }, function(data2, menu2)
                            lname = tostring(data2.value)
                            if lname == nil or lname == "" then
                                return NEX.ShowNotification('Invalid Last Name')
                            end

                            PlayersMenu.integrityPlayer.lastname = lname
                            menu2.close()
                            
                        end, function(data2, menu2)
                            menu2.close()
                        end)
                    else
                        return NEX.ShowNotification('Please enter a valid name.')
                    end
                end
            end, function(data, menu)
                menu.close()
            end)
        end

        if WarMenu.Button('Birth date:', PlayersMenu.integrityPlayer.dob) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_dob', {
                title = ('Birth date: (Format: dd-mm-yyyy'),
                value = PlayersMenu.integrityPlayer.dob
            }, function(data2, menu2)
                dob = tostring(data2.value)
                if dob == nil or dob == "" or not string.match(dob, "-") then
                    return NEX.ShowNotification('Invalid Date')
                end

                PlayersMenu.integrityPlayer.dob = dob
                menu2.close()
                
            end, function(data2, menu2)
                menu2.close()
            end)
        end

        if WarMenu.Button('Model (gender):', PlayersMenu.integrityPlayer.sex) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_sex', {
                title = ('SEX: (Format: "f": Female | "m": Male'),
                value = PlayersMenu.integrityPlayer.sex
            }, function(data, menu)
                sex = tostring(data.value)
                if sex ~= "f" or sex ~= "m" then
                    return NEX.ShowNotification('Sex Invalid')
                end

                PlayersMenu.integrityPlayer.sex = sex
                menu.close()
                
            end, function(data, menu)
                menu.close()
            end)
        end

        if WarMenu.Button('Height:', PlayersMenu.integrityPlayer.height) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_hei', {
                title = ('Height: (Format: centimeters)'),
                value = PlayersMenu.integrityPlayer.height
            }, function(data, menu)
                hei = tonumber(data.value)
                if hei and hei < 150 and hei > 200 then
                    return NEX.ShowNotification('Height Invalid')
                end

                PlayersMenu.integrityPlayer.height = hei
                menu.close()
                
            end, function(data, menu)
                menu.close()
            end)
        end

        WarMenu.Button('~y~ADVANCED OPTIONS')
        if WarMenu.Button('Set VIP', PlayersMenu.integrityPlayer.vip) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_vip', {
                title = ('VIP: (Format: 0 to 6)'),
                value = PlayersMenu.integrityPlayer.vip
            }, function(data, menu)
                vip = tonumber(data.value)
                if hei and vip < 0 and vip > 6 then
                    return NEX.ShowNotification('VIP Invalid')
                end

                PlayersMenu.integrityPlayer.vip = vip
                menu.close()
                
            end, function(data, menu)
                menu.close()
            end)
        end

        if WarMenu.Button('Unlock characters', PlayersMenu.integrityPlayer.unlocked) then
            NEX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'change_unlocked', {
                title = ('VIP: (Format: 0 to 4)'),
                value = PlayersMenu.integrityPlayer.unlocked
            }, function(data, menu)
                unl = tonumber(data.value)
                if unl and unl < 0 and unl > 4 then
                    return NEX.ShowNotification('Invalid Amount')
                end

                PlayersMenu.integrityPlayer.unlocked = unl
                menu.close()
                
            end, function(data, menu)
                menu.close()
            end)
        end

        if WarMenu.Button('[✅] ~g~SAVE CHANGES') then
            NEX.TriggerServerCallback('nex:Admin:ChangeGameData', function(result)
                if result then
                    print("Player successfully saved.")
                end
            end, playerData.serverId, PlayersMenu.integrityPlayer)
        end

    else
        WarMenu.Button('== [❌] ERROR WHEN LOADING')
    end

    --TODO 
    -- => Change custom data like phone number
    -- => 

    WarMenu.Display()
end

PlayersMenu.PlayersOptions = function()

    local playerData = PlayersMenu.OnlinePlayers[PlayersMenu.currentPlayer]

    WarMenu.Button('[💠] IDENTIFIERS')

    if WarMenu.IsItemHovered() then
        WarMenu.ToolTip('DB: ' .. playerData.dbId .. "\nCharId: " .. playerData.charId ..'\nServerId: '..playerData.serverId)
    end

    if WarMenu.MenuButton('[🔰] Integrity management', 'nexadmin_player_integrity') then
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

    WarMenu.Button('------------ [ Options ] ------------')

    if WarMenu.Button("Request screenshot:") then
        TriggerServerEvent('nex:Admin:Reports:RequetsPlayerScreenshot', playerData.serverId)
        NEX.UI.SendAlert('inform', 'Staff Action', 'We are processing the request...', 4000, {})
        WarMenu.CloseMenu()
    end
    if WarMenu.IsItemHovered() then
        WarMenu.ToolTip('Send an image of the players screen to the discord registry.')
    end

    if WarMenu.CheckBox("Freeze:", playerData.isFreeze) then
        playerData.isFreeze = not playerData.isFreeze
        TriggerServerEvent("nex:Admin:ToggleFreeze", playerData.serverId, playerData.isFreeze)
    end

    WarMenu.Button('------------ [ SANCTIONS ] ------------')

    SetTextEntryToFunction('Enter your reason for expulsion:')
    local pressed, inputTextKick = WarMenu.InputButton('[🚨] Eject Player', "FMMC_MPM_NA")
    if pressed then
        if inputTextKick and string.len(inputTextKick) > 3 then
            NEX.TriggerServerCallback('nex:Admin:RegisterNewPunish', function(success)
                if success then
                    NEX.UI.SendAlert('success', 'Sanction executed!', '', 5000, {})
                else
                    NEX.UI.SendAlert('error', 'Whoops! 🔴 Not authorized.', '', 5000, {})
                end
            end, "KICK", playerData.serverId, inputTextKick, nil, false)
        end
    end

    SetTextEntryToFunction('Enter your reason for warning:')
    local pressed, inputText = WarMenu.InputButton('[🚨] Warning player', "FMMC_MPM_NA")
    
    if pressed then
        if inputText and string.len(inputText) > 3 then
            NEX.TriggerServerCallback('nex:Admin:RegisterNewPunish', function(success)
                if success then
                    NEX.UI.SendAlert('success', 'Sanction executed!', '', 5000, {})
                else
                    NEX.UI.SendAlert('error', 'Whoops! 🔴 Not authorized.', '', 5000, {})
                end
            end, "WARN", playerData.serverId, inputText, nil, false)
        end
    end

    SetTextEntryToFunction('Enter your ban reason:')
    local pressed, inputText = WarMenu.InputButton('[🚨] Ban player', "FMMC_MPM_NA")
    
    if pressed then
        if inputText and string.len(inputText) > 3 then
            NEX.TriggerServerCallback('nex:Admin:RegisterNewPunish', function(success)
                if success then
                    NEX.UI.SendAlert('success', 'Sanction executed!', '', 5000, {})
                else
                    NEX.UI.SendAlert('error', 'Whoops! 🔴 Not authorized.', '', 5000, {})
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