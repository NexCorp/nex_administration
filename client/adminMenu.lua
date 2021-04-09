local playerPed = PlayerPedId()
local isPlayerInVehicle = false
local isMenuOpen = false

-- VEHICLE
local currentVehicle = nil
local isPlayerNearVehicle = false

Citizen.CreateThread(function()
    Citizen.Wait(3000)
    SetDayTime()
    if HasAuthorization then

        RegisterKeyMapping('open_admin_menu', 'Menú Administrador', 'KEYBOARD', 'PAGEDOWN')

        RegisterCommand('open_admin_menu', function()
            OpenAdminMenu()
        end)
    end
end)

Citizen.CreateThread(function()

    local checkingEngine = false
    local isNearOfVehicle = true

    while true do
        while NEX == nil do Citizen.Wait(300) end
        if not HasAuthorization then break end -- Maybe this can be improved, if normal player is now a admin, this player must reconnect
        Citizen.Wait(1500)
        playerPed = PlayerPedId()

        isPlayerInVehicle = IsPedInAnyVehicle(playerPed, false)

        if isPlayerInVehicle then
            currentVehicle = GetVehiclePedIsIn(playerPed, false)
            isPlayerNearVehicle = false
        else
            local vehicle = NEX.Game.GetVehicleInDirection()
            if DoesEntityExist(vehicle) then
                if GetVehicleDoorLockStatus(vehicle) == 1 or GetVehicleDoorLockStatus(vehicle) == 0 then
                    local distanceToVeh = math.floor(#(GetEntityCoords(playerPed) - GetEntityCoords(vehicle)))
                    if distanceToVeh <= 5 then
                        currentVehicle = vehicle
                        isPlayerNearVehicle = true
                    end
                end
            else
                currentVehicle = nil
                isPlayerNearVehicle = false
            end
        end
    end
end)

SetDayTime = function()
    for i=0, 23, 1 do
        table.insert(ServerMenu.DayTimeHour, i)
    end

    for i=0, 59, 1 do
        table.insert(ServerMenu.DayTimeMinute, i)
    end

    table.sort(ServerMenu.DayTimeHour, function(a, b)
        return a < b
    end)
    table.sort(ServerMenu.DayTimeMinute, function(a, b)
        return a < b
    end)

end

OpenAdminMenu = function()
    WarMenu.CreateMenu('nexadmin', 'Administrador', '~y~Menu de Gestion')

    WarMenu.CreateSubMenu('nexadmin_commands', 'nexadmin', '[🔰] Comandos Rapidos')
    WarMenu.CreateSubMenu('nexadmin_players', 'nexadmin', '[🕺🏽] Gestion de Jugadores')
    WarMenu.CreateSubMenu('nexadmin_factions', 'nexadmin', '[🚩] Gestion de Facciones')
    WarMenu.CreateSubMenu('nexadmin_server', 'nexadmin', "[🔰] Gestion del Servidor")


    -- FACTIONS

    -- PLAYERS
    WarMenu.CreateSubMenu('nexadmin_players_inspect', 'nexadmin_players', "[🔰] Inspeccionando Jugador")
    WarMenu.CreateSubMenu('nexadmin_player_integrity', 'nexadmin_players_inspect', "[🔰] Gestionado Integridad")
    WarMenu.CreateSubMenu('nexadmin_players_punishments', 'nexadmin_players', "[🔰] Sancionando")

    -- SERVER
    WarMenu.CreateSubMenu('nexadmin_server_announce', 'nexadmin_server', "[💨] ENVIAR ANUNCIOS")
    WarMenu.CreateSubMenu('nexadmin_server_weather', 'nexadmin_server', '[🌞] Estado Climatico')

    WarMenu.SetMenuY('nexadmin', 0.40)

    if WarMenu.IsAnyMenuOpened() then
        return
    end

    WarMenu.OpenMenu('nexadmin')

    while true do
        if not HasAuthorization then break end -- Maybe this can be improved, if normal player is now a admin, this player must reconnect
        if WarMenu.IsMenuOpened('nexadmin') then
            isMenuOpen = true

            WarMenu.MenuButton('[🔰] Comandos Rapidos',   'nexadmin_commands')

            if WarMenu.MenuButton('[🕺🏽] Gestión Jugadores',     'nexadmin_players') then
                PlayersMenu.ProccessOnlinePlayers()
            end

            WarMenu.MenuButton('[🔰] Gestion del Servidor',  'nexadmin_server')

            WarMenu.End()
        elseif WarMenu.IsMenuOpened('nexadmin_commands') then
            CommanderMenu.Main()
        elseif WarMenu.IsMenuOpened('nexadmin_factions') then
            WarMenu.End()
        elseif WarMenu.IsMenuOpened('nexadmin_server') then
            ServerMenu.Main()
        elseif WarMenu.IsMenuOpened('nexadmin_server_announce') then
            ServerMenu.Announce()
        elseif WarMenu.IsMenuOpened('nexadmin_server_weather') then
            ServerMenu.Weather()
        elseif WarMenu.IsMenuOpened('nexadmin_players') then
            PlayersMenu.Main()
        elseif WarMenu.IsMenuOpened('nexadmin_players_inspect') then
            PlayersMenu.PlayersOptions()
        elseif WarMenu.IsMenuOpened('nexadmin_player_integrity') then
            PlayersMenu.PlayerIntegrity()
        elseif WarMenu.IsMenuOpened('nexadmin_players_punishments') then
            PlayersMenu.DoPunishments()
        else
            isMenuOpen = false
            break
        end
        Citizen.Wait(5)
    end
end