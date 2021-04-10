NEX = nil
FreezePlayers = {}


Citizen.CreateThread(function()
    
    while NEX == nil do 
        TriggerEvent('nexus:getNexusObject', function(obj) NEX = obj end)
        Citizen.Wait(100)
    end

    NEX.RegisterCommand('adminpad', 'admin', function(xPlayer, args, showError)
        
        if not args.refresh then
            -- WIP | Open Admin Pad
        else
            NADMIN.refreshNameCache()
            NADMIN.refreshBanCache()
            local data = {
                type = "success",
                title = "Systems Refreshed!",
                text = "Systems have been successfully refreshed.",
                length = 4000,
                style = {}
            }
            xPlayer.sendAlert(data)
        end 

        if cmd == nil then
            
        elseif cmd == "refresh" then
            
        end
    end, false, {help = "Administration PAD", validate = false, arguments = {
        {name = 'refresh', help = "Use 'refresh' to refresh the sanctions list.", type = 'any'},
    }})

    NEX.RegisterCommand('reports', 'admin', function(xPlayer, args, showError)
        TriggerClientEvent("nex:Admin:Reports:ShowPanel", xPlayer.source)
    end, false, {help = "Administration PAD", validate = true, arguments = {}})


    NEX.RegisterCommand('goto', 'admin', function(xPlayer, args, showError)
        
        local coords = args.playerId.getCoords()
        xPlayer.setCoords(coords, 0)

    end, false, {help = "Go to a player", validate = true, arguments = {
        {name = 'playerId', help = "Player ID to teleport to.", type = 'player'},
    }})

    NEX.RegisterCommand('bring', 'admin', function(xPlayer, args, showError)
        
        local coords = xPlayer.getCoords()
        args.playerId.setCoords(coords, 0)

    end, false, {help = "Go to a player", validate = true, arguments = {
        {name = 'playerId', help = "Player ID to teleport.", type = 'player'},
    }})


    --[[ CALLBACKS ]]

    NEX.RegisterServerCallback('nex:Admin:GetGameData', function(source, cb, playerId)
        local xTarget = NEX.GetPlayerFromId(playerId)
        local xPlayer = NEX.GetPlayerFromId(source)
        if xTarget then

            local data = {
                firstname = xTarget.getGameData().getFirstname(),
                lastname = xTarget.getGameData().getLastname(),
                dob = xTarget.getGameData().getDob().getFullDate(),
                sex = xTarget.getGameData().getSex(),
                height = xTarget.getGameData().getHeight(),
                vip = xTarget.getVip(),
                unlocked = xTarget.getUnlockedCharacters()
            }

            cb(data)
        else
            xPlayer.sendAlert({
                type = "error",
                title = "Whoops",
                text = "This player is no longer available.",
                length = 4000,
                style = {}
            })

            cb({})
        end
    end)

    NEX.RegisterServerCallback('nex:Admin:CheckAuth', function(source, cb)
        local xPlayer = NEX.GetPlayerFromId(source)
        if xPlayer and xPlayer.getGroup() == "admin" then
            cb(true)
        else 
            cb(false)
        end
    end)

    NEX.RegisterServerCallback('nex:Admin:ChangeGameData', function(source, cb, playerId, gameData)
        local xTarget = NEX.GetPlayerFromId(playerId)
        local xPlayer = NEX.GetPlayerFromId(source)
        if xTarget then
            local oldData = {
                firstname = xTarget.getGameData().getFirstname(),
                lastname = xTarget.getGameData().getLastname(),
                dob = xTarget.getGameData().getDob().getFullDate(),
                sex = xTarget.getGameData().getSex(),
                height = xTarget.getGameData().getHeight(),
                vip = xTarget.getVip(),
                unlocked = xTarget.getUnlockedCharacters()
            }

            xTarget.setGameData().setFirstname(gameData.firstname or xTarget.getGameData().getFirstname())
            xTarget.setGameData().setLastname(gameData.lastname or xTarget.getGameData().getLastname())
            xTarget.setGameData().setDob(gameData.dob or xTarget.getGameData().getDob().getFullDate())
            xTarget.setGameData().setHeight(gameData.height or xTarget.getGameData().getDob().getHeight())
            xTarget.setVIP(gameData.vip or xTarget.getVip())
            xTarget.setUnlockedCharacters(gameData.unlocked or xTarget.getUnlockedCharacters()) 

            NEX.SavePlayer(xTarget)

            xTarget.sendAlert({
                type = "success",
                title = "Updated Integrity",
                text = "The member "..xPlayer.getName().." [".. xPlayer.dbId .."] has updated your character integrity #".. xTarget.charId ..".",
                length = 8000,
                style = {}
            })

            xPlayer.sendAlert({
                type = "success",
                title = "Updated integrity",
                text = "You have changed the integrity of the player.",
                length = 4000,
                style = {}
            })

            NEX.RegisterLog(xPlayer.source, "PLAYER", "Updated player integrity " .. xTarget.getName() .. " [".. xTarget.dbId .."] (".. xTarget.charId ..") Before: ".. json.encode(oldData) .."\nNow: " .. json.encode(gameData))
            
            cb(true)
        else
            xPlayer.sendAlert({
                type = "error",
                title = "Whoops",
                text = "This player is no longer available.",
                length = 4000,
                style = {}
            })
            cb(false)
        end
    end)

    NEX.RegisterServerCallback('nex:Admin:GenerateCKCode', function(source, cb, charId, reason)
        local xPlayer = NEX.GetPlayerFromId(source)

        if xPlayer.getGroup() == "admin" then
            local code = math.random(10000, 99999)
            MySQL.Async.fetchAll("SELECT characterId, identifier FROM users_characters WHERE characterId = @charId", {
                ['@charId'] = charId
            }, function(result)
                if result[1] ~= nil then
                    MySQL.Async.execute('INSERT INTO nexus_ck (identifier, code, reason, charId, `by`) VALUES (@identifier, @code, @reason, @charId, @by)', {
                        ['@identifier'] = result[1].identifier,
                        ['@code'] = code,
                        ['@reason'] = reason,
                        ['@charId'] = charId,
                        ['@by'] = xPlayer.identifier
                    })
                    return cb(true, code)
                else
                    return cb(false)
                end
            end)
        end
    end)

    NEX.RegisterServerCallback('nex:Admin:getListData', function(source, cb, list, page)
        local xPlayer = NEX.GetPlayerFromId(source)
        if xPlayer.getGroup() == "admin" then
            local punishlist = {}
            for k,v in ipairs(MySQL.Sync.fetchAll("SELECT * FROM nexus_punishments LIMIT @limit OFFSET @offset",{["@limit"]=Config.page_element_limit,["@offset"]=Config.page_element_limit*(page-1)})) do
                punish["target_name"] = namecache[json.decode(punish.target)[1]]
                punish["by_name"] = namecache[punish.punisher] or "NAC"
               
                table.insert(banlist,v)
            end
            cb(json.encode(punishlist))
        end
    end)

    NEX.RegisterServerCallback('nex:Admin:GetOnlinePlayers', function(source, cb)
        local xPlayers = NEX.GetPlayers()
        local players = {}

        for i=1, #xPlayers, 1 do
            local xPlayer = NEX.GetPlayerFromId(xPlayers[i])
            local data = {
                name        = xPlayer.getName(),
                id          = xPlayer.source,
                dbId        = xPlayer.dbId,
                charId      = xPlayer.charId,
                isFreeze    = FreezePlayers[xPlayer.source] or false
            }

            table.insert(players, data)
        end

        cb(players)
    end)

    NEX.RegisterServerCallback('nex:Admin:RegisterNewPunish', function(source, cb, type, target, reason, length, isOffline)
        cb(NADMIN.RegisterNewPunish(source, type, target, reason, length, isOffline))
    end)

    NEX.RegisterServerCallback('nex:Admin:GetPunishList', function(source, cb)
        local xPlayer = NEX.GetPlayerFromId(source)
        if NADMIN.IsAdmin(xPlayer) then
            local punishList = {}
            
            for _, punish in ipairs(MySQL.Sync.fetchAll("SELECT * FROM nexus_punishments LIMIT @limit", {
                ["@limit"] = Config.PerPageLimit}
            )) do
                punish["target_name"] = namecache[punish.target]
                punish["by_name"] = namecache[punish.punisher] or "NAC"

                table.insert(punishList, punish)
            end
            local result = MySQL.Sync.fetchScalar("SELECT CEIL(COUNT(id)/@limit) FROM nexus_punishments",{["@limit"] = Config.PerPageLimit})
            cb(json.encode(punishList), result)
        end
    end)

   
    NEX.RegisterServerCallback("nex:Admin:UnbanPlayer",function(source,cb, id, appealed)
        local xPlayer = NEX.GetPlayerFromId(source)
        if NADMIN.isAdmin(xPlayer) then
            MySQL.Async.execute("UPDATE nexus_punishments SET unbanned=1, appealed = @appeal WHERE id=@id",{
                ["@id"]=id,
                ['@appeal']=appealed
            },function(rc)
                local bannedidentifier = "NAC"
                for k,v in ipairs(bancache) do
                    if v.id==id then
                        bannedidentifier = v.receiver[1]
                        bancache[k].unbanned = true
                        break
                    end
                end

                NADMIN.refreshNameCache()
                NADMIN.refreshBanCache()
                
                NADMIN.LogToAdmins(("Staff ^1%s^7 unbalance ^1%s^7 (%s)"):format(xPlayer.getName(),(bannedidentifier~="NAC" and namecache[bannedidentifier]) and namecache[bannedidentifier] or "A stranger",bannedidentifier))
                cb(rc>0)
            end)
        end
    end)

    MySQL.ready(function()
        NADMIN.refreshNameCache()
        NADMIN.refreshBanCache()
    end)

end)

