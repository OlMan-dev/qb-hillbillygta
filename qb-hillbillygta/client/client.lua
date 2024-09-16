local QBCore = exports['qb-core']:GetCoreObject()
local hillbillyPed = nil
local carToSteal = nil
local carToDeliver = nil
local carLocation = nil
local deliveredVehicles = {}
local towTruck = nil
local towPaperwork = nil

local isHotwiring = false
local carBlip = nil
local playerPed = PlayerPedId()
local deliveryCompleted = false 
local hasActiveJob = false


-- Spawn Billy Joe (Hillbilly NPC)
function SpawnHillbilly()
    local pedModel = Config.HillbillyModel
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end

    hillbillyPed = CreatePed(4, pedModel, Config.HillbillyLocation.x, Config.HillbillyLocation.y, Config.HillbillyLocation.z, Config.HillbillyLocation.w, false, true)
    FreezeEntityPosition(hillbillyPed, true)
    SetEntityInvincible(hillbillyPed, true)
    SetBlockingOfNonTemporaryEvents(hillbillyPed, true)
	
	 TaskStartScenarioInPlace(hillbillyPed, 'WORLD_HUMAN_SMOKING', 0, true)

    exports['qb-target']:AddTargetEntity(hillbillyPed, {
        options = { {
            icon = "fa-solid fa-car",
            label = "Talk to Billy Joe",
            action = function()
                ShowBillyJoeOptions()
            end
        }},
        distance = 2.5
    })
end

-- Show Billy Joe interaction options
function ShowBillyJoeOptions()
    local playerPed = PlayerPedId()
    local playerJob = QBCore.Functions.GetPlayerData().job
    local isOnDuty = playerJob.onduty 

    local menuOptions = {
        {
            header = "Billy Joe",
            isMenuHeader = true
        }
    }

    -- Check if player is a cop and on duty
    if playerJob.name == "police" and isOnDuty then
        table.insert(menuOptions, {
            header = "I don't talk to cops",
            txt = "Billy Joe looks annoyed",
            params = {
                event = "qb-hillbillygta:Nocops"
            }
        })
    else
		
		if hasActiveJob then
            table.insert(menuOptions, {
                header = "You Already Have a Location",
                txt = "Go finish the one I already gave you...",
                params = {
                    event = "", 
                    action = function() 
                        QBCore.Functions.Notify("I already gave you a car location!", 'error', 5000)
                    end
                }
            })
        else
		
			table.insert(menuOptions, {
				header = "Steal a Car",
				txt = "I need free vehicles for parts..",
				params = {
					event = "qb-hillbillygta:startCarStealingJob"
				}
			})
		end
		
        table.insert(menuOptions, {
            header = "Decline and walk away",
            txt = "Not interested",
            params = {
                event = "qb-hillbillygta:declineJob"
            }
        })
    end

    exports['qb-menu']:openMenu(menuOptions)
end

