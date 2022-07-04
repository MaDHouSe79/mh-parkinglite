local QBCore             = exports['qb-core']:GetCoreObject()
local PlayerData         = {}
local LocalVehicles      = {}
local GlobalVehicles     = {}
local UpdateAvailable    = false
local SpawnedVehicles    = false
local isUsingParkCommand = false
local IsDeleting         = false
local InParking          = false
local LastUsedPlate      = nil
local VehicleEntity      = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)
RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

local function CreateParkDisPlay(vehicleData)
    local info, model, owner, plate = nil
    local name = vehicleData.model
    local plate = vehicleData.plate
    if QBCore.Shared.Vehicles[vehicleData.model] then name = QBCore.Shared.Vehicles[name]['name'] end
    if Config.UseOwnerNames then owner = string.format(Lang:t("info.owner", {owner = vehicleData.citizenname}))..'\n' end
    model = string.format(Lang:t("info.model", {model = name}))..'\n'
    plate = string.format(Lang:t("info.plate", {plate = plate}))..'\n'
    if Config.UseOwnerNames then info  = string.format("%s", model..plate..owner) else info  = string.format("%s", model..plate) end    
    return info
end

local function doCarDamage(vehicle, health)
    local engine = health.engine + 0.0
    local body = health.body + 0.0
    local tank = health.tank + 0.0
    if body >= 900.0 then body = 1000.0 SetVehicleFixed(vehicle) end
    if engine >= 900.0 then engine = 1000.0 end
    Wait(100)
    if body < 900.0 then
        SmashVehicleWindow(vehicle, 0)
        SmashVehicleWindow(vehicle, 1)
        SmashVehicleWindow(vehicle, 2)
        SmashVehicleWindow(vehicle, 3)
        SmashVehicleWindow(vehicle, 4)
	SmashVehicleWindow(vehicle, 5)
	SmashVehicleWindow(vehicle, 6)
	SmashVehicleWindow(vehicle, 7)
    end
    if body < 700.0 then
	SetVehicleDoorBroken(vehicle, 0, true)
	SetVehicleDoorBroken(vehicle, 1, true)
	SetVehicleDoorBroken(vehicle, 2, true)
	SetVehicleDoorBroken(vehicle, 3, true)
	SetVehicleDoorBroken(vehicle, 4, true)
	SetVehicleDoorBroken(vehicle, 5, true)
	SetVehicleDoorBroken(vehicle, 6, true)
    end
    if engine < 600.0 then
	SetVehicleTyreBurst(vehicle, 1, false, 990.0)
	SetVehicleTyreBurst(vehicle, 2, false, 990.0)
	SetVehicleTyreBurst(vehicle, 3, false, 990.0)
	SetVehicleTyreBurst(vehicle, 4, false, 990.0)
    end
    if engine < 400.0 then
	SetVehicleTyreBurst(vehicle, 0, false, 990.0)
	SetVehicleTyreBurst(vehicle, 5, false, 990.0)
	SetVehicleTyreBurst(vehicle, 6, false, 990.0)
	SetVehicleTyreBurst(vehicle, 7, false, 990.0)
    end
    SetVehiclePetrolTankHealth(vehicle, tank)
    SetVehicleEngineHealth(vehicle, engine)
    SetVehicleBodyHealth(vehicle, body)
end

local function SetFuel(vehicle, fuel)
     if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
	SetVehicleFuelLevel(vehicle, fuel + 0.0)
	DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
     end
end

local function CreateParkedBlip(label, location)
    local blip = nil
    if Config.UseParkingBlips then
        blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, 545)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 25)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(label)
        EndTextCommandSetBlipName(blip)
    end
    return blip
end

