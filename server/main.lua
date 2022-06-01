local QBCore = exports['qb-core']:GetCoreObject()

-- get player information
local function GetPlayerInfo(Player)
	local info = {}
	info.cid = Player.PlayerData.cid
	info.source = Player.PlayerData.source
	info.citizenid = Player.PlayerData.citizenid
	info.username = Player.PlayerData.name
	info.firstname = Player.PlayerData.charinfo.firstname
	info.lastname = Player.PlayerData.charinfo.lastname
	info.fullname = Player.PlayerData.charinfo.firstname ..' '.. Player.PlayerData.charinfo.lastname
	info.license = QBCore.Functions.GetIdentifier(Player.PlayerData.source, 'license')
	return info
end

-- Find Player Vehicles owned.
local function FindPlayerVehicles(citizenid, cb)
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ?", {citizenid}, function(rs)
        for k, v in pairs(rs) do 
			vehicles[#vehicles+1] = {vehicle = json.decode(v.data), plate = v.plate, citizenid = v.citizenid, citizenname = v.citizenname, model = v.model, fuel = v.fuel, oil = v.oil} 
		end
		cb(vehicles)
    end)
end

-- Find All Player Boats owned
local function FindPlayerBoats(citizenid, cb)
    local boats = {}
    MySQL.Async.fetchAll("SELECT * FROM player_boats WHERE citizenid = ?", {citizenid}, function(rs)
        for k, v in pairs(rs) do 
			boats[#boats+1] = {citizenid = v.citizenid, plate = v.plate, model = v.model, fuel = v.fuel } 
		end
		cb(boats)
    end)
end

-- Refresh client local vehicles entities.
local function RefreshVehicles(src)
    if src == nil then src = -1 end
        local vehicles = {}
        MySQL.Async.fetchAll("SELECT * FROM player_parking", {}, function(rs)
        if type(rs) == 'table' and #rs > 0 then
            for k, v in pairs(rs) do
                vehicles[#vehicles+1] = {vehicle = json.decode(v.data), plate = v.plate, citizenid = v.citizenid, citizenname = v.citizenname, model = v.model, fuel = v.fuel, oil = v.oil}
				TriggerEvent('vehiclekeys:server:SetVehicleOwnerToCitizenid', v.plate, v.citizenid)
            end
            TriggerClientEvent("qb-parking:client:refreshVehicles", src, vehicles)
        end
    end)
end

-- Save Data
local function SaveData(Player, data)
	local player = GetPlayerInfo(Player)
	MySQL.Async.execute("INSERT INTO player_parking (citizenid, citizenname, plate, fuel, oil, model, data, time) VALUES (?,?,?,?,?,?,?,?)", {
		player.citizenid, player.fullname, data.plate, data.fuel, data.oil, data.model, json.encode(data), os.time()
	})
	MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = ? AND citizenid = ?', {
		data.plate, player.citizenid
	})
	TriggerClientEvent("qb-parking:client:addVehicle", -1, {
		vehicle = data, plate = data.plate, fuel = data.fuel, oil = data.oil, citizenid = player.citizenid, citizenname = player.fullname, model = data.model
	})
end

-- Delete Parked Vehicle
local function DeleteParkedVehicle(citizenid, plate)
	MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ? AND citizenid = ?', {plate, citizenid})
	MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ? AND citizenid = ?', {plate, citizenid})
end

-- Add Vip
local function AddVip(source, id)
	local player = GetPlayerInfo(QBCore.Functions.GetPlayer(id))
	MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = ?", {player.citizenid}, function(rs)
		if type(rs) == 'table' and #rs > 0 then
			TriggerClientEvent('QBCore:Notify', source, Lang:t('system.already_vip'), "error")
		else
			MySQL.Async.execute("INSERT INTO player_parking_vips (citizenid, citizenname) VALUES (?, ?)", {player.citizenid, player.fullname})
			TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_add', {username = player.fullname}), "success")
		end
	end)
end

