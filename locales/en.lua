local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Failed to get player citizenid!",
        ["mis_id"]              = "[Error] A player ID is required.",
        ["mis_amount"]          = "[Error] There is no number of vehicles that this player can park in advance.",
    },
    commands = {
        ["addvip"]              = "Add", 
        ["removevip"]           = "Remove", 
    },
    system = {
        ['enable']              = "Park systeen %{type} is enable",
        ["disable"]             = "Park systeem %{type} is disable",
        ["max_allow_reached"]   = "The maximum number of packed vehicles for you is %{max}",
        ["park_or_drive"]       = "Park or Drive",
        ["parked_blip_info"]    = "Parked: %{modelname}",
        ["to_far_from_vehicle"] = "You are to far from the vehicle",
	    ["offline"]             = "The system is currently disarmed.",
        ["vip_add"]             = "Player %{username} is added as vip!",
        ["vip_remove"]          = "Player %{username} is removed as vip!",
	    ["no_permission"]       = "Park system: You do not have permission to park.",
	    ["already_vip"]         = "Player is already a vip!",
    },
    success = {
        ["parked"]              = "Your car is packed",
    },
    info = {
        ["owner"]               = "Owner: ~y~%{owner}~s~",
        ["plate"]               = "Plate: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Press F5 to start driving",
        ["car_already_parked"]  = "This parking lot has already parked a car with the same plate",
        ["car_not_found"]       = "No vehicle found",
        ["maximum_cars"]        = "A maximum of ~r~%{value}~s~ cars can be parked outside on the street, and the limit has been reached, you must park this vehicle in the parking garage!",
        ["must_own_car"]        = "You must own the car.",
        ["has_take_the_car"]    = "Your vehicle has been removed from the parking zone",
        ["only_cars_allowd"]    = "You can only park cars here",
        ["stop_car"]            = "Stop the vehicle before you want to park it...",
        ["drive"]               = "Drive Vecihle",
        ["park"]                = "Park Vehicle",
        ["limit_for_player"]    = "You can park a maximum of %{amount} vehicle(s) on the street!",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