local function PrepareVehicle(entity, vehicleData)
    RequestCollisionAtCoord(vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z)
    SetVehicleOnGroundProperly(entity)
    SetEntityAsMissionEntity(entity, true, true)
    SetEntityInvincible(entity, true)
    SetEntityHeading(vehicle, vehicleData.vehicle.location.w)
    SetVehicleLivery(entity, vehicleData.vehicle.livery)
    SetVehicleEngineHealth(entity, vehicleData.vehicle.health.engine)
    SetVehicleBodyHealth(entity, vehicleData.vehicle.health.body)
    SetVehiclePetrolTankHealth(entity, vehicleData.vehicle.health.tank)
    SetVehRadioStation(entity, 'OFF')
    SetVehicleDirtLevel(entity, 0)
    QBCore.Functions.SetVehicleProperties(VehicleEntity, vehicleData.vehicle.props)
    SetVehicleEngineOn(entity, false, false, true)
    SetModelAsNoLongerNeeded(vehicleData.vehicle.props.model)
end

local function LoadEntity(vehicleData, type)
    local model = vehicleData.vehicle.props.model
    QBCore.Functions.LoadModel(vehicleData.vehicle.props.model)
    VehicleEntity = CreateVehicle(vehicleData.vehicle.props.model, vehicleData.vehicle.location.x, vehicleData.vehicle.location.y, vehicleData.vehicle.location.z - 0.1, vehicleData.vehicle.location.w, false)
    QBCore.Functions.SetVehicleProperties(VehicleEntity, vehicleData.vehicle.props)
    SetVehicleEngineOn(VehicleEntity, false, false, true)
    SetVehicleDoorsLocked(VehicleEntity, 2)
    if type == 'server' then
        TriggerEvent('qb-parking:client:addkey', vehicleData.plate, vehicleData.citizenid)
    end
    PrepareVehicle(VehicleEntity, vehicleData)
end

local function TableInsert(VehicleEntity, vehicleData)
    local tmpBlip = nil
    if vehicleData.citizenid == QBCore.Functions.GetPlayerData().citizenid then
        tmpBlip = CreateParkedBlip(Lang:t('system.parked_blip_info',{modelname = vehicleData.model}), vehicleData.vehicle.location)
    end
    LocalVehicles[#LocalVehicles+1] = {
	entity      = VehicleEntity,
	vehicle     = vehicleData.mods,
	plate       = vehicleData.plate,
        fuel        = vehicleData.fuel,
	citizenid   = vehicleData.citizenid,
	citizenname = vehicleData.citizenname,
	livery      = vehicleData.vehicle.livery,
	health      = vehicleData.vehicle.health,
	model       = vehicleData.model,
        blip        = tmpBlip,
        isGrounded  = false,
	location    = {
	    x = vehicleData.vehicle.location.x,
	    y = vehicleData.vehicle.location.y,
	    z = vehicleData.vehicle.location.z + 0.5,
	    w = vehicleData.vehicle.location.w
	}
    }
end

local function Draw3DText(x, y, z, textInput, fontId, scaleX, scaleY)
    local p     = GetGameplayCamCoords()
    local dist  = #(p - vector3(x, y, z))
    local scale = (1 / dist) * 20
    local fov   = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    SetTextScale(scaleX * scale, scaleY * scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(250, 250, 250, 255)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x, y, z + 2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function DisplayParkedOwnerText()
    if Config.UseParkedVehicleNames then -- for performes
	local pl = GetEntityCoords(PlayerPedId())
	local displayWhoOwnesThisCar = nil
	for k, vehicle in pairs(LocalVehicles) do
	    if #(pl - vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z)) < Config.DisplayDistance then
               displayWhoOwnesThisCar = CreateParkDisPlay(vehicle)
               Draw3DText(vehicle.location.x, vehicle.location.y, vehicle.location.z - 0.2, displayWhoOwnesThisCar, 0, 0.04, 0.04)
            end
	end
    end
end

-- Set No Collission between 2 entities
local function NoColission(entity, location)
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(vector3(location.x, location.y, location.z))
    if distance <= 1 then
        SetEntityNoCollisionEntity(entity, vehicle, true)
    end
end

local function GetPlayerInStoredCar(player)
    local entity = GetVehiclePedIsIn(player)
    local findVehicle = false
    for i = 1, #LocalVehicles do
        if LocalVehicles[i].entity and LocalVehicles[i].entity == entity then
            findVehicle = LocalVehicles[i]
            break
        end
    end
    return findVehicle
end

local function DeleteLocalVehicle(vehicle)
    if type(LocalVehicles) == 'table' and #LocalVehicles > 0 and LocalVehicles[1] then
	for i = 1, #LocalVehicles do
            if type(vehicle.plate) ~= 'nil' and type(LocalVehicles[i]) ~= 'nil' and type(LocalVehicles[i].plate) ~= 'nil' then
		if vehicle.plate == LocalVehicles[i].plate then
		    DeleteEntity(LocalVehicles[i].entity)
                    table.remove(LocalVehicles, i)
		end
	    end
	end
    end
end

-- Spawn local vehicles(server data)
local function SpawnVehicles(vehicles)
    CreateThread(function()
        while IsDeleting do Citizen.Wait(Config.DeleteDelay) end
	if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] then
	    for i = 1, #vehicles, 1 do
                SetEntityCollision(vehicles[i].vehicle, false, true)
                SetEntityVisible(vehicles[i].vehicle, false, 0)
	        DeleteLocalVehicle(vehicles[i].vehicle)
		LoadEntity(vehicles[i], 'server')
		SetVehicleEngineOn(VehicleEntity, false, false, true)
		doCarDamage(VehicleEntity, vehicles[i].vehicle.health)
		TableInsert(VehicleEntity, vehicles[i])
		FreezeEntityPosition(VehicleEntity, true)
	    end
	end
    end)
