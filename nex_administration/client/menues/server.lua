ServerMenu = {}

ServerMenu.WeatherList = {
    ["EXTRASUNNY"] = "Sunny",
    ["CLEAR"] = "Clear sky",
    ["SMOG"] = "Smog",
    ["FOGGY"] = "Foggy",
    ['OVERCAST'] = "Overcast",
    ['CLOUDS'] = "A Little Cloudy",
    ['CLEARING'] = "Clear sky",
    ['LLUVIA'] = "Rain",
    ['THUNDER'] = "Thunder",
    ['SNOW']    = "Snow",
    ['BLIZZARD'] = "Snow storm",
    ['SNOWLIGTH'] = "Snow Beam",
    ['XMAS'] = "Christmas Snow"
} 

ServerMenu.DayTimeHour = {}
ServerMenu.DayTimeMinute = {}
ServerMenu.hourIndex = 1
ServerMenu.minuteIndex = 1

ServerMenu.Main = function()

    WarMenu.MenuButton('[💥] Global Ads', 'nexadmin_server_announce')
    if WarMenu.IsItemHovered() then
        WarMenu.ToolTip('~w~Send a global advertisement to the server.')
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
        

    local _, _hourIndex = WarMenu.ComboBox("Hour", ServerMenu.DayTimeHour, ServerMenu.hourIndex)
    if ServerMenu.hourIndex ~= _hourIndex then
        ServerMenu.hourIndex = _hourIndex
    end


    local _, _minuteIndex = WarMenu.ComboBox("Minute", ServerMenu.DayTimeHour, ServerMenu.minuteIndex)
    if ServerMenu.minuteIndex ~= _minuteIndex then
        ServerMenu.minuteIndex = _minuteIndex
    end

    if WarMenu.Button('~y~Update time to: ~s~' .. displayHour .. ":" .. displayMinute .. " " .. hourName) then
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

    SetTextEntryToFunction('Write your ad message:') 
    local screenAnnouncePressed, inputText = WarMenu.InputButton('[🟢] Announce on screen', "FMMC_MPM_NA")
    
    if screenAnnouncePressed then
        if inputText and string.len(inputText) > 4 then
            NEX.UI.SendAlert('success', 'Sending ad...', {})

            Citizen.Wait(2000)
            TriggerServerEvent('nex:Admin:SendGlobalAnnounce', inputText)

        else
            NEX.UI.SendAlert('error', 'Whoops! 🔴 Your ad must contain at least 5 characters.', {})
        end
    end

    screenAnnouncePressed, inputText = WarMenu.InputButton('[🟣] Announce notification', "FMMC_MPM_NA")
    
    if screenAnnouncePressed then
        if inputText and string.len(inputText) > 4 then
            NEX.UI.SendAlert('success', 'Sending ad...', {})

            Citizen.Wait(2000)
            local data = {
                type = "inform",
                title = "<b>ADMINISTRATION ANNOUNCEMENT</b>",
                text = inputText,
                length = 20000,
                style = {
                    ['background'] = "rgba(3, 142, 187, 0.44)",
                    ['color'] = "white"
                }
            }
            TriggerServerEvent('nex:Admin:SendGlobalNotification', data)

        else
            NEX.UI.SendAlert('error', 'Whoops! 🔴 Your ad must contain at least 5 characters.', {})
        end
    end


    WarMenu.End()
end