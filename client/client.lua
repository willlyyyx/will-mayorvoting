Framework = nil
local machine = nil

CreateThread(function()
    if Config.Framework == "esx" then
        while Framework == nil do
            TriggerEvent(exports["es_extended"]:getSharedObject(), function(obj) Framework = obj end)
            Wait(100)
        end
    elseif Config.Framework == "qbcore" or Config.Framework == "qbx" then
        Framework = exports['qb-core']:GetCoreObject()
    end
end)

CreateThread(function()
    local model = Config.TicketMachine.model
    local coords = Config.TicketMachine.coords
    
    local propHash = GetHashKey(model)
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do Wait(0) end
    
    machine = CreateObject(propHash, coords.x, coords.y, coords.z - 1, false, true, false)
    SetEntityHeading(machine, coords.w)
    FreezeEntityPosition(machine, true)
    SetEntityInvincible(machine, true)
    
    exports.ox_target:addLocalEntity(machine, {
        {
            label = 'Vote for Mayor',
            icon = 'fa-solid fa-vote-yea',
            distance = 2.5,
            onSelect = function()
                local ped = PlayerPedId()
                ClearPedTasks(ped)

                -- play emote when interacting with the target
                RequestAnimDict("amb@prop_human_atm@male@enter")
                while not HasAnimDictLoaded("amb@prop_human_atm@male@enter") do Wait(0) end
                TaskPlayAnim(ped, "amb@prop_human_atm@male@enter", "enter", 8.0, -8.0, 1500, 49, 0, false, false, false)

                -- delay between showing the ui and emote
                Wait(500)

                TriggerServerEvent('mayorvote:checkHasVoted')
            end
        }
    })

    if Config.Blip.enable then 
        local blip = AddBlipForCoord(Config.TicketMachine.coords.x, Config.TicketMachine.coords.y, Config.TicketMachine.coords.z)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipDisplay(blip, Config.Blip.display)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipColour(blip, Config.Blip.colour)
        SetBlipAsShortRange(blip, false)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.label)
        EndTextCommandSetBlipName(blip)
    end
end)

RegisterNetEvent('mayorvote:hasVotedResult', function(hasVoted)
    if hasVoted then
        exports['ox_lib']:notify({
            title = 'Australian Government',
            description = 'Oh no! You have already voted for a Mayor!',
            type = 'error',
        })
    else
        TriggerServerEvent('mayorvote:requestCandidates')
    end
end)

RegisterNetEvent('mayorvote:showNuiVoting', function(candidates)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'show',
        candidates = candidates
    })
end)

RegisterNUICallback('vote', function(data, cb)
    TriggerServerEvent('mayorvote:submitVote', data.name)

    exports.ox_lib:notify({
        title = 'Australian Government',
        description =  'You voted for ' .. data.name .. '!',
        type = 'success'
    })

    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if DoesEntityExist(machine) then
            DeleteEntity(machine)
        end
    end
end)
