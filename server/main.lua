local parkedVehicles = {}
local hasSpawned = false

local function DeleteVehicleAtCoords(location)
    local closestVehicle, closestDistance = GetClosestVehicle(location)
    if closestVehicle ~= -1 and closestDistance <= 2.0 then
        DeleteEntity(closestVehicle)
        while DoesEntityExist(closestVehicle) do
            DeleteEntity(closestVehicle)
            Wait(0)
        end
    end
end

local function CreateVehicle2(model, type, location)
    local veh = CreateVehicleServerSetter(model, type, location.x, location.y, location.z, location.w)
    local netId = NetworkGetNetworkIdFromEntity(veh)
    return veh, netId
end

local function SpawnVehicles(src)
    hasSpawned = true
    parkedVehicles = {}
    local vehicles = nil
    if Config.Framework == 'esx' then
        vehicles = MySQL.query.await("SELECT * FROM owned_vehicles WHERE stored = ?", {3})
        vehicles.state = vehicles.stored
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        vehicles = MySQL.query.await("SELECT * FROM player_vehicles WHERE state = ?", {3})
    end
    if vehicles ~= nil and type(vehicles) == 'table' and #vehicles >= 1 then
        for k, vehicle in pairs(vehicles) do
            if vehicle.location ~= nil then
                if not parkedVehicles[vehicle.plate] then
                    parkedVehicles[vehicle.plate] = {}
                    local location = json.decode(vehicle.location)
                    local mods = json.decode(vehicle.mods)
                    local type = Config.Vehicles[mods.model].type
                    DeleteVehicleAtCoords(vector3(location.x, location.y, location.z))
                    Wait(100)
                    local entity, netid = CreateVehicle2(GetHashKey(vehicle.vehicle), type, location)
                    while not DoesEntityExist(entity) do Wait(0) end
                    local netid = NetworkGetNetworkIdFromEntity(entity)
                    SetVehicleNumberPlateText(entity, mods.plate)
                    local target = GetPlayerDataByCitizenId(vehicle.citizenid)
                    local fullname = target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname
                    parkedVehicles[vehicle.plate] = {fullname = fullname, citizenid = vehicle.citizenid, owner = vehicle.citizenid, netid = netid, entity = entity, mods = mods, hash = vehicle.hash, plate = vehicle.plate, model = vehicle.vehicle, fuel = vehicle.fuel, body = vehicle.body, engine = vehicle.engine, street = vehicle.street, location = location}
                end
            end
        end
        TriggerClientEvent("mh-parkinglite:client:onjoin", -1, {status = true, vehicles = parkedVehicles})
    end
end

local function GetVehicleTypeByModel(model)
    local vehicleData = Config.Vehicles[model]
    if not vehicleData then return 'automobile' end
    local category = vehicleData.category
    local vehicleType = Config.VehicleTypes[category]
    return vehicleType or 'automobile'
end

local function IsPlayerAVip(citizenid)
    local player = nil
    if Config.Framework == 'esx' then
        player = MySQL.query.await("SELECT * FROM users WHERE identifier = ?", {citizenid})[1]
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        player = MySQL.query.await("SELECT * FROM players WHERE citizenid = ?", {citizenid})[1]
    end
    if player ~= nil and player.parkvip ~= nil and player.parkvip == 1 then return true end
    return false
end

local function GetPlayerVipParkMax(citizenid)
    local player = nil
    if Config.Framework == 'esx' then
        player = MySQL.query.await("SELECT * FROM users WHERE identifier = ?", {citizenid})[1]
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        player = MySQL.query.await("SELECT * FROM players WHERE citizenid = ?", {citizenid})[1]
    end
    if player ~= nil and player.parkvip ~= nil and player.parkvip == 1 and player.parkmax ~= nil then return player.parkmax end
    return 0
end

