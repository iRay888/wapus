local searchString = "You have been votekicked"
local waitTime = 3

local teleportService = game:GetService("TeleportService")
local httpService = game:GetService("HttpService")
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local robloxPromptGui = coreGui:WaitForChild("RobloxPromptGui")
local promptOverlay = robloxPromptGui:WaitForChild("promptOverlay")
local hopping = false

while not players.LocalPlayer do
    task.wait()
end

local checkIndex = game.JobId .. " votekicker"

if getgenv()[checkIndex] then
    return
end

getgenv()[checkIndex] = true

local folderName = "votekicked servers"
local fileName = folderName .. "/" .. tostring(players.LocalPlayer.UserId) .. tostring(game.PlaceId) .. ".txt"
local function addToList()
    local votekickedServers = {game.JobId}

    if not isfolder(folderName) then
        makefolder(folderName)
    end

    if isfile(fileName) then
        votekickedServers = httpService:JSONDecode(readfile(fileName))
        table.insert(votekickedServers, game.JobId)
    end

    writefile(fileName, httpService:JSONEncode(votekickedServers))
    return votekickedServers
end

local playerLimit = 28
local serverList = {}
local function startSearching(ignoreList)
    local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
    local cursor = nil

    while not hopping do
        local currentUrl = url
        if cursor then -- only when there is 100+ servers and there usually isnt anymore lol
            currentUrl = currentUrl .. "&cursor=" .. cursor
        end

        local servers = httpService:JSONDecode(request({Url = currentUrl, Method = "GET"}).Body)

        for _, data in servers.data do
            if type(data) == "table" and data.playing and (playerLimit >= data.playing) and (not table.find(ignoreList, data.id)) then
                table.insert(serverList, data)
            end
        end

        cursor = servers.nextPageCursor

        if not cursor then
            break
        else
            task.wait(0.5)
        end
    end
end

local function serverHop()
    if hopping then
        return
    end
    hopping = true

    task.delay(0.5, function()
        table.sort(serverList, function(data0, data1)
            return data0.playing > data1.playing
        end)

        task.delay(1, function()
            hopping = false

            pcall(function()
                promptOverlay:FindFirstChild("ErrorPrompt").TitleFrame.ErrorTitle.Text = "Disconnected"
            end)
        end)

        queue_on_teleport(request({Url = "https://raw.githubusercontent.com/iRay888/wapus/refs/heads/main/votekick.lua", Method = "GET"}).Body)
        teleportService:TeleportToPlaceInstance(game.PlaceId, serverList[1].id)
    end)
end

local connection; connection = game:GetService("RunService").RenderStepped:Connect(function()
    local errorPrompt = promptOverlay:FindFirstChild("ErrorPrompt")
    
    if errorPrompt then
        local errorFrame = errorPrompt.MessageArea.ErrorFrame
        
        if string.find(errorFrame.ErrorMessage.ContentText, searchString) then
            task.spawn(startSearching, addToList())
            task.delay(0.2, function()
                local buttonArea = errorFrame.ButtonArea
                local buttonHeight = buttonArea.LeaveButton.AbsoluteSize.Y
                errorPrompt.Size = UDim2.new(UDim.new(errorPrompt.Size.X.Scale, errorPrompt.Size.X.Offset), UDim.new(errorPrompt.Size.Y.Scale, errorPrompt.Size.Y.Offset + (buttonHeight * 1.5)))
                local newButton = buttonArea.LeaveButton:Clone()
                newButton.Parent = buttonArea
                buttonArea.ButtonLayout.CellPadding = UDim2.new(UDim.new(0, 0), UDim.new(0, (buttonHeight * 0.25)))
                errorFrame.Position = UDim2.new(UDim.new(errorFrame.Position.X.Scale, errorFrame.Position.X.Offset), UDim.new(errorFrame.Position.Y.Scale, errorFrame.Position.Y.Offset - buttonHeight * 0.6))
                newButton.ButtonText.Text = "Server Hop Now (Less Stable)"
                newButton.MouseButton1Click:Connect(serverHop)
            
                for index = math.max(1, math.ceil(waitTime)), 1, -1 do
                    errorPrompt.TitleFrame.ErrorTitle.Text = "Server Hopping In " .. tostring(index) .. (((index == 1) and " Second") or " Seconds")
                    task.wait(1)
                end

                errorPrompt.TitleFrame.ErrorTitle.Text = "Server Hopping..."
                serverHop()
            end)

            connection:Disconnect()
        end
    end
end)
