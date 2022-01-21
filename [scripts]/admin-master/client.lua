ESX = nil


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

RegisterNetEvent('setgroup')
AddEventHandler('setgroup', function()
    group = true
end)    

Citizen.CreateThread(function()
    while true do
        Citizen.Wait( 2000 )

        if NetworkIsSessionStarted() then
            TriggerServerEvent( "checkadmin")
        end
    end
end )

local maxHealth = GetEntityMaxHealth(playerPed)
local health = GetEntityHealth(playerPed)
local newHealth = math.min(maxHealth , math.floor(health + maxHealth/1))

--==--==--==--
-- Noclip
--==--==--==--


function DrawPlayerInfo(target)
	drawTarget = target
	drawInfo = true
end

function StopDrawPlayerInfo()
	drawInfo = false
	drawTarget = 0
end
Citizen.CreateThread( function()
	while true do
		Citizen.Wait(0)
		if drawInfo then
			local text = {}
			-- cheat checks
			local targetPed = GetPlayerPed(drawTarget)
			
			table.insert(text,"E pour stop spectate")
			
			for i,theText in pairs(text) do
				SetTextFont(0)
				SetTextProportional(1)
				SetTextScale(0.0, 0.30)
				SetTextDropshadow(0, 0, 0, 0, 255)
				SetTextEdge(1, 0, 0, 0, 255)
				SetTextDropShadow()
				SetTextOutline()
				SetTextEntry("STRING")
				AddTextComponentString(theText)
				EndTextCommandDisplayText(0.3, 0.7+(i/30))
			end
			
			if IsControlJustPressed(0,103) then
				local targetPed = PlayerPedId()
				local targetx,targety,targetz = table.unpack(GetEntityCoords(targetPed, false))
	
				RequestCollisionAtCoord(targetx,targety,targetz)
				NetworkSetInSpectatorMode(false, targetPed)
	
				StopDrawPlayerInfo()
				
			end
			
		end
	end
end)
function SpectatePlayer(targetPed,target,name)
    local playerPed = PlayerPedId() -- yourself
	enable = true
	if targetPed == playerPed then enable = false end

    if(enable)then

        local targetx,targety,targetz = table.unpack(GetEntityCoords(targetPed, false))

        RequestCollisionAtCoord(targetx,targety,targetz)
        NetworkSetInSpectatorMode(true, targetPed)
		DrawPlayerInfo(target)
        ESX.ShowNotification('~g~Mode spectateur en cours')
    else

        local targetx,targety,targetz = table.unpack(GetEntityCoords(targetPed, false))

        RequestCollisionAtCoord(targetx,targety,targetz)
        NetworkSetInSpectatorMode(false, targetPed)
		StopDrawPlayerInfo()
        ESX.ShowNotification('~b~Mode spectateur arrêtée')
    end
end

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function setupScaleform(scaleform)

    local scaleform = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(1)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    Button(GetControlInstructionalButton(2, config.controls.openKey, true))
    ButtonMessage("Disable Noclip")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, config.controls.goUp, true))
    ButtonMessage("Go Up")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, config.controls.goDown, true))
    ButtonMessage("Go Down")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(1, config.controls.turnRight, true))
    Button(GetControlInstructionalButton(1, config.controls.turnLeft, true))
    ButtonMessage("Turn Left/Right")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(1, config.controls.goBackward, true))
    Button(GetControlInstructionalButton(1, config.controls.goForward, true))
    ButtonMessage("Go Forwards/Backwards")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, config.controls.changeSpeed, true))
    ButtonMessage("Change Speed ("..config.speeds[index].label..")")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(config.bgR)
    PushScaleformMovieFunctionParameterInt(config.bgG)
    PushScaleformMovieFunctionParameterInt(config.bgB)
    PushScaleformMovieFunctionParameterInt(config.bgA)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

