bancache = {}
namecache = {}
NADMIN = {}

NADMIN.AnalyzeNewPunishment = function(source, target, reason, method)

    local xTarget = nil
    local isOnline = false

    --if target == "7991e33c01e8fd7b8928ec9cc3e5b34f6b835112" then return end -- This is a prevent punish for server owner :D

    if method == "license" then
        xTarget = NEX.GetPlayerFromIdentifier(target)
    elseif method == "db" then
        xTarget = NEX.GetPlayerFromDBId(target)
    elseif method == "id" then
        xTarget = NEX.GetPlayerFromId(target)
    end

    if xTarget ~= nil then
        isOnline = true
        xTarget = xTarget.source
    end

    if isOnline then
        return NADMIN.RegisterNewPunish(source, "BAN", xTarget, reason, nil, false)
    else
        if method ~= "id" then
            local success, reason = NADMIN.BanPlayer(NEX.GetPlayerFromId(source), target, reason, nil, true)
            local data = {
                type = "success",
                title = "Sanción ejecutada",
                text = "Se ha sancionado a " .. target,
                length = 4000,
                style = {}
            }
            TriggerClientEvent('nex:Core:SendAlert', source, data)
            return success, reason
        else
            local data = {
                type = "error",
                title = "Error de sanción",
                text = "El GameID no se encuentra en línea.",
                length = 4000,
                style = {}
            }
            TriggerClientEvent('nex:Core:SendAlert', source, data)
        end
    end



end

NADMIN.RegisterNewPunish = function(xSource, type, target, reason, length, isOffline)
    if not target or not reason or not type then return false end

    local xPlayer = NEX.GetPlayerFromId(xSource)
    local xTarget = NEX.GetPlayerFromId(target)

    if (not xPlayer or (not xTarget and not isOffline)) and xSource ~= "NAC" then
        return false
    end

    if not xPlayer then xPlayer = xSource end

    if xSource == "NAC" or NADMIN.IsAdmin(xPlayer) then -- CHANGE THIS 
        -- if xTarget.identifier == "7991e33c01e8fd7b8928ec9cc3e5b34f6b835112" then
        --     return false
        -- end

        if type == "BAN" then
            local success, reason = NADMIN.BanPlayer(xPlayer, isOffline and target or xTarget, reason, length, isOffline)
            return success, reason
        elseif type == "WARN" then
            return NADMIN.WarnPlayer(xPlayer, xTarget, reason)
        elseif type == "KICK" then
            NADMIN.LogToDiscord("EXPULSIÓN", xSource, xTarget.source, reason)
            DropPlayer(xTarget.source, reason)
            return true
        else
            return false
        end
    else
        return false
    end
end

NADMIN.WarnPlayer = function(xSource, xTarget, reason)
    local author = "NAC"
    local authorName = "[Nexus AC]"

    if xSource ~= "NAC" then
        author = xSource.identifier
        authorName = xSource.getName() 
    end

    MySQL.Async.execute('INSERT INTO nexus_punishments (type, punisher, target, reason) VALUES ("WARN", @punisher, @receiver, @message)', {
        ['@receiver'] = json.encode({license=xTarget.identifier}),
        ['@punisher'] = author,
        ['@message'] = reason
    })

    TriggerClientEvent('nex:Admin:GotWarned', xTarget.source, authorName, reason)

    NADMIN.LogToDiscord("ADVERTENCIA/STRIKE", xSource.source or "NAC", xTarget.source, reason)

    return true
end

