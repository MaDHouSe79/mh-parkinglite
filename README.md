<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>

<p align="center">
    <a href="https://github.com/MaDHouSe79/mh-parking/issues">
        <img src="https://img.shields.io/github/issues/MaDHouSe79/mh-parking"/> 
    </a>
    <a href="https://github.com/MaDHouSe79/mh-parking/watchers">
        <img src="https://img.shields.io/github/watchers/MaDHouSe79/mh-parking"/> 
    </a> 
    <a href="https://github.com/MaDHouSe79/mh-parking/network/members">
        <img src="https://img.shields.io/github/forks/MaDHouSe79/mh-parking"/> 
    </a>  
    <a href="https://github.com/MaDHouSe79/mh-parking/stargazers">
        <img src="https://img.shields.io/github/stars/MaDHouSe79/mh-parking?color=white"/> 
    </a>
    <a href="https://github.com/MaDHouSe79/mh-parking/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/MaDHouSe79/mh-parking?color=black"/> 
    </a>      
</p>

<p align="center">
    <img src="https://komarev.com/ghpvc/?username=MaDHouSe79&label=Profile%20views&color=3464eb&style=for-the-badge&logo=star&abbreviated=true" alt="MaDHouSe79" style="padding-right:20px;" />
</p>

# Youtube
- [Youtube](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)

# MH-Parking
This is a very awesome parking mod, that i specially made for [qb-core](https://github.com/qbcore-framework/qb-core) 
This is just how you park in real live 😁 so park anywhere you want 👊😁👍

# Dependencies
- [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)

# Optional
- [interact-sound](https://github.com/qbcore-framework/interact-sound)


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

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)