end

-- Spawn single vehicle(client data)
local function SpawnVehicle(vehicleData)
    CreateThread(function()
	if LocalPlayer.state.isLoggedIn then
	    while IsDeleting do Wait(Config.DeleteDelay) end
            SetEntityCollision(vehicleData.vehicle, false, true)
            SetEntityVisible(vehicleData.vehicle, false, 0)
	    DeleteLocalVehicle(vehicleData.vehicle)
            if Config.UseSpawnDelay then Wait(Config.DeleteDelay) end
	    LoadEntity(vehicleData, 'client')
	    PrepareVehicle(VehicleEntity, vehicleData)
            doCarDamage(VehicleEntity, vehicleData.vehicle.health)
	    TableInsert(VehicleEntity, vehicleData)
            if Config.UseSpawnDelay then Wait(Config.FreezeDelay) end
	    FreezeEntityPosition(VehicleEntity, true)
	end
    end)
end

local function RemoveVehicles(vehicles)
    IsDeleting = true
    if type(vehicles) == 'table' and #vehicles > 0 and vehicles[1] then
	for i = 1, #vehicles, 1 do
	    local vehicle, distance = QBCore.Functions.GetClosestVehicle(vehicles[i].vehicle.location)
	    if NetworkGetEntityIsLocal(vehicle) and distance < 1 then
		local driver = GetPedInVehicleSeat(vehicle, -1)
		if not DoesEntityExist(driver) or not IsPedAPlayer(driver) then
		    local tmpModel = GetEntityModel(vehicle)
		    SetModelAsNoLongerNeeded(tmpModel)
		    DeleteEntity(vehicle)
		    Wait(100)
	        end
	    end
        end
    end
    LocalVehicles = {}
    IsDeleting = false
end

local function DisplayHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function CreateVehicleEntity(vehicle)
    QBCore.Functions.LoadModel(vehicle.props.model)
    return CreateVehicle(vehicle.props.model, vehicle.location.x, vehicle.location.y, vehicle.location.z, vehicle.location.w, true)
end

local function DeleteNearByVehicle(location)
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(location)
    if distance <= 1 then
        for i = 1, #LocalVehicles do
            if LocalVehicles[i].entity == vehicle then
                table.remove(LocalVehicles, i)
            end
            local tmpModel = GetEntityModel(vehicle)
            SetModelAsNoLongerNeeded(tmpModel)
            DeleteEntity(vehicle)
            tmpModel = nil
        end
    end
end

