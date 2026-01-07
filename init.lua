-- monitoring_player_information
-- Sends player information to monitoring
-- SPDX-LICENSE-IDENTIFIER: MIT

core.log("action", "[monitoring_player_information] Enabling player information logging")

local monitoring_counters = {}

for field, description in ipairs({
    ["protocol_version"] = "protocol version",
    ["formspec_version"] = "formspec version",
}) do
    monitoring_counters[field] = {
        all = monitoring.counter(
            "player_information_" .. field,
            "Number of player joins by " .. description,
            { labels = { field } }
        ),
        new = monitoring.counter(
            "player_information_" .. field .. "_new",
            "Number of new player joins by " .. description,
            { labels = { field } }
        ),
    }
end

core.register_on_joinplayer(function(player, last_login)
    local info = core.get_player_information(player:get_player_name())

    for field, counters in pairs(monitoring_counters) do
        local value = info[field] or 0

        counters.all:inc(1, { [field] = value })

        if not last_login then
            counters.new:inc(1, { [field] = value })
        end
    end
end)
