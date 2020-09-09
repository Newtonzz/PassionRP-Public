-- For the sake of saving your self to start up yet another resource, just add this script to any existing resource and update your manifest by adding  "client/pov.lua", (if it's the last client resource make sure to remove the comma)

Citizen.CreateThread(function()
    local setpov = false
    while true do
        DisableControlAction(0, 0, true) -- Controlkey "V"
        local PlayerPed = PlayerPedId()
        local VehicleCurrentCamViewMode = GetFollowVehicleCamViewMode(PlayerPed) -- src https://runtime.fivem.net/doc/natives/?_0xAC253D7842768F48
            if IsPedInAnyVehicle(PlayerPed) then -- When in Vehicle
            if not setpov and IsDisabledControlJustPressed(0, 0) then
                setpov = true
                SetFollowVehicleCamViewMode(4) -- First Person View
            elseif setpov and IsDisabledControlJustPressed(0, 0) then
                setpov = false
                SetFollowVehicleCamViewMode(0) -- Third Person View Close
            end
        elseif not IsPedInAnyVehicle(PlayerPed2) then -- When on foot
            local CurrentCamViewMode = GetFollowPedCamViewMode(PlayerPed)
            if not setpov and IsDisabledControlJustPressed(0, 0) then
                setpov = true
                SetFollowPedCamViewMode(4)
            elseif setpov and IsDisabledControlJustPressed(0, 0) then
                setpov = false
                SetFollowPedCamViewMode(0)
            end
        end
        Citizen.Wait(0)
    end
end)
