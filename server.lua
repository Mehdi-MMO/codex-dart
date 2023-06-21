RegisterCommand('removedart', function(source, args)
    local playerId = source
    local playerPed = GetPlayerPed(playerId)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle ~= nil then
        local vehicleCoords = GetEntityCoords(vehicle)
        local nearestVehicle = GetClosestVehicle(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, 3.0, 0, 70)
        
        if nearestVehicle == vehicle then
            if lockedVehicle == vehicle then
                lockedVehicle = nil
                dartTimer = 0
                if DARTBlip ~= nil then
                    RemoveBlip(DARTBlip)
                    DARTBlip = nil
                end
                TriggerClientEvent('chat:addMessage', playerId, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {'D.A.R.T System', 'Dart removed from your vehicle.'}
                })
            else
                TriggerClientEvent('chat:addMessage', playerId, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {'D.A.R.T System', 'There is no dart attached to your vehicle.'}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', playerId, {
                color = {255, 0, 0},
                multiline = true,
                args = {'D.A.R.T System', 'You must be near your vehicle to remove the dart.'}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', playerId, {
            color = {255, 0, 0},
            multiline = true,
            args = {'D.A.R.T System', 'You must be in a vehicle to remove the dart.'}
        })
    end
end)

function BroadcastDartBlipToOfficers()
    -- TODO: Implement the code to broadcast the blip to other on-duty law enforcement officers
end
