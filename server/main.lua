local QBCore = exports['qb-core']:GetCoreObject()

-------------------------------------------Local Function----------------------------------------

-- get player information
local function GetPlayerInfo(Player)
	local info = {}
	info.source    = Player.source
	info.citizenid = Player.PlayerData.citizenid
	info.username  = Player.PlayerData.name
	info.firstname = Player.PlayerData.charinfo.firstname
	info.lastname  = Player.PlayerData.charinfo.lastname
	info.fullname  = Player.PlayerData.charinfo.firstname ..' '.. Player.PlayerData.charinfo.lastname
	return info
end

-- Get all vehicles the player owned.
local function FindPlayerVehicles(citizenid, cb)
    local vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = ?", {citizenid}, function(rs)
        for k, v in pairs(rs) do
			vehicles[#vehicles+1] = {vehicle = json.decode(v.data), plate = v.plate, citizenid = v.citizenid, citizenname = v.citizenname, model = v.model, fuel = v.fuel,oil = v.oil}
        end
        cb(vehicles)
    end)
end

local function FindPlayerBoats(citizenid, cb)
    local boats = {}
    MySQL.Async.fetchAll("SELECT * FROM player_boats WHERE citizenid = ?", {citizenid}, function(rs)
        for k, v in pairs(rs) do
			boats[#boats+1] = { citizenid = v.citizenid, plate = v.plate}
        end  
    end)
	cb(boats)
end

-- Get the number of the vehicles.
local function GetVehicleNumOfParking()
    local rs = MySQL.Async.fetchAll('SELECT id FROM player_parking', {})
    if type(rs) == 'table' then return #rs else return 0 end
end

-- Refresh client local vehicles entities.
local function RefreshVehicles(src)
    if src == nil then src = -1 end
        local vehicles = {}
		local player = GetPlayerInfo(QBCore.Functions.GetPlayer(src))
        MySQL.Async.fetchAll("SELECT * FROM player_parking", {}, function(rs)
        if type(rs) == 'table' and #rs > 0 then
            for k, v in pairs(rs) do
                vehicles[#vehicles+1] = {vehicle = json.decode(v.data), plate = v.plate, citizenid = v.citizenid, citizenname = v.citizenname, model = v.model, fuel = v.fuel, oil = v.oil}
                if Player ~= nil and player.citizenid == v.citizenid then
					TriggerEvent('vehiclekeys:client:SetVehicleOwnerToCitizenid', v.plate, v.citizenid)
                end
            end
            TriggerClientEvent("qb-parking:client:refreshVehicles", src, vehicles)
        end
    end)
end

local function SaveData(player, data)
	local player = GetPlayerInfo(player)
	MySQL.Async.execute("INSERT INTO player_parking (citizenid, citizenname, plate, fuel, oil, model, data, time) VALUES (?,?,?,?,?,?,?,?)", {
		player.citizenid,
		player.fullname,
		data.plate,
		data.fuel,
		data.oil,
		data.model,
		json.encode(data),
		os.time()
	})
	MySQL.Async.execute('UPDATE player_vehicles SET state = 3 WHERE plate = ? AND citizenid = ?', {data.plate, player.citizenid})
	TriggerClientEvent("qb-parking:client:addVehicle", -1, {
		vehicle     = data,
		plate       = data.plate, 
		fuel        = data.fuel,
		oil         = data.oil,
		citizenid   = player.citizenid, 
		citizenname = player.fullname,
		model       = data.model
	})
end
--------------------------------------------Callbacks--------------------------------------------
QBCore.Commands.Add(Config.Command.addvip, Lang:t("commands.addvip"), {{name='ID', help='The id of the player you want to add.'}}, true, function(source, args)
	if args[1] and tonumber(args[1]) > 0 then
		local id = tonumber(args[1])
		if id > 0 then
			local player = GetPlayerInfo(QBCore.Functions.GetPlayer(id))
			MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = ?", {player.citizenid}, function(rs)
				if type(rs) == 'table' and #rs > 0 then
					TriggerClientEvent('QBCore:Notify', player.source, Lang:t('system.already_vip'), "error")
				else
					MySQL.Async.execute("INSERT INTO player_parking_vips (citizenid, citizenname) VALUES (?, ?)", {player.citizenid, player.username})
					TriggerClientEvent('QBCore:Notify', player.source, Lang:t('system.vip_add', {username = player.username}), "success")
				end
			end)
		end
	end
end, 'admin')

QBCore.Commands.Add(Config.Command.removevip, Lang:t("commands.removevip"), {{name='ID', help='The id of the player you want to remove.'}}, true, function(source, args)
	if args[1] and tonumber(args[1]) > 0 then
		local id = tonumber(args[1])
		if id > 0 then
			local player = GetPlayerInfo(QBCore.Functions.GetPlayer(id))
			MySQL.Async.fetchAll("SELECT * FROM player_parking_vips WHERE citizenid = ?", {player.citizenid}, function(rs)
				if type(rs) == 'table' and #rs > 0 then
					MySQL.Async.execute('DELETE FROM player_parking_vips WHERE citizenid = ?', {player.citizenid})
					TriggerClientEvent('QBCore:Notify', player.source, Lang:t('system.vip_remove', {username = player.fullname}), "success")
				else
					TriggerClientEvent('QBCore:Notify', player.source, Lang:t('system.vip_not_found'), "error")
				end
			end)
		end
	end
end, 'admin')

-- Save the car to database
QBCore.Functions.CreateCallback("qb-parking:server:save", function(source, cb, data)
    if UseParkingSystem then
		local player  = GetPlayerInfo(QBCore.Functions.GetPlayer(source))
		local isFound = false
		FindPlayerVehicles(player.citizenid, function(vehicles) -- free for all
			for k, v in pairs(vehicles) do
				if type(v.plate) and data.plate == v.plate then
					isFound = true
				end		
			end
			if isFound then
				MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = ? AND plate = ?", {player.citizenid, data.plate}, function(rs)
					if type(rs) == 'table' and #rs > 0 then
						cb({
							status  = false,
							message = Lang:t("info.car_already_parked"),
						})
					else
						if #rs < Config.MaxServerParkedVehicles then
							SaveData(QBCore.Functions.GetPlayer(source), data)
							cb({ 
								status  = true, 
								message = Lang:t("success.parked"),
							})
						else 
							cb({ 
								status  = true, 
								message = Lang:t("info.maximum_cars", {value = Config.MaxServerParkedVehicles}),
							})
						end
					end
				end)	
			else 
				FindPlayerBoats(player.citizenid, function(boats) 
					for k, v in pairs(boats) do
						if type(v.plate) and data.plate == v.plate then
							isFound = true
						end		
					end
					if isFound then
						SaveData(QBCore.Functions.GetPlayer(source), data)
						cb({status  = true, message = Lang:t("success.parked")})
					else
						cb({status  = false, message = Lang:t("info.must_own_car")})
					end
				end)
			end
		end)
	else 
		cb({
			status  = false,
			message = Lang:t("system.offline"),
		})
    end
end)

