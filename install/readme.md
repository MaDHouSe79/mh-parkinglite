# Here are some codes you can use in your server.

# QB Shared Vehicles trailers.
- Change the price or shop is you want.
```lua
--- Trailers
{ model = "trailersmall",    name = "trailersmall",                  brand = "Trailer",         price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
{ model = "boattrailer",     name = "boattrailer",                   brand = "Boattrailer",     price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
{ model = "boattrailer2",    name = "boattrailer2",                  brand = "Boattrailer",     price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
{ model = "trailers",        name = "trailers",                      brand = "Trailers",        price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
{ model = "trailers2",       name = "trailers2",                     brand = "Trailers",        price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
{ model = "trailers3",       name = "trailers3",                     brand = "Trailers",        price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
{ model = "trailers4",       name = "trailers4",                     brand = "Trailers",        price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
{ model = "trflat",          name = "trflat",                        brand = "Trailers",        price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
{ model = "tr4",             name = "tr4",                           brand = "Trailers",        price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
{ model = "tr2",             name = "tr2",                           brand = "Trailers",        price = 10000,   category = "trailer",        type = "automobile", shop = "trailers" },
```

# QB-Vehicleshop (trailer shop)
```lua
['trailers'] = {
    ['Type'] = 'free-use',
    ['Zone'] = {
        ['Shape'] = {
            vector2(980.17779541016, -1144.8859863281),
            vector2(979.470703125, -1159.9912109375),
            vector2(957.63580322266, -1159.2982177734),
            vector2(958.64776611328, -1138.3218994141),
            vector2(969.24969482422, -1138.6915283203),
        },
        ['minZ'] = 22.610145568848,
        ['maxZ'] = 28.610145568848,
        ['size'] = 7.0,
    },
    ['Job'] = 'none',
    ['ShopLabel'] = 'Trailer Shop',
    ['showBlip'] = true,
    ['blipSprite'] = 479,
    ['blipColor'] = 3,
    ['TestDriveTimeLimit'] = 1.5,
    ['Location'] = vector3(973.4020, -1151.5939, 24.8990),
    ['ReturnLocation'] = vector3(988.3016, -1165.1842, 25.0336),
    ['VehicleSpawn'] = vector4(972.8048, -1168.8602, 25.2488, 0.1642),
    ['TestDriveSpawn'] = vector4(966.4030, -1169.0101, 25.3640, 0.8755),
    ['FinanceZone'] = vector3(970.8918, -1143.9852, 25.1887),
    ['ShowroomVehicles'] = {
        [1] = {
            coords = vector4(966.6785, -1156.2245, 25.1178, 269.0622),
            defaultVehicle = 'tr2',
            chosenVehicle = 'tr2'
        },
        [2] = {
            coords = vector4(966.9294, -1153.0031, 25.0312, 269.7032),
            defaultVehicle = 'trflat',
            chosenVehicle = 'trflat'
        },
        [3] = {
            coords = vector4(965.5670, -1146.6980, 24.9106, 269.3104),
            defaultVehicle = 'boattrailer',
            chosenVehicle = 'boattrailer'
        },
    },
}
```
