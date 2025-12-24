-- https://discord.gg/tUEJZYvF9d
local executor = string.lower(identifyexecutor and identifyexecutor() or "")
local source = game:HttpGet("https://raw.githubusercontent.com/iRay888/wapus/refs/heads/main/source.lua"))
local threadSource = [[
    for _, func in getgc(false) do
        if type(func) == "function" and islclosure(func) and debug.getinfo(func).name == "require" and string.find(debug.getinfo(func).source, "ClientLoader") then
            ]] .. source .. [[
            break
        end
    end
]]

local function runSource(runner, getAll)
    for _, actor in getAll() do
        runner(actor, threadSource)
    end
end

if (string.find(executor, "wave") or string.find(executor, "choco")) and (not getgenv().executed) then
    runSource(run_on_actor, get_deleted_actors)
elseif string.find(executor, "volt") and (not getgenv().executed) then
    runSource(run_on_actor, getactors)
elseif string.find(executor, "potassium") and (not getgenv().executed) then
    runSource(run_on_thread, getactorthreads)
elseif getfflag and (string.lower(tostring(getfflag("DebugRunParallelLuaOnMainThread"))) == "true") then
    loadstring(source)()
elseif setfflag then
    setfflag("DebugRunParallelLuaOnMainThread", "True")

    if queue_on_teleport then
        queue_on_teleport(source)
    end
    
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end

getgenv().executed = true