NADMIN.BanPlayer = function(xSource, xTarget, reason, length, isOffline)
    local targetIdentifiers, offlineName, timestring, data = {}, nil, nil, nil
    local xPlayerIdentifier, xPlayerName = "NAC", "[Nexus AC]"

    if xSource ~= "NAC" then
        xPlayerIdentifier   = xSource.identifier
        xPlayerName         = xSource.getName()
    end

    if isOffline then
        local existRecord = true
        local data = MySQL.Sync.fetchAll("SELECT * FROM users_identifiers WHERE identifier=@identifier", {
            ['@identifier'] = xTarget
        })

        if #data < 1 then
            existRecord = false
        end

        if not existRecord then
            targetIdentifiers = {
                license = xTarget
            }
        else
            
            offlinename = data[1].name
            targetIdentifiers = {
                discord = data[1].discord,
                xbl = data[1].xbl,
                live = data[1].live,
                license = data[1].license
            }
        end
    else
        targetidentifiers = GetPlayerIdentifiers(xTarget.source)
    end



    if length == "" then length = nil end
    MySQL.Async.execute('INSERT INTO nexus_punishments (type, punisher, target, reason, expires) VALUES ("BAN", @punisher, @receiver, @message, @expires)', {
        ['@receiver'] = json.encode(targetIdentifiers), 
        ['@punisher'] = xPlayerIdentifier,
        ['@expires'] = length,
        ['@message'] = reason
    }, function(_)
        local banId = MySQL.Sync.fetchScalar('SELECT MAX(id) FROM nexus_punishments')
        -- LOG
        
        if length ~= nil then
            timestring = length
            local year, month, day, hour, minute = string.match(length, "(%d+)/(%d+)/(%d+) (%d+):(%d+)")
            length = os.time({
                year = year,
                month = month,
                day = day,
                hour = hour,
                minute = minute
            })
        end

        table.insert(bancache, {
            id = banId,
            sender = xPlayerIdentifier,
            reason = reason,
            sender_name = xPlayerName,
            receiver = targetidentifiers,
            length = length
        })

        local punish = "BAN TEMPORAL: "
        if timestring then
            punish = punish .. timestring
        else 
            punish = "PERMANENTE"
        end

        if isOffline then 
            xTarget = targetIdentifiers
        else
            if not xTarget then
                return false, 'DATABASE ERROR'
            end

            local banType = "PERMANENTE"
            if timestring then
                banType = "BAN TEMPORAL, duración: " .. timestring
            end

            TriggerClientEvent('nex:Admin:GotBanned', xTarget.source, reason)
            Citizen.SetTimeout(9600, function()
                DropPlayer(xTarget.source, Config.BanFormat:format(reason,length~=nil and timestring or "PERMANENTE",xPlayerName,banid==nil and "1" or banid))
            end)

        end

        NADMIN.LogToDiscord(punish, xSource.source or "NAC", xTarget.source or json.encode(targetIdentifiers), reason)
        
    end)
    return true, ""
end

NADMIN.IsAdmin = function(xPlayer)
    for k,v in ipairs(Config.AdminGroups) do
        if xPlayer.getGroup()==v then return true end
    end
    return false
end

NADMIN.LogToConsole = function(message)
    -- TODO
end