local function GetAmountOfParkedVehiclesByCitizenid(citizenid)
    local result = nil
    if Config.Framework == 'esx' then
        result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ? AND stored = ?", {citizenid, 3})
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        result = MySQL.query.await("SELECT * FROM player_vehicles WHERE citizenid = ? AND state = ?", {citizenid, 3})
    end
    if result ~= nil and #result >= 1 then return tonumber(#result) else return 0 end
end

-- Save the car to database
CreateCallback("mh-parkinglite:server:save", function(source, cb, data)
    local src = source
    local citizenid = GetCitizenId(src)
    local defaultParking = Config.MaxParkingPerPlayer
    local result = nil
    if Config.Framework == 'esx' then
        result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?", {citizenid, data.plate})[1]
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        result = MySQL.query.await("SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?", {citizenid, data.plate})[1]
    end
    if result ~= nil and result.state ~= nil and type(result.state) == 'number' then
        if result.state == 3 then
            cb({status = false, message = Lang:t("info.car_already_parked")})
            return
        elseif result.state == 0 then

            if Config.UseVip then
                local isvip = IsPlayerAVip(citizenid)
                if isvip then
                    defaultParking = GetPlayerVipParkMax(citizenid)
                else
                    cb({status = false, message = "You are not a Parking VIP Member..."})
                    return 
                end
            end

            local count = GetAmountOfParkedVehiclesByCitizenid(citizenid)
            if count >= defaultParking then
                cb({status = false, message = Lang:t("info.limit_parking",{limit = defaultParking})})
                return
            end

            if Config.Framework == 'esx' then
                MySQL.Async.execute('UPDATE owned_vehicles SET stored = ?, location = ?, mods = ?, street = ? WHERE plate = ? AND owner = ?', {3, json.encode(data.location), json.encode(data.mods), data.street, data.plate, citizenid})
            elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                MySQL.Async.execute('UPDATE player_vehicles SET state = ?, location = ?, mods = ?, street = ? WHERE plate = ? AND citizenid = ?', {3, json.encode(data.location), json.encode(data.mods), data.street, data.plate, citizenid})
            end

            local _data = {netid = data.netid, citizenid = result.citizenid, model = result.vehicle, plate = result.plate, body = result.body, engine = result.engine, fuel = result.fuel, street = data.street, location = data.location, mods = json.decode(result.mods)}
            cb({status = true, message = Lang:t("info.vehicle_parked")})
            TriggerClientEvent("mh-parkinglite:client:addVehicle", -1, {status = true, vehicle = _data})
            return
        end
    end
end)

-- When player request to drive the car
CreateCallback("mh-parkinglite:server:drive", function(source, cb, data)
    local src = source
    local Player = GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local isFound = false
    local result = nil
    if Config.Framework == 'esx' then
        result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?", {citizenid, data.plate})[1]
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        result = MySQL.query.await("SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?", {citizenid, data.plate})[1]
    end
    if result ~= nil and result.state ~= nil and type(result.state) == 'number' then
        if result.state == 3 then
            if Config.Framework == 'esx' then
                MySQL.Async.execute('UPDATE owned_vehicles SET stored = ? WHERE plate = ? AND owner = ?', {0, data.plate, citizenid})
            elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
                MySQL.Async.execute('UPDATE player_vehicles SET state = ? WHERE plate = ? AND citizenid = ?', {0, data.plate, citizenid})
            end
            TriggerClientEvent("mh-parkinglite:client:deleteVehicle", -1, {status = true, plate = data.plate})
            cb({status = true, message = Lang:t("info.has_take_the_car")})
            return 
        elseif result.state < 3 then
            cb({status = false, message = Lang:t('info.car_not_found')})
        else
            cb({status = false, message = "Something goes wrong..."})
            return    
        end
    end
end)

