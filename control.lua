-- Mod: bluespiderMod

-- Copy the items in the blueprint to the logistic slot.
function set_logistic_request(veh, item, count, slot, numberOfCopies)
    itemStack = {} 
    itemStack["name"] = item
    itemStack["count"] = count * numberOfCopies
    veh.set_request_slot(itemStack, slot)
end

-- Emtpy the logistics grid
function empty_logistic_slots(veh)
    for i = 1, veh.request_slot_count do
        veh.clear_request_slot(i)
    end
end

-- add the blueprint items to the grid, add in case of already existing items.
function add_bp_to_logistics_grid(veh, bp, numberOfCopies)
--   0.0.2 -- issues with difference in entity and item name causing dumps. found cost_to_build dictionary
--   items = aggregate_entities(bp.get_blueprint_entities())
    items = bp.cost_to_build
    if (items ~= nil) then
        i = 0
        nextSlot = veh.request_slot_count + 1
        lastUsedSlot = veh.request_slot_count
        for k, v in pairs(items) do
            i_found = false
            for i=1, lastUsedSlot do
               slot_item = veh.get_request_slot(i)
               if slot_item ~= nil then           
                    if (slot_item.name == k) then
                        i_found = true
                        useSlot = i                    
                        break
                    end
               end
            end
            if i_found then
                v = v + slot_item.count
            else
                useSlot = nextSlot
                nextSlot = nextSlot + 1
            end
            set_logistic_request(veh, k, v, useSlot, numberOfCopies)
        end
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
end

-- Capture the event when the spidertron remote is used
script.on_event(defines.events.on_player_used_spider_remote, spider_remote_used)
