---------------
-- Variables --
---------------
PRPCore = nil

-------------------
-- PRP Core Stuff --
-------------------
Citizen.CreateThread(function()
	while PRPCore == nil do
		TriggerEvent('PRPCore:GetObject', function(obj) PRPCore = obj end)
		Citizen.Wait(0)
	end
end)



---------------
-- Main Loop --
---------------

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(300000)
        Citizen.Wait(math.random(1, 31))
        local PlayerData = PRPCore.Functions.GetPlayerData()
        local Citizenid = PlayerData.citizenid
        local MoneyTable = PlayerData.money
        local Total = (MoneyTable.cash + MoneyTable.bank)
        local Name = GetPlayerName(PlayerId())
        local Charinfo = PlayerData.charinfo
        local FirstLast = Charinfo.firstname.." "..Charinfo.lastname
        local JobName = PlayerData.job.name
        local JobLabel = PlayerData.job.grade.label
        local JobOnDuty = PlayerData.job.onduty

        if JobOnDuty == true then
            JobOnDuty = "true"
        else
            JobOnDuty = "false"
        end

        TriggerServerEvent("stats:setmeta")
        TriggerServerEvent("stats:upload", Name, FirstLast, Citizenid, Total, JobName, JobLabel, JobOnDuty)
        Citizen.Wait(5000)

    end
end)

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end