local function MakeVehicleReadyToDrive(vehicle, warp)
    DeleteNearByVehicle(vector3(vehicle.location.x, vehicle.location.y, vehicle.location.z))
    QBCore.Functions.LoadModel(vehicle.props.model)
    local VehicleEntity = CreateVehicle(vehicle.props.model, vehicle.location.x, vehicle.location.y, vehicle.location.z, vehicle.location.w, true)
    if warp then TaskWarpPedIntoVehicle(PlayerPedId(), VehicleEntity, -1) end
    QBCore.Functions.SetVehicleProperties(VehicleEntity, vehicle.props)
    RequestCollisionAtCoord(vehicle.location.x, vehicle.location.y, vehicle.location.z)
    SetVehicleOnGroundProperly(VehicleEntity)
    FreezeEntityPosition(VehicleEntity, false)
    SetVehicleLivery(VehicleEntity, vehicle.livery)
    SetVehRadioStation(VehicleEntity, 'OFF')
    SetVehicleDirtLevel(VehicleEntity, 0)
    SetVehicleFuelLevel(VehicleEntity, vehicle.fuel)
    SetModelAsNoLongerNeeded(vehicle.props["model"])
    doCarDamage(VehicleEntity, vehicle.health)
    SetFuel(VehicleEntity, vehicle.fuel)
end

local function Drive(player, vehicle, warp)
    QBCore.Functions.TriggerCallback("qb-parking:server:drive", function(callback)
        if callback.status then
            QBCore.Functions.DeleteVehicle(vehicle.entity)
            QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(player))
            if Config.UseParkingBlips then RemoveBlip(vehicle.blip) end
            vehicle = false
            MakeVehicleReadyToDrive(callback.data, warp)
        else
            QBCore.Functions.Notify(callback.message, "error", 5000)
        end
    end, vehicle)
end

local function ParkCar(player, vehicle, warp)
    SetVehicleEngineOn(vehicle, false, false, true)
    if warp then
        TaskLeaveVehicle(player, vehicle)
    end
    RequestAnimSet("anim@mp_player_intmenu@key_fob@")
    TaskPlayAnim(player, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false)
    Wait(2000)
    ClearPedTasks(player)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
    Wait(150)
    SetVehicleLights(vehicle, 2)
    Wait(150)
    SetVehicleLights(vehicle, 0)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
end

local function Save(player, vehicle, warp)
    local props = QBCore.Functions.GetVehicleProperties(vehicle)
    LastUsedPlate = props.plate
    QBCore.Functions.TriggerCallback('qb-parking:server:isOwner', function(isOwner)
        if isOwner then 
            ParkCar(player, vehicle, warp)
            QBCore.Functions.TriggerCallback("qb-parking:server:save", function(callback)
                if callback.status then
                    QBCore.Functions.DeleteVehicle(vehicle)
                else
                    QBCore.Functions.Notify(callback.message, "error", 5000)
                end
            end, {
                props       = props,
                livery      = GetVehicleLivery(vehicle),
                citizenid   = QBCore.Functions.GetPlayerData().citizenid,
                plate       = props.plate,
                fuel        = GetVehicleFuelLevel(vehicle),
                oil         = GetVehicleOilLevel(vehicle),
                model       = props.model,
                health      = {engine = GetVehicleEngineHealth(vehicle), body = GetVehicleBodyHealth(vehicle), tank = GetVehiclePetrolTankHealth(vehicle) },
                location    = vector4(GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z - 0.5, GetEntityHeading(vehicle)),
            })
        else
            QBCore.Functions.Notify(Lang:t('info.must_own_car'), "error", 5000)
        end
    end, props.plate)
end

