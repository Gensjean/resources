local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX                             = nil
local GUI                       = {}
GUI.Time                        = 0
local PlayerData                = {}
local FirstSpawn                = true
local IsDead                    = false
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local RespawnToHospitalMenu     = nil
local OnJob                     = false
local CurrentCustomer           = nil
local CurrentCustomerBlip       = nil
local DestinationBlip           = nil
local IsNearCustomer            = false
local CustomerIsEnteringVehicle = false
local CustomerEnteredVehicle    = false
local TargetCoords              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	Citizen.Wait(5000)
	PlayerData = ESX.GetPlayerData()
end)

function DrawSub(msg, time)
	ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(msg)
	DrawSubtitleTimed(time, 1)
  end
  
  function ShowLoadingPromt(msg, time, type)
	Citizen.CreateThread(function()
	  Citizen.Wait(0)
	  N_0xaba17d7ce615adbf("STRING")
	  AddTextComponentString(msg)
	  N_0xbd12f8228410d9b4(type)
	  Citizen.Wait(time)
	  N_0x10d373323e5b9c0d()
	end)
  end
  
  function GetRandomWalkingNPC()
  
	local search = {}
	local peds   = ESX.Game.GetPeds()
  
	for i=1, #peds, 1 do
	  if IsPedHuman(peds[i]) and IsPedWalking(peds[i]) and not IsPedAPlayer(peds[i]) then
		table.insert(search, peds[i])
	  end
	end
  
	if #search > 0 then
	  return search[GetRandomIntInRange(1, #search)]
	end
  
	print('Using fallback code to find walking ped')
  
	for i=1, 250, 1 do
  
	  local ped = GetRandomPedAtCoord(0.0,  0.0,  0.0,  math.huge + 0.0,  math.huge + 0.0,  math.huge + 0.0,  26)
  
	  if DoesEntityExist(ped) and IsPedHuman(ped) and IsPedWalking(ped) and not IsPedAPlayer(ped) then
		table.insert(search, ped)
	  end
  
	end
  
	if #search > 0 then
	  return search[GetRandomIntInRange(1, #search)]
	end
  
  end
  
  function ClearCurrentMission()
  
	if DoesBlipExist(CurrentCustomerBlip) then
	  RemoveBlip(CurrentCustomerBlip)
	end
  
	if DoesBlipExist(DestinationBlip) then
	  RemoveBlip(DestinationBlip)
	end
  
	CurrentCustomer           = nil
	CurrentCustomerBlip       = nil
	DestinationBlip           = nil
	IsNearCustomer            = false
	CustomerIsEnteringVehicle = false
	CustomerEnteredVehicle    = false
	TargetCoords              = nil
  
  end
  
  function StartAmbulanceJob()
  
	ShowLoadingPromt(_U('taking_service') .. 'Ambulance', 5000, 3)
	ClearCurrentMission()
  
	OnJob = true
  
  end
  
  function StopAmbulanceJob()
  
	local playerPed = GetPlayerPed(-1)
  
	if IsPedInAnyVehicle(playerPed, false) and CurrentCustomer ~= nil then
	  local vehicle = GetVehiclePedIsIn(playerPed,  false)
	  TaskLeaveVehicle(CurrentCustomer,  vehicle,  0)
  
	  if CustomerEnteredVehicle then
		TaskGoStraightToCoord(CurrentCustomer,  TargetCoords.x,  TargetCoords.y,  TargetCoords.z,  1.0,  -1,  0.0,  0.0)
	  end
  
	end
  
	ClearCurrentMission()
  
	OnJob = false
  
	DrawSub(_U('mission_complete'), 5000)
  
  end

function RespawnPed(ped, coords)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
	ClearPedBloodDamage(ped)

	ESX.UI.Menu.CloseAll()
end

RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(_type)
	local playerPed = GetPlayerPed(-1)
	local maxHealth = GetEntityMaxHealth(playerPed)
	if _type == 'small' then
		local health = GetEntityHealth(playerPed)
		local newHealth = math.min(maxHealth , math.floor(health + maxHealth/8))
		SetEntityHealth(playerPed, newHealth)
	elseif _type == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end
	ESX.ShowNotification(_U('healed'))
end)

-- Disable most inputs when dead
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsDead then
			-- DisableAllControlActions(0)
			EnableControlAction(0, Keys['T'], true)
			EnableControlAction(0, Keys['F10'], true)
			EnableControlAction(0, Keys['BACKSPACE'], true)
			EnableControlAction(0, Keys['PAGEUP'], true)
			EnableControlAction(0, Keys['PAGEDOWN'], true)
			EnableControlAction(0, Keys['LEFT'], true)
			EnableControlAction(0, Keys['RIGHT'], true)
			EnableControlAction(0, Keys['TOP'], true)
			EnableControlAction(0, Keys['DOWN'], true)
			DisableControlAction(0, Keys['F1'], true)
		else
			Citizen.Wait(500)
		end
	end
end)

function StartRespawnTimer()
	Citizen.SetTimeout(Config.RespawnDelayAfterRPDeath, function()
		if IsDead then
			RemoveItemsAfterRPDeath()
		end
	end)
end

function StartDistressSignal()
	Citizen.CreateThread(function()
		local timer = Config.RespawnDelayAfterRPDeath

		while timer > 0 and IsDead do
			Citizen.Wait(2)
			timer = timer - 30

			SetTextFont(4)
			SetTextProportional(1)
			SetTextScale(0.45, 0.45)
			SetTextColour(185, 185, 185, 255)
			SetTextDropShadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(_U('distress_send'))
			EndTextCommandDisplayText(0.400, 0.745)

			if IsControlPressed(0, Keys['G']) then
				SendDistressSignal()
				break
			end
		end
	end)
end

function SendDistressSignal()
	local playerPed = PlayerPedId()
	PedPosition		= GetEntityCoords(playerPed)
	
	local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }

	ESX.ShowNotification(_U('distress_sent'))

    TriggerServerEvent('call:makeCall', 'ambulance', _U('distress_message'), PlayerCoords, {

		PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
	})
end

function ShowDeathTimer()
	local respawnTimer = Config.RespawnDelayAfterRPDeath
	local allowRespawn = Config.RespawnDelayAfterRPDeath/2
	local fineAmount = Config.EarlyRespawnFineAmount
	local payFine = false

	if Config.EarlyRespawn and Config.EarlyRespawnFine then
		ESX.TriggerServerCallback('esx_ambulancejob:checkBalance', function(finePayable)
			if finePayable then
				payFine = true
			else
				payFine = false
			end
		end)
	end

	Citizen.CreateThread(function()
		while respawnTimer > 0 and IsDead do
			Citizen.Wait(0)

			raw_seconds = respawnTimer/1000
			raw_minutes = raw_seconds/60
			minutes = stringsplit(raw_minutes, ".")[1]
			seconds = stringsplit(raw_seconds-(minutes*60), ".")[1]

			SetTextFont(4)
			SetTextProportional(0)
			SetTextScale(0.0, 0.5)
			SetTextColour(255, 255, 255, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()

			local text = _U('please_wait', minutes, seconds)

			if Config.EarlyRespawn then
				if not Config.EarlyRespawnFine and respawnTimer <= allowRespawn then
					text = text .. _U('press_respawn')
				elseif Config.EarlyRespawnFine and respawnTimer <= allowRespawn and payFine then
					text = text .. _U('respawn_now_fine', fineAmount)
				else
					text = text
				end
			end

			SetTextCentre(true)
			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(0.5, 0.8)

			if Config.EarlyRespawn then
				if not Config.EarlyRespawnFine then
					if IsControlPressed(0, Keys['E']) then
						RemoveItemsAfterRPDeath()
						break
					end
				elseif Config.EarlyRespawnFine then
					if respawnTimer <= allowRespawn and payFine then
						if IsControlPressed(0, Keys['E']) then
							PayFine()
							break
						end
					end
				end
			end
			respawnTimer = respawnTimer - 15
		end
	end)
end

function RemoveItemsAfterRPDeath()
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end

		ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
			ESX.SetPlayerData('lastPosition', Config.Zones.Respawn.Pos)
			ESX.SetPlayerData('loadout', {})

			TriggerServerEvent('esx:updateLastPosition', Config.Zones.Respawn.Pos)
			RespawnPed(GetPlayerPed(-1), Config.Zones.Respawn.Pos)

			StopScreenEffect('DeathFailOut')
			DoScreenFadeIn(800)
		end)
	end)