-- Remove Vip
local function RemoveVip(source, id)
	local player = GetPlayerInfo(QBCore.Functions.GetPlayer(id))
	MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = ?", {player.citizenid}, function(rs)
		if type(rs) == 'table' and #rs > 0 then
			MySQL.Async.execute('DELETE FROM player_parking_vips WHERE citizenid = ?', {player.citizenid})
			TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_remove', {username = player.fullname}), "success")
		else
			TriggerClientEvent('QBCore:Notify', source, Lang:t('system.vip_not_found'), "error")
		end
	end)
end

local function checkVersion(err, responseText, headers)
    curVersion = LoadResourceFile(GetCurrentResourceName(), "version")
    if responseText == nil then
        print("^1"..resourceName.." check for updates failed ^7")
        return
    end
    if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
        updateavail = true
        print("\n^1----------------------------------------------------------------------------------^7")
        print(resourceName.." is outdated, latest version is: ^2"..responseText.."^7, installed version: ^1"..curVersion.."^7!\nupdate from https://github.com"..updatePath.."")
        print("^1----------------------------------------------------------------------------------^7")
    elseif tonumber(curVersion) > tonumber(responseText) then
        print("\n^3----------------------------------------------------------------------------------^7")
        print(resourceName.." git version is: ^2"..responseText.."^7, installed version: ^1"..curVersion.."^7!")
        print("^3----------------------------------------------------------------------------------^7")
    else
        print("\n"..resourceName.." is up to date. (^2"..curVersion.."^7)")
    end
end

-- Add Vip Command
QBCore.Commands.Add(Config.Command.addvip, Lang:t("commands.addvip"), {{name='ID', help='The id of the player you want to add.'}}, true, function(source, args)
	if args[1] and tonumber(args[1]) > 0 then
		local id = tonumber(args[1])
		if id > 0 then AddVip(source, id) end
	end
end, 'admin')

-- Remove Vip Command
QBCore.Commands.Add(Config.Command.removevip, Lang:t("commands.removevip"), {{name='ID', help='The id of the player you want to remove.'}}, true, function(source, args)
	if args[1] and tonumber(args[1]) > 0 then
		local id = tonumber(args[1])
		if id > 0 then RemoveVip(source, id) end
	end
end, 'admin')

-- Save
QBCore.Functions.CreateCallback("qb-parking:server:save", function(source, cb, data)
    if Config.UseParkingSystem then
		local player = GetPlayerInfo(QBCore.Functions.GetPlayer(source))
		local isFound = false
		FindPlayerVehicles(player.citizenid, function(vehicles) -- free for all
			for k, v in pairs(vehicles) do if type(v.plate) and data.plate == v.plate then isFound = true end end
			if isFound then
				MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = ? AND plate = ?", {player.citizenid, data.plate}, function(rs)
					if type(rs) == 'table' and #rs > 0 then
						cb({status = false, message = Lang:t("info.car_already_parked")})
					else
						SaveData(QBCore.Functions.GetPlayer(source), data)
						cb({status = true, message = Lang:t("success.parked")})
					end
				end)	
			else 
				FindPlayerBoats(player.citizenid, function(boats) 
					for k, v in pairs(boats) do if type(v.plate) and data.plate == v.plate then isFound = true end end
					if isFound then
						SaveData(QBCore.Functions.GetPlayer(source), data)
						cb({status = true, message = Lang:t("success.parked")})
					else
						cb({status = false, message = Lang:t("info.must_own_car")})
					end
				end)
			end
		end)
	else 
		cb({status = false, message = Lang:t("system.offline")})
    end
end)

