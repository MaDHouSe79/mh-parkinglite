local LocalVehicles = {}
local GlobalVehicles = {}
local isLoggedIn = false
local isUsingParkCommand = false
local isEnteringVehicle = false
local isInVehicle = false
local currentVehicle = nil
local currentSeat = nil
local currentPlate = nil
local display3Dtext = Config.Display3DText
local saveSteeringAngle = Config.SaveSteeringAngle

local function DoesPlateExist(plate)
    for i = 1, #LocalVehicles do
        if LocalVehicles[i] ~= nil and LocalVehicles[i].plate == plate then
            return true
        end
    end
    return false
end

local function TableInsert(entity, data)
    if not DoesPlateExist(data.plate) then
        LocalVehicles[#LocalVehicles + 1] = {
            citizenid = data.citizenid,
            netid = data.netid,
            entity = entity,
            mods = data.mods,
            plate = data.plate,
            model = data.model,
            body = data.body,
            engine = data.engine,
            fuel = data.fuel,
            steerangle = data.steerangle,
            street = data.street,
            location = {x = data.location.x, y = data.location.y, z = data.location.z + 0.5, w = data.location.w},
        }
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

local function SetVehicleWaypoit(coords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = GetDistance(playerCoords, coords)
    if distance < 200 then
        Notify(Lang:t('info.no_waipoint', {distance = Round(distance, 2)}), "error", 5000)
    elseif distance > 200 then
        SetNewWaypoint(coords.x, coords.y)
    end
end

local function GetVehicleMenu()
    TriggerCallback("mh-parkinglite:server:GetVehicles", function(result)
        if result.status then
            if result.data ~= nil then
                local num = 0
                local options = {}
                for k, v in pairs(result.data) do
                    if v.state == 3 then
                        num = num + 1
                        local coords = json.decode(v.location)
                        options[#options + 1] = {
                            id = num,
                            title = FirstToUpper(v.vehicle) .. " " .. v.plate .. " is parked",
                            icon = "nui://mh-parkinglite/core/images/" .. v.vehicle .. ".png",
                            description = Lang:t('info.street', {street = v.street}) .. '\n' .. Lang:t('info.fuel', {fuel = v.fuel}) .. '\n' .. Lang:t('info.engine', {engine = v.engine}) .. '\n' .. Lang:t('info.body', {body = v.body}) .. '\n' .. Lang:t('info.click_to_set_waypoint'),
                            arrow = false,
                            onSelect = function()
                                SetVehicleWaypoit(coords)
                            end
                        }
                    end
                end
                num = num + 1
                options[#options + 1] = {
                    id = num,
                    title = Lang:t('info.close'),
                    icon = "fa-solid fa-stop",
                    description = '',
                    arrow = false,
                    onSelect = function()
                    end
                }
                lib.registerContext({id = 'parkMenu', title = "MH Parking Lite", icon = "fa-solid fa-warehouse", options = options})
                lib.showContext('parkMenu')
            else
                Notify(Lang:t('info.no_vehicles_parked'), "error", 5000)
            end
        end
    end)
end

local function Drive(data)
    TriggerCallback("mh-parkinglite:server:drive", function(callback)
        if callback.status then
            if Config.FreezeVehicles then
                FreezeEntityPosition(data.entity, false)
            end
            Notify(callback.message, "success", 5000)
        else
            Notify(callback.message, "error", 5000)
        end
    end, data)
end

local function Save(vehicle)
    SetVehicleEngineOn(vehicle, false, false, true)
    TriggerServerEvent('mh-parkinglite:server:AllPlayersLeaveVehicle', VehToNet(vehicle), GetAllPlayersInVehicle(vehicle))
    Wait(2500)
    BlinkVehiclelights(vehicle)
    local trailerdata = nil
    local hasTrailer, trailer = GetVehicleTrailerVehicle(vehicle)
    if hasTrailer then
        trailerdata = {
            model = Config.Trailers[GetEntityModel(trailer)].model,
            brand = Config.Trailers[GetEntityModel(trailer)].brand,
            hash = GetEntityModel(trailer),
            coords = GetEntityCoords(trailer),
            heading = GetEntityHeading(trailer),
            mods = GetVehicleProperties(trailer),
        }
    end
    local mods = GetVehicleProperties(vehicle)
    local coords = GetEntityCoords(vehicle)
    local heading = GetEntityHeading(vehicle)    
    local steerangle = GetVehicleSteeringAngle(vehicle) + 0.0
    local street = GetStreetName(coords)
    TriggerCallback("mh-parkinglite:server:save", function(callback)
        if callback.status then
            if Config.FreezeVehicles then FreezeEntityPosition(vehicle, true) end
            Notify(callback.message, "success", 5000)
        else
            Notify(callback.message, "error", 5000)
        end
    end, {
        netid = VehToNet(vehicle),
        plate = GetPlate(vehicle),
        engine = GetVehicleEngineHealth(vehicle),
        body = GetVehicleBodyHealth(vehicle),
        fual = GetFuel(vehicle),
        mods = mods,
        model = mods.model,
        street = street,
        steerangle = steerangle,
        location = vector4(coords.x, coords.y, coords.z - 0.5, heading),
        trailerdata = trailerdata        
    })
end

RegisterKeyMapping(Config.Command.park, Lang:t('info.park_or_drive'), 'keyboard', Config.KeyBindButton)
RegisterCommand(Config.Command.park, function() isUsingParkCommand = true end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then 
        PlayerData = {}
        isLoggedIn = false
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = GetPlayerData()
        isLoggedIn = true
        TriggerServerEvent('mh-parkinglite:server:onjoin')
    end
end)

RegisterNetEvent(OnPlayerLoaded, function()
    PlayerData = GetPlayerData()
    isLoggedIn = true
    TriggerServerEvent('mh-parkinglite:server:onjoin')
end)

RegisterNetEvent(OnPlayerUnload, function()
    PlayerData = {}
    isLoggedIn = false
end)

RegisterNetEvent(OnJobUpdate, function(job)
    PlayerData.job = job
end)

RegisterNetEvent("mh-parkinglite:client:OpenParkMenu", function(data)
    if data.status == true then GetVehicleMenu() end
end)

RegisterNetEvent("mh-parkinglite:client:ToggleParknames", function(data)
    if data.status == true then 
        display3Dtext = not display3Dtext
        if display3Dtext then
            Notify("Vehicle 3D text is now enable", "success", 5000)
        else
            Notify("Vehicle 3D text is now disable", "success", 5000)
        end
    end
end)

RegisterNetEvent("mh-parkinglite:client:ToggleSaveSteeringAngle", function(data)
    if data.status == true then 
        saveSteeringAngle = not saveSteeringAngle
        if saveSteeringAngle then
            Notify("Save Steering Angle is now enable", "success", 5000)
        else
            Notify("Save Steering Angle is now disable", "success", 5000)
        end
    end
end)

RegisterNetEvent("mh-parkinglite:client:addVehicle", function(data)
    if data.status == true then
        if NetworkDoesEntityExistWithNetworkId(data.vehicle.netid) then
            NetworkRequestControlOfNetworkId(data.vehicle.netid)
            local vehicle = NetworkGetEntityFromNetworkId(data.vehicle.netid)
            if DoesEntityExist(vehicle) then
                SetVehicleProperties(vehicle, data.vehicle.mods)
                DoVehicleDamage(vehicle, data.vehicle.body, data.vehicle.engine)
                SetFuel(vehicle, data.vehicle.fuel + 0.0)
                SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
                TableInsert(vehicle, data)
            end
        end
    end
end)

RegisterNetEvent("mh-parkinglite:client:deleteVehicle", function(data)
    if data.status == true then
        if type(LocalVehicles) == 'table' and #LocalVehicles >= 1 then
            for i = 1, #LocalVehicles do
                if LocalVehicles[i] ~= nil and LocalVehicles[i].plate ~= nil and LocalVehicles[i].plate == data.plate then
                    table.remove(LocalVehicles, i)
                end
            end
        end
    end
end)

RegisterNetEvent('mh-parkinglite:client:onjoin', function(data)
    if data.status == true then
        local vehicles = data.vehicles
        for k, v in pairs(vehicles) do
            while not NetworkDoesEntityExistWithNetworkId(v.netid) do Wait(0) end
            if NetworkDoesEntityExistWithNetworkId(v.netid) then
                NetworkRequestControlOfNetworkId(v.netid)
                local vehicle = NetworkGetEntityFromNetworkId(v.netid)
                if DoesEntityExist(vehicle) then
                    SetEntityAsMissionEntity(vehicle, true, true)
                    SetVehicleProperties(vehicle, v.mods)
                    SetVehicleSteeringAngle(vehicle, v.steerangle + 0.0)
                    DoVehicleDamage(vehicle, v.body, v.engine)
                    SetFuel(vehicle, v.fuel + 0.0)
                    SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
                    local coords = GetEntityCoords(vehicle)
                    local heading = GetEntityHeading(vehicle)
                    SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
                    TableInsert(vehicle, v)
                end
            end
        end
        Wait(1500)
        if Config.FreezeVehicles then
            for i = 1, #LocalVehicles, 1 do
                if LocalVehicles[i].entity ~= nil then
                    if DoesEntityExist(LocalVehicles[i].entity) then
                        FreezeEntityPosition(LocalVehicles[i].entity, true)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('mh-parkinglite:client:leaveVehicle', function(data)
    if data.status == true then LeaveVehicle(data) end
end)

RegisterNetEvent('mh-parkinglite:client:notify', function(data)
    if data.status == true then Notify(data.message, data.type, data.length) end
end)

-- Set Steering Angle to save when parking the vehicle.
CreateThread(function()
    local angle, speed = 0.0, 0.0
    while true do
        Wait(0)
        if isLoggedIn and saveSteeringAngle and isInVehicle then
            local veh = GetVehiclePedIsUsing(PlayerPedId())
            if DoesEntityExist(veh) then
                local tangle = GetVehicleSteeringAngle(veh)
                if tangle > 10.0 or tangle < -10.0 then angle = tangle end
                speed = GetEntitySpeed(veh)
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                if speed < 0.1 and DoesEntityExist(vehicle) and not GetIsTaskActive(PlayerPedId(), 151) and
                    not GetIsVehicleEngineRunning(vehicle) then
                    SetVehicleSteeringAngle(vehicle, angle)
                end
            end
        end
    end
end)

-- Draw 3D vehicle text
CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and display3Dtext then
            local playerCoords = GetEntityCoords(GetPlayerPed(-1))
            local txt1, txt2 = "", ""
            for i = 1, #LocalVehicles, 1 do
                if LocalVehicles[i] ~= nil then
                    if DoesEntityExist(LocalVehicles[i].entity) then
                        local vehicleCoords = GetEntityCoords(LocalVehicles[i].entity)
                        local distance = GetDistance(playerCoords, vehicleCoords)
                        if distance < Config.DisplayDistance then
                            local owner, plate, model, brand = LocalVehicles[i].citizenid, LocalVehicles[i].plate, nil, nil
                            for k, vehicle in pairs(Config.Vehicles) do
                                if vehicle.model == LocalVehicles[i].model then
                                    model, brand = vehicle.name, vehicle.brand
                                    break
                                end
                            end
                            if model ~= nil and brand ~= nil then
                                sleep = 0
                                local netid = LocalVehicles[i].netid
                                txt1 = "Brand: ~o~" .. brand .. "~s~\nModel: ~b~" .. model .. "~s~\nPlate: ~g~" .. plate .. "~s~\nOwner: ~y~" .. owner .. "~s~\n"
                                if Config.DisplayToAllPlayers then
                                    sleep = 0
                                    Draw3DText(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, txt1, 0, 0.04, 0.04)
                                else
                                    if Config.DisplayToCopPlayers then
                                        if PlayerData.job.type == 'leo' and PlayerData.job.onduty then
                                            sleep = 0
                                            Draw3DText(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, txt1, 0, 0.04, 0.04)
                                        end
                                    end
                                    if PlayerData.citizenid == LocalVehicles[i].citizenid then
                                        sleep = 0
                                        Draw3DText(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, txt1, 0, 0.04, 0.04)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Park/Unpark logic
CreateThread(function()
    while true do
        Wait(0)
        if isLoggedIn then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)

                -- The player must be the driver of the vehicle.
                if GetPedInVehicleSeat(vehicle, -1) == ped then

                    -- Check if the player is in a parked vehicle.
                    local storedVehicle = GetPlayerInStoredCar(ped)
                    if storedVehicle ~= false then
                        DisplayHelpText(Lang:t("info.press_drive_car", {key = Config.KeyBindButton}))
                        if IsControlJustReleased(0, Config.ParkButton) then -- E
                            isUsingParkCommand = true 
                        end
                    end

                    -- Check if the player press F button.
                    if IsControlJustReleased(0, 75) then -- F
                        if Config.AutoParkWhenEngineIsOff then
                            local engineIsOn = GetIsVehicleEngineRunning(vehicle)
                            if not engineIsOn then isUsingParkCommand = true end
                        end
                    end

                    -- When the park command is used.
                    if isUsingParkCommand then
                        isUsingParkCommand = false
                        if storedVehicle ~= false then
                            Drive(storedVehicle)
                        else
                            if GetEntitySpeed(vehicle) > 0.9 then
                                Notify(Lang:t("info.stop_car"), 'error', 1500)
                            elseif IsThisModelACar(GetEntityModel(vehicle)) or IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelABicycle(GetEntityModel(vehicle)) or IsThisModelAHeli(GetEntityModel(vehicle)) or IsThisModelAPlane(GetEntityModel(vehicle)) then
                                Save(vehicle)
                            else
                                Notify(Lang:t("info.only_cars_allowd"), "error", 5000)
                            end
                        end
                    end
                end
            else
                isUsingParkCommand = false
            end
        end
    end
end)

-- Check if player is in vehicle or not
CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn then
            sleep = 100
            local ped = PlayerPedId()
            if not isInVehicle and not IsPlayerDead(PlayerId()) then
                if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
                    currentVehicle = GetVehiclePedIsTryingToEnter(ped)
                    currentSeat = GetSeatPedIsTryingToEnter(ped)
                    isEnteringVehicle = true
                    currentPlate = GetPlate(currentVehicle)
                    local netid = VehToNet(currentVehicle)
                    --TriggerServerEvent('mh-parking:server:EnteringVehicle', netid, currentSeat)
                elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and
                    isEnteringVehicle then
                    isEnteringVehicle = false
                elseif IsPedInAnyVehicle(ped, false) then
                    isEnteringVehicle = false
                    isInVehicle = true
                    currentVehicle = GetVehiclePedIsUsing(ped)
                    currentSeat = GetPedVehicleSeat(ped)
                    currentPlate = GetPlate(currentVehicle)
                    local netid = VehToNet(currentVehicle)
                    --TriggerServerEvent('mh-parking:server:EnteredVehicle', netid, currentSeat)
                end
            elseif isInVehicle and not IsPlayerDead(PlayerId()) then
                if not IsPedInAnyVehicle(ped, false) then
                    local vehicle = GetVehiclePedIsIn(ped, true)
                    isEnteringVehicle = false
                    isInVehicle = false
                    currentVehicle = 0
                    currentSeat = 0
                    Citizen.Wait(2500)
                    SetVehicleEngineOn(vehicle, false, false, true)
                    --TriggerServerEvent('mh-parking:server:LeftVehicle', netid, currentSeat)
                elseif not IsPedInAnyVehicle(ped, false) and not IsPlayerDead(PlayerId()) then
                    isEnteringVehicle = false
                    isInVehicle = false
                    currentVehicle = 0
                    currentSeat = 0
                end
            end
        end
        Wait(sleep)
    end
end)