end

function PayFine()
	ESX.TriggerServerCallback('esx_ambulancejob:payFine', function()
	RemoveItemsAfterRPDeath()
	end)
end

function OnPlayerDeath()
	IsDead = true
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 1)

	if Config.ShowDeathTimer == true then
		ShowDeathTimer()
	end

	StartRespawnTimer()
	StartDistressSignal()

	ClearPedTasksImmediately(GetPlayerPed(-1))
	StartScreenEffect('DeathFailOut', 0, false)
end

function TeleportFadeEffect(entity, coords)

	Citizen.CreateThread(function()

		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.Teleport(entity, coords, function()
			DoScreenFadeIn(800)
		end)

	end)

end

function WarpPedInClosestVehicle(ped)

	local coords = GetEntityCoords(ped)

	local vehicle, distance = ESX.Game.GetClosestVehicle({
		x = coords.x,
		y = coords.y,
		z = coords.z
	})

	if distance ~= -1 and distance <= 5.0 then

		local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
		local freeSeat = nil

		for i=maxSeats - 1, 0, -1 do
			if IsVehicleSeatFree(vehicle, i) then
				freeSeat = i
				break
			end
		end

		if freeSeat ~= nil then
			TaskWarpPedIntoVehicle(ped, vehicle, freeSeat)
		end

	else
		ESX.ShowNotification(_U('no_vehicles'))
	end

end

function OpenAmbulanceActionsMenu()

	local elements = {
		{label = _U('cloakroom'), value = 'cloakroom'}
	}

	if Config.EnablePlayerManagement and PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'ambulance_actions',
		{
			title		= _U('ambulance'),
			align		= 'top-left',
			elements	= elements
		},
		function(data, menu)

			if data.current.value == 'cloakroom' then
				OpenCloakroomMenu()
			end

			if data.current.value == 'boss_actions' then
				TriggerEvent('esx_society:openAlyniaBMenu', 'ambulance', function(data, menu)
					menu.close()
				end, {wash = false})
			end

		end,
		function(data, menu)

			menu.close()

			CurrentAction		= 'ambulance_actions_menu'
			CurrentActionMsg	= _U('open_menu')
			CurrentActionData	= {}

		end
	)

end