config = {
    controls = {
        -- [[Controls, list can be found here : https://docs.fivem.net/game-references/controls/]]
        openKey = 288, -- [[F2]]
        goUp = 85, -- [[Q]]
        goDown = 48, -- [[Z]]
        turnLeft = 34, -- [[A]]
        turnRight = 35, -- [[D]]
        goForward = 32,  -- [[W]]
        goBackward = 33, -- [[S]]
        changeSpeed = 21, -- [[L-Shift]]
    },

    speeds = {
        -- [[If you wish to change the speeds or labels there are associated with then here is the place.]]
        { label = "Very Slow", speed = 0},
        { label = "Slow", speed = 0.5},
        { label = "Normal", speed = 2},
        { label = "Fast", speed = 4},
        { label = "Very Fast", speed = 6},
        { label = "Extremely Fast", speed = 10},
        { label = "Extremely Fast v2.0", speed = 20},
        { label = "Max Speed", speed = 25}
    },

    offsets = {
        y = 0.5, -- [[How much distance you move forward and backward while the respective button is pressed]]
        z = 0.2, -- [[How much distance you move upward and downward while the respective button is pressed]]
        h = 3, -- [[How much you rotate. ]]
    },

    -- [[Background colour of the buttons. (It may be the standard black on first opening, just re-opening.)]]
    bgR = 0, -- [[Red]]
    bgG = 0, -- [[Green]]
    bgB = 0, -- [[Blue]]
    bgA = 80, -- [[Alpha]]
}


noclipActive = false -- [[Wouldn't touch this.]]

index = 1 -- [[Used to determine the index of the speeds table.]]

Citizen.CreateThread(function()

    buttons = setupScaleform("instructional_buttons")

    currentSpeed = config.speeds[index].speed

    while true do
        Citizen.Wait(1)

        if noclipActive then
            DrawScaleformMovieFullscreen(buttons)

            local yoff = 0.0
            local zoff = 0.0

            if IsControlJustPressed(1, config.controls.changeSpeed) then
                if index ~= 8 then
                    index = index+1
                    currentSpeed = config.speeds[index].speed
                else
                    currentSpeed = config.speeds[1].speed
                    index = 1
                end
                setupScaleform("instructional_buttons")
            end

			if IsControlPressed(0, config.controls.goForward) then
                yoff = config.offsets.y
			end
			
            if IsControlPressed(0, config.controls.goBackward) then
                yoff = -config.offsets.y
			end
			
            if IsControlPressed(0, config.controls.turnLeft) then
                SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity)+config.offsets.h)
			end
			
            if IsControlPressed(0, config.controls.turnRight) then
                SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity)-config.offsets.h)
			end
			
            if IsControlPressed(0, config.controls.goUp) then
                zoff = config.offsets.z
			end
			
            if IsControlPressed(0, config.controls.goDown) then
                zoff = -config.offsets.z
			end
			
            local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))
            local heading = GetEntityHeading(noclipEntity)
            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, heading)
            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, noclipActive, noclipActive, noclipActive)
        end
    end
end)

--==--==--==--
-- Noclip fin
--==--==--==--


local function TeleportToWaypoint()-- https://gist.github.com/samyh89/32a780abcd1eea05ab32a61985857486
    local entity = PlayerPedId()
    if IsPedInAnyVehicle(entity, false) then
        entity = GetVehiclePedIsUsing(entity)
    end
    local success = false
    local blipFound = false
    local blipIterator = GetBlipInfoIdIterator()
    local blip = GetFirstBlipInfoId(8)
    
    while DoesBlipExist(blip) do
        if GetBlipInfoIdType(blip) == 4 then
            cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector()))--GetBlipInfoIdCoord(blip)
            blipFound = true
            break
        end
        blip = GetNextBlipInfoId(blipIterator)
        Wait(0)
    end
    
    if blipFound then
        local groundFound = false
        local yaw = GetEntityHeading(entity)
        
        for i = 0, 1000, 1 do
            SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
            SetEntityRotation(entity, 0, 0, 0, 0, 0)
            SetEntityHeading(entity, yaw)
            SetGameplayCamRelativeHeading(0)
            Wait(0)
            if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then
                cz = ToFloat(i)
                groundFound = true
                break
            end
        end
        if not groundFound then
            cz = -300.0
        end
        success = true
    else
        ShowInfo('~r~Aucun Marker trouvés')
    end
    
    if success then
        SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
        SetGameplayCamRelativeHeading(0)
        if IsPedSittingInAnyVehicle(PlayerPedId()) then
            if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
                SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
            end
        end
    end

