local ESX = exports['es_extended']:getSharedObject()
local jailRecords = {}

local function notify(src, msg, kind)
    TriggerClientEvent('smrkec_jailsystem:notify', src, msg, kind or 'inform')
end

local function getIdentifier(xPlayer)
    return xPlayer and (xPlayer.identifier or (xPlayer.getIdentifier and xPlayer.getIdentifier()))
end

local function hasPermission(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not xPlayer.job then return false end
    return Config.AllowedJobs[xPlayer.job.name] == true
end

local function getCharacterName(xPlayer, fallback)
    if not xPlayer then return fallback or 'Unknown' end
    if xPlayer.getName then return xPlayer.getName() end
    local first = xPlayer.get and xPlayer.get('firstName')
    local last = xPlayer.get and xPlayer.get('lastName')
    if first or last then return (tostring(first or '') .. ' ' .. tostring(last or '')):gsub('^%s*(.-)%s*$', '%1') end
    return GetPlayerName(xPlayer.source) or fallback or 'Unknown'
end

CreateThread(function()
    local tableName = Config.DatabaseTable
    MySQL.query(([=[CREATE TABLE IF NOT EXISTS `%s` (
        `identifier` varchar(80) NOT NULL,
        `remaining_seconds` int NOT NULL DEFAULT 0,
        `reason` varchar(255) NOT NULL DEFAULT 'No reason provided',
        `officer` varchar(100) NOT NULL DEFAULT 'Unknown',
        `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`identifier`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]=]):format(tableName))

    local rows = MySQL.query.await(('SELECT identifier, remaining_seconds, reason, officer FROM `%s` WHERE remaining_seconds > 0'):format(tableName)) or {}
    for _, row in ipairs(rows) do
        jailRecords[row.identifier] = {
            remaining = tonumber(row.remaining_seconds) or 0,
            reason = row.reason or 'No reason provided',
            officer = row.officer or 'Unknown',
            lastTick = os.time()
        }
    end
end)

local function saveRecord(identifier, record)
    if not identifier then return end
    if not record or record.remaining <= 0 then
        jailRecords[identifier] = nil
        MySQL.update(('DELETE FROM `%s` WHERE identifier = ?'):format(Config.DatabaseTable), { identifier })
        return
    end
    MySQL.update(('INSERT INTO `%s` (identifier, remaining_seconds, reason, officer) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE remaining_seconds = VALUES(remaining_seconds), reason = VALUES(reason), officer = VALUES(officer)'):format(Config.DatabaseTable), {
        identifier, math.max(0, math.floor(record.remaining)), record.reason, record.officer
    })
end

local function getRemaining(record)
    if not record then return 0 end
    local elapsed = math.max(0, os.time() - (record.lastTick or os.time()))
    return math.max(0, record.remaining - elapsed)
end

local function sendJailState(src, record)
    if not record then
        TriggerClientEvent('smrkec_jailsystem:setJail', src, false)
        return
    end
    record.remaining = getRemaining(record)
    record.lastTick = os.time()
    if record.remaining <= 0 then
        local xPlayer = ESX.GetPlayerFromId(src)
        saveRecord(getIdentifier(xPlayer), nil)
        TriggerClientEvent('smrkec_jailsystem:setJail', src, false)
        return
    end
    TriggerClientEvent('smrkec_jailsystem:setJail', src, {
        remaining = math.floor(record.remaining), reason = record.reason,
        jailSpawn = { x = Config.JailSpawn.x, y = Config.JailSpawn.y, z = Config.JailSpawn.z, w = Config.JailSpawn.w },
        releaseSpawn = { x = Config.ReleaseSpawn.x, y = Config.ReleaseSpawn.y, z = Config.ReleaseSpawn.z, w = Config.ReleaseSpawn.w }
    })
end

RegisterNetEvent('smrkec_jailsystem:requestState', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = getIdentifier(xPlayer)
    if identifier and jailRecords[identifier] then
        sendJailState(src, jailRecords[identifier])
    else
        TriggerClientEvent('smrkec_jailsystem:setJail', src, false)
    end
end)

RegisterNetEvent('smrkec_jailsystem:requestNearby', function()
    local src = source
    if not hasPermission(src) then notify(src, 'Do tega menija nimaš dostopa.', 'error'); return end
    local officerPed = GetPlayerPed(src)
    if officerPed == 0 then return end
    local origin = GetEntityCoords(officerPed)
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        local target = tonumber(id)
        if target then
            local ped = GetPlayerPed(target)
            if ped ~= 0 then
                local coords = GetEntityCoords(ped)
                local distance = #(origin - coords)
                if distance <= Config.NearbyDistance and (Config.AllowSelfJail or target ~= src) then
                    local xTarget = ESX.GetPlayerFromId(target)
                    list[#list + 1] = {
                        id = target,
                        name = getCharacterName(xTarget, GetPlayerName(target)),
                        distance = math.floor(distance * 10) / 10,
                        self = target == src
                    }
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.distance < b.distance end)
    TriggerClientEvent('smrkec_jailsystem:nearbyResult', src, list)
end)

RegisterNetEvent('smrkec_jailsystem:jailPlayer', function(targetId, reason, months)
    local src = source
    if not hasPermission(src) then notify(src, 'Do tega dejanja nimaš dostopa.', 'error'); return end
    targetId = tonumber(targetId)
    months = tonumber(months)
    reason = tostring(reason or ''):gsub('[\r\n]', ' '):sub(1, 255)
    if not targetId or not GetPlayerName(targetId) then notify(src, 'Igralec ni več na voljo.', 'error'); return end
    if targetId == src and not Config.AllowSelfJail then notify(src, 'Sam sebe ne moreš zapreti.', 'error'); return end
    if not months or months < Config.MinMonths or months > Config.MaxMonths or months % 1 ~= 0 then
        notify(src, ('Čas mora biti med %s in %s meseci.'):format(Config.MinMonths, Config.MaxMonths), 'error'); return
    end
    if #reason < 3 then notify(src, 'Vpiši razlog zapora (vsaj 3 znake).', 'error'); return end

    local sourcePed, targetPed = GetPlayerPed(src), GetPlayerPed(targetId)
    if sourcePed == 0 or targetPed == 0 then return end
    local distance = #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed))
    if distance > Config.NearbyDistance + 1.0 then notify(src, 'Igralec je predaleč stran.', 'error'); return end

    local xTarget = ESX.GetPlayerFromId(targetId)
    local xOfficer = ESX.GetPlayerFromId(src)
    local identifier = getIdentifier(xTarget)
    if not identifier then notify(src, 'Ni bilo mogoče prepoznati igralca.', 'error'); return end

    local record = {
        remaining = months * 60,
        reason = reason,
        officer = getCharacterName(xOfficer, GetPlayerName(src)),
        lastTick = os.time()
    }
    jailRecords[identifier] = record
    saveRecord(identifier, record)
    sendJailState(targetId, record)
    notify(src, ('%s je bil zaprt za %s mesecev.'):format(getCharacterName(xTarget, GetPlayerName(targetId)), months), 'success')
    notify(targetId, ('Zaprt si za %s mesecev. Razlog: %s'):format(months, reason), 'inform')
end)

RegisterNetEvent('smrkec_jailsystem:releasePlayer', function(targetId)
    local src = source
    if not hasPermission(src) then notify(src, 'Do tega dejanja nimaš dostopa.', 'error'); return end
    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then notify(src, 'Igralec ni več na voljo.', 'error'); return end
    local xTarget = ESX.GetPlayerFromId(targetId)
    local identifier = getIdentifier(xTarget)
    if identifier then saveRecord(identifier, nil) end
    TriggerClientEvent('smrkec_jailsystem:setJail', targetId, false)
    notify(src, 'Igralec je bil izpuščen iz zapora.', 'success')
    notify(targetId, 'Policija te je izpustila iz zapora.', 'success')
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    local src = tonumber(playerId) or source
    SetTimeout(1500, function()
        local xPlayer = ESX.GetPlayerFromId(src)
        local identifier = getIdentifier(xPlayer)
        if identifier and jailRecords[identifier] then sendJailState(src, jailRecords[identifier]) end
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = getIdentifier(xPlayer)
    if identifier and jailRecords[identifier] then
        local record = jailRecords[identifier]
        record.remaining = getRemaining(record)
        record.lastTick = os.time()
        saveRecord(identifier, record)
    end
end)

-- Keep persisted time reasonably fresh while the player is online.
CreateThread(function()
    while true do
        Wait(15000)
        for _, playerId in ipairs(GetPlayers()) do
            local src = tonumber(playerId)
            local xPlayer = ESX.GetPlayerFromId(src)
            local identifier = getIdentifier(xPlayer)
            local record = identifier and jailRecords[identifier]
            if record then
                record.remaining = getRemaining(record)
                record.lastTick = os.time()
                if record.remaining <= 0 then
                    saveRecord(identifier, nil)
                    TriggerClientEvent('smrkec_jailsystem:setJail', src, false)
                else
                    saveRecord(identifier, record)
                    TriggerClientEvent('smrkec_jailsystem:timeUpdate', src, math.floor(record.remaining))
                end
            end
        end
    end
end)