AddEventHandler("playerConnecting",function(name, setKick, def)
    def.defer()

    local identifiers = GetPlayerIdentifiers(source)
    local _source = source
    def.update("Starting connection to server ... \nIf you do not advance after five seconds, please reconnect.")
    
    if ConfigServer.ShowJoinQuitMessages then
        -- This need improvements, sometime playername can't be found and says 'Magick?' as username.
        Citizen.CreateThread(function()
            local xPlayers = NEX.GetPlayers()

            for i=1, #xPlayers, 1 do
                local xPlayer = NEX.GetPlayerFromId(xPlayers[i])

                if xPlayer.getGroup() == "admin" then
                    xPlayer.showNotification('~g~'..(GetPlayerName(_source) or "Magick?").."~w~ joined the server.")
                end
            end
        end)
    end

    if #identifiers > 0 and identifiers[1] ~= nil then
        local banned, data = NADMIN.IsPlayerBanned(identifiers)
        namecache[identifiers[1]]=GetPlayerName(source)
        if data ~= nil and data.sender_name == "NAC" then
            data.sender_name = "[Nexus AntiCheat]"
        end

        if banned then
            print(("[^1NAC^7] Player %s (%s) tried to join, your ban expires: %s (Ban ID: #%s)"):format(GetPlayerName(source),data.receiver[1],data.length and os.date("%Y-%m-%d %H:%M",data.length) or "PERMANENT",data.id))
            local kickmsg = Config.banformat:format(data.reason,data.length and os.date("%Y-%m-%d %H:%M",data.length) or "PERMANENTE",data.sender_name,data.id)
            def.done(kickmsg)
        else
            local data = {["@name"]=GetPlayerName(source)}
            for k,v in ipairs(identifiers) do
                data["@"..NADMIN.Split(v,":")[1]]=v
                if NADMIN.Split(v,":")[1] == "license" then
                    data['@identifier'] = NADMIN.Split(v,":")[2]
                end
            end
            
            if data["@steam"] then
                MySQL.Async.execute("INSERT INTO `users_identifiers` (identifier, `steam`, `license`, `ip`, `name`, `xbl`, `live`, `discord`, `fivem`) VALUES (@identifier, @steam, @license, @ip, @name, @xbl, @live, @discord, @fivem) ON DUPLICATE KEY UPDATE `license`=@license, `ip`=@ip, `name`=@name, `xbl`=@xbl, `live`=@live, `discord`=@discord, `fivem`=@fivem",data)
            end
            def.update("Preloading the server...")
            Citizen.Wait(2500)
            def.done()
        end
    else
        def.done("[NAC] Your identifier was not found, please reconnect.")
    end
   
end)