end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

	-- TextEntry		-->	The Text above the typing field in the black square
	-- ExampleText		-->	An Example Text, what it should say in the typing field
	-- MaxStringLenght	-->	Maximum String Lenght

	AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
	blockinput = true --Blocks new input while typing if **blockinput** is used

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the typing
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return nil --Returns nil if the typing got aborted
	end
end

function gestionjoueurs()
	for k,v in ipairs(ServersIdSession) do
                if GetPlayerName(GetPlayerFromServerId(v)) == "**Invalid**" then table.remove(ServersIdSession, k) 
                end

                RageUI.Button("["..v.."] - "..GetPlayerName(GetPlayerFromServerId(v)), nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
			end)
			end
			end			

--==--==--==--
-- coordonne et crosshair
--==--==--==--

Admin = {
	showcoords = false,
	showcrosshair = false,
	ghostmode = false,
    godmode = false,
    showName = false,
    gamerTags = {}
}
MainColor = {
	r = 225, 
	g = 55, 
	b = 55,
	a = 255
}

function DrawTxt(text,r,z)
    SetTextColour(MainColor.r, MainColor.g, MainColor.b, 255)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0,0.4)
    SetTextDropshadow(1,0,0,0,255)
    SetTextEdge(1,0,0,0,255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(r,z)
 end
--==--==--==--
-- coordonne fin
--==--==--==--

 --------------------------------------------
 Citizen.CreateThread(function()
	while true do
		if Admin.showName then
			for k, v in ipairs(ESX.Game.GetPlayers()) do
				local otherPed = GetPlayerPed(v)

				if otherPed ~= plyPed then
					if #(GetEntityCoords(plyPed, false) - GetEntityCoords(otherPed, false)) < 5000.0 then
						Admin.gamerTags[v] = CreateFakeMpGamerTag(otherPed, ('[%s] %s'):format(GetPlayerServerId(v), GetPlayerName(v)), false, false, '', 0)
					else
						RemoveMpGamerTag(Admin.gamerTags[v])
						Admin.gamerTags[v] = nil
					end
				end
			end
		end

		Citizen.Wait(100)
	end
end)

 Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

local ServersIdSession = {}

Citizen.CreateThread(function()
    while true do
        Wait(500)
        for k,v in pairs(GetActivePlayers()) do
            local found = false
            for _,j in pairs(ServersIdSession) do
                if GetPlayerServerId(v) == j then
                    found = true
                end
            end
            if not found then
                table.insert(ServersIdSession, GetPlayerServerId(v))
            end
        end
    end
end)

local joueurPed = GetPlayerPed(IdSelected)
 --------------------------------------------





RMenu.Add('admin', 'main', RageUI.CreateMenu("Administration", "Menu admin"))
RMenu.Add('admin', 'perso', RageUI.CreateSubMenu(RMenu:Get('admin', 'main'), "Paramètres perso", "Pour soit même"))
RMenu.Add('admin', 'ped', RageUI.CreateSubMenu(RMenu:Get('admin', 'main'), "Peds", "Pour se mettre en ped"))
RMenu.Add('admin', 'particule', RageUI.CreateSubMenu(RMenu:Get('admin', 'main'), "Particule", "Pour se mettre des particules"))
RMenu.Add('admin', 'voiture', RageUI.CreateSubMenu(RMenu:Get('admin', 'main'), "Voiture", "Pour les voitures"))
RMenu.Add('admin', 'customcar', RageUI.CreateSubMenu(RMenu:Get('admin', 'voiture'), "Custom", "Pour custom la voiture"))
RMenu.Add('admin', 'couleur', RageUI.CreateSubMenu(RMenu:Get('admin', 'customcar'), "Couleur", "Pour colorer la voiture"))
RMenu.Add('admin', 'neon', RageUI.CreateSubMenu(RMenu:Get('admin', 'customcar'), "Néon", "Pour les néons de la voiture"))
RMenu.Add('admin', 'listej', RageUI.CreateSubMenu(RMenu:Get('admin', 'main'), "Liste joueurs", "Pour voir la liste des joueurs"))
RMenu.Add('admin', 'gestj', RageUI.CreateSubMenu(RMenu:Get('admin', 'listej'), "Gestion joueurs", "Pour gérer les joueurs"))


Citizen.CreateThread(function()
    while true do
        RageUI.IsVisible(RMenu:Get('admin', 'main'), true, true, true, function()

            RageUI.Button("Paramètres perso", "Pour soit même", {RightLabel = "→→→"},true, function()
            end, RMenu:Get('admin', 'perso'))
            RageUI.Button("Peds", "Pour se mettre en ped", {RightLabel = "→→→"},true, function()
            end, RMenu:Get('admin', 'ped'))
            RageUI.Button("Particule", "Pour se mettre des particules", {RightLabel = "→→→"},true, function()
            end, RMenu:Get('admin', 'particule'))
            RageUI.Button("Voiture", "Pour les voitures", {RightLabel = "→→→"},true, function()
            end, RMenu:Get('admin', 'voiture'))
            RageUI.Button("Liste joueurs", "Pour voir la liste des joueurs", {RightLabel = "→→→"},true, function()
            end, RMenu:Get('admin', 'listej'))
            
        end, function()
        end)

    		RageUI.IsVisible(RMenu:Get('admin', 'perso'), true, true, true, function()
            RageUI.Button("NoClip", "Pour activer/désactiver le noclip", {RightLabel = "~g~ON~b~/~r~OFF"}, true, function(Hovered, Active, Selected)
                if (Selected) then      
                noclipActive = not noclipActive

            if IsPedInAnyVehicle(PlayerPedId(), false) then
                noclipEntity = GetVehiclePedIsIn(PlayerPedId(), false)
            else
                noclipEntity = PlayerPedId()
            end

            SetEntityCollision(noclipEntity, not noclipActive, not noclipActive)
            FreezeEntityPosition(noclipEntity, noclipActive)
            SetEntityInvincible(noclipEntity, noclipActive)
            SetVehicleRadioEnabled(noclipEntity, not noclipActive) -- [[Stop radio from appearing when going upwards.]]
        	end
            end)
            RageUI.Button("Fantome", "Pour activer le mode fantome", {RightLabel = "~g~ON~b~/~r~OFF"}, true, function(Hovered, Active, Selected)
                if (Selected) then       
               -- SetEntityVisible(PlayerPedId(), false, false)
               Admin.ghostmode = not Admin.ghostmode

				if Admin.ghostmode then
				SetEntityVisible(PlayerPedId(), false, false)
				ESX.ShowNotification('MODE FANTOME ON')
				else
				SetEntityVisible(PlayerPedId(), true, false)
				ESX.ShowNotification('MODE FANTOME OFF')
				end
                
                end
            end)
            RageUI.Button("Invincible", "Pour activer le godmode", {RightLabel = "~g~ON~b~/~r~OFF"}, true, function(Hovered, Active, Selected)
                if (Selected) then       
               -- SetEntityVisible(PlayerPedId(), false, false)
               Admin.godmode = not Admin.godmode

                if Admin.godmode then
                SetEntityInvincible(PlayerPedId(), true)
                ESX.ShowNotification('GODMODE ON')
                else
                SetEntityInvincible(PlayerPedId(), false)
                ESX.ShowNotification('GODMODE OFF')
                end
                
                end
            end)
            RageUI.Button("Coordonnées", "Pour afficher/enlever les coords", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                Admin.showcoords = not Admin.showcoords    
                end   
                end)
            RageUI.Button("Crosshair", "Pour mettre/enlever un crosshair", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                Admin.showcrosshair = not Admin.showcrosshair  
                end      
            end)
            RageUI.Button("ID joueur", "Pour mettre/enlever l'ID sur la tête des joueurs", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                Admin.showName = not Admin.showName

			if not showname then
				for k, v in pairs(Admin.gamerTags) do
					RemoveMpGamerTag(v)
					Admin.gamerTags[k] = nil
				end
			end  
                end      
            end)
            RageUI.Button("Revive", "Pour revive quelqu'un", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local previve = KeyboardInput('id du joueur', '', 3)
                ExecuteCommand('revive', previve)
                end      
            end)
            RageUI.Button("Give armes", "Pour se give toute les armes", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                TriggerServerEvent('haciadmin:allweapon')
                end      
            end)
            RageUI.Button("Retirer armes", "Pour se give toute les armes", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                TriggerServerEvent('haciadmin:removeweapon')
                end      
            end)
            RageUI.Button("TP Marker", "Pour se tp au marker", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                TeleportToWaypoint() 
                end      
            end)
        end, function()
        end)
    		RageUI.IsVisible(RMenu:Get('admin', 'ped'), true, true, true, function()
            RageUI.Button("Normal", "Pour se remettre en normal", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                    local isMale = skin.sex == 0


                    TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
                        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                            TriggerEvent('skinchanger:loadSkin', skin)
                            TriggerEvent('esx:restoreLoadout')
                    end)
                    end)
                    end)
            end
            end)
        
			RageUI.Button("Singe", "Pour se mettre en singe", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local j1 = PlayerId()
    			local p1 = GetHashKey('a_c_chimp')
    			RequestModel(p1)
    			while not HasModelLoaded(p1) do
      			  Wait(100)
   				 end
   				 SetPlayerModel(j1, p1)
   				 SetModelAsNoLongerNeeded(p1)
   				 ESX.ShowNotification('Tu est maintenant un singe')
                end      
            end)
            RageUI.Button("Danseuse", "Pour se mettre en danseuse", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local j1 = PlayerId()
    			local p1 = GetHashKey('csb_stripper_01')
    			RequestModel(p1)
    			while not HasModelLoaded(p1) do
      			  Wait(100)
   				 end
   				 SetPlayerModel(j1, p1)
   				 SetModelAsNoLongerNeeded(p1)
   				 ESX.ShowNotification('Tu est maintenant une danseuse')
                end      
            end)
            RageUI.Button("Cosmonaute", "Pour se mettre en cosmonaute", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local j1 = PlayerId()
    			local p1 = GetHashKey('s_m_m_movspace_01')
    			RequestModel(p1)
    			while not HasModelLoaded(p1) do
      			  Wait(100)
   				 end
   				 SetPlayerModel(j1, p1)
   				 SetModelAsNoLongerNeeded(p1)
   				 ESX.ShowNotification('Tu est maintenant un cosmonaute')
                end      
            end)
             RageUI.Button("Alien", "Pour se mettre en alien", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local j1 = PlayerId()
    			local p1 = GetHashKey('s_m_m_movalien_01')
    			RequestModel(p1)
    			while not HasModelLoaded(p1) do
      			  Wait(100)
   				 end
   				 SetPlayerModel(j1, p1)
   				 SetModelAsNoLongerNeeded(p1)
   				 ESX.ShowNotification('Tu est maintenant un alien')
                end      
            end)
             RageUI.Button("Chat", "Pour se mettre en chat", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local j1 = PlayerId()
                local p1 = GetHashKey('a_c_cat_01')
                RequestModel(p1)
                while not HasModelLoaded(p1) do
                  Wait(100)
                 end
                 SetPlayerModel(j1, p1)
                 SetModelAsNoLongerNeeded(p1)
                 ESX.ShowNotification('Tu est maintenant un chat')
                end      
            end)
             RageUI.Button("Aigle", "Pour se mettre en aigle", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local j1 = PlayerId()
                local p1 = GetHashKey('a_c_chickenhawk')
                RequestModel(p1)
                while not HasModelLoaded(p1) do
                  Wait(100)
                 end
                 SetPlayerModel(j1, p1)
                 SetModelAsNoLongerNeeded(p1)
                 ESX.ShowNotification('Tu est maintenant un aigle')
                end      
            end)
             RageUI.Button("Coyote", "Pour se mettre en coyote", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local j1 = PlayerId()
                local p1 = GetHashKey('a_c_coyote')
                RequestModel(p1)
                while not HasModelLoaded(p1) do
                  Wait(100)
                 end
                 SetPlayerModel(j1, p1)
                 SetModelAsNoLongerNeeded(p1)
                 ESX.ShowNotification('Tu est maintenant un coyote')
                end      
            end)
             RageUI.Button("A choisir", "Pour choisir un ped", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local j1 = PlayerId()
                local newped = KeyboardInput('ped a choisir', '', 45)
                local p1 = GetHashKey(newped)
                RequestModel(p1)
                while not HasModelLoaded(p1) do
                  Wait(100)
                 end
                 SetPlayerModel(j1, p1)
                 SetModelAsNoLongerNeeded(p1)
                 ESX.ShowNotification('c bon c changer')
                end      
            end)
        end, function()
        end)
		RageUI.IsVisible(RMenu:Get('admin', 'particule'), true, true, true, function()
             RageUI.Button("Trainée noir", "Pour avoir une trainée noir sur un véhicule", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local ped = PlayerPedId()
                local particleDictionary = "core"
                local particleName = "veh_exhaust_truck_rig"
                local loopAmount = 25
                RequestNamedPtfxAsset(particleDictionary)
                while not HasNamedPtfxAssetLoaded(particleDictionary) do
                    Citizen.Wait(0)
                end
                local particleEffects = {}
                for x=0,loopAmount do
                    UseParticleFxAssetNextCall(particleDictionary)
                    local particle = StartParticleFxLoopedOnEntity(particleName, GetVehiclePedIsIn(ped, false), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                    table.insert(particleEffects, 1, particle)
                    Citizen.Wait(0)
                end
                ESX.ShowNotification('trainée noir ok')
                end      
            end)
        end, function()
        end)
    	RageUI.IsVisible(RMenu:Get('admin', 'voiture'), true, true, true, function()
    		RageUI.Button("Retourner", "Pour retourner la voiture", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local plyCoords = GetEntityCoords(plyPed)
			local newCoords = plyCoords + vector3(0.0, 2.0, 0.0)
			local closestVeh = GetClosestVehicle(plyCoords, 10.0, 0, 70)

			SetEntityCoords(closestVeh, newCoords)
			ESX.ShowNotification('voiture retourné')
		  
                end      
            end)
            RageUI.Button("Boost", "Pour booster la voiture", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                FullVehicleBoost()  
                end      
            end)
            RageUI.Button("Plaque", "Pour changer la plaque de la voiture", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local newname = KeyboardInput('nouvelle plaque 8 caractères', '', 8) -- 8 = le max de lettre possible dans une plaque
                    SetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false) , newname)
                end      
            end)
            RageUI.Button("Gravité", "Pour changer la gravité de la voiture", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local gravite = KeyboardInput('choisi la gravité en chiffre', '', 4) -- 8 = le max de lettre possible dans une plaque
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleGravityAmount(vehicle, gravite)
                end      
            end)
            RageUI.Button("Supprimer", "Pour supprimer la voiture", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                ExecuteCommand('dv')
                end      
            end)
            RageUI.Button("Réparer", "Pour réparer la voiture", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)
			SetVehicleFixed(plyVeh)
			SetVehicleDirtLevel(plyVeh, 0.0) 
                end   
            end)   
            RageUI.Button("Custom", "Pour custom la voiture", {RightLabel = "→→→"},true, function()
            end, RMenu:Get('admin', 'customcar')) 
        end, function()
        end)
        RageUI.IsVisible(RMenu:Get('admin', 'customcar'), true, true, true, function()
            RageUI.Button("Couleur", "Pour les couleurs", {RightLabel = "→→→"},true, function()
            end, RMenu:Get('admin', 'couleur')) 
            RageUI.Button("Néon", "Pour les néons", {RightLabel = "→→→"},true, function()
            end, RMenu:Get('admin', 'neon'))    
       end, function()
        end)
		RageUI.IsVisible(RMenu:Get('admin', 'couleur'), true, true, true, function()
    		RageUI.Button("Bleu", "Couleur bleu", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleCustomPrimaryColour(vehicle, 0, 0, 255)
                SetVehicleCustomSecondaryColour(vehicle, 0, 0, 255)
                end      
            end)
            RageUI.Button("Rouge", "Couleur rouge", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleCustomPrimaryColour(vehicle, 255, 0, 0)
                SetVehicleCustomSecondaryColour(vehicle, 255, 0, 0)
                end      
            end)
            RageUI.Button("Vert", "Couleur verte", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleCustomPrimaryColour(vehicle, 0, 255, 0)
                SetVehicleCustomSecondaryColour(vehicle, 0, 255, 0)
                end      
            end)
            RageUI.Button("Noir", "Couleur noir", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
                SetVehicleCustomSecondaryColour(vehicle, 0, 0, 0)
                end      
            end)
            RageUI.Button("Rose", "Couleur rose", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleCustomPrimaryColour(vehicle, 100, 0, 60)
                SetVehicleCustomSecondaryColour(vehicle, 100, 0, 60)
                end      
            end)
            RageUI.Button("Blanc", "Couleur blanc", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleCustomPrimaryColour(vehicle, 255, 255, 255)
                SetVehicleCustomSecondaryColour(vehicle, 255, 255, 255)
                end      
            end)
    	 
       end, function()
        end)
        RageUI.IsVisible(RMenu:Get('admin', 'neon'), true, true, true, function()
            RageUI.Button("Activer néon", "Pour activer les néons sur cette voiture", {RightLabel = "~g~ON"}, true, function(Hovered, Active, Selected)
              
             if (Selected) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleNeonLightEnabled(vehicle, 0, true)
                SetVehicleNeonLightEnabled(vehicle, 1, true)
                SetVehicleNeonLightEnabled(vehicle, 2, true)
                SetVehicleNeonLightEnabled(vehicle, 3, true)
             end
            end)
            RageUI.Button("Désactiver néon", "Pour désactiver les néons sur cette voiture", {RightLabel = "~r~OFF"}, true, function(Hovered, Active, Selected)
              
             if (Selected) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 3, false)
             end
            end)
            RageUI.Button("Néon rouge", "", {RightLabel = ""}, true, function(Hovered, Active, Selected)
              
             if (Selected) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleNeonLightsColour(vehicle, 255, 0, 0)
             end
            end)
            RageUI.Button("Néon vert", "", {RightLabel = ""}, true, function(Hovered, Active, Selected)
              
             if (Selected) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleNeonLightsColour(vehicle, 0, 255, 0)
             end
            end)
            RageUI.Button("Néon bleu", "", {RightLabel = ""}, true, function(Hovered, Active, Selected)
              
             if (Selected) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleNeonLightsColour(vehicle, 0, 0, 255)
             end
            end)
            RageUI.Button("Néon blanc", "", {RightLabel = ""}, true, function(Hovered, Active, Selected)
              
             if (Selected) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleNeonLightsColour(vehicle, 255, 255, 255)
             end
            end)
            RageUI.Button("Néon rose", "", {RightLabel = ""}, true, function(Hovered, Active, Selected)
              
             if (Selected) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleNeonLightsColour(vehicle, 100, 0, 60)
             end
            end)
       end, function()
        end)
    	RageUI.IsVisible(RMenu:Get('admin', 'listej'), true, true, true, function()
              for k,v in ipairs(ServersIdSession) do
                if GetPlayerName(GetPlayerFromServerId(v)) == "**Pas connecter**" then table.remove(ServersIdSession, k) end
                RageUI.Button("[ID : "..v.."~s~] - ~r~"..GetPlayerName(GetPlayerFromServerId(v)), nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        IdSelected = v
                    end
                end, RMenu:Get('admin', 'gestj'))
            end
    	
       end, function()
        end)
        RageUI.IsVisible(RMenu:Get('admin', 'gestj'), true, true, true, function()
        RageUI.Button("~r~Joueur~s~: ".. GetPlayerName(GetPlayerFromServerId(IdSelected)) .." [ID : "..IdSelected.."]", nil, {}, true, function(Hovered, Active, Selected)
        end)    
        RageUI.Button("~r~Spectate ~s~ : ".. GetPlayerName(GetPlayerFromServerId(IdSelected)) .." ", nil, {}, true, function(Hovered, Active, Selected)
                if (Selected) then
				local playerId = GetPlayerFromServerId(IdSelected)
                    SpectatePlayer(GetPlayerPed(playerId),playerId,GetPlayerName(playerId))
                end
            end)
        RageUI.Button("~r~Se TP à ~s~ : ".. GetPlayerName(GetPlayerFromServerId(IdSelected)) .." ", nil, {}, true, function(Hovered, Active, Selected)
            if (Selected) then
                SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected))))
                ESX.ShowNotification('~b~Vous venez de vous TP à~s~ '.. GetPlayerName(GetPlayerFromServerId(IdSelected)) ..'')
            end
        end)
        RageUI.Button("~r~Kick ~s~ : ".. GetPlayerName(GetPlayerFromServerId(IdSelected)) .." ", nil, {}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    ESX.ShowNotification('~b~Vous venez de kick ~s~ '.. GetPlayerName(GetPlayerFromServerId(IdSelected)) ..'! Aucun retour posible .')
                Citizen.Wait(3500) 
                    TriggerServerEvent('haciadmin:kickjoueur', IdSelected)
                end
            end)
       end, function()
        end)
            Citizen.Wait(0)
        end
    end)

	



 --------------------------------------------




   function FullVehicleBoost()
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
		SetVehicleModKit(vehicle, 0)
		SetVehicleMod(vehicle, 14, 0, true)
		SetVehicleNumberPlateTextIndex(vehicle, 5)
		ToggleVehicleMod(vehicle, 18, true)
		SetVehicleColours(vehicle, 0, 0)
		SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
		SetVehicleModColor_2(vehicle, 5, 0)
		SetVehicleExtraColours(vehicle, 111, 111)
		SetVehicleWindowTint(vehicle, 2)
		ToggleVehicleMod(vehicle, 22, true)
		SetVehicleMod(vehicle, 23, 11, false)
		SetVehicleMod(vehicle, 24, 11, false)
		SetVehicleWheelType(vehicle, 120)
		SetVehicleWindowTint(vehicle, 3)
		ToggleVehicleMod(vehicle, 20, true)
		SetVehicleTyreSmokeColor(vehicle, 0, 0, 0)
		LowerConvertibleRoof(vehicle, true)
		SetVehicleIsStolen(vehicle, false)
		SetVehicleIsWanted(vehicle, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetCanResprayVehicle(vehicle, true)
		SetPlayersLastVehicle(vehicle)
		SetVehicleFixed(vehicle)
		SetVehicleDeformationFixed(vehicle)
		SetVehicleTyresCanBurst(vehicle, false)
		SetVehicleWheelsCanBreak(vehicle, false)
		SetVehicleCanBeTargetted(vehicle, false)
		SetVehicleExplodesOnHighExplosionDamage(vehicle, false)
		SetVehicleHasStrongAxles(vehicle, true)
		SetVehicleDirtLevel(vehicle, 0)
		SetVehicleCanBeVisiblyDamaged(vehicle, false)
		IsVehicleDriveable(vehicle, true)
		SetVehicleEngineOn(vehicle, true, true)
		SetVehicleStrong(vehicle, true)
		RollDownWindow(vehicle, 0)
		RollDownWindow(vehicle, 1)
		SetVehicleNeonLightEnabled(vehicle, 0, true)
		SetVehicleNeonLightEnabled(vehicle, 1, true)
		SetVehicleNeonLightEnabled(vehicle, 2, true)
		SetVehicleNeonLightEnabled(vehicle, 3, true)
		SetVehicleNeonLightsColour(vehicle, 0, 0, 255)
		
		SetPedCanBeDraggedOut(PlayerPedId(), false)
		SetPedStayInVehicleWhenJacked(PlayerPedId(), true)
		SetPedRagdollOnCollision(PlayerPedId(), false)
		ResetPedVisibleDamage(PlayerPedId())
		ClearPedDecorations(PlayerPedId())
		SetIgnoreLowPriorityShockingEvents(PlayerPedId(), true)
	end
end



    Citizen.CreateThread(function()
    while true do
    	if Admin.showcoords then
            x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
            roundx=tonumber(string.format("%.2f",x))
            roundy=tonumber(string.format("%.2f",y))
            roundz=tonumber(string.format("%.2f",z))
            DrawTxt("~r~X:~s~ "..roundx,0.05,0.00)
            DrawTxt("     ~r~Y:~s~ "..roundy,0.11,0.00)
            DrawTxt("        ~r~Z:~s~ "..roundz,0.17,0.00)
            DrawTxt("             ~r~Angle:~s~ "..GetEntityHeading(PlayerPedId()),0.21,0.00)
        end
        if Admin.showcrosshair then
            DrawTxt('+', 0.495, 0.484, 1.0, 0.3, MainColor)
        end
    	Citizen.Wait(0)
    end
end)
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
                if group == true then 
                    if IsControlJustPressed(1,57) then
                        RageUI.Visible(RMenu:Get('admin', 'main'), not RageUI.Visible(RMenu:Get('admin', 'main')))
                    end
                end
       		 end
    end)

Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
                if group == true then 
                    if IsControlPressed(1, 19) and IsControlJustPressed(1, 26) then
                        TeleportToWaypoint() 
                    end
                end
       		 end
    end)