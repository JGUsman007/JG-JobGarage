ESX = exports['es_extended']:getSharedObject()



RegisterNetEvent('JG-Sharedgarage:spawnvehicle',function(vehplate)
    TriggerClientEvent('JG-Sharedgarage:setvehicleout',-1,vehplate)
end)


RegisterNetEvent('JG-Sharedgarage:savevehicle',function(String,vehicle)
    TriggerClientEvent('JG-Sharedgarage:savevehicle',-1,String,vehicle)
end)



RegisterNetEvent('update:garage', function (data)
    _Garage = data
end)


lib.callback.register('Get:Garage', function()
    return _Garage
end)
