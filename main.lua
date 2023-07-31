-- TODO: Make more robust

while true do
    print("Waiting for requests...")
    local clientId, message = rednet.receive("ChungIndustries")

    if message:find("^download") then
        local path = "/cloud/"..message:match(":(.*)")
        print("Request received for: "..path)
        shell.run("bg update_client "..clientId.." "..path)
    end
end