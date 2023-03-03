ESX = exports['es_extended']:getSharedObject()
local hasenteredmarker = false


CreateThread(function()
    while true do 
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local xPlayer = ESX.GetPlayerData()
        local isinmarker = false
        local currentaction
        for k,v in pairs(Config.Garage) do
            local distance =  #(playerCoords - v.pos)
            if xPlayer.job.name == v.jobname then
                if distance < Config.garageradius then
                    sleep = 0
                    isinmarker = true
                    if IsPedSittingInAnyVehicle(PlayerPedId()) then
                        currentaction = '[E] to save vehicle'
                        if IsControlJustReleased(0, 38) then 
                            lib.hideTextUI()
                            savevehicle(v)
                        end
                    else
                        currentaction = '[E] to access garage'
                        if  IsControlJustReleased(0, 38) then 
                        openmenu(v)
                        lib.hideTextUI()    
                    end
                    end
                end
            end
        end
        if isinmarker and not hasenteredmarker then
            hasenteredmarker = true
            lib.showTextUI(currentaction)
        end

        if not isinmarker and hasenteredmarker then
            hasenteredmarker = false
            lib.hideTextUI()
        end
        
Wait(sleep)
    end
end)


function savevehicle(v)
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local vehicleplate = GetVehicleNumberPlateText(vehicle)
    local String = vehicleplate:gsub("[ \t]", "")

    for i = 1, #v.vehicles do
        if v.vehicles[i].numberplate == String then
            print('hello')
            local vehdata = v.vehicles[i]
            vehdata.notingarage = false
            ESX.Game.DeleteVehicle(vehicle)
        end
    end
end



function openmenu(v)
local data = v

local options = {}
    for k,v in pairs(v.vehicles) do
        
        table.insert(options,{
            title = v.name,
            description = 'Numberplate :'..v.numberplate,
            onSelect = function()
                spawnvehicle(data,v)
            end,
            disabled = v.notingarage      
        })

    end


    lib.registerContext({
        id = 'sharedgarage',
        title = 'Garage',
        options = options,
        onExit = function()
            lib.showTextUI('[E] to access garage')
        end
    })

    lib.showContext('sharedgarage')

end




function spawnvehicle(data,v)
    local xPlayer = ESX.GetPlayerData()
    RegisterNetEvent('JG-Sharedgarage:setvehicleout', function()
        v.notingarage = true
    end)
    if xPlayer.job.grade >= v.grade then
        local vehicle = v
        local coords = data
        print(v)
        TriggerServerEvent('JG-Sharedgarage:spawnvehicle', function(vehicle)
            vehicle = v
        end)
        
        ESX.Game.SpawnVehicle(vehicle.model,coords.spawnpos,coords.spawnheading,function(vehdata)
        SetVehicleNumberPlateText(vehdata,vehicle.numberplate)
        exports['LegacyFuel']:SetFuel(vehdata, 100.0)
        SetVehicleDirtLevel(vehdata,0.0)
        SetVehicleLivery(vehdata, v.livery)
        SetVehicleMod(vehdata,18,1,true)
        local plate = GetVehicleNumberPlateText(vehdata)
        exports['t1ger_keys']:GiveTemporaryKeys(plate, v.model, 'Job')
        end)
    else
        ESX.ShowNotification('You are not Authorized for this vehicle', 2000, error)
end
end