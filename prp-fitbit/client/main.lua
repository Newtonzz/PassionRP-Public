Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

PRPCore = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if PRPCore == nil then
            TriggerEvent('PRPCore:GetObject', function(obj) PRPCore = obj end)
            Citizen.Wait(200)
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    Wait(2500)
    passiveUpdate()
  end)

-- Code

local inWatch = false
local isLoggedIn = false
local compassToggle = true

PlayerJob = {}
local hunger = 100
local thirst = 100
local stress = 0
local StressGain = 0
local IsGaining = false
-- steps is the last amount of steps since saving
local m_steps

-- count is the steps measured since last save
local m_count = 0

-- the next time in ticks it should save
local m_nextSave

RegisterNetEvent("PRPCore:Client:OnPlayerUnload")
AddEventHandler("PRPCore:Client:OnPlayerUnload", function()
    isLoggedIn = false
end)

RegisterNetEvent("PRPCore:Client:OnPlayerLoaded")
AddEventHandler("PRPCore:Client:OnPlayerLoaded", function()
    isLoggedIn = true
    PlayerJob = PRPCore.Functions.GetPlayerData().job
    local PlayerData = PRPCore.Functions.GetPlayerData()
    TriggerEvent('prp-hud:toggleHud',PlayerData.metadata["fitbit"].hud)
    TriggerEvent('prp-hud:toggleCompass',PlayerData.metadata["fitbit"].compass)
end)


-- STRESS
RegisterNetEvent('hud:client:UpdateStress')
AddEventHandler('hud:client:UpdateStress', function(newStress)
    stress = newStress
    passiveUpdate()
end)

Citizen.CreateThread(function()
    while true do
        if not IsGaining then
            StressGain = math.ceil(StressGain)
            if StressGain > 0 then
                PRPCore.Functions.Notify('Gained Stress', "primary", 2000)
                TriggerServerEvent('prp-hud:Server:UpdateStress', StressGain)
                StressGain = 0
            end
        end

        Citizen.Wait(3000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if PRPCore ~= nil and isLoggedIn then
            if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                speed = GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1), false)) * 3.6
                if speed >= FXStress.MinimumSpeed then
                    TriggerServerEvent('prp-hud:Server:GainStress', math.random(2, 4))
                end
            end
        end
        Citizen.Wait(20000)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = GetPlayerPed(-1)

        if IsPedShooting(GetPlayerPed(-1)) then
            local StressChance = math.random(1, 3)
            local odd = math.random(1, 3)
            if StressChance == odd then
                local PlusStress = math.random(2, 4) / 100
                StressGain = StressGain + PlusStress
            end
            if not IsGaining then
                IsGaining = true
            end
        else
            if IsGaining then
                IsGaining = false
            end
        end

        if (PlayerJob.name ~= "police") then
            if IsPlayerFreeAiming(PlayerId()) and not IsPedShooting(GetPlayerPed(-1)) then
                local CurrentWeapon = GetSelectedPedWeapon(ped)
                local WeaponData = PRPCore.Shared.Weapons[CurrentWeapon]
                if WeaponData.name:upper() ~= "WEAPON_UNARMED" then
                    local StressChance = math.random(1, 20)
                    local odd = math.random(1, 20)
                    if StressChance == odd then
                        local PlusStress = math.random(1, 3) / 100
                        StressGain = StressGain + PlusStress
                    end
                end
                if not IsGaining then
                    IsGaining = true
                end
            else
                if IsGaining then
                    IsGaining = false
                end
            end
        end

        Citizen.Wait(2)
    end
end)

function GetShakeIntensity(stresslevel)
    local retval = 0.05
    for k, v in pairs(FXStress.Intensity["shake"]) do
        if stresslevel >= v.min and stresslevel < v.max then
            retval = v.intensity
            break
        end
    end
    return retval
end

