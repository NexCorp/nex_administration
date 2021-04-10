RegisterNetEvent('nex:Admin:ToggleFreeze')
RegisterNetEvent("nex:Admin:ReceiveAGlobalMessage")

AddEventHandler('nex:Admin:ToggleFreeze', function(toggle)
    local veh = GetVehiclePedIsIn(PlayerPedId())

    if veh ~= nil then
        FreezeEntityPosition(veh, toggle)
    end

    FreezeEntityPosition(PlayerPedId(), toggle)
end)

AddEventHandler("nex:Admin:ReceiveAGlobalMessage",function(sender, message)
    PrepareMusicEvent('FHPRB_START')
    PrepareMusicEvent('FHPRB_STOP')

    TriggerMusicEvent('FHPRB_START')

	TriggerEvent("chat:addMessage",{color={255,255,0},multiline=true,args={"[AD] ","Incoming ad from ".. sender .."!"}})
	
	local counts = 8
	while true do
		if counts == 0 then break end;
        PlaySoundFrontend(-1, "FIRST_PLACE", "HUD_MINI_GAME_SOUNDSET", 1)
        Citizen.Wait(400)
        PlaySoundFrontend(-1, "Zone_Enemy_Capture", "DLC_Apartments_Drop_Zone_Sounds", 1)
        
        Citizen.Wait(500)
        PlaySoundFrontend(-1, "Zone_Enemy_Capture", "DLC_Apartments_Drop_Zone_Sounds", 1)
        PlaySoundFrontend(-1, "Hit_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET", 1)
        PlaySoundFrontend(-1, "Hit_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET", 1)
		counts = counts - 1
	end

    Citizen.SetTimeout(11000, function()
        TriggerMusicEvent('FHPRB_STOP')
    end)
    
	PlaySoundFrontend(-1, "Goal", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
	NEX.Scaleform.ShowFreemodeMessage('~r~GENERAL ANNOUNCEMENT!', "Administration announcement \n~y~" .. message, 10)
	PlaySoundFrontend(-1, "Out_Of_Area", "DLC_Lowrider_Relay_Race_Sounds", 1)
	PlaySoundFrontend(-1, "Zone_Enemy_Capture", "DLC_Apartments_Drop_Zone_Sounds", 1)
end)