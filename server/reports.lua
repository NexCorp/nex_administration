local reports = {}
local discord = {}
local wait = {}
local blocked = {}
local hidden = {}

-- TODO:
-- - Block System

RegisterServerEvent("nex:Admin:Reports:init")
AddEventHandler("nex:Admin:Reports:init", function()
    local src = source
    local identifier = nil
    local data = nil

    for k,v in pairs(GetPlayerIdentifiers(src)) do
        if string.find(v,'discord') then
            identifier = string.sub(v, 9)
        end
    end

    if not identifier then
        discord[src] = GetPlayerName(src)
    else
        PerformHttpRequest("https://discordapp.com/api/users/"..identifier, function(err, text, headers)
            if err == 200 then
                discord[src] = json.decode(text).username .. '#' .. json.decode(text).discriminator
            else
                discord[src] = GetPlayerName(source)
            end
        end, "GET", "", {["Content-type"] = "application/json", ["Authorization"] = "Bot " .. ConfigServer.DiscordBotKey})
    end
end)

RegisterServerEvent('nex:Admin:Reports:SuccessScreenshot')
AddEventHandler('nex:Admin:Reports:SuccessScreenshot', function(target)
    local xPlayer = NEX.GetPlayerFromId(target)
    local data = {
        type = "success",
        title = "Staff Action",
        text = "La imagén fué enviada al discord.",
        length = 4000,
        style = {}
    }
    xPlayer.sendAlert(data)
end)


RegisterServerEvent('nex:Admin:Reports:RequetsPlayerScreenshot')
AddEventHandler('nex:Admin:Reports:RequetsPlayerScreenshot', function(target)
    TriggerClientEvent('nex:Admin:Reports:RequetsScreenshot', target, source)
end)