function GetEffectInterval(stresslevel)
    local retval = 60000
    for k, v in pairs(FXStress.EffectInterval) do
        if stresslevel >= v.min and stresslevel < v.max then
            retval = v.timeout
            break
        end
    end
    return retval
end

Citizen.CreateThread(function()
    while true do
        local ped = GetPlayerPed(-1)
        local Wait = GetEffectInterval(stress)
        if stress >= 100 then
            local ShakeIntensity = GetShakeIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = (FallRepeat * 1750)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 3000, 500)

            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                local player = PlayerPedId()
                SetPedToRagdollWithFall(player, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(player), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Citizen.Wait(500)
            for i = 1, FallRepeat, 1 do
                Citizen.Wait(750)
                DoScreenFadeOut(200)
                Citizen.Wait(1000)
                DoScreenFadeIn(200)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
                SetFlash(0, 0, 200, 750, 200)
            end
        elseif stress >= FXStress.MinimumStress then
            local ShakeIntensity = GetShakeIntensity(stress)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 2500, 500)
        end
        Citizen.Wait(Wait)
    end
end)

--FOOD/WATER

RegisterNetEvent("hud:client:UpdateNeeds")
AddEventHandler("hud:client:UpdateNeeds", function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
    passiveUpdate()
end)

-- STAPPEN TELLER 2.0 

CreateThread(function()
    -- retrieve old steps count from kvp
    m_steps = GetResourceKvpFloat("stappenteller_steps")
    reset()

    while true do
        -- update step count every 500ms
        Wait(500)

    local _, walkDist = StatGetFloat(`mp0_dist_walking`)
    local _, runDist  = StatGetFloat(`mp0_dist_running`)
    local distance = walkDist + runDist

        -- meters to steps
        m_count = distance * 1.31233595800525

        if GetGameTimer() > m_nextSave then
        saveSteps()
        end
    end
end)

-- reset resets the local gta dist stats used for counting
function reset()
    StatSetFloat(`mp0_dist_walking`, 0.0, true)
    StatSetFloat(`mp0_dist_running`, 0.0, true)

    -- save every 20 seconds
    m_nextSave = GetGameTimer() + 20000
end

-- getSteps gets the amount of steps
function getSteps()
    return math.floor(m_steps + m_count)
end

-- saveSteps saves the amount of steps to KVP and stappenteller 2.0
function saveSteps()
    m_steps = getSteps()
    m_count = 0

    reset()

    SetResourceKvpFloat("stappenteller_steps", m_steps) -- Indra was here
end

-- copy pasta from indra ezpz

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- BASIC APPS
local hudToggle = true
local _hungerThirstToggle = true
function openWatch()
    local PlayerData = PRPCore.Functions.GetPlayerData()
    SendNUIMessage({
        action = "openWatch",
        watchData = {},
        stepData = getSteps(),
        hungerData = hunger,
        thirstData = thirst,
        stressData = stress,
        foodReminder = PlayerData.metadata["fitbit"].food,
        thirstReminder = PlayerData.metadata["fitbit"].thirst,
        compassToggle = PlayerData.metadata["fitbit"].compass,
        hudToggle = PlayerData.metadata["fitbit"].hud,
        hungerThirstToggle = PlayerData.metadata["fitbit"].hungerThirst,
    })
    SetNuiFocus(true, true)
    inWatch = true
    playAnim('amb@code_human_wander_idles_fat@male@idle_a','idle_a_wristwatch',1500)
end

function passiveUpdate()
    local PlayerData = PRPCore.Functions.GetPlayerData()
    SendNUIMessage({
        action = "passiveUpdate",
        stepData = getSteps(),
        hungerData = hunger,
        thirstData = thirst,
        stressData = stress,
        foodReminder = PlayerData.metadata["fitbit"].food,
        thirstReminder = PlayerData.metadata["fitbit"].thirst,
        compassToggle = PlayerData.metadata["fitbit"].compass,
        hudToggle = PlayerData.metadata["fitbit"].hud,
        hungerThirstToggle = PlayerData.metadata["fitbit"].hungerThirst,
    })