AddEventHandler('playerDropped', function(reason)
    if ConfigServer.ShowJoinQuitMessages then
        local xPlayers = NEX.GetPlayers()

        for i=1, #xPlayers, 1 do
            local xPlayer = NEX.GetPlayerFromId(xPlayers[i])

            if xPlayer.getGroup() == "admin" then
                xPlayer.showNotification('~g~'..GetPlayerName(source).."~w~ disconnects for: ~y~" .. reason .. "~w~.")
            end
        end
    end
end)



AddEventHandler('nex:Admin:WarnPlayer', function(xSource, xTarget, reason)
    NADMIN.RegisterNewPunish(xSource, "WARN", xTarget, reason, nil, false)
end)

AddEventHandler('nex:Admin:BanPlayer', function(xSource, xTarget, reason, length, isOffline)
    NADMIN.RegisterNewPunish(xSource, "BAN", xTarget, reason, length, isOffline)
end)

RegisterServerEvent('nex:Admin:ExecutePunishment')
AddEventHandler('nex:Admin:ExecutePunishment', function(target, reason, method)
    NADMIN.AnalyzeNewPunishment(source, target, reason, method)
end)

RegisterServerEvent('nex:Admin:SendGlobalAnnounce')
AddEventHandler('nex:Admin:SendGlobalAnnounce', function(message)
    local xPlayer = NEX.GetPlayerFromId(source)
    if NADMIN.IsAdmin(xPlayer) then
        TriggerClientEvent("nex:Admin:ReceiveAGlobalMessage", -1, xPlayer.name, message)
    end
end)

RegisterServerEvent('nex:Admin:SendGlobalNotification')
AddEventHandler('nex:Admin:SendGlobalNotification', function(data)
    TriggerClientEvent('nex:Core:SendAlert', -1, data)
    TriggerClientEvent('nex:Core:playFrontEndSound', -1, "Enter_1st", "GTAO_Magnate_Boss_Modes_Soundset")
end)