-- Cancel Trees & Bridge after loading screen from popping up.
-- Add this to any existing resource and update your manifest by adding "client/trees.lua", (if it's the last client resource make sure to remove the comma)
local Tree = false

AddEventHandler("playerSpawned", function ()
    if not Tree then
        ShutdownLoadingScreenNui() -- src https://runtime.fivem.net/doc/natives/?_0xB9234AFB
        Tree = true
    end
end)