-- Check Distance To Force Vehicle to the Ground
local function checkDistanceToForceGrounded(distance)
    if type(LocalVehicles) == 'table' and #LocalVehicles > 0 and LocalVehicles[1] then
        for i = 1, #LocalVehicles do
            if type(LocalVehicles[i]) ~= 'nil' and type(LocalVehicles[i].entity) ~= 'nil' then
                local tmp = LocalVehicles[i]
                if DoesEntityExist(LocalVehicles[i].entity) then
                    if GetVehicleWheelSuspensionCompression(LocalVehicles[i].entity) == 0 then
                        SetEntityCoords(tmp.entity, tmp.location.x, tmp.location.y, tmp.location.z)
                        SetVehicleOnGroundProperly(tmp.entity)
                        LocalVehicles[i].isGrounded = true
                    end
                    if #(GetEntityCoords(PlayerPedId()) - vector3(tmp.location.x, tmp.location.y, tmp.location.z)) < 150 then
                        if not tmp.isGrounded then
                            SetEntityCoords(tmp.entity, tmp.location.x, tmp.location.y, tmp.location.z)
                            SetVehicleOnGroundProperly(tmp.entity)
                            LocalVehicles[i].isGrounded = true
                        end
                    else
                        LocalVehicles[i].isGrounded = false
                    end
                    if Config.DebugMode then
                        if not tmp.isGrounded then
                            print("Parking Force Grounded - Plate ("..tmp.plate..") Model ("..tmp.modelname ..") Grounded ("..tostring(LocalVehicles[i].isGrounded)..") ")
                        else
                            print("Parking can\'t force a vehicle to the ground at this moment. (No vehicle neerby)")
                        end
                    end
                end
            end
        end
        Wait(5000)
    end
end

-- Get the stored vehicle player is in
local function GetParkeddCar(vehicle)
    local findVehicle = false
    for i = 1, #LocalVehicles do
        if LocalVehicles[i].entity and LocalVehicles[i].entity == vehicle then
            findVehicle = LocalVehicles[i]
            break
        end
    end
    return findVehicle
end

RegisterKeyMapping('park', Lang:t('system.park_or_drive'), 'keyboard', 'F5') 
RegisterCommand(Config.Command.park, function()
    isUsingParkCommand = true
end, false)

RegisterCommand(Config.Command.parknames, function()
    Config.UseParkedVehicleNames = not Config.UseParkedVehicleNames
    if Config.UseParkedVehicleNames then
        QBCore.Functions.Notify(Lang:t('system.enable', {type = "names"}), "success", 1500)
    end
    if not Config.UseParkedVehicleNames then
        QBCore.Functions.Notify(Lang:t('system.disable', {type = "names"}), "error", 1500)
    end
end, false)

RegisterNetEvent("qb-parking:client:refreshVehicles", function(vehicles)
    GlobalVehicles = vehicles
    RemoveVehicles(vehicles)
    Wait(1000)
    SpawnVehicles(vehicles)
    Wait(1000)
end)

RegisterNetEvent("qb-parking:client:addVehicle", function(vehicle)
    SpawnVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:deleteVehicle", function(vehicle)
    DeleteLocalVehicle(vehicle)
end)

RegisterNetEvent("qb-parking:client:impound",  function(plate)
    TriggerServerEvent('qb-parking:server:vehicle_action_impound', plate)
end)

RegisterNetEvent("qb-parking:client:stolen",  function(plate)
    TriggerServerEvent('qb-parking:server:vehicle_action_stolen', plate)
end)

RegisterNetEvent("qb-parking:client:unpark", function(plate)
    TriggerServerEvent('qb-parking:server:vehicle_action_unpark', plate)
end)

RegisterNetEvent("qb-parking:client:isUsingParkCommand", function()
    isUsingParkCommand = true
end)

RegisterNetEvent("qb-parking:client:unparking", function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(GetEntityCoords(PlayerPedId())) 
    if distance <= 5.0 then
        Drive(PlayerPedId(), GetParkeddCar(vehicle), false)
    else
        QBCore.Functions.Notify(Lang:t("system.to_far_from_vehicle"), "error", 2000)
    end
end)

RegisterNetEvent("qb-parking:client:parking", function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
    if distance <= 5.0 then
        Save(PlayerPedId(), vehicle, false)
    else
        QBCore.Functions.Notify(Lang:t("system.to_far_from_vehicle"), "error", 2000)
    end
end)

RegisterNetEvent('qb-parking:client:setParkedVecihleLocation', function(location)
    SetNewWaypoint(location.x, location.y)
    QBCore.Functions.Notify(Lang:t("success.route_has_been_set"), 'success')
end)

