ESX = exports['es_extended']:getSharedObject()
local hasenteredmarker = false


Mainthread = function()
    for k, v in pairs(Config.Garage) do
        local point = lib.points.new({
            coords = v.pos,
            distance = Config.garageradius,
        })

        function point:onEnter()
            if ESX.PlayerData.job.name == v.jobname then
                _registerradial(true, v)
                lib.showTextUI('Garage', {
                    icon = 'fa-solid fa-car'
                })
            end
        end

        function point:onExit()
            _registerradial(false, v)
            lib.hideTextUI()
        end
    end
end

--[[Mainthread = function()
    while true do
        local sleep = 1500
        local playerCoords = GetEntityCoords(cache.ped)
        local isinmarker = false
        for k, v in pairs(Config.Garage) do
            if ESX.PlayerData.job.name == v.jobname then
                local distance = #(playerCoords - v.pos)
                if distance < 8 then
                    isinmarker = true
                end
                if isinmarker and not hasenteredmarker then
                    hasenteredmarker = true
                    _registerradial(true, v)
                    lib.showTextUI('Garage', {
                        icon = 'fa-solid fa-car'
                    })
                end

                if not isinmarker and hasenteredmarker then
                    hasenteredmarker = false
                    _registerradial(false, v)
                    lib.hideTextUI()
                end
            end
        end
        Wait(sleep)
    end
end--]]

function _registerradial(state, v)
    if state then
        lib.registerRadial({
            id = '_job_garage',
            items = {
                {
                    label = 'Deposit',
                    icon = 'share',
                    onSelect = function()
                        savevehicle()
                    end
                },
                {
                    label = 'Take Out vehicle',
                    icon = 'car',
                    onSelect = function()
                        openmenu(v)
                    end
                },

            }
        })
        lib.addRadialItem({
            {
                id = 'job_garage',
                label = 'Garage',
                icon = 'warehouse',
                menu = '_job_garage'
            },
        })
    else
        lib.removeRadialItem('job_garage')
    end
end

function savevehicle()
    local vehicle = cache.vehicle
    if vehicle then
        local vehicleplate = GetVehicleNumberPlateText(vehicle)
        local String = vehicleplate:gsub("[ \t]", "")
        TriggerServerEvent('JG-Sharedgarage:savevehicle', String, vehicle)
    else
        lib.Notify('You must be inside a vehicle', {
            icon = 'fa-solid fa-car'
        })
    end
end

RegisterNetEvent('JG-Sharedgarage:savevehicle', function(String, vehicle)
    for k, v in pairs(Config.Garage) do
        for k, v in pairs(v.vehicles) do
            if v.numberplate == String then
                v.notingarage = false
                ESX.Game.DeleteVehicle(vehicle)
            end
        end
    end
end)


function openmenu(v)
    local data = v
    local xPlayer = ESX.GetPlayerData()
    local options = {}
    local vehtype
    for k, v in pairs(v.vehicles) do
        if xPlayer.job.grade >= v.grade then
            if v.type == vehtype then

            else
                vehtype = v.type
                table.insert(options, {
                    title = v.type,
                    icon = 'fa-solid fa-car',
                    arrow = true,
                    onSelect = function()
                        lib.hideContext()
                        Wait(200)
                        openvehiclemenu(v.type, data)
                    end
                })
            end
        end
    end


    lib.registerContext({
        id = 'sharedgarage',
        title = 'Garage',
        options = options
    })
    lib.showContext('sharedgarage')
end

function openvehiclemenu(type, data)
    local _options = {}

    for k, v in pairs(data.vehicles) do
        if v.type == type then
            table.insert(_options, {
                title = v.name,
                description = 'Numberplate :' .. v.numberplate,
                icon = 'fa-solid fa-car',
                onBack = function()
                    openmenu(data)
                end,
                onSelect = function()
                    spawnvehicle(data, v)
                end,
                disabled = v.notingarage
            })

            lib.registerContext({
                id = type,
                title = 'Garage',
                menu = 'sharedgarage',
                options = _options
            })
        end
    end

    lib.showContext(type)
end

--[[function openmenu(v)
    local data = v
    local xPlayer = ESX.GetPlayerData()
    local options = {}
    for k, v in pairs(v.vehicles) do
        if xPlayer.job.grade >= v.grade then
        table.insert(options, {
            title = v.name,
            description = 'Numberplate :' .. v.numberplate,
            icon = 'fa-solid fa-car',
            onSelect = function()
                spawnvehicle(data, v)
            end,
            disabled = v.notingarage
        })
    end
end


    lib.registerContext({
        id = 'sharedgarage',
        title = 'Garage',
        options = options
    })

    lib.showContext('sharedgarage')
end--]]



RegisterNetEvent('JG-Sharedgarage:setvehicleout', function(vehplate)
    for k, v in pairs(Config.Garage) do
        for k, v in pairs(v.vehicles) do
            if v.numberplate == vehplate then
                v.notingarage = true
                local _data = Config.Garage
                TriggerServerEvent('update:garage', _data)
            end
        end
    end
end)


function spawnvehicle(data, v)
    local xPlayer = ESX.GetPlayerData()
    if xPlayer.job.grade >= v.grade then
        local vehicle = v
        local coords = data
        local vehplate = vehicle.numberplate
        TriggerServerEvent('JG-Sharedgarage:spawnvehicle', vehplate)

        if not IsModelInCdimage(vehicle.model) then return end
        RequestModel(vehicle.model)                -- Request the model
        while not HasModelLoaded(vehicle.model) do -- Waits for the model to load
            Wait(0)
        end


        local vehdata = CreateVehicle(vehicle.model, coords.spawnpos, coords.spawnheading, true, false)
        SetVehicleNumberPlateText(vehdata, vehicle.numberplate)
        if v.extra then
            for _, data in pairs(v.extra) do
                SetVehicleExtra(vehdata, _, not (data))
            end
        end
        SetVehicleModKit(vehdata)
        SetVehicleMod(vehdata, 48, v.livery)

        if v._black_white then
            SetVehicleCustomPrimaryColour(vehdata, 255, 255, 255)
            SetVehicleCustomSecondaryColour(vehdata, 0, 0, 0)
        end
        -- exports['LegacyFuel']:SetFuel(vehdata, 100.0)
        SetVehicleDirtLevel(vehdata, 0.0)
        SetVehicleMod(vehdata, 18, 1, true)
        local plate = GetVehicleNumberPlateText(vehdata)
        local _data = Config.Garage
        TriggerServerEvent('update:garage', _data)
    else
        ESX.ShowNotification('You are not Authorized for this vehicle', 2000, error)
    end
end

AddEventHandler('esx:playerLoaded', function(playerData)
    local _garage = lib.callback.await('Get:Garage', false)
    if _garage == nil then
        Mainthread()
        return
    end
    Config.Garage = nil
    Config.Garage = _garage
    Mainthread()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)
