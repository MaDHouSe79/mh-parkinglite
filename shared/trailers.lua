-- [[ ===================================================== ]] --
-- [[              MH Park System by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --

Config.Trailers = {
    [712162987] =   {model = "trailersmall", name = "trailersmall", brand = "Trailer",     offset = {backwards = -5.70}},
    [524108981] =   {model = "boattrailer",  name = "boattrailer",  brand = "Boattrailer", offset = {backwards = -7.25}},
    [1835260592] =  {model = "boattrailer2", name = "boattrailer2", brand = "Boattrailer", offset = {backwards = -8.79}},
    [-877478386] =  {model = "trailers",     name = "trailers",     brand = "Trailers",    offset = {backwards = -6.1}},
    [-1579533167] = {model = "trailers2",    name = "trailers2",    brand = "Trailers",    offset = {backwards = -6.1}},
    [-2058878099] = {model = "trailers3",    name = "trailers3",    brand = "Trailers",    offset = {backwards = -6.1}},
    [-100548694] =  {model = "trailers4",    name = "trailers4",    brand = "Trailers",    offset = {backwards = -6.1}},
    [-1352468814] = {model = "trflat",       name = "trflat",       brand = "Trailers",    offset = {backwards = -6.1}},
    [2091594960] =  {model = "tr4",          name = "tr4",          brand = "Trailers",    offset = {backwards = -7.8}},
    [2078290630] =  {
        model = "tr2",          
        name = "tr2",          
        brand = "Trailers",    
        offset = {backwards = -7.8}, 
        parklist = { 
            [1] = { id = 1, coords = vector3(0.0, 4.8, 1.0), loaded = false, entity = nil }, 
            [2] = { id = 2, coords = vector3(0.0, 0.0, 1.1), loaded = false, entity = nil }, 
            [3] = { id = 3, coords = vector3(0.0, -5.1, 1.2), loaded = false, entity = nil },
            [4] = { id = 4, coords = vector3(0.0, 5.1, 3.0), loaded = false, entity = nil }, 
            [5] = { id = 5, coords = vector3(0.0, 0.0, 3.1), loaded = false, entity = nil }, 
            [6] = { id = 6, coords = vector3(0.0, -5.1, 3.2), loaded = false, entity = nil }
        }
    },
}

Config.TrailerBoats = {
    -- dinghy
    [1033245328] = {model = "dinghy",  name = "Dinghy", brand = "Trailers"},
    [276773164]  = {model = "dinghy2", name = "Dinghy", brand = "Trailers"},
    [509498602]  = {model = "dinghy3", name = "Dinghy", brand = "Trailers"},
    [867467158]  = {model = "dinghy4", name = "Dinghy", brand = "Trailers"},
    [3314393930] = {model = "dinghy5", name = "Dinghy", brand = "Trailers"},
    -- seashark
    [-1030275036] = {model = "seashark",  name = "Seashark", brand = "Trailers"},
    [3678636260]  = {model = "seashark2", name = "Seashark", brand = "Trailers"},
    [3983945033]  = {model = "seashark3", name = "Seashark", brand = "Trailers"},
}

Config.TrailerSettings = {
    -- tr2 trailer
    [2078290630] = {
        offsetX = 0.0,   -- dont edit this part
        offsetY = 0.0,   -- dont edit this part
        offsetZ = 0.08,  -- dont edit this part
        hasRamp = false, -- if this trailer has a ramp already
        hasdoors = true, -- if this trailer has doors (this can be ramps as well, depends on the door numver)
        width = 3.0,     -- the width of the trailer 
        length = 9.0,    -- the length of the trailer
        loffset = -1.0,  -- lower offset (dont edit this part)
        doors = {ramp = 5, platform = 4}, -- door numbers (make sure this is right)
        ramp = {},       -- this trailer has its own ramp
        maxspace = 6,    -- max space for vehicles
        parked = 0,      -- count the total parked vehicles on this trailer.
    },

    -- pjtrailer (gooseneck)
    [1029869057]  = {
        offsetX = 0.0,
        offsetY = 0.0,
        offsetZ = 0.08,
        width = 3.0,
        length = 9.0,
        loffset = -1.0,
        hasRamp = false,
        hasdoors = true,
        doors = {ramp = 5, platform = 4},
        ramp = {},
        maxspace = 2,
        parked = 0,
    }, 

    -- trflat (only a ramp)
    [-1352468814] = {
        offsetX = 0.0,
        offsetY = 0.0,
        offsetZ = 0.15,
        width = 3.0,
        length = 9.0,
        loffset = -1.0,
        hasRamp = true,
        hasdoors = false,
        doors = {ramp = 5},
        ramp = {offsetX = 0.0, offsetY = -9.3, offsetZ = -1.4, rotation = 180.0},
        maxspace = 2,
        parked = 0,
    },      

    -- small trailer (no doords)
    [712162987] = {
        offsetX = 0.0,
        offsetY = -0.3,
        offsetZ = 0.08,
        width = 3.0,
        length = 9.0,
        loffset = -1.0,
        hasdoors = false,
        hasRamp = false,
        doors = {},
        ramp = {},
        maxspace = 1,
        parked = 0,
    },

    -- boat trailer (no doors)
    [524108981] = {
        offsetX = 0.0,
        offsetY = 0.0,
        offsetZ = 0.08,
        width = 3.0,
        length = 9.0,
        loffset = -1.0,
        hasdoors = false,
        hasRamp = false,
        doors = {},
        ramp = {},
        maxspace = 1,
        parked = 0,
    },                                   
}
