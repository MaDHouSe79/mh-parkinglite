## QB-Parking
This is a very awesome parking mod, that i specially made for [qb-core](https://github.com/qbcore-framework/qb-core) 
This is just how you park in real live 😁 so park anywhere you want 👊😁👍

## Read The Updates.md for updates and changes.

## 📸 Screenshot 👊😁👍
![foto1](https://www.madirc.nl/fivem/foto1.png)


## 🎥 Video 👊😁👍
[![Watch the video1](https://www.madirc.nl/fivem/video.png)](https://youtu.be/cLCthqPRLQQ)


## 💪 Dependencies
- ✅ [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)
- ✅ [qb-core](https://github.com/qbcore-framework/qb-core)
- ✅ [qb-garages](https://github.com/MaDHouSe79/qb-garages)
- ✅ [qb-vehiclekeys](https://github.com/qbcore-framework/qb-vehiclekeys)

## 💪 Optional
- ✅ [interact-sound](https://github.com/qbcore-framework/interact-sound)


## 🙏 How to install and do not forget anything, or it will not work, or give many errors.
- 👉 Step 1: First stop your server. 😁
- 👉 Step 2: Copy the directory qb-parking to resources/[qb]/
- 👉 Step 3: Add the player_parking.sql with 2 tables to your correct database.
- 👉 Step 4: Add any recommended extra code what I say you should add.
- 👉 Step 5: If you are 100% sure, you have done all 4 steps correctly, go to step 6.😁
- 👉 Step 6: Start your server.  
- 👉 Step 7: Most important step -> Enjoy 👊😎👍


## 🍀 Features
- ✅ Easy to install and use
- ✅ QB-Phone notifications
- ✅ Admin Controll like disable or enable the system or set it to only allowed for vip players only.
- ✅ User Controll like displaying text on screen.
- ✅ Players with user status will only see the model name of this vecihle, not the owners name or plate.
- 👉 Your players will love this extra feature, if they can park there own vehicle in front of there housees or clubs. 
- 👉 Your players can setup youtube scenes, and if they want, they can come back later, and your vechiles are still there.
- 👉 This is very usefull cause if you make a scene and somehthing goes wrong, then don't wory you vechiles are right there.
- 👉 And of course you should not forget to park your vehicle 👊😁👍


## 🎮 How To Use
- 👉 Typ "/park" to park or drive your vehicle where you are at that moment. (Users and Admins)
- 👉 Typ "/park-names if you want to display the names ontop of the vehicle that is parked. (Users and Admins)
- 👉 If you want to use the F5 button, you must add it to your /binds and add on F5 the word "park"


## ⚙️ Settings
- 👉 Change the max cars that can park in the world space, change the amount from Config.Maxcarparking in the config.lua file. 
- 👉 Vip users can be added in shared/config.lua => Config.VipPlayers = {} only if you use the vip option.
- 👉 Knowledge of programming and use your brains cause i'am not going to help you install this mod, cause it's very easy to do.


## 💯 What i recommend for using this mod
- 👉 I recommend to use this mod only for vip players or for players who are most online on you server.
- 👉 Try not to spawn too many vehicles in world space, this can cause issues and hiccups. 
- 👉 It is also recommended to have a good computer/server to use this mod, cause you will need it.
- 👉 To keep the server nice and clean for everyody, use this system only for vip players. 


## 💯 I tested this mod on a computer/server with the following settings
- ✅ Prossessor: I7 12xCore
- ✅ Memory: 16 gig memory
- ✅ Graphics: GTX 1050 TI 4GB


## 🙏 Don't do this...
- 👉 DO NOT park your vehicles on roofs or that kind of stuff, just don't do it, it will work, but it breaks the mod,
- 👉 use the recommended parking spots in the world like you do in real life,
- 👉 you can do of course just park at your own house on a parking spot to keep it nice and clean for everyone.


## 👇 To keep things nice and clean for the qb-core system and database.
- ✅ Go to resources[qb]/qb-core/server/player.lua around line 506, and find, local playertables = {}. 
- ✅ This is, if we want to delete a character, we also want to delete the parked vehicles in the database,
- ✅ Place the line below at the bottom in playertables (there are more insite), so place this one at the bottom.
````lua
{ table = 'player_parking' },
````


## ⚙️ To get a other languages.
- 1: copy a file from the resources[qb]/qb-parking/locales directory
- 2: rename this file for example fr.lua or sp.lua
- 3: translate the lines in the file to your language
- 4: you now have added a new language to the system, enjoy 😎


## 🐞 Any bugs issues or suggestions, let my know.
- If you have any suggestions or nice ideas let me know and we can see what we can do 👊😎
- Keep it nice and clean for everybody and have fun with this awesome qb-parking mod 😎👍


## 🙈 Youtube & Discord
- [Youtube](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)
- [Discord](https://discord.gg/cEMSeE9dgS)