CreateCallback('mh-parkinglite:server:spawnvehicle', function(source, cb, plate, model, location)
    local vehType = Config.Vehicles[model] and Config.Vehicles[model].type or GetVehicleTypeByModel(model)
    local veh = CreateVehicleServerSetter(GetHashKey(model), vehType, location.x, location.y, location.z, location.w)
    while not DoesEntityExist(veh) do Wait(1) end
    local netId = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleNumberPlateText(veh, plate)
    local result = nil
    if Config.Framework == 'esx' then
        result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ? LIMIT 1', {plate})[1]
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        result = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ? LIMIT 1', {plate})[1]
    end
    if result then 
        cb({netid = netId, citizenid = result.citizenid, model = result.vehicle, plate = plate, body = result.body, engine = result.engine, fuel = result.fuel, steerangle = result.steerangle, street = result.street, location = location, mods = json.decode(result.mods)})
        return 
    else
        cb(nil)
        return 
    end
end)

CreateCallback("mh-parkinglite:server:GetVehicles", function(source, cb)
    local src = source
    local citizenid = GetCitizenId(src)
    local result = nil
    if Config.Framework == 'esx' then
        result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ? AND stored = ? ORDER BY id ASC", {citizenid, 3})
        result.state = result.stored
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        result = MySQL.query.await("SELECT * FROM player_vehicles WHERE citizenid = ? AND state = ? ORDER BY id ASC", {citizenid, 3})
    end
    cb({status = true, data = result})
end)

RegisterNetEvent('mh-parkinglite:server:AllPlayersLeaveVehicle', function(vehicleNetID, players)
    if players ~= nil and #players >= 1 then
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetID)
        if DoesEntityExist(vehicle) then
            for i = 1, #players, 1 do TriggerClientEvent('mh-parkinglite:client:leaveVehicle', players[i].playerId, {status = true, vehicleNetID = vehicleNetID}) end
        end
    end
end)

AddCommand(Config.Command.parkmenu, "", {}, true, function(source, args)
    local src = source
    TriggerClientEvent('mh-parkinglite:client:OpenParkMenu', src, {status = true})
end)

RegisterServerEvent('mh-parkinglite:server:onjoin', function()
    local src = source
    local players = GetPlayers()
    if #players <= 1 then
        if not hasSpawned then
            hasSpawned = true
            SpawnVehicles(src)
        end
    elseif #players > 1 then
        if not hasSpawned then
            hasSpawned = true
            SpawnVehicles(#players)
        end
    end
    TriggerClientEvent("mh-parkinglite:client:onjoin", src, {status = true, vehicles = parkedVehicles})
end)

---------------------------------------------------------------------------
RegisterNetEvent('police:server:Impound', function(plate, fullImpound, price, body, engine, fuel)
    local src = source
    if parkedVehicles[plate] and parkedVehicles[plate].netid ~= false and parkedVehicles[plate].entity ~= false then
        parkedVehicles[plate] = nil
        TriggerClientEvent("mh-parkinglite:client:deleteVehicle", -1, {status = true, plate = plate})
    end
end)

local function ParkingTimeCheckLoop()
    if Config.UseTimerPark then
        local result = nil
        if Config.Framework == 'esx' then
            result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE stored = 3", {})
        elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
            result = MySQL.query.await("SELECT * FROM player_vehicles WHERE state = 3", {})
        end
        if result ~= nil then
            for k, v in pairs(result) do
                local total = os.time() - v.time
                if v.parktime > 0 and total > v.parktime then
                    print("[MH Parking] - [Time Limit Detection] - Vehicle with plate: ^2" .. v.plate .. "^7 has been impound by the police.")
                    if parkedVehicles[v.plate] and parkedVehicles[v.plate].netid ~= false and parkedVehicles[v.plate].entity ~= false then
                        parkedVehicles[v.plate] = nil
                        TriggerClientEvent("mh-parkinglite:client:deleteVehicle", -1, {status = true, plate = v.plate})
                    end
                    local cost = (math.floor(((os.time() - v.time) / Config.PayTimeInSecs) * Config.ParkPrice))
                    PoliceImpound(v.plate, true, cost, v.body, v.engine, v.fuel)
                end
            end
        end
    end
    SetTimeout(10000, ParkingTimeCheckLoop)
end
ParkingTimeCheckLoop()