local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Kunne ikke finne spiller citizenid!",
        ["mis_id"]              = "[Error] En spiller ID er påkrevd.",
        ["mis_amount"]          = "[Error] There is no number of vehicles that this player can park.",
    },
    commands = {
        ["addvip"]              = "Add", 
        ["removevip"]           = "Remove",
        ["togglenames"]         = "Toogle vehicle names",
    },
    system = {
        ['enable']              = "Park system %{type} is now enable",
        ["disable"]             = "Park system %{type} is now disable",
        ["update_needed"]       = "Park System er utdatert....",
        ["max_allow_reached"]   = "Du har parkert maks antall kjøretøy du kan parkere %{max}",
        ["park_or_drive"]       = "Park or Drive",
        ["parked_blip_info"]    = "Parked: %{modelname}",
        ["offline"]             = "Park System is offline",
        ["vip_add"]             = "Player %{username} is added as vip!",
        ["vip_remove"]          = "Player %{username} is removed as vip!",
        ["no_permission"]       = "Park system: You do not have permission to park.",
    	["already_vip"]         = "Player is already a vip!",
        ["vip_not_found"]       = "Player not found!",
        ["already_reserved"]    = "This parking place has already been reserved.",

    },
    success = {
        ["parked"]              = "Din bil er parkert",
        ["route_has_been_set"]  = "GPS er satt til lokasjon av bilen din.",
    },
    info = {
        ["owner"]               = "Eier: ~y~%{owner}~s~",
        ["plate"]               = "Reg nr: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Trykk K for å kjøre",
        ["car_already_parked"]  = "Et kjøretøy med samme skilt nr er allerede parkert",
        ["car_not_found"]       = "Inget kjøretøy funnet",
        ["maximum_cars"]        = "Det kan være maks ~r~%{amount}~s~ biler parkert på gaten, og grensen er nå nådd, du må parkere dette kjøretøyet i en garasje!",
        ["must_own_car"]        = "Du må eie bilen for å parkere den.",
        ["has_take_the_car"]    = "Ditt kjøretøy er fjernet fra parkerings sonen",
        ["only_cars_allowd"]    = "Du kan bare parkere biler her",
        ["stop_car"]            = "Stopp kjøretøy før du parkerer",
        ["drive"]               = "Drive Vecihle",
        ["park"]                = "Park Vehicle",
        ["limit_for_player"]    = "you can park %{amount} amount of vegicles on the street!",
        ["not_allowed_to_park"] = "You cannot park a vehicle here!",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