NADMIN.LogToDiscord = function(category, playerId, targetId, message)

    if ConfigServer.WebhookPunishLogs == nil then return end

    local xPlayer = nil
    if playerId ~= "NAC" then
        xPlayer = NEX.GetPlayerFromId(playerId)
    else
        xPlayer = {
            getName = function()
                return "NAC SYSTEM"
            end,

            getDBId = function()
                return "-1"
            end,

            source = -1
        }
    end

    local data = nil
    if type(targetId) == "string" then
        data = {
            embeds = {
                {
                    title = "[VIGILANTE] SANCION EJECUTADA",
                    description = "Se ha ejecutado un castigo:",
                    color = 16771840,
                    fields = {
                        {
                            name = "SANCIONADOR: SteamName | DB | GameID",
                            value = xPlayer.getName() .. " | " .. xPlayer.getDBId() .. " | " .. xPlayer.source 
                        },
                        {
                            name = "SANCIONADO: Data",
                            value = tostring(targetId)
                        },
                        {
                            name = "TIPO SANCIÓN:",
                            value = category 
                        },
                        {
                            name = "MOTIVO:",
                            value = message
                        },
                    },
                    footer = {
                        text = "Nexus AntiCheat System",
                        icon_url = "https://images-ext-2.discordapp.net/external/05w3zIVuaUzJS6zPgq1FuOmG4kif6_NCPQQVHS864mw/https/images-ext-2.discordapp.net/external/PN4jUr9A0-7sD4iKtfJVB3MeTVaGQMhUaihqjp3qFRc/https/cdn.probot.io/HkWlJsRlXU.gif"
                    }
                }
            },
            username = "Nexus AntiCheat v2.0",
            avatar_url = "https://images-ext-2.discordapp.net/external/05w3zIVuaUzJS6zPgq1FuOmG4kif6_NCPQQVHS864mw/https/images-ext-2.discordapp.net/external/PN4jUr9A0-7sD4iKtfJVB3MeTVaGQMhUaihqjp3qFRc/https/cdn.probot.io/HkWlJsRlXU.gif" 
        }
    else
        local xTarget = NEX.GetPlayerFromId(targetId)
        data = {
            embeds = {
                {
                    title = "[VIGILANTE] SANCION EJECUTADA",
                    description = "Se ha ejecutado un castigo:",
                    color = 16771840,
                    fields = {
                        {
                            name = "SANCIONADOR: SteamName | DB | GameID",
                            value = xPlayer.getName() .. " | " .. xPlayer.getDBId() .. " | " .. xPlayer.source 
                        },
                        {
                            name = "SANCIONADO: SteamName | DB | GameID",
                            value = xTarget.getName() .. " | " .. xTarget.getDBId() .. " | " .. xTarget.source 
                        },
                        {
                            name = "TIPO SANCIÓN:",
                            value = category 
                        },
                        {
                            name = "MOTIVO:",
                            value = message
                        },
                    },
                    footer = {
                        text = "Nexus AntiCheat System",
                        icon_url = "https://images-ext-2.discordapp.net/external/05w3zIVuaUzJS6zPgq1FuOmG4kif6_NCPQQVHS864mw/https/images-ext-2.discordapp.net/external/PN4jUr9A0-7sD4iKtfJVB3MeTVaGQMhUaihqjp3qFRc/https/cdn.probot.io/HkWlJsRlXU.gif"
                    }
                }
            },
            username = "Nexus AntiCheat v2.0",
            avatar_url = "https://images-ext-2.discordapp.net/external/05w3zIVuaUzJS6zPgq1FuOmG4kif6_NCPQQVHS864mw/https/images-ext-2.discordapp.net/external/PN4jUr9A0-7sD4iKtfJVB3MeTVaGQMhUaihqjp3qFRc/https/cdn.probot.io/HkWlJsRlXU.gif" 
        }
    end

   
    PerformHttpRequest(ConfigServer.WebhookPunishLogs, function(err, text, headers) end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end

NADMIN.LogToAdmins = function(message)
    for k,v in ipairs(NEX.GetPlayers()) do  
        if isAdmin(NEX.GetPlayerFromId(v)) then
            TriggerClientEvent("chat:addMessage",v,{color={255,0,0},multiline=false,args={"[SANCIONES] ",msg}})
        end
    end
end

NADMIN.IsPlayerBanned = function(identifiers)
    for _,ban in ipairs(bancache) do
        if not ban.unbanned and (ban.expires == nil or ban.expires > os.time() or ban.appealed) then
            for _,bid in ipairs(ban.receiver) do
                for _,pid in ipairs(identifiers) do
                    if bid==pid then return true, ban end
                end
            end
        end
    end
    return false, nil
end

NADMIN.refreshNameCache = function()
    namecache = {}
    for k,v in ipairs(MySQL.Sync.fetchAll("SELECT identifier, name FROM users_identifiers")) do
        namecache[v.identifier] = v.name
    end
end

NADMIN.refreshBanCache = function()
    bancache = {}
    for k,v in ipairs(MySQL.Sync.fetchAll("SELECT * FROM nexus_punishments")) do
        table.insert(bancache, {
            id = v.id,
            type = v.type,
            senderName = namecache[v.by] or "[NAC]",
            sender = v.by,
            targetName = namecache[v.target],
            target = v.target,
            reason = v.reason,
            expires = v.expires,
            appeal = v.appeal,
            unbanned = v.unbanned
        })
    end
end

NADMIN.Split = function(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do 
        table.insert(result, match) 
    end
    return result
end