RegisterNetEvent('qb-parking:client:addkey', function(plate, citizenid)
    TriggerServerEvent('vehiclekeys:server:SetVehicleOwnerToCitizenid', plate, citizenid)
end)

CreateThread(function()
    while not IsDeleting do
	if #LocalVehicles ~= 0 then
            for i = 1, #LocalVehicles do
                if type(LocalVehicles[i]) ~= 'nil' and type(LocalVehicles[i].entity) ~= 'nil' then
                    if DoesEntityExist(LocalVehicles[i].entity) and type(LocalVehicles[i].isGrounded) == 'nil' then
		        if #(GetEntityCoords(PlayerPedId()) - vector3(Config.ParkingLocation.x, Config.ParkingLocation.y, Config.ParkingLocation.z)) < Config.PlaceOnGroundRadius then
                            SetEntityCoords(LocalVehicles[i].entity, LocalVehicles[i].location.x, LocalVehicles[i].location.y, LocalVehicles[i].location.z)
                            SetVehicleOnGroundProperly(LocalVehicles[i].entity)
                            SetVehicleFuelLevel(LocalVehicles[i].entity)
                            LocalVehicles[i].isGrounded = true
                        end
                    end
                end
            end
	end
	Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local pl = GetEntityCoords(PlayerPedId())
	if #(pl - vector3(Config.ParkingLocation.x, Config.ParkingLocation.y, Config.ParkingLocation.z)) < Config.ParkingLocation.s then
	    InParking = true
	    crParking = 'allparking'
	end
	if InParking then
	    if not SpawnedVehicles then
	        RemoveVehicles(GlobalVehicles)
	        TriggerServerEvent("qb-parking:server:refreshVehicles", crParking)
		SpawnedVehicles = true
		Wait(2000)
	    end
        else
	    if SpawnedVehicles then
	        RemoveVehicles(GlobalVehicles)
		SpawnedVehicles = false
	    end
	end
	Wait(0)
    end
end)

CreateThread(function()
    if Config.UseParkingSystem then
	while true do
	    local player = PlayerPedId()
	    if InParking and IsPedInAnyVehicle(player) then
		local storedVehicle = GetPlayerInStoredCar(player)
		local vehicle = GetVehiclePedIsIn(player)
                if storedVehicle ~= false then
		    DisplayHelpText(Lang:t("info.press_drive_car"))
		    if IsControlJustReleased(0, Config.parkingButton) then
		        isUsingParkCommand = true
		    end
		end
		if isUsingParkCommand then
		    isUsingParkCommand = false
		    if storedVehicle ~= false then
			Drive(player, storedVehicle, true)
		    else
		        if vehicle then
                            local speed = GetEntitySpeed(vehicle)
                            if speed > 0.9 then
                                QBCore.Functions.Notify(Lang:t("info.stop_car"), 'error', 1500)
			    elseif IsThisModelACar(GetEntityModel(vehicle)) or IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelABicycle(GetEntityModel(vehicle)) or IsThisModelAHeli(GetEntityModel(vehicle)) or IsThisModelAPlane(GetEntityModel(vehicle)) or IsThisModelABoat(GetEntityModel(vehicle)) then
                                QBCore.Functions.TriggerCallback('qb-parking:server:allowtopark', function(cb)
                                    if cb.status then
                                        Save(player, vehicle, true)
                                    else
                                        QBCore.Functions.Notify(cb.message, "error", 5000)
                                    end
                                end)
			    else
				QBCore.Functions.Notify(Lang:t("info.only_cars_allowd"), "error", 5000)
			    end						
			end
		    end
		end
	    else
		isUsingParkCommand = false
	    end
	    Wait(0)
	end
    end
end)

CreateThread(function()
    if Config.UseParkingSystem then
        while true do
            DisplayParkedOwnerText()
            Wait(0)
        end
    end
end)

CreateThread(function()
    while true do
        checkDistanceToForceGrounded(Config.ForceGroundedDistane)
        Wait(Config.ForceGroundenInMilSec)
    end
end)

