local DrinkPrompt
local CollectPrompt
local active = false
local drink = false
local amount = 0
local cooldown = 0
local oldWaterpump = {}
local checkwaterpump = 0
local waterpump

local Watergroup = GetRandomIntInRange(0, 0xffffff)
print('Watergroup: ' .. Watergroup)

function Drinkwater()
    Citizen.CreateThread(function()
        local str = 'Drink'
        local wait = 0
        DrinkPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(DrinkPrompt, 0xC7B5340A)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(DrinkPrompt, true)
        PromptSetEnabled(DrinkPrompt, true)
        PromptSetHoldMode(DrinkPrompt, true)
        PromptSetGroup(DrinkPrompt, Watergroup)
        PromptRegisterEnd(DrinkPrompt)
    end)
end

function CollectWater()
    Citizen.CreateThread(function()
        local str = 'Collect'
        local wait = 0
        CollectPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(CollectPrompt, 0xD9D0E1C0)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(DrinkPrompt, str)
        PromptSetEnabled(CollectPrompt, true)
        PromptSetVisible(CollectPrompt, true)
        PromptSetHoldMode(CollectPrompt, true)
        PromptSetGroup(CollectPrompt, Watergroup)
        PromptRegisterEnd(CollectPrompt)
    end)
end

Citizen.CreateThread(function()
    Wait(2000)
    Drinkwater()
    CollectWater()
    while true do
        Wait(1)
        local playerped = PlayerPedId()
        if checkwaterpump < GetGameTimer() and not IsPedOnMount(playerped) and not IsPedInAnyVehicle(playerped) and not eat and cooldown < 1 then
            waterpump = GetClosestWaterpump()
            checkwaterpump = GetGameTimer() + 500
        end
        if waterpump then
            if active == false then
                local WaterGroupName = CreateVarString(10, 'LITERAL_STRING', 'Water')
                PromptSetActiveGroupThisFrame(Watergroup, WaterGroupName)
            end
            if PromptHasHoldModeCompleted(CollectPrompt) then
                active = true
                oldWaterpump[tostring(waterpump)] = true
                goCollect()
            end
            if PromptHasHoldModeCompleted(DrinkPrompt) then
                active = true
                oldWaterpump[tostring(waterpump)] = true
                goDrink()
                amount = amount +1
                if amount == 4 then
                    TriggerEvent("redem_roleplay:Tip", "Do not drink too much from unboiled water , you know what happend in Armadillo." 4000)
                end
                if amount > 4 then
                    Wait(2300)
                    startPoisone()
                end
            end
        else

        end
    end    
end)

function goDrink()
    local playerped = PlayerPedId()
    RequestAnimDict("amb_work@prop_human_pump_water@female_b@idle_a")
    while not HasAnimDictLoaded("amb_work@prop_human_pump_water@female_b@idle_a") do
        Wait(100)
    end
    TaskPlayAnim(playerped, "amb_work@prop_human_pump_water@female_b@idle_a", "enter_lf", 8.0, -0.5, -1, 0, 0, true, 0, false, 0, false)
    Wait(800)
    TaskPlayAnim(playerPed, "amb_work@prop_human_pump_water@female_b@idle_a", "base", 8.0, -0.5, -1, 0, 0, true, 0, false, 0, false)
    Wait(2300)
    TaskPlayAnim(playerPed, "amb_work@prop_human_pump_water@female_b@idle_a", "exit_eat", 8.0, -0.5, -1, 0, 0, true, 0, false, 0, false)
    Wait(2500)
    TriggerServerEvent('redemrp_water:addWater')
    drink = false
    active = false
    ClearPedTasks(playerped)
end

function goCollect()
    local playerPed = PlayerPedId()
    RequestAnimDict("amb_work@prop_human_pump_water@female_b@idle_a")
    while not HasAnimDictLoaded("amb_work@prop_human_pump_water@female_b@idle_a") do
        Wait(100)
    end
    TaskPlayAnim(playerPed, "amb_work@prop_human_pump_water@female_b@idle_a", "enter_lf", 8.0, -0.5, -1, 0, 0, true, 0, false, 0, false)
    Wait(800)
    TaskPlayAnim(playerPed, "amb_work@prop_human_pump_water@female_b@idle_a", "base", 8.0, -0.5, -1, 0, 0, true, 0, false, 0, false)
    Wait(2300)
    TriggerServerEvent('redemrp_water:Drinkwater')
    active = false
    ClearPedTasks(playerPed)
end

RegisterNetEvent('redemrp_water:addWater')
AddEventHandler('redemrp_water:addWater', function()
    local playerPed = PlayerPedId()
    RequestAnimDict("amb_work@prop_human_pump_water@female_b@idle_a")
    while not HasAnimDictLoaded("amb_work@prop_human_pump_water@female_b@idle_a") do
        Wait(100)
    end
    TaskPlayAnim(playerPed, "amb_work@prop_human_pump_water@female_b@idle_a", "exit_eat", 8.0, -0.5, -1, 0, 0, true, 0, false, 0, false)
    Wait(2500)
    TriggerServerEvent('redemrp_water:addWater')
    amount = amount + 1
    if amount == 4  then
        TriggerEvent("redem_roleplay:Tip", "Do not drink too much from unboiled water , you know what happend in Armadillo.", 4000)
    end
    if amount > 4 then
        Wait(2300)
        startPoisone()
    end
    ClearPedTasks(playerPed)
end)

Citizen.CreateThread(function()
    while true do
        Wait(60000)
        if amount > 0 then
            amount = amount - 1
        end
    end
end)

function startPoisone()
    local dict = "amb_misc@world_human_vomit_kneel@male_a@idle_c"
    local anim = "idle_g"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
    local test = 10
    Citizen.CreateThread(function()
        while test > 0 do
            if not IsEntityPlayingAnim( PlayerPedId() ,dict, anim, 31) then
                TaskPlayAnim( PlayerPedId(), dict, anim, 8.0, -8.0, -1, 31, 0, true, 0, false, 0, false)
            end
            Wait(2000)
            local hp = GetEntityHealth(PlayerPedId())
            SetEntityHealth(PlayerPedId(),hp-5)
            test = test -1
        end
        ClearPedTasksImmediately(PlayerPedId())
    end)
end

function GetClosestWaterpump()
    local playerped = PlayerPedId()
    local itemSet = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, GetEntityCoords(playerped), 2.0, itemSet, 3, Citizen.ResultAsInteger())
    if size > 0 then
        for index = 0, size - 1 do
            local entity = GetIndexedItemInItemset(index, itemSet)
            local model_hash = GetEntityModel(entity)
            if (model_hash ==  -40350080) and not oldWaterpump[tostring(entity)] then
              if IsItemsetValid(itemSet) then
                  DestroyItemset(itemSet)
              end
              return entity
            end
        end
    else
    end

    if IsItemsetValid(itemSet) then
        DestroyItemset(itemSet)
    end
end