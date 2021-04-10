RegisterServerEvent('nex:Admin:ToggleFreeze')

AddEventHandler('nex:Admin:ToggleFreeze', function(target, toggle)
    local xPlayer = NEX.GetPlayerFromId(target)
    if xPlayer then
        TriggerClientEvent('nex:Admin:ToggleFreeze', xPlayer.source, toggle)

        FreezePlayers[xPlayer.source] = toggle

        NEX.RegisterLog(source, "STAFF", "Freezing: " .. xPlayer.getName() .. " | Condition " .. tostring(toggle))
        TriggerClientEvent('nex:Core:SendAlert', source, {
            type = "success",
            title = "Staff Action",
            length = 5000,
            text = "Your action has been executed...",
            style = {}
        })
    end
end)