function OpenMobileAmbulanceActionsMenu()

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'mobile_ambulance_actions',
	{
		title		= _U('ambulance'),
		align		= 'top-left',
		elements	= {
			{label = _U('ems_menu'), value = 'citizen_interaction'},
			{ label = _U('billing'),   value = 'billing' }			
		}
	}, function(data, menu)

		if data.current.value == 'billing' then

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = _U('invoice_amount')
			}, function(data, menu)

				local amount = tonumber(data.value)
				if amount == nil then
					ESX.ShowNotification(_U('amount_invalid'))
				else
					menu.close()
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players_near'))
					else
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_ambulance', 'Ambulance', amount)
						ESX.ShowNotification(_U('billing_sent'))
					end

				end

			end, function(data, menu)
				menu.close()
			end)

		elseif data.current.value == 'citizen_interaction' then
			ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'citizen_interaction',
			{
				title		= _U('ems_menu_title'),
				align		= 'top-left',
				elements	= {
					{label = _U('ems_menu_revive'), value = 'revive'},
					{label = _U('ems_menu_small'), value = 'small'},
					{label = _U('ems_menu_big'), value = 'big'},
					{label = _U('ems_menu_pickup'), value = 'drag'},
				}
			}, function(data, menu)
				if IsBusy then return end
				if data.current.value == 'revive' then -- revive

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(qtty)
							if qtty > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health == 0 then
									local playerPed = GetPlayerPed(-1)

									IsBusy = true
									ESX.ShowNotification(_U('revive_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									exports['progressBars']:startUI(10000, "Réanimation en cour ...")
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
									TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
									IsBusy = false

									-- Show revive award?
									if Config.ReviveReward > 0 then
										ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(closestPlayer), Config.ReviveReward))
									else
										ESX.ShowNotification(_U('revive_complete', GetPlayerName(closestPlayer)))
									end
								else
									ESX.ShowNotification(_U('player_not_unconscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_medikit'))
							end
						end, 'medikit')
					end
				elseif data.current.value == 'small' then

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(qtty)
							if qtty > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = GetPlayerPed(-1)

									IsBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									exports['progressBars']:startUI(10000, "Soins en cour ...")
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									IsBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_bandage'))
							end
						end, 'bandage')
					end
				elseif data.current.value == 'big' then

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(qtty)
							if qtty > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = GetPlayerPed(-1)

									IsBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									exports['progressBars']:startUI(10000, "Soins en cour ...")
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									IsBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_medikit'))
							end
						end, 'medikit')
					end
				elseif data.current.value == 'drag' then

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification('Il y a personne ici')
					else
						menu.close()
						TriggerEvent('esx_barbie_lyftupp')
					end
				end
			end, function(data, menu)
				menu.close()
			end)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function OpenCloakroomMenu()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'cloakroom',
		{
			title		= _U('cloakroom'),
			align		= 'top-left',
			elements = {
				{label = _U('ems_clothes_civil'), value = 'citizen_wear'},
				{label = _U('ems_clothes_ems'), value = 'ambulance_wear'},
			},
		},
		function(data, menu)

			menu.close()

			if data.current.value == 'citizen_wear' then

				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					TriggerEvent('skinchanger:loadSkin', skin)
					TriggerServerEvent("player:serviceOff", "ambulance")
				end)

			end

			if data.current.value == 'ambulance_wear' then

				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
						TriggerServerEvent("player:serviceOn", "ambulance")
					else
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
						TriggerServerEvent("player:serviceOn", "ambulance")
					end

				end)

			end

			CurrentAction		= 'ambulance_actions_menu'
			CurrentActionMsg	= _U('open_menu')
			CurrentActionData	= {}

		end,
		function(data, menu)
			menu.close()
		end
	)

end

function OpenVehicleSpawnerMenu()

	ESX.UI.Menu.CloseAll()

	if Config.EnableSocietyOwnedVehicles then

		local elements = {}

		ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(vehicles)

			for i=1, #vehicles, 1 do
				table.insert(elements, {label = GetDisplayNameFromVehicleModel(vehicles[i].model) .. ' [' .. vehicles[i].plate .. ']', value = vehicles[i]})
			end

			ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'vehicle_spawner',
			{
				title		= _U('veh_menu'),
				align		= 'top-left',
				elements = elements,
			}, function(data, menu)
				menu.close()

				local vehicleProps = data.current.value
				ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, 270.0, function(vehicle)
					ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
					local playerPed = GetPlayerPed(-1)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				end)
				TriggerServerEvent('esx_society:removeVehicleFromGarage', 'ambulance', vehicleProps)

			end, function(data, menu)
				menu.close()
				CurrentAction		= 'vehicle_spawner_menu'
				CurrentActionMsg	= _U('veh_spawn')
				CurrentActionData	= {}
			end
			)
		end, 'ambulance')

	else -- not society vehicles

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'vehicle_spawner',
		{
			title		= _U('veh_menu'),
			align		= 'top-left',
			elements	= Config.AuthorizedVehicles
		}, function(data, menu)
			menu.close()
			ESX.Game.SpawnVehicle(data.current.model, Config.Zones.VehicleSpawnPoint.Pos, 230.0, function(vehicle)
				local playerPed = GetPlayerPed(-1)
				local plate = GetVehicleNumberPlateText(vehicle)
				ESX.ShowAdvancedNotification('Hôpital de Los Santos', 'Christine', 'Voici la clé du véhicule immatriculé~g~ ' .. plate .. '~s~, bonne route !', 'CHAR_HITCHER_GIRL', 8)
				TriggerServerEvent('esx_vehiclelock3:givekey', 'no', plate) -- vehicle lock
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			end)
		end, function(data, menu)
			menu.close()
			CurrentAction		= 'vehicle_spawner_menu'
			CurrentActionMsg	= _U('veh_spawn')
			CurrentActionData	= {}
		end
		)
	end
end

function OpenPharmacyMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'pharmacy',
	{
		title		= _U('pharmacy_menu_title'),
		align		= 'top-left',
		elements = {
			{label = _U('pharmacy_take') .. ' ' .. _('medikit'), value = 'medikit'},
			{label = _U('pharmacy_take') .. ' ' .. _('doliprane'), value = 'doliprane'},
			{label = _U('pharmacy_take') .. ' ' .. _('bandage'), value = 'bandage'}
		},
	}, function(data, menu)
		TriggerServerEvent('esx_ambulancejob:giveItem', data.current.value)
		TriggerClientEvent('esx:showAdvancedNotification', source, 'Hôpital de Los Santos', 'Christine', 'Voici ce que vous aviez demandé, bonne journée !', 'CHAR_HITCHER_GIRL', 3)

	end, function(data, menu)
		menu.close()
		CurrentAction		= 'pharmacy'
		CurrentActionMsg	= _U('open_pharmacy')
		CurrentActionData	= {}
	end
	)
end

AddEventHandler('playerSpawned', function()
	IsDead = false

	if FirstSpawn then
		TriggerServerEvent('esx_ambulancejob:firstSpawn')
		exports.spawnmanager:setAutoSpawn(false) -- disable respawn
		FirstSpawn = false
	end
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)

	local specialContact = {
	name		= 'Ambulance',
	number		= 'ambulance',
	base64Icon	= 'data:image/png;base64,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'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)

end)

AddEventHandler('esx:onPlayerDeath', function(reason)
	OnPlayerDeath()
end)


RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()

	local playerPed = GetPlayerPed(-1)
	local coords	= GetEntityCoords(playerPed)
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)

	Citizen.CreateThread(function()

	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Citizen.Wait(0)
	end

	ESX.SetPlayerData('lastPosition', {
		x = coords.x,
		y = coords.y,
		z = coords.z
	})

	TriggerServerEvent('esx:updateLastPosition', {
		x = coords.x,
		y = coords.y,
		z = coords.z
	})

	RespawnPed(playerPed, {
		x = coords.x,
		y = coords.y,
		z = coords.z
	})

	StopScreenEffect('DeathFailOut')

	DoScreenFadeIn(800)

	end)

end)


AddEventHandler('esx_ambulancejob:hasEnteredMarker', function(zone)

	if zone == 'HospitalInteriorEntering2' then
		local heli = Config.HelicopterSpawner

		if not IsAnyVehicleNearPoint(heli.SpawnPoint.x, heli.SpawnPoint.y, heli.SpawnPoint.z, 3.0) and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
			ESX.Game.SpawnVehicle('polmav', {
				x = heli.SpawnPoint.x,
				y = heli.SpawnPoint.y,
				z = heli.SpawnPoint.z
			}, heli.Heading, function(vehicle)
				SetVehicleModKit(vehicle, 0)
				SetVehicleLivery(vehicle, 1)
			end)

		end
		
	end

	if zone == 'StairsGoTopBottom' then
		CurrentAction		= 'fast_travel_goto_top'
		CurrentActionMsg	= _U('fast_travel')
		CurrentActionData	= {pos = Config.Zones.StairsGoTopTop.Pos}
	end

	if zone == 'StairsGoBottomTop' then
		CurrentAction		= 'fast_travel_goto_bottom'
		CurrentActionMsg	= _U('fast_travel')
		CurrentActionData	= {pos = Config.Zones.StairsGoBottomBottom.Pos}
	end

	if zone == 'AmbulanceActions' then
		CurrentAction		= 'ambulance_actions_menu'
		CurrentActionMsg	= _U('open_menu')
		CurrentActionData	= {}
	end

	if zone == 'BossActions' then
		CurrentAction		= 'boss_actions_menu'
		CurrentActionMsg	= _U('open_menu')
		CurrentActionData	= {}
	end

	if zone == 'VehicleSpawner' then
		CurrentAction		= 'vehicle_spawner_menu'
		CurrentActionMsg	= _U('veh_spawn')
		CurrentActionData	= {}
	end

	if zone == 'Pharmacy' then
		CurrentAction		= 'pharmacy'
		CurrentActionMsg	= _U('open_pharmacy')
		CurrentActionData	= {}
	end

	if zone == 'VehicleDeleter' then

		local playerPed = GetPlayerPed(-1)
		local coords	= GetEntityCoords(playerPed)

		if IsPedInAnyVehicle(playerPed, false) then

			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = coords.x,
				y = coords.y,
				z = coords.z
			})

			if distance ~= -1 and distance <= 1.0 then

				CurrentAction		= 'delete_vehicle'
				CurrentActionMsg	= _U('store_veh')
				CurrentActionData	= {vehicle = vehicle}

			end

		end

	end

end)

function FastTravel(pos)
		TeleportFadeEffect(GetPlayerPed(-1), pos)
end

AddEventHandler('esx_ambulancejob:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

-- Create blips
Citizen.CreateThread(function()

	local blip = AddBlipForCoord(Config.Blip.Pos.x, Config.Blip.Pos.y, Config.Blip.Pos.z)

	SetBlipSprite(blip, Config.Blip.Sprite)
	SetBlipDisplay(blip, Config.Blip.Display)
	SetBlipScale(blip, Config.Blip.Scale)
	SetBlipColour(blip, Config.Blip.Colour)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('hospital'))
	EndTextCommandSetBlipName(blip)

end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local coords = GetEntityCoords(GetPlayerPed(-1))
		for k,v in pairs(Config.Zones) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				if PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				elseif k ~= 'AmbulanceActions' and k ~= 'BossActions' and k ~= 'VehicleSpawner' and k ~= 'VehicleDeleter' and k ~= 'Pharmacy' then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		local coords		= GetEntityCoords(GetPlayerPed(-1))
		local isInMarker	= false
		local currentZone	= nil
		for k,v in pairs(Config.Zones) do
			if PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.MarkerSize.x) then
					isInMarker	= true
					currentZone = k
				end
			elseif k ~= 'AmbulanceActions'  and k ~= 'BossActions' and k ~= 'VehicleSpawner' and k ~= 'VehicleDeleter' and k ~= 'Pharmacy' and k ~= 'StairsGoTopBottom' and k ~= 'StairsGoBottomTop' then
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.MarkerSize.x) then
					isInMarker	= true
					currentZone = k
				end
			end
		end
		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			lastZone				= currentZone
			TriggerEvent('esx_ambulancejob:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_ambulancejob:hasExitedMarker', lastZone)
		end
	end
