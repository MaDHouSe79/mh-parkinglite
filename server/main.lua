local QBCore = exports['qb-core']:GetCoreObject()
local updateavail = false


-- Get Player username
local function GetUsername(player)
    local tmpName = player.PlayerData.name
    if Config.useRoleplayName then
	tmpName = player.PlayerData.charinfo.firstname ..' '.. player.PlayerData.charinfo.lastname
    end
    return tmpName
end

-- Get Citizenid
local function GetCitizenid(player)
    return player.PlayerData.citizenid
end

-- Get all vehicles the player owned.
local function FindPlayerVehicles(citizenid, cb)
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ?", {citizenid}, function(rs)
        for k, v in pairs(rs) do
	    vehicles[#vehicles+1] = {
		vehicle     = json.decode(v.data),
		plate       = v.plate,
		citizenid   = v.citizenid,
		citizenname = v.citizenname,
		model       = v.model,
		fuel        = v.fuel,
		oil         = v.oil,
	    }
        end
        cb(vehicles)
    end)
end


-- Get the number of the vehicles.
local function GetVehicleNumOfParking()
    local rs = MySQL.Async.fetchAll('SELECT id FROM player_parking', {})
    if type(rs) == 'table' then
        return #rs
    else
        return 0
    end
end

-- Refresh client local vehicles entities.
local function RefreshVehicles(src)
    if src == nil then src = -1 end
        local vehicles = {}
        MySQL.Async.fetchAll("SELECT * FROM player_parking", {}, function(rs)
        if type(rs) == 'table' and #rs > 0 then
            for k, v in pairs(rs) do
                vehicles[#vehicles+1] = {
                    vehicle     = json.decode(v.data),
                    plate       = v.plate,
                    citizenid   = v.citizenid,
                    citizenname = v.citizenname,
                    model       = v.model,
		    fuel        = v.fuel,
		    oil         = v.oil,
                }
                if QBCore.Functions.GetPlayer(src) ~= nil and QBCore.Functions.GetPlayer(src).PlayerData.citizenid == v.citizenid then
                    if not Config.ImUsingOtherKeyScript then
			TriggerClientEvent('mh-parking:client:addkey', v.plate, v.citizenid)
                    end
                end
            end
            TriggerClientEvent("mh-parking:client:refreshVehicles", src, vehicles)
        end
    end)
end

local function SaveData(Player, data)
    MySQL.Async.execute("INSERT INTO player_parking (citizenid, citizenname, plate, fuel, oil, model, data, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {
	GetCitizenid(Player),
	GetUsername(Player),
	data.plate,
	data.fuel,
	data.oil,
	data.model,
	json.encode(data),
	os.time(),
    })
    MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = ? AND citizenid = ?', {data.plate, GetCitizenid(Player)})
    TriggerClientEvent("qb-parking:client:addVehicle", -1, {
	vehicle     = data,
	plate       = data.plate, 
	fuel        = data.fuel,
	oil         = data.oil,
	citizenid   = GetCitizenid(Player), 
	citizenname = GetUsername(Player),
	model       = data.model,
    })
end


-- Save the car to database
QBCore.Functions.CreateCallback("qb-parking:server:save", function(source, cb, vehicleData)
    if UseParkingSystem then
	local src     = source
	local Player  = QBCore.Functions.GetPlayer(src)
	local plate   = vehicleData.plate
	local isFound = false
	FindPlayerVehicles(GetCitizenid(Player), function(vehicles) -- free for all
	    for k, v in pairs(vehicles) do
		if type(v.plate) and plate == v.plate then
		    isFound = true
		end		
	    end
	    if isFound then
		MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = ? AND plate = ?", {GetCitizenid(Player), plate}, function(rs)
		    if type(rs) == 'table' and #rs > 0 then
			cb({status = false, message = Lang:t("info.car_already_parked")})
		    else
			if #rs < Config.Maxcarparking then
			    SaveData(Player, vehicleData)
			    cb({status = true, message = Lang:t("success.parked")})
		        else 
			    cb({status = true, message = Lang:t("info.maximum_cars", {value = Config.Maxcarparking}),})
			end
		    end
		end)	
	    end
	end)
    else 
	cb({status = false, message = Lang:t("system.offline")})
    end
end)

-- When player request to drive the car
QBCore.Functions.CreateCallback("mh-parking:server:drive", function(source, cb, vehicleData)
    if UseParkingSystem then
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local plate = vehicleData.plate
	local isFound = false
	FindPlayerVehicles(GetCitizenid(Player), function(vehicles)
	    for k, v in pairs(vehicles) do
	        if type(v.plate) and plate == v.plate then
		    isFound = true
		end
	    end
	    if isFound then
	        MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = ? AND plate = ?", {GetCitizenid(Player), plate}, function(rs)
		    if type(rs) == 'table' and #rs > 0 and rs[1] then
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ? AND citizenid = ?', {plate, GetCitizenid(Player)})
			MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ? AND citizenid = ?', {plate, GetCitizenid(Player)})
			cb({
			    status  = true,
			    message = Lang:t("info.has_take_the_car"),
			    data    = json.decode(rs[1].data),
			    fuel    = rs[1].fuel,
			})
			TriggerClientEvent("mh-parking:client:deleteVehicle", -1, { plate = plate })
		    end
		end)			
	    end
	end)
    else 
        cb({status = false, message = Lang:t("system.offline")})
    end
end)

QBCore.Functions.CreateCallback("mh-parking:server:vehicle_action", function(source, cb, plate, action)
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = ?", {plate}, function(rs)
	if type(rs) == 'table' and #rs > 0 and rs[1] then
	    MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ?', {plate})
	    if action == 'impound' then
	        MySQL.Async.execute('UPDATE player_vehicles SET state = 2, garage = ? WHERE plate = ? AND citizenid = ?', {'impoundlot', plate, rs[1].citizenid})
	    else
	        MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ?', {plate})
	    end
	    cb({ status  = true })
	    TriggerClientEvent("mh-parking:client:deleteVehicle", -1, { plate = plate })
	else
	    cb({status = false, message = Lang:t("info.car_not_found")})
	end
    end)
end)

-- Reset state and counting to stay in sync.
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(2000)
	print("[qb-parking] - parked vehicles state check reset.")
	MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE state = 0 OR state = 1 OR state = 2", {}, function(vehicles)
            if type(vehicles) == 'table' and #vehicles > 0 then
	        for _, vehicle in pairs(vehicles) do
		    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = ?", {vehicle.plate}, function(rs)
			if type(rs) == 'table' and #rs > 0 then
                            for _, v in pairs(rs) do
				MySQL.Async.execute('DELETE FROM player_parking WHERE plate = @plate', {["@plate"] = vehicle.plate})
				MySQL.Async.execute('UPDATE player_vehicles SET state = @state WHERE plate = @plate', {["@state"] = Config.ResetState, ["@plate"] = vehicle.plate})					
			    end
			end
		    end)
		end
	    end
	end)
    end
end)

-- When the client request to refresh the vehicles.
RegisterServerEvent('mh-parking:server:refreshVehicles', function(parkingName)
    RefreshVehicles(source)
end)