function SetVehicleModifications(vehicle, props)-- Apply all modifications to a vehicle entity
    if DoesEntityExist(vehicle) then
		SetVehicleModKit(vehicle, 0)
		-- plate:
		if props.plate then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end
        if props.plateIndex then
            SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
        end
		-- lockStatus:
		if props.lockstatus then
			SetVehicleDoorsLocked(vehicle, props.lockstatus)
		end
		-- colours:
		if props.color1 and props.color2 then
			SetVehicleColours(vehicle, props.color1, props.color2)
		end
		if props.customprimarycolor then
			SetVehicleCustomPrimaryColour(vehicle, props.customprimarycolor.r, props.customprimarycolor.g, props.customprimarycolor.b)
		end
		if props.customsecondarycolor then
			SetVehicleCustomSecondaryColour(vehicle, props.customsecondarycolor.r, props.customsecondarycolor.g, props.customsecondarycolor.b)
		end
		if props.interiorColor then
            SetVehicleInteriorColor(vehicle, props.interiorColor)
        end
		if props.dashboardColor then
            SetVehicleDashboardColour(vehicle, props.dashboardColor)
        end
		if props.pearlescentColor and props.wheelColor then
			SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor)
		end
		if props.tyreSmokeColor then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end
		-- wheels:
		if props.wheels then
            SetVehicleWheelType(vehicle, props.wheels)
        end
		-- windows:
		if props.windowTint then
            SetVehicleWindowTint(vehicle, props.windowTint)
        end
		-- neonlight:
		if props.neonEnabled then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end
		if props.neonColor then
            SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
        end
		-- mods:
		if props.modSpoilers then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 0, props.modSpoilers, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 0, props.modSpoilers, false)
			end
        end
		if props.modFrontBumper then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 1, props.modFrontBumper, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
			end
        end
		if props.modRearBumper then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 2, props.modRearBumper, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 2, props.modRearBumper, false)
			end
        end
		if props.modSideSkirt then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 3, props.modSideSkirt, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
			end
        end
		if props.modExhaust then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 4, props.modExhaust, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 4, props.modExhaust, false)
			end
        end
		if props.modFrame then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 5, props.modFrame, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 5, props.modFrame, false)
			end
        end
		if props.modGrille then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 6, props.modGrille, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 6, props.modGrille, false)
			end
        end
		if props.modHood then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 7, props.modHood, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 7, props.modHood, false)
			end
        end
		if props.modFender then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 8, props.modFender, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 8, props.modFender, false)
			end
        end
		if props.modRightFender then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 9, props.modRightFender, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 9, props.modRightFender, false)
			end
        end
		if props.modRoof then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 10, props.modRoof, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 10, props.modRoof, false)
			end
        end
		if props.modEngine then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 11, props.modEngine, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 11, props.modEngine, false)
			end
        end
		if props.modBrakes then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 12, props.modBrakes, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 12, props.modBrakes, false)
			end
        end
		if props.modTransmission then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 13, props.modTransmission, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 13, props.modTransmission, false)
			end
        end
		if props.modHorns then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 14, props.modHorns, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 14, props.modHorns, false)
			end
        end
		if props.modSuspension then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 15, props.modSuspension, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 15, props.modSuspension, false)
			end
        end
		if props.modArmor then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 16, props.modArmor, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 16, props.modArmor, false)
			end
        end
		if props.modTurbo then
            ToggleVehicleMod(vehicle, 18, props.modTurbo)
        end
		if props.modSmokeEnabled then
            ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled)
        end
		if props.modXenon then
            ToggleVehicleMod(vehicle, 22, props.modXenon)
        end
		if props.modFrontWheels then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
			end
        end
		if props.modBackWheels then
            if props.modCustomTiresR then
				SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR)
			else
				SetVehicleMod(vehicle, 24, props.modBackWheels, false)
			end
        end
		if props.modPlateHolder then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 25, props.modPlateHolder, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
			end
        end
		if props.modVanityPlate then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 26, props.modVanityPlate, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
			end
        end
		if props.modTrimA then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 27, props.modTrimA, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 27, props.modTrimA, false)
			end
        end
		if props.modOrnaments then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 28, props.modOrnaments, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 28, props.modOrnaments, false)
			end
        end
		if props.modDashboard then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 29, props.modDashboard, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 29, props.modDashboard, false)
			end
        end
		if props.modDial then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 30, props.modDial, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 30, props.modDial, false)
			end
        end
		if props.modDoorSpeaker then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 31, props.modDoorSpeaker, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
			end
        end
		if props.modSeats then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 32, props.modSeats, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 32, props.modSeats, false)
			end
        end
		if props.modSteeringWheel then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 33, props.modSteeringWheel, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
			end
        end
		if props.modShifterLeavers then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 34, props.modShifterLeavers, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
			end
        end
		if props.modAPlate then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 35, props.modAPlate, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 35, props.modAPlate, false)
			end
        end
		if props.modSpeakers then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 36, props.modSpeakers, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 36, props.modSpeakers, false)
			end
        end
		if props.modTrunk then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 37, props.modTrunk, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 37, props.modTrunk, false)
			end
        end
		if props.modHydrolic then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 38, props.modHydrolic, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 38, props.modHydrolic, false)
			end
        end
		if props.modEngineBlock then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 39, props.modEngineBlock, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
			end
        end
		if props.modAirFilter then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 40, props.modAirFilter, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 40, props.modAirFilter, false)
			end
        end
		if props.modStruts then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 41, props.modStruts, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 41, props.modStruts, false)
			end
        end
		if props.modArchCover then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 42, props.modArchCover, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 42, props.modArchCover, false)
			end
        end
		if props.modAerials then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 43, props.modAerials, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 43, props.modAerials, false)
			end
        end
		if props.modTrimB then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 44, props.modTrimB, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 44, props.modTrimB, false)
			end
        end
		if props.modTank then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 45, props.modTank, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 45, props.modTank, false)
			end
        end
		if props.modWindows then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 46, props.modWindows, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 46, props.modWindows, false)
			end
        end
		if props.modLivery then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 48, props.modLivery, props.modCustomTiresF)
				SetVehicleLivery(vehicle, props.modLivery)
			else
				SetVehicleMod(vehicle, 48, props.modLivery, false)
				SetVehicleLivery(vehicle, props.modLivery)
			end
        end
		-- extras:
		if props.extras then
            for id, enabled in pairs(props.extras) do
                if enabled then
                    SetVehicleExtra(vehicle, tonumber(id), 0)
                else
                    SetVehicleExtra(vehicle, tonumber(id), 1)
                end
            end
        end
		-- stats:
		if props.health then
            SetEntityHealth(vehicle, props.health + 0.0)
        end
		if props.bodyHealth then
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
        end
		if props.engineHealth then
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
        end
		if props.engineHealth and renderScorched and props.engineHealth < -3999.0 then
			TriggerServerEvent('MojiaGarages:server:renderScorched', NetworkGetNetworkIdFromEntity(vehicle), true)
		end
		if props.tankHealth then
            SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
        end
		if props.tankHealth and renderScorched and props.tankHealth < -999.0 then
			TriggerServerEvent('MojiaGarages:server:renderScorched', NetworkGetNetworkIdFromEntity(vehicle), true)
		end
		if props.dirtLevel then
            SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
        end
		if props.fuelLevel then
            SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
        end
		-- doors:
		if props.doorsmissing then
            for id, state in pairs(props.doorsmissing) do
				if state then
					SetVehicleDoorBroken(vehicle, tonumber(id), state)
					
				end
			end
        end
		-- tires
		SetVehicleTyresCanBurst(vehicle, not props.bulletprooftires)
		if not props.bulletprooftires and props.tiresburst then
			for id, state in pairs(props.tiresburst) do
				SetVehicleTyreBurst(vehicle, tonumber(id), state, 1000.0)
			end
		end
		-- windows:
		if props.windowsbroken then
            for id, state in pairs(props.windowsbroken) do
				if not state then
					SmashVehicleWindow(vehicle, tonumber(id))
				end
			end
        end
		-- xenon lights:
		if props.xenonColor then
            SetVehicleXenonLightsColor(vehicle, props.xenonColor)
        end
	end
end