-- When player request to drive the car
QBCore.Functions.CreateCallback("qb-parking:server:drive", function(source, cb, data)
    if UseParkingSystem then
		local src = source
		local player = GetPlayerInfo(QBCore.Functions.GetPlayer(src))
		local isFound = false
		FindPlayerVehicles(player.citizenid, function(vehicles)
			for k, v in pairs(vehicles) do
				if type(v.plate) and data.plate == v.plate then
					isFound = true
				end
			end
			if isFound then
				MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = ? AND plate = ?", {player.citizenid, data.plate}, function(rs)
					if type(rs) == 'table' and #rs > 0 and rs[1] then
						MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ? AND citizenid = ?', { data.plate, player.citizenid})
						MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ? AND citizenid = ?', { data.plate, player.citizenid})
						cb({
							status  = true,
							message = Lang:t("info.has_take_the_car"),
							data    = json.decode(rs[1].data),
							fuel    = rs[1].fuel
						})
						TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = data.plate })
					end
				end)
			else
				FindPlayerBoats(player.citizenid, function(boats) 
					for k, v in pairs(boats) do
						if type(v.plate) and data.plate == v.plate then
							isFound = true
						end
					end
					if isFound then
						MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE citizenid = ? AND plate = ?", {player.citizenid, data.plate}, function(rs)
							if type(rs) == 'table' and #rs > 0 and rs[1] then
								MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ? AND citizenid = ?', {data.plate, player.citizenid})
								MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ? AND citizenid = ?', {data.plate, player.citizenid})
								cb({
									status  = true,
									message = Lang:t("info.has_take_the_car"),
									data    = json.decode(rs[1].data),
									fuel    = rs[1].fuel
								})
								TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = data.plate })
							end
						end)
					else
						cb({
							status  = false,
							message = Lang:t("info.must_own_car"),
						})
					end
				end)				
			end
		end)
    else 
		cb({
			status  = false,
			message = Lang:t("system.offline"),
		})
    end
