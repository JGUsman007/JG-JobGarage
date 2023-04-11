ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('JG-Sharedgarage:spawnvehicle',function()
    TriggerClientEvent('JG-Sharedgarage:setvehicleout',-1, function()
    end)
end)


RegisterNetEvent('JG-Sharedgarage:despawnvehicle',function()
    TriggerClientEvent('JG-Sharedgarage:setvehiclein',-1, function()
    end)
end)