end

function playAnim(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(GetPlayerPed(-1), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
    RemoveAnimDict(animDict)
end

function closeWatch()
    SetNuiFocus(false, false)
end

RegisterNUICallback('close', function()
    closeWatch()
end)

RegisterNetEvent('prp-fitbit:use')
AddEventHandler('prp-fitbit:use', function()
  openWatch(true)
end)

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(5 * 60 * 1000)
        
        if isLoggedIn then
            PRPCore.Functions.TriggerCallback('prp-fitbit:server:HasFitbit', function(hasItem)
                if hasItem then
                    local PlayerData = PRPCore.Functions.GetPlayerData()
                    if PlayerData.metadata["fitbit"].food ~= nil then
                        if PlayerData.metadata["hunger"] < PlayerData.metadata["fitbit"].food then
                            TriggerEvent("chatMessage", "FITBIT ", "warning", "Your food "..round(PlayerData.metadata["hunger"], 2).."%")
                            PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
                        end
                    end
        
                    if PlayerData.metadata["fitbit"].thirst ~= nil then
                        if PlayerData.metadata["thirst"] < PlayerData.metadata["fitbit"].thirst  then
                            TriggerEvent("chatMessage", "FITBIT ", "warning", "Your hydration "..round(PlayerData.metadata["thirst"], 2).."%")
                            PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
                        end
                    end
                end
            end, "fitbit")
        end
    end
end)

RegisterNUICallback('setFoodWarning', function(data)
    local foodValue = tonumber(data.value)

    TriggerServerEvent('prp-fitbit:server:setValue', 'food', foodValue)

    PRPCore.Functions.Notify('Fitbit: Food warning set at '..foodValue..'%')
end)

RegisterNUICallback('setThirstWarning', function(data)
    local thirstValue = tonumber(data.value)

    TriggerServerEvent('prp-fitbit:server:setValue', 'thirst', thirstValue)

    PRPCore.Functions.Notify('Fitbit: Thirst warning set at '..thirstValue..'%')
end)

RegisterNUICallback('setStepCount', function(data)

    PRPCore.Functions.Notify('Fitbit: Step counter reset!')
    StatSetFloat(`mp0_dist_walking`, 0.0, true)
    StatSetFloat(`mp0_dist_running`, 0.0, true)
    m_steps = 0
    SetResourceKvpFloat("stappenteller_steps", data.value) -- Ojow zoveel stappen heb je gemaakt.
end)

RegisterNUICallback('toggleCompass', function(data)
    compassToggle = data.value
    TriggerEvent('prp-hud:toggleCompass',data.value)
    TriggerServerEvent('prp-fitbit:server:setValue', 'compass', compassToggle)
    if compassToggle then
        PRPCore.Functions.Notify('Fitbit: Compass has been enabled')
    else
        PRPCore.Functions.Notify('Fitbit: Compass has been disabled')
    end
end)

RegisterNUICallback('toggleHud', function(data)
    hudToggle = data.value
    TriggerEvent('prp-hud:toggleHud',data.value)
    TriggerServerEvent('prp-fitbit:server:setValue', 'hud', hudToggle)
    if hudToggle then
        PRPCore.Functions.Notify('Fitbit: Hud has been enabled')
    else
        PRPCore.Functions.Notify('Fitbit: Hud has been disabled')
    end
end)

RegisterNUICallback('toggleHungerThirst', function(data)
    _hungerThirstToggle = data.value
    TriggerEvent('prp-hud:toggleHungerThirst', _hungerThirstToggle)
    TriggerServerEvent('prp-fitbit:server:setValue', 'hungerThirst', _hungerThirstToggle)
    if _hungerThirstToggle then
        PRPCore.Functions.Notify('Fitbit: Hunger and Thirst HUD has been enabled')
    else
        PRPCore.Functions.Notify('Fitbit: Hunger and Thirst HUD has been disabled')
    end
end)
