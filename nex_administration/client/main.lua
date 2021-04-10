NEX = nil
HasAuthorization = false

local pos_before_assist,assisting,assist_target,last_assist = nil, false, nil, nil

Citizen.CreateThread(function()
	while NEX == nil do
		TriggerEvent('nexus:getNexusObject', GetCurrentResourceName(), function(obj) NEX = obj end)
		Citizen.Wait(200)
	end

	Citizen.SetTimeout(4000, function()
		if HasAuthorization then print("[NAC] Admin Authorization accepted.") end
	end)

	Citizen.Wait(2000)

	while true do
		NEX.TriggerServerCallback('nex:Admin:CheckAuth', function(hasAuthorization)
			HasAuthorization = hasAuthorization
		end)
		Citizen.Wait(10000)
	end
end)

SetTextEntryToFunction = function(text)
    local defaultText = "Enter text:"
    AddTextEntry("FMMC_MPM_NA", text)
    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        AddTextEntry("FMMC_MPM_NA", defaultText)
    end)
end

function GetIndexedPlayerList()
	local players = {}
	for k,v in ipairs(GetActivePlayers()) do
		players[tostring(GetPlayerServerId(v))]=GetPlayerName(v)..(v==PlayerId() and " (self)" or "")
	end
	return json.encode(players)
end