RegisterNetEvent('qb-hillbillygta:startCarStealingJob', function()
    if hasActiveJob then
        QBCore.Functions.Notify("I already gave you a car location!", 'error', 5000)
        return 
    end

    QBCore.Functions.TriggerCallback('qb-hillbillygta:canStartJob', function(canStart)
        if canStart then
            local selectedCarModel = Config.CarModels[math.random(1, #Config.CarModels)]
            carLocation = Config.CarLocations[math.random(1, #Config.CarLocations)]

            RequestModel(selectedCarModel)
            while not HasModelLoaded(selectedCarModel) do
                Wait(10)
            end

            carToSteal = CreateVehicle(selectedCarModel, carLocation.x, carLocation.y, carLocation.z, carLocation.w, true, true)
            local plate = GetVehicleNumberPlateText(carToSteal)

            QBCore.Functions.Notify(string.format(Config.Lang['go_steal_car'], plate, GetStreetNameFromHashKey(GetStreetNameAtCoord(carLocation.x, carLocation.y, carLocation.z))), 'primary', 10000)

            carBlip = AddBlipForCoord(carLocation.x, carLocation.y, carLocation.z)
            SetBlipSprite(carBlip, 225)
            SetBlipColour(carBlip, 1)
            SetBlipScale(carBlip, 1.2)
            SetBlipAsShortRange(carBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Stolen Car")
            EndTextCommandSetBlipName(carBlip)
			
			hasActiveJob = true

            MonitorPlayerInVehicle()
        else
            QBCore.Functions.Notify(Config.Lang['cops'], 'error', 3000)
        end
    end)
end)

-- Event when player declines the job
RegisterNetEvent('qb-hillbillygta:declineJob', function()
    QBCore.Functions.Notify("Okay chicken, maybe some other time.", 'error', 5000)
end)

RegisterNetEvent('qb-hillbillygta:Nocops', function()
    QBCore.Functions.Notify("I said leave me alone!", 'error', 5000)
end)

function MonitorPlayerInVehicle()
    Citizen.CreateThread(function()
        while true do
            Wait(500)
            if IsPedInVehicle(PlayerPedId(), carToSteal, false) and GetPedInVehicleSeat(carToSteal, -1) == PlayerPedId() then
				if not isHotwiring then
					StartHotwire()
				end
                break
            end
        end
    end)
end

-- Hotwire process
function StartHotwire()
    if isHotwiring then return end
    isHotwiring = true

    local hotwireTime = math.random(Config.minHotwireTime, Config.maxHotwireTime)
    local ped = PlayerPedId()
	
	AttemptPoliceAlert('Vehicle theft underway')

    if carBlip then
        RemoveBlip(carBlip)
        carBlip = nil
    end

    if Config.DeliveryLocation then
        SetNewWaypoint(Config.DeliveryLocation.x, Config.DeliveryLocation.y)
        SetupDeliveryCheckpoint(Config.DeliveryLocation)
    else
        QBCore.Functions.Notify("Error: Delivery location not defined!", 'error')
        isHotwiring = false
        return
    end

    QBCore.Functions.Progressbar('hotwire_vehicle', "Starting hotwire process...", hotwireTime, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true
    }, {
        animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        anim = 'machinic_loop_mechandplayer',
        flags = 16
    }, {}, {}, function() 
        StopAnimTask(ped, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 1.0)

        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))

        SetVehicleDoorOpen(carToSteal, 4, false, false)

        TaskLeaveVehicle(ped, carToSteal, 0)
        Citizen.Wait(1000)

        local vehicleCoords = GetEntityCoords(carToSteal)
        local vehicleHeading = GetEntityHeading(carToSteal)
        local frontCoords = GetOffsetFromEntityInWorldCoords(carToSteal, 0.0, 2.0, 0.5)
        TaskGoToCoordAnyMeans(ped, frontCoords.x, frontCoords.y, frontCoords.z, 1.0, 0, 0, 786603, 0xbf800000)
        Citizen.Wait(5000)
        TaskTurnPedToFaceEntity(ped, carToSteal, -1)
        Citizen.Wait(2000)

        RequestAnimDict('mini@repair')
        while not HasAnimDictLoaded('mini@repair') do
            Citizen.Wait(500)
        end
        TaskPlayAnim(ped, 'mini@repair', 'fixing_a_ped', 8.0, -8.0, -1, 1, 0, false, false, false)
        Citizen.Wait(6000)

        StopAnimTask(ped, 'mini@repair', 'fixing_a_ped', 1.0)

        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', GetVehicleNumberPlateText(carToSteal))
        QBCore.Functions.Notify("You successfully hotwired the vehicle!", 'success')

        SetVehicleDoorShut(carToSteal, 4, false)

        TaskEnterVehicle(ped, carToSteal, 20000, -1, 1.0, 1, 0)

        SetupDeliverCarInteraction()
		isHotwiring = false 
    end, function()
        StopAnimTask(ped, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 1.0)
        QBCore.Functions.Notify("Hotwiring cancelled.", 'error')
        isHotwiring = false
    end)
end

-- Delivery Checkpoint
function SetupDeliveryCheckpoint(location)
    if not location or not location.x or not location.y or not location.z then
        QBCore.Functions.Notify("Error: Delivery location is invalid!", 'error')
        return
    end

    local ped = PlayerPedId()
    local deliveryCheckpoint = nil

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500) 

            local playerCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - vector3(location.x, location.y, location.z))

            if distance < 100.0 and not deliveryCheckpoint then
                deliveryCheckpoint = CreateCheckpoint(11, location.x, location.y, location.z, 0, 0, 0, 2.5, 255, 255, 255, 200, 0)
                SetCheckpointIconRgba(deliveryCheckpoint, 255, 255, 255, 255)
                SetCheckpointCylinderHeight(deliveryCheckpoint, 2.5, 2.5, 2.5)
            end

            if deliveryCheckpoint and distance < 5.0 then
                DeleteCheckpoint(deliveryCheckpoint)
                deliveryCheckpoint = nil
                QBCore.Functions.Notify("Vehicle Delivered. Go see Billy Joe for payment", 'success')
                break
            end
        end
    end)
end

function SetupDeliverCarInteraction()
    if carToSteal then
        exports['qb-target']:AddTargetEntity(hillbillyPed, {
            options = { {
                icon = "fa-solid fa-car",
                label = "Deliver the car to Billy Joe",
                action = function()
                    DeliverCarToBillyJoe()
                end
            }},
            distance = 2.5
        })
    end
