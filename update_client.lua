local tArgs = {...}
local clientId, localFilePath = table.unpack(tArgs)
clientId = tonumber(clientId)


function get_files(path)
    local files = {}

    print(path)

    for _, file in ipairs(fs.list(path)) do
        if fs.isDir(path.."/"..file) then
            get_files(path.."/"..file)
        else
            files[#files + 1] = path.."/"..file
        end
    end

    return files
end


local files = get_files(localFilePath)

rednet.send(clientId, #files, "ChungIndustries")

-- TODO: Error handling

while true do
    local id, message = rednet.receive("ChungIndustries", 30)

    if tonumber(id) == clientId then
        if message == "done" then
            break
        end

        local fileIndex = tonumber(message)
        local filePath = files[fileIndex]
        local file = fs.open(filePath, "r")
        local fileContent = file.readAll()
        file.close()
        
        rednet.send(clientId, {filePath, fileContent}, "ChungIndustries")
    end 
end