-- Drive
QBCore.Functions.CreateCallback("qb-parking:server:drive", function(source, cb, data)
    if Config.UseParkingSystem then
		local player = GetPlayerInfo(QBCore.Functions.GetPlayer(source))
		local isFound = false
		FindPlayerVehicles(player.citizenid, function(vehicles)
			for k, v in pairs(vehicles) do if type(v.plate) and data.plate == v.plate then isFound = true end end
			if isFound then
				MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = ? AND plate = ?", { player.citizenid, data.plate }, function(rs)
					if type(rs) == 'table' and #rs > 0 and rs[1] then
						DeleteParkedVehicle(player.citizenid, data.plate)
						cb({status = true, message = Lang:t("info.has_take_the_car"), data = json.decode(rs[1].data), fuel = rs[1].fuel})
						TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = data.plate })
					end
				end)
			else
				FindPlayerBoats(player.citizenid, function(boats) 
					for k, v in pairs(boats) do if type(v.plate) and data.plate == v.plate then isFound = true end end
					if isFound then
						MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = ? AND plate = ?", {player.citizenid, data.plate }, function(rs)
							if type(rs) == 'table' and #rs > 0 and rs[1] then
								DeleteParkedVehicle(player.citizenid, data.plate)
								cb({status = true, message = Lang:t("info.has_take_the_car"), data = json.decode(rs[1].data), fuel = rs[1].fuel})
								TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = data.plate })
							end
						end)
					else
						cb({status = false, message = Lang:t("info.must_own_car")})
					end
				end)				
			end
		end)
    else 
		cb({status = false, message = Lang:t("system.offline")})
    end
end)

-- Park Vehicle Action
QBCore.Functions.CreateCallback("qb-parking:server:vehicle_action", function(source, cb, plate, action)
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = ?", {plate}, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ?', {plate})
			if action == 'impound' then
				MySQL.Async.execute('UPDATE player_vehicles SET state = 2 WHERE plate = ?', {plate})
			else
				MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ?', {plate})
			end
			TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = plate })
			cb({status = true})
		else
			cb({status  = false, message = Lang:t("info.car_not_found")})
		end
    end)
end)

-- Allow To Park
QBCore.Functions.CreateCallback('qb-parking:server:allowtopark', function(source, cb)
	local server_allowed, player_allowed, allowed, text = false, false, false, nil
	local player = GetPlayerInfo(QBCore.Functions.GetPlayer(source))
	local server_total = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM player_vehicles WHERE state = 3')
	local player_total = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM player_vehicles WHERE citizenid=? AND state = ?', {player.citizenid, 3})
	if Config.UseMaxParkingOnServer then
		if server_total < Config.MaxServerParkedVehicles then server_allowed = true else text = Lang:t('info.maximum_cars', {amount = Config.MaxServerParkedVehicles}) end
		if server_allowed and Config.UseMaxParkingPerPlayer then if player_total < Config.MaxStreetParkingPerPlayer then player_allowed = true else text = Lang:t('info.limit_for_player', {amount = Config.MaxStreetParkingPerPlayer}) end end
		if server_allowed then if player_allowed then allowed = true end end
	else
		if Config.UseMaxParkingPerPlayer then  
			if player_total < Config.MaxStreetParkingPerPlayer then player_allowed = true else text = Lang:t('info.limit_for_player', {amount = Config.MaxStreetParkingPerPlayer}) end
		else
			if Config.UseForVipOnly then 
				local isVip = MySQL.Sync.fetchScalar('SELECT * FROM player_parking_vips WHERE citizenid = ?', {player.citizenid})
				if isVip and isVip >= 1 then player_allowed = true else text = Lang:t('system.no_permission') end	
			end
		end
		if player_allowed then allowed = true end
	end
	cb({status = allowed, message = text})
end)

-- Reset state and counting to stay in sync.
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(2000)
		print("[qb-parking] - parked vehicles state check reset.")
		MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE state = 0 OR state = 1 OR state = 2", {
		}, function(vehicles)
			if type(vehicles) == 'table' and #vehicles > 0 then
				for _, vehicle in pairs(vehicles) do
					MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = ?", {vehicle.plate}, function(rs)
						if type(rs) == 'table' and #rs > 0 then
							for _, v in pairs(rs) do
								MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ?', {vehicle.plate})
								MySQL.Async.execute('UPDATE player_vehicles SET state = ? WHERE plate = ?', {Config.ResetState, vehicle.plate})					
							end
						end
					end)
				end
			end
		end)
    end
end)

if Config.CheckForUpdates then
    Citizen.CreateThread( function()
        updatePath = "/MaDHouSe79/qb-parkinglite"
        resourceName = "("..GetCurrentResourceName()..")"
        PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
    end)
end

-- Refresh vehicles.
RegisterServerEvent('qb-parking:server:refreshVehicles', function(parkingName) RefreshVehicles(source) end)
