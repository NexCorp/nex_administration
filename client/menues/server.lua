ServerMenu = {}

ServerMenu.WeatherList = {
    ["EXTRASUNNY"] = "Soleado",
    ["CLEAR"] = "Cielo Despejado",
    ["SMOG"] = "Smog",
    ["FOGGY"] = "Brumoso",
    ['OVERCAST'] = "Nublado",
    ['CLOUDS'] = "Pocas Nubes",
    ['CLEARING'] = "Cielo Claro",
    ['LLUVIA'] = "Lluvia",
    ['THUNDER'] = "Tormenta",
    ['SNOW']    = "Nieve",
    ['BLIZZARD'] = "Tormenta de Nieve",
    ['SNOWLIGTH'] = "Haz de Nieve",
    ['XMAS'] = "Nieve Navideña"
} 

ServerMenu.DayTimeHour = {}
ServerMenu.DayTimeMinute = {}
ServerMenu.hourIndex = 1
ServerMenu.minuteIndex = 1

ServerMenu.Main = function()

    WarMenu.MenuButton('[💥] Anuncios Globales', 'nexadmin_server_announce')
    if WarMenu.IsItemHovered() then
        WarMenu.ToolTip('~w~Envia un anuncio global al servidor.')
    end

    
    -- if WarMenu.Button('[📛] Menú Reportes') then
    --     TriggerEvent('nex:Admin:Reports:ShowPanel')
    --     WarMenu.CloseMenu()
    -- end

    -- if WarMenu.IsItemHovered() then
    --     WarMenu.ToolTip('~w~Revisa los últimos reportes de jugadores.')
    -- end

    -- WarMenu.MenuButton('[🌀] Menú Status', 'nexadmin_server_status')

    -- WarMenu.MenuButton('[⛅] Menú Climatico', 'nexadmin_server_weather')

    WarMenu.End()
end

ServerMenu.Weather = function()
    
    local displayHour = ServerMenu.DayTimeHour[ServerMenu.hourIndex] 
    local displayMinute = ServerMenu.DayTimeMinute[ServerMenu.minuteIndex]
    local hourName = "PM"

    if displayHour < 13 then
        hourName = "AM"
    end

    if displayHour < 10 then
        displayHour = "0"..displayHour
    end

    if displayMinute < 10 then
        displayMinute = "0"..displayMinute
    end
        

    local _, _hourIndex = WarMenu.ComboBox("Hora", ServerMenu.DayTimeHour, ServerMenu.hourIndex)
    if ServerMenu.hourIndex ~= _hourIndex then
        ServerMenu.hourIndex = _hourIndex
    end


    local _, _minuteIndex = WarMenu.ComboBox("Minuto", ServerMenu.DayTimeHour, ServerMenu.minuteIndex)
    if ServerMenu.minuteIndex ~= _minuteIndex then
        ServerMenu.minuteIndex = _minuteIndex
    end

    if WarMenu.Button('~y~Actualizar Tiempo a las: ~s~' .. displayHour .. ":" .. displayMinute .. " " .. hourName) then
        -- Change this line with yout Timer Sync event
        TriggerServerEvent('nex:Sync:SetTime', displayHour, displayMinute)
    end

    WarMenu.Button('——————————————————')

    for key, cycle in pairs(ServerMenu.WeatherList) do
        if WarMenu.Button(cycle) then
            print(key)
        end
    end

    WarMenu.End()
end


ServerMenu.Announce = function()

    SetTextEntryToFunction('Escriba el mensaje del anuncio:') 
    local screenAnnouncePressed, inputText = WarMenu.InputButton('[🟢] Anunciar en pantalla', "FMMC_MPM_NA")
    
    if screenAnnouncePressed then
        if inputText and string.len(inputText) > 4 then
            NEX.UI.SendAlert('success', 'Enviando anuncio...', {})

            Citizen.Wait(2000)
            TriggerServerEvent('nex:Admin:SendGlobalAnnounce', inputText)

        else
            NEX.UI.SendAlert('error', '¡Whoops! 🔴 Su anuncio debe contener mínimo 5 carácteres.', {})
        end
    end

    screenAnnouncePressed, inputText = WarMenu.InputButton('[🟣] Anunciar notificación', "FMMC_MPM_NA")
    
    if screenAnnouncePressed then
        if inputText and string.len(inputText) > 4 then
            NEX.UI.SendAlert('success', 'Enviando anuncio...', {})

            Citizen.Wait(2000)
            local data = {
                type = "inform",
                title = "<b>ANUNCIO DE ADMINISTRACIÓN</b>",
                text = inputText,
                length = 20000,
                style = {
                    ['background'] = "rgba(3, 142, 187, 0.44)",
                    ['color'] = "white"
                }
            }
            TriggerServerEvent('nex:Admin:SendGlobalNotification', data)

        else
            NEX.UI.SendAlert('error', '¡Whoops! 🔴 Su anuncio debe contener mínimo 5 carácteres.', {})
        end
    end


    WarMenu.End()
end