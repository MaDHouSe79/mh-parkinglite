Config = {}

Config.Framework = "qb" -- qb/qbx/esx
Config.Target = "qb-target" -- qb-target or ox_target
Config.KeyScript = "qb-vehiclekeys" -- qb-vehiclekeys or qbx_vehiclekeys
Config.UseAutoPark = true

Config.ParkButton = 166 -- F5
Config.KeyBindButton = "F5" -- 166

Config.AutoParkWhenEngineIsOff = true
Config.SaveSteeringAngle = true

Config.UseVip = true
Config.MaxParkingPerPlayer = 5 -- This if for NOT vip mode enable

Config.ParkWithTrailers = true
Config.ParkTrailersWithLoad = true

Config.FreezeVehicles = true

Config.Command = {
    park = 'park',
    parknames = 'park-names',
    parkmenu = 'parkmenu',
    togglesteerangle = 'togglesteerangle',
}

Config.VehicleTypes = {
    motorcycles = 'bike', 
    boats = 'boat', 
    helicopters = 'heli', 
    planes = 'plane', 
    submarines = 'submarine', 
    trailer = 'trailer', 
    train = 'train'
}

Config.Models = {
    trucks = {'hauler', 'bison', 'sadler'},
    trailers = {'tr2', 'trailersmall', 'boattrailer', 'trflat'},
    ramp = "imp_prop_flatbed_ramp"
}

-- Police Impound
Config.PayTimeInSecs = 10 -- 10 dollar or euro...
Config.ParkPrice = 100 -- price to park
Config.MaxParkTime = 259200 -- 3 Days, after that the vehicle wil be impounded.
-- 1 Day  = 86400 Seconden   10 Days   = 864000 Seconden   2500    Days = 216000000 Seconden
-- 2 Days = 172800 Seconden  20 Days   = 1728000 Seconden  5000    Days = 432000000 Seconden
-- 3 Days = 259200 Seconden  30 Days   = 2592000 Seconden  10000   Days = 864000000 Seconden
-- 4 Days = 345600 Seconden  40 Days   = 3456000 Seconden  25000   Days = 2160000000 Seconden
-- 5 Days = 432000 Seconden  50 Days   = 4320000 Seconden  50000   Days = 4320000000 Seconden
-- 6 Days = 518400 Seconden  100 Days  = 8640000 Seconden  100000  Days = 8640000000 Seconden
-- 7 Days = 604800 Seconden  250 Days  = 21600000 Seconden	250000  Days = 21600000000 Seconden
-- 8 Days = 691200 Seconden  500 Days  = 43200000 Seconden 500000  Days = 43200000000 Seconden
-- 9 Days = 777600 Seconden  1000 Days = 86400000 Seconden 1000000 Days = 86400000000 Seconden
---------------------------------------------------------------------------------------

-- Police impound (server side)
function PoliceImpound(plate, fullImpound, price, body, engine, fuel)
    if Config.Framework == 'esx' then
        -- add your trigger here
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        TriggerEvent("police:server:Impound", plate, fullImpound, price, body, engine, fuel)
    end
end

-- Vehicle keys (client side)
function SetClientVehicleOwnerKey(plate, vehicle)
    if Config.KeyScript == "qb-vehiclekeys" then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    elseif Config.KeyScript == "qbx_vehiclekeys" then
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
    end
end