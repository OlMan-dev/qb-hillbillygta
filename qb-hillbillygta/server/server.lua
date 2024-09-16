local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('qb-hillbillygta:canStartJob', function(source, cb)
    local policeOnline = 0 --Set minimum police requirements
    for _, player in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(player)
        if Player and Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty then
            policeOnline = policeOnline + 1
        end
    end

    if policeOnline >= Config.MinPolice then -- Ensure you set your config to what you
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('qb-hillbillygta:rewardPlayer')
AddEventHandler('qb-hillbillygta:rewardPlayer', function(reward)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddMoney('cash', reward)
        TriggerClientEvent('QBCore:Notify', src, string.format(Config.Lang['reward_message'], reward), 'success', 5000)
    end
end)

