Config                           = {}
---------

Config.CheckForUpdates           = true

Config.UseSpawnDelay             = true      -- 👉 Default false, if your vehicles spawn on top of each other, set this to true
Config.DeleteDelay               = 1500      -- 👉 Default 500, a delay for spawning in a other vehicle. (works only if Config.UseSpawnDelay = true)
Config.FreezeDelay               = 50        -- 👉 Default 10, a sort delay for freezeing a vehicle. (works only if Config.UseSpawnDelay = true)
Config.DisplayDistance           = 20.0      -- 👉 Distence to see text above parked vehicles (player dependent)
---------
Config.KeyBindButton             = "F5"      -- 👉 If you want to change the drive and park button. (you must use /binds for this)
Config.ParkingButton             = 166       -- 👉 F5 (vehicle exit and or park)
---------
Config.UseStopSpeedForPark       = true      -- 👉 Default true
Config.MinSpeedToPark            = 0.9       -- 👉 Default 1 the min speed to park
---------
Config.PlaceOnGroundRadius       = 100.0     -- 👉 lower wil limit the distance of placeing vehicles on the ground.
Config.ResetState                = 1         -- 👉 1 is stored in garage, 2 is police impound. 
---------
Config.UseParkingSystem          = true      -- 👉 Auto turn on when server is starting. (default true)
Config.UseParkedVehicleNames     = false     -- 👉 Default is false, if you want to see names just type /park-names on/off if you set this to true it is auto on 
Config.UseOwnerNames             = false     -- 👉 If you want to use owner names above parked vehicles

Config.UseParkingBlips           = true      -- 👉 If you want to have parking blips on the map (player dependent)

Config.UseTargetEye              = true      -- 👉 If you want to use target
Config.InteractDistance          = 5.0       -- 👉 Interact distance.

-- Vip Or All players can park.
Config.UseForVipOnly             = false     -- 👉 If you only want to use vip set this to true: NOTE (Config.UseMaxParkingOnServer and Config.UseMaxParkingPerPlayer to false)
Config.UseMaxParkingOnServer     = true      -- 👉 If you want to limit the parking on the server
Config.MaxServerParkedVehicles   = 25        -- 👉 Max allowed to park on server
Config.UseMaxParkingPerPlayer    = true      -- 👉 If you want to limit players with a amount of parking vehicles
Config.MaxStreetParkingPerPlayer = 1         -- 👉 Max allowed pakring vehivles per player
---------

Config.Command = {
    park         = 'park',                   -- 👉 User/Admin permission
    parknames    = 'park-names',             -- 👉 User/Admin permission
    addvip       = 'park-addvip',            -- 👉 Admin permission
    removevip    = 'park-removevip',         -- 👉 Admin permission
}

-- Do not change this below...
Config.ParkingLocation = {x = 232.11, y = -770.14, z = 0.0, w = 900.10, s = 99999099.0}
