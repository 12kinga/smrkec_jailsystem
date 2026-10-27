local ESX = exports['es_extended']:getSharedObject()
local isJailed = false
local jailData = nil
local jailEndAt = 0
local lastTeleport = 0

local function notify(message, kind)
    if lib and lib.notify then
        lib.notify({ title = 'Smrkec Jail', description = message, type = kind or 'inform' })
    else
        ESX.ShowNotification(message)
    end
end

RegisterNetEvent('smrkec_jailsystem:notify', function(message, kind) notify(message, kind) end)

RegisterCommand('jailmenu', function()
    local data = ESX.GetPlayerData()
    local job = data and data.job and data.job.name
    if not job or not Config.AllowedJobs[job] then
        notify('Do jail menija nimaš dostopa.', 'error')
        return
    end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', serverName = Config.ServerName, title = Config.MenuTitle, locale = Config.Locale or 'en' })
    TriggerServerEvent('smrkec_jailsystem:requestNearby')
end, false)

RegisterKeyMapping('jailmenu', 'Odpri Smrkec Jail Menu', 'keyboard', '')

RegisterNetEvent('smrkec_jailsystem:nearbyResult', function(players)
    SendNUIMessage({ action = 'players', players = players or {}, maxMonths = Config.MaxMonths, minMonths = Config.MinMonths })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

RegisterNUICallback('refresh', function(_, cb)
    TriggerServerEvent('smrkec_jailsystem:requestNearby')
    cb({ ok = true })
end)

RegisterNUICallback('jail', function(data, cb)
    TriggerServerEvent('smrkec_jailsystem:jailPlayer', data and data.id, data and data.reason, data and data.months)
    cb({ ok = true })
end)

RegisterNUICallback('release', function(data, cb)
    TriggerServerEvent('smrkec_jailsystem:releasePlayer', data and data.id)
    cb({ ok = true })
end)

RegisterNetEvent('smrkec_jailsystem:setJail', function(data)
    if not data then
        local wasJailed = isJailed
        isJailed, jailData, jailEndAt = false, nil, 0
        SendNUIMessage({ action = 'jailStatus', jailed = false })
        if wasJailed and Config.ReleaseSpawn then
            local p = Config.ReleaseSpawn
            SetEntityCoords(PlayerPedId(), p.x, p.y, p.z, false, false, false, false)
            SetEntityHeading(PlayerPedId(), p.w)
            notify('Tvoja zaporna kazen je zaključena.', 'success')
        end
        return
    end
    isJailed = true
    jailData = data
    jailEndAt = GetGameTimer() + (tonumber(data.remaining) or 0) * 1000
    if Config.TeleportOnJailLoad and data.jailSpawn then
        local p = data.jailSpawn
        SetEntityCoords(PlayerPedId(), p.x, p.y, p.z, false, false, false, false)
        SetEntityHeading(PlayerPedId(), p.w)
    end
    SendNUIMessage({ action = 'jailStatus', jailed = true, reason = data.reason, remaining = data.remaining })
end)

RegisterNetEvent('smrkec_jailsystem:timeUpdate', function(seconds)
    if isJailed then
        jailEndAt = GetGameTimer() + (tonumber(seconds) or 0) * 1000
        SendNUIMessage({ action = 'time', remaining = seconds })
    end
end)

CreateThread(function()
    Wait(2500)
    TriggerServerEvent('smrkec_jailsystem:requestState')
end)

-- Keep jailed players inside the configured prison boundary.
CreateThread(function()
    while true do
        if isJailed and Config.JailZoneCenter and Config.JailZoneRadius then
            Wait(Config.JailZoneCheckInterval or 750)
            if isJailed then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local center = Config.JailZoneCenter
                local distance = #(coords - center)
                if distance > Config.JailZoneRadius then
                    local spawn = Config.JailSpawn
                    SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, false)
                    SetEntityHeading(ped, spawn.w)
                    notify('Ne moreš zapustiti območja zapora.', 'error')
                end
            end
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        if isJailed then
            Wait(1000)
            local remaining = math.max(0, math.ceil((jailEndAt - GetGameTimer()) / 1000))
            SendNUIMessage({ action = 'time', remaining = remaining })
            if remaining <= 0 then
                -- Server remains authoritative; request an update in case of a delayed tick.
                TriggerServerEvent('smrkec_jailsystem:requestState')
                Wait(1500)
            end
            if Config.RestrictControls then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 37, true)
                DisableControlAction(0, 44, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
            end
        else
            Wait(1000)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then SetNuiFocus(false, false) end
end)