end)

QBCore.Functions.CreateCallback("qb-parking:server:vehicle_action", function(source, cb, plate, action)
    MySQL.Async.fetchAll("SELECT * FROM player_parking WHERE plate = ?", {plate}, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			MySQL.Async.execute('DELETE FROM player_parking WHERE plate = ?', {plate})
			if action == 'impound' then
				MySQL.Async.execute('UPDATE player_vehicles SET state = 2 WHERE plate = ?', {plate})
			else
				MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = @plate', {["@plate"] = plate})
			end
			TriggerClientEvent("qb-parking:client:deleteVehicle", -1, { plate = plate })
			cb({ status  = true })
		else
			cb({
				status  = false,
				message = Lang:t("info.car_not_found"),
			})
		end
    end)
end)

QBCore.Functions.CreateCallback('qb-parking:server:allowtopark', function(source, cb)
	local server_allowed, player_allowed, allowed, text = false, false, false, nil
	local player = GetPlayerInfo(QBCore.Functions.GetPlayer(source))
	local server_total = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM player_vehicles WHERE state = ?', {3})
	local player_total = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM player_vehicles WHERE citizenid = ? AND state = ?', {player.citizenid, 3})
	if Config.UseMaxParkingOnServer then -- is server limiter is true
		if server_total < Config.MaxServerParkedVehicles then -- if total server parked vehicles is lower then Config value
			server_allowed = true -- set server allow to park
		else
			text = Lang:t('info.maximum_cars', {amount = Config.MaxServerParkedVehicles})
		end
		if server_allowed and Config.UseMaxParkingPerPlayer then -- if server is allowd to park and player parking limiter is true
			if player_total < Config.MaxStreetParkingPerPlayer then -- if the total parking is lower then the config value
				player_allowed = true -- set player allow to park
			else
				text = Lang:t('info.limit_for_player', {amount = Config.MaxStreetParkingPerPlayer})
			end
		end
		if server_allowed then -- if true 
			if player_allowed then -- if true
				allowed = true -- set allow to park
				text = nil -- remove text
			end
		end
	else -- id the server has not limiter
		if Config.UseMaxParkingPerPlayer then -- but if a player has a park limiter 
			if player_total < Config.MaxStreetParkingPerPlayer then -- is the total parking is lower then the config value
				player_allowed = true -- set player allow to park
			else
				text = Lang:t('info.limit_for_player', {amount = Config.MaxStreetParkingPerPlayer})
			end
		else
			if Config.UseForVipOnly then -- only allow for vip players
				local isVip = MySQL.Sync.fetchScalar('SELECT * FROM player_parking_vips WHERE citizenid = ?', {player.citizenid})
				if isVip and isVip >= 1 then
					player_allowed = true -- set player allow to park 	
				else
					player_allowed = false
					text = Lang:t('system.no_permission')
				end	
			end
		end
		if player_allowed then
			allowed = true
			text = nil
		end
	end
	cb({
		status = allowed, 
		message = text
	})
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

-- When the client request to refresh the vehicles.
RegisterServerEvent('qb-parking:server:refreshVehicles', function(parkingName)
    RefreshVehicles(source)
end)
