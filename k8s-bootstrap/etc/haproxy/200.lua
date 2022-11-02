# 200.lua
core.register_service("200-response", "http", function(applet)
    local response = ""
    applet:set_status(200)
    applet:add_header("Content-Length", "0")
    applet:start_response()
    applet:send(response)
end)