end)

function setUniform(job, playerPed)
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Uniforms[job].male ~= nil then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end

			if job == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		else
			if Config.Uniforms[job].female ~= nil then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].female)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end

			if job == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		end
	end)
end



function OpenGetStocksMenu()

	ESX.TriggerServerCallback('esx_ambulancejob:getStockItems', function(items)


		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		{
			title    = _U('police_stock'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)

			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)

				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_ambulancejob:getStockItem', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksMenu()
				end

			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)

	end)
end

function OpenPutStocksMenu()

	ESX.TriggerServerCallback('esx_ambulancejob:getPlayerInventory', function(inventory)

		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		{
			title    = _U('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)

			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)

				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_ambulancejob:putStockItems', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksMenu()
				end

			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)
	end)

end

function OpenArmoryMenu()
	local elements = {}

	if Config.EnablePlayerManagement then
		table.insert(elements, {label = "Prendre un objet",  value = 'get_stock'})
		table.insert(elements, {label = "Déposer un objet", value = 'put_stock'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory', {
		title    = "Coffre fort",
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		elseif data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		end

	end, function(data, menu)
		menu.close()
	end)
end


_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("L.S.M.C", "Choissisez la catégorie")
_menuPool:Add(mainMenu)

  
-----------------------------------
-- NativeUI - Création des menus --
-----------------------------------

function OpenGarageMenu()

  local grade = PlayerData.job.grade_name

  garageMenu = NativeUI.CreateMenu("L.S.M.C", "Garage")
  _menuPool:Add(garageMenu)

  menu = garageMenu
 
  local cadet = NativeUI.CreateItem("Ambulance", "")
  menu:AddItem(cadet)

  menumbk = menu

  menumbk:Visible(true)

  menu.OnItemSelect = function(sender, item, index)
  	if item == cadet then
  		ESX.ShowAdvancedNotification('Infirmière', 'Christina', 'Je prépare votre véhicule, veuillez patientez encore un peu !', 'CHAR_HITCHER_GIRL', 8)
  		Citizen.Wait(500)
 		ESX.Game.SpawnVehicle("sams1",  Config.Zones.VehicleSpawnPoint.Pos, 30.4249, function(vehicle)
			local voiture = ESX.Game.GetClosestVehicle(player)
			local plate = GetVehicleNumberPlateText(vehicle)
			TriggerServerEvent('esx_vehiclelock:givekey', 'no', plate)
			ESX.ShowAdvancedNotification('Garage', 'Sortie d\'un véhicule', 'Vous avez sorti un véhicule de votre entreprise, voici la plaque: ~g~ ' .. plate .. '~s~ !', 'CHAR_BIKESITE', 8)
			TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

		end)
	elseif item == ambulance then
	  		ESX.ShowAdvancedNotification('Infirmière', 'Christina', 'Je prépare votre véhicule, veuillez patientez encore un peu !', 'CHAR_HITCHER_GIRL', 8)
  		Citizen.Wait(500)
		ESX.Game.SpawnVehicle("ambulance", Config.Zones.VehicleSpawnPoint.Pos, 30.4249, function(vehicle)
			local voiture = ESX.Game.GetClosestVehicle(player)
			local plate = GetVehicleNumberPlateText(vehicle)
			TriggerServerEvent('esx_vehiclelock3:givekey', 'no', plate)
			ESX.ShowAdvancedNotification('Garage', 'Sortie d\'un véhicule', 'Vous avez sorti un véhicule de votre entreprise, voici la plaque: ~g~ ' .. plate .. '~s~ !', 'CHAR_BIKESITE', 8)
			TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

	   end)
  	end
  end
end

function OpenAction()
  local grade = PlayerData.job.grade_name
  local playerPed = PlayerPedId()
  garageMenu = NativeUI.CreateMenu("L.S.M.C", "Vestiaire")
  _menuPool:Add(garageMenu)

  menu = garageMenu
 
  local recuperer = NativeUI.CreateItem("Récupérer ma tenue", "")
  menu:AddItem(recuperer)


  local Prendre = NativeUI.CreateItem("Prendre votre tenue de médecin", "")
  menu:AddItem(Prendre)

  menumbk = menu



  menumbk:Visible(true)
  menu.OnItemSelect = function(sender, item, index)
     if item == recuperer then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
			TriggerEvent('skinchanger:loadSkin', skin)
			TriggerServerEvent("player:serviceOff", "ambulance")
		end)
	ESX.ShowAdvancedNotification('Infirmière', 'Christina', 'Voici votre tenue civile, bonne soirée à vous !', 'CHAR_HITCHER_GIRL', 8)
	elseif item == Prendre then
		TriggerServerEvent("player:serviceOn", "ambulance")
		if grade == 'ambulance' then

			setUniform("ambulance_wear", playerPed)
			ESX.ShowAdvancedNotification('Infirmière', 'Christina', 'Voici votre tenue, enfilez-là dans la cabine !', 'CHAR_HITCHER_GIRL', 8)
			elseif grade == 'doctor' then
			setUniform("doctor_wear", playerPed)
			ESX.ShowAdvancedNotification('Infirmière', 'Christina', 'Voici votre tenue, enfilez-là dans la cabine !', 'CHAR_HITCHER_GIRL', 8)
			elseif grade == 'chief_doctor' then
			setUniform("chief_doctor_wear", playerPed)
			ESX.ShowAdvancedNotification('Infirmière', 'Christina', 'Voici votre tenue, enfilez-là dans la cabine !', 'CHAR_HITCHER_GIRL', 8)
			elseif grade == 'boss' then
			setUniform("boss_wear", playerPed)
			ESX.ShowAdvancedNotification('Infirmière', 'Christina', 'Voici votre tenue, enfilez-là dans la cabine !', 'CHAR_HITCHER_GIRL', 8)
			end
	end
  end
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
	blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
		blockinput = false
        return result
    else
        Citizen.Wait(500)
		blockinput = false
        return nil
    end
