local oxmysql = exports.oxmysql
local candidates = {}

-- Load and save candidates
local function loadCandidates()
    local file = LoadResourceFile(GetCurrentResourceName(), "candidates.json")
    candidates = file and json.decode(file) or {}
end

local function getAustraliaDateTime()
    return os.date("!%d/%m/%Y at %I:%M %p", os.time() + (10 * 3600)) -- UTC+10
end
local function logVoteWebhook(source, charName, candidateName, count)
    if not Config.WebhookURL or Config.WebhookURL == "" then
        print("^1[Webhook]^7 Webhook URL is not set in config.")
        return
    end

    -- Get license and discord identifiers
    local license = "Not found"
    local discordId = "Not found"
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, 8) == "license:" then
            license = id
        elseif string.sub(id, 1, 8) == "discord:" then
            discordId = "<@" .. string.sub(id, 9) .. ">" 
        end
    end

    local embed = {{
        title = "🚨 Optic Networks | Election Vote 🚨",
        color = 1142005,
        fields = {
            { name = "Character Name", value = charName, inline = true },
            { name = "Voted For", value = candidateName, inline = true },
            { name = "Total Votes", value = tostring(count) + 1, inline = true },
            { name = "License", value = license, inline = false },
            { name = "Discord ID", value = discordId, inline = false },
        },
        footer = {
            text = "Optic Networks | Election Log • " .. getAustraliaDateTime()
        }        
    }}

    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
        if err ~= 204 and err ~= 200 then
            print("^1[Webhook Error]^7 HTTP Code:", err, "| Response:", text)
        else
            print("^2[Webhook]^7 Vote logged to Discord.")
        end
    end, 'POST', json.encode({
        username = "Mayor Voting Bot",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Ensure SQL table exists
CreateThread(function()
    loadCandidates()
    MySQL.query([[CREATE TABLE IF NOT EXISTS mayor_votes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        license VARCHAR(64) NOT NULL UNIQUE,
        player_name VARCHAR(100),
        candidate_name VARCHAR(100),
        vote_time DATETIME DEFAULT CURRENT_TIMESTAMP
    )]])
end)

-- Framework init
Framework = nil
CreateThread(function()
    if Config.Framework == "esx" then
        while Framework == nil do
            TriggerEvent(exports["es_extended"]:getSharedObject(), function(obj) Framework = obj end)
            Wait(100)
        end
    elseif Config.Framework == "qbx" then
        Framework = exports['qb-core']:GetSharedObject()
    end
end)

-- Check if player has voted
RegisterNetEvent('mayorvote:checkHasVoted', function()
    local src = source
    local ids = GetPlayerIdentifiers(src)
    local license = ids[1]
    local result = MySQL.scalar.await('SELECT 1 FROM mayor_votes WHERE license = ?', { license })
    TriggerClientEvent('mayorvote:hasVotedResult', src, result ~= nil)
end)

RegisterNetEvent('mayorvote:requestCandidates', function()
    TriggerClientEvent('mayorvote:showNuiVoting', source, candidates)
end)

-- Submit vote
RegisterNetEvent('mayorvote:submitVote', function(candidateName)
    local src = source
    local ids = GetPlayerIdentifiers(src)
    local license = ids[1]
    local name = GetPlayerName(src)

    local alreadyVoted = MySQL.scalar.await('SELECT 1 FROM mayor_votes WHERE license = ?', { license })
    if alreadyVoted then return end

    MySQL.insert('INSERT INTO mayor_votes (license, player_name, candidate_name) VALUES (?, ?, ?)', {
        license, name, candidateName
    })

    local count = MySQL.scalar.await('SELECT COUNT(*) FROM mayor_votes WHERE candidate_name = ?', { candidateName })
    logVoteWebhook(src, name, candidateName, count)
end)


-- Return candidate names with votes
RegisterNetEvent('mayorvote:getVotedCandidates', function()
    local result = MySQL.query.await('SELECT DISTINCT candidate_name FROM mayor_votes')
    local names = {}
    for _, row in pairs(result) do table.insert(names, row.candidate_name) end
    TriggerClientEvent('mayorvote:showResetMenu', source, names)
end)


