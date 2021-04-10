CommanderMenu = {}
CommanderMenu.GodMode = false
CommanderMenu.Invisible = false

CommanderMenu.Main = function()
    if WarMenu.CheckBox('Godmode: ', CommanderMenu.GodMode) then
        CommanderMenu.GodMode = not CommanderMenu.GodMode
        if CommanderMenu.GodMode then 
            NEX.UI.SendAlert('success', 'God mode', 'Activated', 2000)
            CommanderMenu.GodModeThreads() 
        else
            NEX.UI.SendAlert('error', 'God mode', 'Deactivated', 2000)
        end
    end

    if WarMenu.Button('Clothing manager') then
        TriggerEvent('nex:Clothing:OpenClothingMenu', "clothesmenu")
        WarMenu.CloseMenu()
    end

    if WarMenu.Button('Appearance manager') then
        TriggerEvent('nex:Clothing:OpenStartingMenu')
        WarMenu.CloseMenu()
    end

    if WarMenu.Button('Outfit manager') then
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