end


function facturePaye()
	local plyId = KeyboardInput("JO_JACKY_FACTURE", "Prix de la facture", "", 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			local plyPedCoords = GetEntityCoords(plyPed)
			print(plyId)
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer == -1 or closestDistance > 3.0 then
					ESX.ShowNotification(_U('no_players_near'))
				else
					TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_ambulance', 'Ambulance', plyId)
					ESX.ShowNotification(_U('billing_sent'))
			end
		end
	end
end
-- FIN TP UN JOUEUR A MOI

function OpenActionPatron()
  local grade = PlayerData.job.grade_name

  garageMenu = NativeUI.CreateMenu("L.S.M.C", "Action patron")
  _menuPool:Add(garageMenu)

  menu = garageMenu
 
  local medikit = NativeUI.CreateItem("Gestion entreprise", "")
  menu:AddItem(medikit)


  local bandage = NativeUI.CreateItem("Coffre fort", "Accèder au compte du L.S.M.C")
  menu:AddItem(bandage)

  menumbk = menu

  menumbk:Visible(true)
  menu.OnItemSelect = function(sender, item, index)
     if item == medikit then
		_menuPool:CloseAllMenus()
					TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data, menu)
						menu.close()
					end, { wash = false }) -- disable washing money
	elseif item == bandage then
		_menuPool:CloseAllMenus()
		OpenArmoryMenu()
	end
  end
end

function OpenPharmacy()
  local grade = PlayerData.job.grade_name

  garageMenu = NativeUI.CreateMenu("L.S.M.C", "Pharmacie")
  _menuPool:Add(garageMenu)

  menu = garageMenu
 
  local medikit = NativeUI.CreateItem("Prendre vos kits de soins", "")
  menu:AddItem(medikit)


  local bandage = NativeUI.CreateItem("Prendre vos bandages", "")
  menu:AddItem(bandage)

   local coffre = NativeUI.CreateItem("Coffre fort", "Accèder au compte du L.S.M.C")
  menu:AddItem(coffre)


  menumbk = menu

  menumbk:Visible(true)
  menu.OnItemSelect = function(sender, item, index)
     if item == medikit then
	TriggerServerEvent('esx_ambulancejob:giveItem', "medikit")
	ESX.ShowAdvancedNotification('Infirmière', 'Christina', 'Voici ce que vous aviez demandé, bonne journée !', 'CHAR_HITCHER_GIRL', 8)
	elseif item == bandage then
	TriggerServerEvent('esx_ambulancejob:giveItem', "bandage")
	ESX.ShowAdvancedNotification('Infirmière', 'Christina', 'Voici ce que vous aviez demandé, bonne journée !', 'CHAR_HITCHER_GIRL', 8)
	elseif item == coffre then
		_menuPool:CloseAllMenus()
		OpenArmoryMenu()		
	end
  end
end

function AddActionsMenu(menu)
	persoMenu = _menuPool:AddSubMenu(menu, "Intéractions citoyen", nil, nil, "", "", 255, 255, 255, 200)
	


	local titleBar = NativeUI.CreateItem("                      - Papiers -", "")
	persoMenu.SubMenu:AddItem(titleBar)

	local apItem = NativeUI.CreateItem("Vérifier l'identité de la personne", "")
	persoMenu.SubMenu:AddItem(apItem)

	local titleBars = NativeUI.CreateItem("                  - Interactions -", "")
	persoMenu.SubMenu:AddItem(titleBars)

	local soigner = NativeUI.CreateItem("Soigner les petites blessures", "")
	persoMenu.SubMenu:AddItem(soigner)



	local soignerGrv = NativeUI.CreateItem("Soigner les blessures graves", "")
	persoMenu.SubMenu:AddItem(soignerGrv)

	local rea = NativeUI.CreateItem("Réanimer la personne", "")
	persoMenu.SubMenu:AddItem(rea)

	local porter = NativeUI.CreateItem("Porter la personne", "")
	persoMenu.SubMenu:AddItem(porter)


	local fac = NativeUI.CreateItem("Faire une facture", "")
	persoMenu.SubMenu:AddItem(fac)


	persoMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == apItem then
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
		  if closestPlayer ~= -1 and closestDistance <= 3.0 then
		  	TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(closestPlayer), GetPlayerServerId(PlayerId()))
		  	_menuPool:CloseAllMenus()
		  	else
		 	ESX.ShowNotification(_U('no_players_nearby'))
			end
		elseif item == fac then
			facturePaye()
			_menuPool:CloseAllMenus()
		elseif item == rea then 
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(qtty)
							if qtty > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health == 0 then
									local playerPed = GetPlayerPed(-1)

									IsBusy = true
									ESX.ShowNotification(_U('revive_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									exports['progressBars']:startUI(10000, "Réanimation en cour ...")
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
									TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
									IsBusy = false

									-- Show revive award?
									if Config.ReviveReward > 0 then
										ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(closestPlayer), Config.ReviveReward))
									else
										ESX.ShowNotification(_U('revive_complete', GetPlayerName(closestPlayer)))
									end
								else
									ESX.ShowNotification(_U('player_not_unconscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_medikit'))
							end
						end, 'medikit')
					end
			elseif item == soigner then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(qtty)
							if qtty > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = GetPlayerPed(-1)

									IsBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									exports['progressBars']:startUI(10000, "Soins en cour ...")
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									IsBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_bandage'))
							end
						end, 'bandage')
					end	
			elseif item == soignerGrv then

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(qtty)
							if qtty > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = GetPlayerPed(-1)

									IsBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									exports['progressBars']:startUI(10000, "Soins en cour ...")
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									IsBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_medikit'))
							end
						end, 'medikit')
					end
			elseif item == porter then

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification('Il y a personne ici')
					else
						TriggerEvent('esx_barbie_lyftupp')
					end									
		end
	end
