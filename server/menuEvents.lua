RegisterServerEvent('nex:Admin:ToggleFreeze')

AddEventHandler('nex:Admin:ToggleFreeze', function(target, toggle)
    local xPlayer = NEX.GetPlayerFromId(target)
    if xPlayer then
        TriggerClientEvent('nex:Admin:ToggleFreeze', xPlayer.source, toggle)

        FreezePlayers[xPlayer.source] = toggle

        NEX.RegisterLog(source, "STAFF", "Congelamiento: " .. xPlayer.getName() .. " | Estado: " .. tostring(toggle))
        TriggerClientEvent('nex:Core:SendAlert', source, {
            type = "success",
            title = "Staff Action",
            length = 5000,
            text = "Se ha ejecutado su acción...",
            style = {}
        })
    end
end)