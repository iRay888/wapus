-- https://discord.gg/tUEJZYvF9d
-- known to work on wave, nihon, awp.gg, syn z, seliware
-- known to work on wave, nihon, awp.gg, syn z, seliware, sirhurt
local isLimited = ...
local environment = identifyexecutor and identifyexecutor() or ""
local source = game:HttpGet("https://raw.githubusercontent.com/iRay888/wapus/refs/heads/main/" .. (isLimited and "source-limited.lua" or "source.lua"))
if string.find(string.lower(environment), "wave") and not executed then
    run_on_actor(getdeletedactors()[1], source)
elseif getfflag and string.find(string.lower(tostring(getfflag("DebugRunParallelLuaOnMainThread"))), "true") and not executed then
    loadstring(source)()
elseif string.find(environment, "AWP") ~= nil and not executed then
    for _, v in getactors() do
        run_on_actor(v, [[
            for _, func in getgc(false) do
                if type(func) == "function" and islclosure(func) and debug.getinfo(func).name == "require" and string.find(debug.getinfo(func).source, "ClientLoader") then
                    ]] .. source .. [[
                    break
                end
            end
        ]])
    end
elseif environment == "Nihon" and not executed then
    for _, actor in getactorthreads() do
        run_on_thread(actor, [[
            for _, func in getgc(false) do
                if type(func) == "function" and islclosure(func) and debug.getinfo(func).name == "require" and string.find(debug.getinfo(func).source, "ClientLoader") then
                    ]] .. source .. [[
                    break
                end
            end
        ]])
    end
else
    queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/iRay888/wapus/refs/heads/main/hook.lua") .. "task.wait(5);" .. source)
    setfflag("DebugRunParallelLuaOnMainThread", "True")
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end
getgenv().executed = true