end

-- Deliver the car to Billy Joe
function DeliverCarToBillyJoe()
    if carToSteal and not deliveryCompleted then
        local vehicleId = GetVehicleNumberPlateText(carToSteal)
        
        if not deliveredVehicles[vehicleId] then
            deliveredVehicles[vehicleId] = true

            TriggerServerEvent('qb-hillbillygta:rewardPlayer', math.random(Config.RewardMin, Config.RewardMax))
            QBCore.Functions.Notify("Car delivered successfully!", 'success')

            deliveryCompleted = true

            RefreshBillyJoeMenu()
            
            deliveryCompleted = false
            hasActiveJob = false

            local billyJimLocation = vector4(1994.72, 3793.79, 31.18, 16.1)
            RequestModel('s_m_y_xmech_01')
            while not HasModelLoaded('s_m_y_xmech_01') do
                Citizen.Wait(200)
            end

            local hillbillyPed2 = CreatePed(4, 's_m_y_xmech_01', billyJimLocation, billyJimLocation.w, false, true)
            SetPedAsNoLongerNeeded(hillbillyPed2)
            
            local frontCoords = GetOffsetFromEntityInWorldCoords(carToSteal, 0.0, 2.0, 0.5) 
            TaskGoToCoordAnyMeans(hillbillyPed2, frontCoords.x, frontCoords.y, frontCoords.z, 1.0, 0, 0, 786603, 0xbf800000)
            Citizen.Wait(10000)
            TaskTurnPedToFaceEntity(hillbillyPed2, carToSteal, -1)
            Citizen.Wait(2000)

            StartDismantling(carToSteal, hillbillyPed2, billyJimLocation)
        else
            QBCore.Functions.Notify("This vehicle has already been delivered.", 'error')
        end
    else
        QBCore.Functions.Notify("You haven't stolen a car yet or the car has already been delivered.", 'error')
    end
end

function StartDismantling(vehicle, ped, returnLocation)
    loadAnimDict("mini@repair")

    TaskPlayAnim(ped, "mini@repair", "fixing_a_ped", 3.0, -1.0, -1, 1, 0, false, false, false)

	local function smashWindow(windowIndex)
    SmashVehicleWindow(vehicle, windowIndex)
    Citizen.Wait(3000) -- Wait 1 second before smashing the next window
	end
	
    local function removeDoor(doorIndex)
        SetVehicleDoorBroken(vehicle, doorIndex, true)
        Citizen.Wait(3000) -- Wait 3 seconds before removing the next part
    end
	
    local function removeTire(wheelIndex)
        SetVehicleTyreBurst(vehicle, wheelIndex, true, 1000.0)
        Citizen.Wait(3000) -- Wait 3 seconds before removing the next tire
    end

    -- Remove all doors
    for i = 0, 3 do
        removeDoor(i)
    end

    -- Remove both hoods
    SetVehicleDoorBroken(vehicle, 4, true) -- Hood
    Citizen.Wait(3000) -- Wait 3 seconds
    SetVehicleDoorBroken(vehicle, 5, true) -- Trunk
    Citizen.Wait(3000) -- Wait 3 seconds

    -- Remove all tires
    for i = 0, 5 do
        removeTire(i)
    end

	-- Smash all windows
	for i = 0, 5 do
    smashWindow(i)
	end

    Citizen.Wait(3000) 

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)

    StopAnimTask(ped, "mini@repair", "fixing_a_ped", 1.0)
    TaskGoToCoordAnyMeans(ped, returnLocation.x, returnLocation.y, returnLocation.z, 1.0, 0, 0, 786603, 0xbf800000)
    Citizen.Wait(8000) -- Wait for ped to reach location

    DeletePed(ped)
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function RefreshBillyJoeMenu()
    exports['qb-target']:RemoveTargetEntity(hillbillyPed)
    exports['qb-target']:AddTargetEntity(hillbillyPed, {
        options = { {
            icon = "fa-solid fa-car",
            label = "Talk to Billy Joe",
            action = function()
                ShowBillyJoeOptions()
            end
        }},
        distance = 2.5
    })
end

function AttemptPoliceAlert(message)
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData.job.name == "police" and playerData.job.onduty then
        TriggerServerEvent('police:server:policeAlert', {
            title = "Vehicle Theft in Progress",
            message = message,
            location = GetEntityCoords(PlayerPedId())
        })
    else
    end
end

Citizen.CreateThread(function()
    SpawnHillbilly()
end)