-- Mod: bluespiderMod

-- Aggregate all unique item/entities in the blueprint by item
function aggregate_entities(ents)
    itemList = {}
    for _, ent in pairs(ents) do
        if (itemList[ent.name] == nil) then
            itemList[ent.name] = 1
        else
            itemList[ent.name] = itemList[ent.name] + 1
        end
    end
    return itemList
end

-- Copy the items in the blueprint to the logistic slot.
function set_logistic_request(veh, item, count, slot, numberOfCopies)
    game.print("Item adding " ..  slot)
    itemStack = {} 
    itemStack["name"] = item
    itemStack["count"] = count * numberOfCopies
    veh.set_request_slot(itemStack, slot)
    game.print("Item added")
end

-- Emtpy the logistics grid
function empty_logistic_slots(veh)
    for i = 1, veh.request_slot_count do
        veh.clear_request_slot(i)
    end
end

-- add the blueprint items to the grid, add in case of already existing items.
function add_bp_to_logistics_grid(veh, bp, numberOfCopies)
    items = aggregate_entities(bp.get_blueprint_entities())
    if (items ~= nil) then
        i = 0
        nextSlot = veh.request_slot_count + 1
        lastUsedSlot = veh.request_slot_count
        for k, v in pairs(items) do
            i_found = false
            game.print("Run over the grid for " .. k)
            game.print(veh.request_slot_count)
            for i=1, lastUsedSlot do
               game.print("Start Looping")
               slot_item = veh.get_request_slot(i)
               if slot_item ~= nil then           
                game.print(slot_item.name .. ":" .. k)
                    if (slot_item.name == k) then
                        i_found = true
                        useSlot = i
                        game.print("Break Looping")                       
                        break
                    end
               end
               game.print("End Looping")
            end
            game.print("Decide what to do with the item")
            if i_found then
                game.print("Found")
                v = v + slot_item.count
            else
                game.print("Not Found")
                game.print(veh.request_slot_count)
                game.print(i_favail)
                useSlot = nextSlot
                nextSlot = nextSlot + 1
            end
            set_logistic_request(veh, k, v, useSlot, numberOfCopies)
        end
        game.print("Zouden we hier al gepasseerd zijn")
    end
end

function spider_remote_used(event)
    spider = event.vehicle
    inventory = spider.get_inventory(defines.inventory.spider_trunk)
    -- This returns the first blueprint in the Trunk.
    -- So current prerequisite is that the blueprint needs to be the first blueprint in the inventory.
    bps = inventory.find_item_stack("blueprint")
    if bps ~= nil then
        if bps.is_blueprint then
            -- Process blueprint name. Via naming convention specific actions on inventory and logistics are performed
            -- The BP name should start with _P_
            -- _E_ found in name Empties the logistics slots.
            -- _nXX_ XX should be a digit. Number of times the items contained in the blueprint should be requested. 
            if (string.sub(bps.label,1,3) == "_P_") then
                sCopies = string.match(bps.label,'_n(%d+)_')
                if sCopies == nil then
                    sCopies = 1
                end
                if (string.find(bps.label, '_E_') ~= nil) then
                    empty_logistic_slots(spider)
                end
                add_bp_to_logistics_grid(spider, bps, sCopies)
                bps.label = string.sub(bps.label,2)
            end 
        end
    end
    game.print("Testing")
end

-- Capture the event when the spidertron remote is used
script.on_event(defines.events.on_player_used_spider_remote, spider_remote_used)
