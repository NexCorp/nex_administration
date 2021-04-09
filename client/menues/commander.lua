CommanderMenu = {}
CommanderMenu.GodMode = false
CommanderMenu.Invisible = false

CommanderMenu.Main = function()
    if WarMenu.CheckBox('Godmode: ', CommanderMenu.GodMode) then
        CommanderMenu.GodMode = not CommanderMenu.GodMode
        if CommanderMenu.GodMode then 
            NEX.UI.SendAlert('success', 'Modo Dios', 'Activado', 2000)
            CommanderMenu.GodModeThreads() 
        else
            NEX.UI.SendAlert('error', 'Modo Dios', 'Desactivado', 2000)
        end
    end

    if WarMenu.Button('Gestor de ropa') then
        TriggerEvent('nex:Clothing:OpenClothingMenu', "clothesmenu")
        WarMenu.CloseMenu()
    end

    if WarMenu.Button('Gestor de apariencia') then
        TriggerEvent('nex:Clothing:OpenStartingMenu')
        WarMenu.CloseMenu()
    end

    if WarMenu.Button('Gestor de outfits') then
        TriggerEvent('openOutfitsMenu', true)
        WarMenu.CloseMenu()
    end

    WarMenu.End()
end

CommanderMenu.GodModeThreads = function()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5)

            if CommanderMenu.GodMode then
                SetPlayerInvincible(PlayerId(), true)
            elseif not CommanderMenu.GodMode then
                SetPlayerInvincible(PlayerId(), false)
                break
            end
        end
    end)
end