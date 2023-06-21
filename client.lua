local dartSetup = false
local dartRange = 50.0
local inRange = false
local targetVehicle = nil
local lockedVehicle = nil
local dartTimer = 0

local DARTBlip = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerped = GetPlayerPed(PlayerId())

        if IsPedInAnyPoliceVehicle(playerped, false) then
            local emergencyVehicle = GetVehiclePedIsIn(playerped, false)
            local vehicleInFront = GetVehicleInFrontOfEntity(emergencyVehicle)
            
            if vehicleInFront ~= nil then
                targetVehicle = vehicleInFront
                inRange = true
            else
                targetVehicle = nil
                inRange = false
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        
        if dartTimer > 0 then
            dartTimer = dartTimer - 1
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if dartTimer ~= 0 then
            local targetCoords = GetEntityCoords(lockedVehicle)

            if DARTBlip ~= nil then
                RemoveBlip(DARTBlip)
            end
            
            DARTBlip = AddBlipForEntity(lockedVehicle)
            SetBlipSprite(DARTBlip, 794)
            SetBlipDisplay(DARTBlip, 4)
            SetBlipNameToPlayerName(DARTBlip, lockedVehicle)
            
            if dartTimer >= 3 then
                SetBlipColour(DARTBlip, Config.BlipColors.Blue)
            elseif dartTimer == 2 then
                SetBlipColour(DARTBlip, Config.BlipColors.Orange)
            else
                SetBlipColour(DARTBlip, Config.BlipColors.Red)
            end
        elseif DARTBlip ~= nil then
            RemoveBlip(DARTBlip)
            DARTBlip = nil
        end
    end
end)

RegisterCommand('firedart', function()
    if targetVehicle ~= nil then
        if dartTimer == 0 then
            lockedVehicle = targetVehicle
            dartTimer = Config.DartTimer -- Timer in minutes
            TriggerEvent("chat:addMessage", {
                color = { 255, 0, 0 },
                multiline = true,
                args = { "D.A.R.T System", "Dart fired and attached to the target vehicle." }
            })
        else
            TriggerEvent("chat:addMessage", {
                color = { 255, 0, 0 },
                multiline = true,
                args = { "D.A.R.T System", "Dart already fired and attached. Timer: " .. dartTimer .. " minutes." }
            })
        end
    end
end)

RegisterCommand('trackdart', function()
    dartSetup = not dartSetup
    
    if dartSetup then
        TriggerEvent("chat:addMessage", {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "D.A.R.T System", "D.A.R.T system activated. Scanning for vehicles in range." }
        })
    else
        TriggerEvent("chat:addMessage", {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "D.A.R.T System", "D.A.R.T system deactivated." }
        })
    end
end)

RegisterCommand('stopdart', function()
    dartSetup = false
    targetVehicle = nil
    inRange = false
    lockedVehicle = nil
    dartTimer = 0
    if DARTBlip ~= nil then
        RemoveBlip(DARTBlip)
        DARTBlip = nil
    end
    TriggerEvent("chat:addMessage", {
        color = { 255, 0, 0 },
        multiline = true,
        args = { "D.A.R.T System", "D.A.R.T system stopped." }
    })
end)

RegisterCommand('removedart', function()
    if lockedVehicle ~= nil then
        lockedVehicle = nil
        dartTimer = 0
        if DARTBlip ~= nil then
            RemoveBlip(DARTBlip)
            DARTBlip = nil
        end
        TriggerEvent("chat:addMessage", {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "D.A.R.T System", "Dart removed from your vehicle." }
        })
    else
        TriggerEvent("chat:addMessage", {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "D.A.R.T System", "There is no dart attached to your vehicle." }
        })
    end
end)

function GetVehicleInFrontOfEntity(entity)
    local coords = GetOffsetFromEntityInWorldCoords(entity, 0.0, 1.0, 0.3)
    local coords2 = GetOffsetFromEntityInWorldCoords(entity, 0.0, dartRange, 0.0)
    local rayhandle = CastRayPointToPoint(coords, coords2, 10, entity, 0)
    local _, _, _, _, entityHit = GetRaycastResult(rayhandle)
    
    if entityHit > 0 and IsEntityAVehicle(entityHit) then
        return entityHit
    else
        return nil
    end
end
