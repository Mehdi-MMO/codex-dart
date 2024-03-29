local dartSetup = false
local dartRange = 100.0
local inRange = false
local targetVehicle = nil
local lockedVehicle = nil
local dartTimer = 0

local DARTBlip = nil

local keybindEnabled = true

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

if Config.UseCommand then
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
                
                -- Play front-end sound when dart is fired
                PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
            else
                TriggerEvent("chat:addMessage", {
                    color = { 255, 0, 0 },
                    multiline = true,
                    args = { "D.A.R.T System", "Dart already fired and attached. Timer: " .. dartTimer .. " minutes." }
                })
            end
        end
    end)
else
    RegisterKeyMapping('firedart', 'Fire D.A.R.T', 'keyboard', 'G')

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            if keybindEnabled then
                if IsDisabledControlJustReleased(0, 47) then
                    if targetVehicle ~= nil then
                        if dartTimer == 0 then
                            lockedVehicle = targetVehicle
                            dartTimer = Config.DartTimer -- Timer in minutes
                            TriggerEvent("chat:addMessage", {
                                color = { 255, 0, 0 },
                                multiline = true,
                                args = { "D.A.R.T System", "Dart fired and attached to the target vehicle." }
                            })
                            
                            -- Play front-end sound when dart is fired
                            PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
                        else
                            TriggerEvent("chat:addMessage", {
                                color = { 255, 0, 0 },
                                multiline = true,
                                args = { "D.A.R.T System", "Dart already fired and attached. Timer: " .. dartTimer .. " minutes." }
                            })
                        end
                    end
                end
            end
        end
    end)
end

RegisterCommand('trackdart', function()
    dartSetup = not dartSetup
    
    if dartSetup then
        keybindEnabled = false
        TriggerEvent("chat:addMessage", {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "D.A.R.T System", "D.A.R.T system activated. Scanning for vehicles in range." }
        })
    else
        keybindEnabled = true
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
    keybindEnabled = true
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
    local coords = GetEntityCoords(entity)
    local forwardVector = GetEntityForwardVector(entity)
    local rayStart = coords + forwardVector * 1.0
    local rayEnd = coords + forwardVector * dartRange

    local rayhandle = CastRayPointToPoint(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, 10, entity, 0)
    local _, _, _, _, entityHit = GetRaycastResult(rayhandle)

    if entityHit > 0 and IsEntityAVehicle(entityHit) then
        return entityHit
    else
        return nil
    end
end
