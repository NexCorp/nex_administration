RegisterNetEvent("nex:Admin:GotWarned")
RegisterNetEvent('nex:Admin:GlobalAnnounce')
RegisterNetEvent("nex:Admin:GotBanned")


AddEventHandler("nex:Admin:GotWarned",function(sender,message)

    PrepareMusicEvent('MP_DM_COUNTDOWN_KILL')
    TriggerMusicEvent('MP_DM_COUNTDOWN_KILL')
	TriggerEvent("chat:addMessage",{color={255,255,0},multiline=true,args={"[PUNISHMENT] ","You have received a warning"..(sender~="" and " from "..sender or "").."!\n-> "..message}})
    
    local counts = 6
    while true do
        ClearTimecycleModifier()

		if counts == 0 then break end;
        PlaySoundFrontend(-1, "FIRST_PLACE", "HUD_MINI_GAME_SOUNDSET", 1)
        SetTimecycleModifier("VolticFlash")
        
        Citizen.Wait(200)
        ClearTimecycleModifier()
		PlaySoundFrontend(-1, "Friend_Deliver", "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS", 1)
        Citizen.Wait(500)
        
        PlaySoundFrontend(-1, "Zone_Enemy_Capture", "DLC_Apartments_Drop_Zone_Sounds", 1)
        
        counts = counts - 1
    end

    ClearTimecycleModifier()
	PlaySoundFrontend(-1, "Success", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
	NEX.Scaleform.ShowFreemodeMessage('~y~ATTENTION!', sender .." warned you.\n Reason: ~r~" .. message, 7)
	PlaySoundFrontend(-1, "Out_Of_Area", "DLC_Lowrider_Relay_Race_Sounds", 1)
	PlaySoundFrontend(-1, "Zone_Enemy_Capture", "DLC_Apartments_Drop_Zone_Sounds", 1)

end)


AddEventHandler("nex:Admin:GotBanned",function(rsn)
    PrepareMusicEvent('FM_COUNTDOWN_10S')
    TriggerMusicEvent('FM_COUNTDOWN_10S')

    Citizen.Wait(2000)

    Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			DisableAllControlActions(0)
			DisableFrontendThisFrame()
			local ped = GetPlayerPed(-1)
			NEX.UI.Menu.CloseAll()
			FreezeEntityPosition(ped, true)
		end
    end)
    
	local counts = 6
	while true do
        if counts == 0 then break end;
        if counts == 4 then end
        
        PlaySoundFrontend(-1, "Zone_Enemy_Capture", "DLC_Apartments_Drop_Zone_Sounds", 1)
        PlaySoundFrontend(-1, "Friend_Deliver", "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS", 1)

        Citizen.Wait(200)
        PlaySoundFrontend(-1, "Zone_Enemy_Capture", "DLC_Apartments_Drop_Zone_Sounds", 1)
        PlaySoundFrontend(-1, "Success", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
		Citizen.Wait(400)
		counts = counts - 1
	end

    PlaySoundFrontend(-1, "Success", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
    NEX.Scaleform.ShowTrafficMovie(10) 

end)