end



function GeneratePersonalMenu()
	local joueur = GetPlayerName(PlayerId(-1))
	_menuPool = NativeUI.CreatePool()

	mainMenu = NativeUI.CreateMenu("L.S.M.C", "Choissisez la catégorie")
	_menuPool:Add(mainMenu)


	AddActionsMenu(mainMenu)

	_menuPool:MouseControlsEnabled(false)
	_menuPool:ControlDisablingEnabled(false)
	_menuPool:RefreshIndex()
end



-- Key Controls
Citizen.CreateThread(function()
	while true do


		if _menuPool then
			_menuPool:ProcessMenus()
		end

		Citizen.Wait(10)



		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlJustReleased(0, Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then

				if CurrentAction == 'ambulance_actions_menu' then
					OpenAction()
				end
				
				if CurrentAction == 'boss_actions_menu' then
					OpenActionPatron()
				end

				if CurrentAction == 'vehicle_spawner_menu' then
					OpenGarageMenu()
				end

				if CurrentAction == 'pharmacy' then
					OpenPharmacy()
				end

				if CurrentAction == 'fast_travel_goto_top' or CurrentAction == 'fast_travel_goto_bottom' then
					FastTravel(CurrentActionData.pos)
				end

				if CurrentAction == 'delete_vehicle' then
					if Config.EnableSocietyOwnedVehicles then
						local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
						TriggerServerEvent('esx_society:putVehicleInGarage', 'ambulance', vehicleProps)
					end
					local voiture = ESX.Game.GetClosestVehicle(player)
					local plate = GetVehicleNumberPlateText(voiture)
					local joueur = GetPlayerName(PlayerId(-1))
					TriggerServerEvent('esx_vehiclelock3:deletekeyjobs', 'no', plate)
					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end

				CurrentAction = nil

			end

		end

		if IsControlJustReleased(0, Keys['F6']) and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' and not IsDead then
			if mainMenu:Visible() then
				mainMenu:Visible(false)
			elseif not mainMenu:Visible() then
				ESX.PlayerData = ESX.GetPlayerData()
				GeneratePersonalMenu()
				mainMenu:Visible(true)
			end
		end

		if IsControlPressed(0,  Keys['DELETE']) and (GetGameTimer() - GUI.Time) > 150 then

			if OnJob then
			  StopAmbulanceJob()
			else
	  
			  if PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
	  
				local playerPed = GetPlayerPed(-1)
	  
				if IsPedInAnyVehicle(playerPed,  false) then
	  
				  local vehicle = GetVehiclePedIsIn(playerPed,  false)
	  
				  if PlayerData.job.grade >= 3 then
					StartAmbulanceJob()
				  else
					if GetEntityModel(vehicle) == GetHashKey('ambulance2') then
					  StartAmbulanceJob()
					else
					  ESX.ShowNotification(_U('must_in_ambulance'))
					end
				  end
	  
				else
	  
				  if PlayerData.job.grade >= 3 then
					ESX.ShowNotification(_U('must_in_vehicle'))
				  else
					ESX.ShowNotification(_U('must_in_ambulance'))
				  end
	  
				end
	  
			  end
	  
			end
	  
			GUI.Time = GetGameTimer()
	  
		  end
		  end
	  end)

RegisterNetEvent('esx_ambulancejob:requestDeath')
AddEventHandler('esx_ambulancejob:requestDeath', function()
	if Config.AntiCombatLog then
		Citizen.Wait(5000)
		SetEntityHealth(GetPlayerPed(-1), 0)
	end
end)

-- String string
function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

Citizen.CreateThread(function()

	while true do
  
	  Citizen.Wait(0)
  
	  local playerPed = GetPlayerPed(-1)
  
	  if OnJob then
  
		if CurrentCustomer == nil then
  
		  DrawSub(_U('drive_search_pass'), 5000)
  
		  if IsPedInAnyVehicle(playerPed,  false) and GetEntitySpeed(playerPed) > 0 then
  
			local waitUntil = GetGameTimer() + GetRandomIntInRange(15000,  20000)
  
			while OnJob and waitUntil > GetGameTimer() do
			  Citizen.Wait(0)
			end
  
			if OnJob and IsPedInAnyVehicle(playerPed,  false) and GetEntitySpeed(playerPed) > 0 then
  
			  CurrentCustomer = GetRandomWalkingNPC()
  
			  if CurrentCustomer ~= nil then
  
				CurrentCustomerBlip = AddBlipForEntity(CurrentCustomer)
  
				SetBlipAsFriendly(CurrentCustomerBlip, 1)
				SetBlipColour(CurrentCustomerBlip, 2)
				SetBlipCategory(CurrentCustomerBlip, 3)
				SetBlipRoute(CurrentCustomerBlip,  true)
  
				SetEntityAsMissionEntity(CurrentCustomer,  true, false)
				ClearPedTasksImmediately(CurrentCustomer)
				SetBlockingOfNonTemporaryEvents(CurrentCustomer, 1)
  
				local standTime = GetRandomIntInRange(20000,  10000)
  
				TaskStandStill(CurrentCustomer, standTime)
  
				ESX.ShowNotification(_U('customer_found'))
  
			  end
  
			end
  
		  end
  
		else
  
		  if IsPedFatallyInjured(CurrentCustomer) then
  
			ESX.ShowNotification(_U('client_unconcious'))
  
			if DoesBlipExist(CurrentCustomerBlip) then
			  RemoveBlip(CurrentCustomerBlip)
			end
  
			if DoesBlipExist(DestinationBlip) then
			  RemoveBlip(DestinationBlip)
			end
  
			SetEntityAsMissionEntity(CurrentCustomer,  false, true)
  
			CurrentCustomer           = nil
			CurrentCustomerBlip       = nil
			DestinationBlip           = nil
			IsNearCustomer            = false
			CustomerIsEnteringVehicle = false
			CustomerEnteredVehicle    = false
		TargetCoords              = nil
  
		  end
  
		  if IsPedInAnyVehicle(playerPed,  false) then
  
			local vehicle          = GetVehiclePedIsIn(playerPed,  false)
			local playerCoords     = GetEntityCoords(playerPed)
			local customerCoords   = GetEntityCoords(CurrentCustomer)
			local customerDistance = GetDistanceBetweenCoords(playerCoords.x,  playerCoords.y,  playerCoords.z,  customerCoords.x,  customerCoords.y,  customerCoords.z)
  
			if IsPedSittingInVehicle(CurrentCustomer,  vehicle) then
  
			  if CustomerEnteredVehicle then
  
				local targetDistance = GetDistanceBetweenCoords(playerCoords.x,  playerCoords.y,  playerCoords.z,  TargetCoords.x,  TargetCoords.y,  TargetCoords.z)
  
				if targetDistance <= 5.0 then
  
				  TaskLeaveVehicle(CurrentCustomer,  vehicle,  0)
  
				  ESX.ShowNotification(_U('arrive_dest'))
  
				  TaskGoStraightToCoord(CurrentCustomer,  TargetCoords.x,  TargetCoords.y,  TargetCoords.z,  1.0,  -1,  0.0,  0.0)
				  SetEntityAsMissionEntity(CurrentCustomer,  false, true)
  
				  TriggerServerEvent('esx_ambulancejob:success')
  
				  RemoveBlip(DestinationBlip)
  
				  local scope = function(customer)
					ESX.SetTimeout(60000, function()
					  DeletePed(customer)
					end)
				  end
  
				  scope(CurrentCustomer)
  
				  CurrentCustomer           = nil
				  CurrentCustomerBlip       = nil
				  DestinationBlip           = nil
				  IsNearCustomer            = false
				  CustomerIsEnteringVehicle = false
				  CustomerEnteredVehicle    = false
				  TargetCoords              = nil
  
				end
  
				if TargetCoords ~= nil then
				  DrawMarker(1, TargetCoords.x, TargetCoords.y, TargetCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 2.0, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
				end
  
			  else
  
				RemoveBlip(CurrentCustomerBlip)
  
				CurrentCustomerBlip = nil
  
				--TargetCoords = Config.JobLocations[GetRandomIntInRange(1,  #Config.JobLocations)]
		  TargetCoords = {x = 362.2872314453,y = -589.1022949219,z = 28.400829315186 }
  
				local street = table.pack(GetStreetNameAtCoord(TargetCoords.x, TargetCoords.y, TargetCoords.z))
				local msg    = nil
  
				if street[2] ~= 0 and street[2] ~= nil then
				  msg = string.format(_U('take_me_to_near', GetStreetNameFromHashKey(street[1]),GetStreetNameFromHashKey(street[2])))
				else
				  msg = string.format(_U('take_me_to', GetStreetNameFromHashKey(street[1])))
				end
  
				ESX.ShowNotification(msg)
  
				DestinationBlip = AddBlipForCoord(TargetCoords.x, TargetCoords.y, TargetCoords.z)
  
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString("Destination")
				EndTextCommandSetBlipName(blip)
  
				SetBlipRoute(DestinationBlip,  true)
  
				CustomerEnteredVehicle = true
  
			  end
  
			else
  
			  DrawMarker(1, customerCoords.x, customerCoords.y, customerCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 2.0, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
  
			  if not CustomerEnteredVehicle then
  
				if customerDistance <= 30.0 then
  
				  if not IsNearCustomer then
					ESX.ShowNotification(_U('close_to_client'))
					IsNearCustomer = true
				  end
  
				end
  
				if customerDistance <= 100.0 then
  
				  if not CustomerIsEnteringVehicle then
  
					ClearPedTasksImmediately(CurrentCustomer)
  
					local seat = 2
  
					for i=4, 0, 1 do
					  if IsVehicleSeatFree(vehicle,  seat) then
						seat = i
						break
					  end
					end
  
					TaskEnterVehicle(CurrentCustomer,  vehicle,  -1,  seat,  2.0,  1)
  
					CustomerIsEnteringVehicle = true
  
				  end
  
				end
  
			  end
  
			end
  
		  else
  
			DrawSub(_U('return_to_veh'), 5000)
  
		  end
  
		end
  
	  end
  
	end
  end)

if IsControlPressed(0,  Keys['F6']) and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' and (GetGameTimer() - GUI.Time) > 150 then
			if mainMenu:Visible() then
				mainMenu:Visible(false)
			elseif not mainMenu:Visible() then
				ESX.PlayerData = ESX.GetPlayerData()
				GeneratePersonalMenu()
				mainMenu:Visible(true)
			end
	GUI.Time = GetGameTimer()
end