Citizen.CreateThread(function()
    while NEX == nil do
        Citizen.Wait(200)
    end

    if ConfigServer.EnableReportCommand then
        NEX.RegisterCommand('report', 'user', function(xPlayer, args, showError)
            local message = ""

            for i=1, #args.mensaje do
                message = message .. " " .. args.mensaje[i]
            end

            xPlayer.triggerEvent('nex:Admin:Reports:CreateReport', message)

        end, false, {help = "Create and send report for the admin", validate = false, arguments = {
            {name = 'mensaje', help = "mensaje", type = 'multistring'}
        }})
    else 
        print("[NexAdmin] Your 'report' command has been disabled.")
    end

    NEX.RegisterServerCallback('nex:Admin:Reports:RequetsScreenshot', function(source, cb, adminSource, imgUrl)
        if not Config.SendScreeshotToDiscord then return end

        local xPlayer = NEX.GetPlayerFromId(source)
        local discordData = {
            embeds = { 
                {
                    title = "SOLICITUD DE SCREENSHOT",
                    color = 31487,
                    fields = { 
                        {
                            name = "Solicitante: ",
                            value = GetPlayerName(adminSource)
                        }, 
                        {
                            name = "Usuario: " .. GetPlayerName(source),
                            value = "CharId: ".. xPlayer.charId .." | DbId: ".. xPlayer.dbId .." | GameId: "..xPlayer.source
                        }, 
                        {
                            name = "Captura de pantalla:",
                            value = "🔽🔽🔽🔽🔽🔽"
                        } 
                    },
                    image = {
                        url = imgUrl
                    }
                } 
            },
            username = "Ximena de Soporte",
            avatar_url = "https://images-ext-2.discordapp.net/external/05w3zIVuaUzJS6zPgq1FuOmG4kif6_NCPQQVHS864mw/https/images-ext-2.discordapp.net/external/PN4jUr9A0-7sD4iKtfJVB3MeTVaGQMhUaihqjp3qFRc/https/cdn.probot.io/HkWlJsRlXU.gif" 

        }

        local webhook = ConfigServer.WebhookImageLogs
        PerformHttpRequest(webhook, function(err, text, headers)
        end, 'POST', json.encode(discordData), { ['Content-Type'] = 'application/json' })

        cb(true)
    end)

    NEX.RegisterServerCallback('nex:Admin:Reports:SendReport', function(source, cb, message, imgUrl)
        
        local xPlayer = NEX.GetPlayerFromId(source)

        if ((wait[source]) and (wait[source]+10000 > GetGameTimer())) then
            local data = {
                type = "error",
                title = "Reportes",
                text = "Por favor, espera unos segundos antes de enviar otro mensaje de soporte.",
                length = 8000,
                style = {}
            }
            xPlayer.sendAlert(data)
            return cb(false)
        end

        if string.len(message) < 8 then
            local data = {
                type = "error",
                title = "Reportes",
                text = "Por favor, especifica más información en tu reporte.",
                length = 8000,
                style = {}
            }
            xPlayer.sendAlert(data)
            return cb(false)
        end

        if blocked[source] then
            local data = {
                type = "error",
                title = "Reportes",
                text = "Has sido bloqueado del sistema de reportes hasta nuevo aviso.",
                length = 8000,
                style = {}
            }
            xPlayer.sendAlert(data)
            return cb(false)
        end

        local xPlayers = NEX.GetPlayers()
        local report = #reports + 1

        local identifier = xPlayer.identifier
        local job = xPlayer.job.name
        local ping = GetPlayerPing(xPlayer.source)
        local money = "Money: " .. xPlayer.getAccount('money').money .. "  Banco: " .. xPlayer.getAccount('bank').money


        reports[report] = { 
            report = report,
            id = source,
            name = GetPlayerName(source),
            text = message,
            discord = discord[source],
            dbId = xPlayer.dbId,
            charId=xPlayer.charId,
            identifier = identifier,
            job = job,
            ping = ping,
            money = money
        }

        local discordData = {
            embeds = { 
                {
                    title = "REPORTE RECIBIDO",
                    color = 31487,
                    fields = { 
                        {
                            name = "Usuario: " .. GetPlayerName(source),
                            value = "CharId: ".. xPlayer.charId .." | DbId: ".. xPlayer.dbId .." | GameId: "..xPlayer.source
                        }, 
                        {
                            name = "Mensaje",
                            value = message
                        },
                        {
                            name = "Captura de pantalla:",
                            value = "🔽🔽🔽🔽🔽🔽"
                        } 
                    },
                    image = {
                        url = imgUrl or ""
                    }
                } 
            },
            username = "Mauricio de Soporte",
            avatar_url = "https://images-ext-2.discordapp.net/external/05w3zIVuaUzJS6zPgq1FuOmG4kif6_NCPQQVHS864mw/https/images-ext-2.discordapp.net/external/PN4jUr9A0-7sD4iKtfJVB3MeTVaGQMhUaihqjp3qFRc/https/cdn.probot.io/HkWlJsRlXU.gif" 

        }

        local webhook = ConfigServer.WebhookReportsLogs
        PerformHttpRequest(webhook, function(err, text, headers)
        end, 'POST', json.encode(discordData), { ['Content-Type'] = 'application/json' })

            
        for k,v in pairs(xPlayers) do
            local s_xPlayer = NEX.GetPlayerFromId(v)

            if s_xPlayer.getGroup() == 'admin' then
                TriggerClientEvent("chat:addMessage",s_xPlayer.source,{color={255,0,0},multiline=false,args={"[Report] By: " .. xPlayer.getName() .. "(".. xPlayer.source ..") [".. xPlayer.dbId .."] | ",message}})
                s_xPlayer.showNotification('New report from: ~y~' .. xPlayer.getName() .. " [".. xPlayer.dbId .."] ~w~| ~g~".. message)
            end
            
        end


        if string.match(message, "heal") or string.match(message, "revive") or string.match(message, "heal") then
            local data = {
                type = "success",
                title = "Reportes",
                text = "Su reporte ha sido enviado, pero recuerde que solicitar suministros mágicos como 'revive' o 'heal' entre otros puede demorar mas en ser atendido.",
                length = 8000,
                style = {}
            }
            xPlayer.sendAlert(data)
        else
            local data = {
                type = "success",
                title = "Reportes",
                text = "Se ha enviado su solicitud de ayuda.",
                length = 8000,
                style = {}
            }
            xPlayer.sendAlert(data)
        end



        wait[source] = GetGameTimer()
        cb(true)
    end)

    NEX.RegisterServerCallback("nex:Admin:Reports:IsBlocked", function(source, cb, id)
        cb(blocked[id] == true)
    end)
end)