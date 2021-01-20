data = {}
TriggerEvent("redemrp_inventory:getData",function(call)
    data = call
end)

RegisterServerEvent('redemrp_water:addWater')
AddEventHandler('redemrp_water:addWater', function() 
	local _source = source
	local ItemData = data.getItem(_source, 'water')
    math.randomseed(GetGameTimer())
	local amount = math.random(1,2)
	ItemData.AddItem(amount)
	ItemData2.AddItem(1)
end)

RegisterServerEvent("RegisterUsableItem:water")
AddEventHandler("RegisterUsableItem:water", function(source)
    local _source = source
	local ItemData = data.getItem(_source, 'water')
	ItemData.RemoveItem(1)
    TriggerClientEvent('redemrp_water:Drinkwater', _source)
end)
