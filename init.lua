-- monitoring_player_information
-- Sends player information to monitoring
-- SPDX-LICENSE-IDENTIFIER: MIT

core.log("action", "[monitoring_player_information] Enabling player information logging")

local monitoring_counters = {
    ["protocol_version"] = { all = {}, new = {} },
    ["formspec_version"] = { all = {}, new = {} },
}

local function increment_counter(field, value, new)
    local counters = monitoring_counters[field][value]
    if not counters then
        counters = {
            all = monitoring.counter(
                "player_information_" .. field,
                "Number of player joins by " .. field,
                { labels = { [field] = value } }
            ),
            new = monitoring.counter(
                "player_information_" .. field .. "_new",
                "Number of new player joins by " .. field,
                { labels = { [field] = value } }
            ),
        }
        monitoring_counters[field][value] = counters
    end

    counters.all:inc()
    if new then
        counters.new:inc()
    end
end

core.register_on_joinplayer(function(player, last_login)
    local info = core.get_player_information(player:get_player_name())

    for field in pairs(monitoring_counters) do
        local value = info[field] or 0
        increment_counter(field, value, not last_login)
    end
end)
