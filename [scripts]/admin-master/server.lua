ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


local admins = {
    'steam:11000010500c242'
}

function isAdmin(player)
    local allowed = false
    for i,id in ipairs(admins) do
        for x,pid in ipairs(GetPlayerIdentifiers(player)) do
            if string.lower(pid) == string.lower(id) then
                allowed = true
            end
        end
    end
    return allowed
end

RegisterServerEvent('checkadmin')
AddEventHandler('checkadmin', function()
	local id = source
	if isAdmin(id) then
		TriggerClientEvent("setgroup", source)
	end
end)

RegisterNetEvent('haciadmin:allweapon')
AddEventHandler('haciadmin:allweapon', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source) 
    xPlayer.addWeapon('WEAPON_KNIFE', 9999)
    xPlayer.addWeapon('WEAPON_KNUCKLE', 9999)
    xPlayer.addWeapon('WEAPON_NIGHTSTICK', 9999)
    xPlayer.addWeapon('WEAPON_HAMMER', 9999)
    xPlayer.addWeapon('WEAPON_BAT', 9999)
    xPlayer.addWeapon('WEAPON_MACHETE', 9999)
    xPlayer.addWeapon('WEAPON_GRENADE', 9999)
    xPlayer.addWeapon('WEAPON_STICKYBOMB', 9999)
    xPlayer.addWeapon('WEAPON_COMBATPISTOL', 9999)
    xPlayer.addWeapon('WEAPON_STUNGUN', 9999)
    xPlayer.addWeapon('WEAPON_GUSENBERG', 9999)
    xPlayer.addWeapon('WEAPON_RAYCARBINE', 9999)
    xPlayer.addWeapon('WEAPON_SPECIALCARBINE', 9999)
    xPlayer.addWeapon('WEAPON_HEAVYSHOTGUN', 9999)
    xPlayer.addWeapon('WEAPON_DBSHOTGUN', 9999)
    xPlayer.addWeapon('WEAPON_SNIPERRIFLE', 9999)
    xPlayer.addWeapon('WEAPON_GRENADELAUNCHER', 9999)
    xPlayer.addWeapon('WEAPON_RPG', 9999)
    xPlayer.addWeapon('WEAPON_RAILGUN', 9999)
    xPlayer.addWeapon('WEAPON_SMG', 9999)
    TriggerClientEvent('esx:showNotification', source, "~g~tu t'es give toute les armes!")
end)

RegisterNetEvent('haciadmin:removeweapon')
AddEventHandler('haciadmin:removeweapon', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source) 
    
                for i=1, #xPlayer.loadout, 1 do
                xPlayer.removeWeapon(xPlayer.loadout[i].name)
                end
    TriggerClientEvent('esx:showNotification', source, "~r~tu t'es retirer toute les armes!")
end)

RegisterServerEvent('haciadmin:kickjoueur')
AddEventHandler('haciadmin:kickjoueur', function(player)
    DropPlayer(player, "Vous avez été kick ! Plus d'informations sur notre discord.")
end)