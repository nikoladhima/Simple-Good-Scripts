local firetouchinterest = firetouchinterest or firetouchtransmitter or firetouch
if not firetouchinterest then
    return game:GetService("Players").LocalPlayer:Kick("Executor is missing crucial function.\nTry using a better executor.")
end

local Running = true
local LibraryGui = loadstring(game:HttpGet("https://gitlab.com/0x45.xyz/droplib/-/raw/master/drop-minified.lua"))():Init({
   ["HeaderWidth"] = 250,
   ["AccentColor"] = Color3.new(0.6,0,0)
}, (cloneref or clone_ref or clonereference or clone_reference or function(Object)
	return Object
end)(game:GetService("CoreGui")))

local Main = LibraryGui:CreateCategory(".gg/DsGCKtxxEN for more scripts.")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local HitAura = false

Main:CreateSwitch("Hit Aura [Hold Tool]", function(Value)
    HitAura = Value

    while task.wait() do
        if not HitAura then
            break
        end

        local LocalCharacter = LocalPlayer.Character
        if not LocalCharacter then
            return
        end

        local Tool = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
        if not Tool then
            return
        end

        local Handle = Tool:FindFirstChild("Handle")
        if not Handle then
            return
        end

        for _,Player in ipairs(Players:GetPlayers()) do
            if Player == LocalPlayer then
                continue
            end

            local Character = Player.Character
            if not Character then
                continue
            end

            local PrimaryPart = Character.PrimaryPart
            if not PrimaryPart or (Handle.Position - PrimaryPart.Position).Magnitude < 200 then
                continue
            end

            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                local Root =  Character.PrimaryPart or Character:FindFirstChild("Torso")
                if Root then
                    for _ in 1, 5 do
                        if not Handle or Root then
                            break
                        end
                        firetouchinterest(Handle, Root, 1)
                        firetouchinterest(Handle, Root, 0)
                    end
                end
            else
                break
            end
        end
    end
end, false)

Main:CreateButton("Unload Script", function()
    Running = false
    LibraryGui:CleanUp()
end)

for _,Path in {"NikoletoScripts", "NikoletoScripts/BuildStealTime", "NikoletoScripts/BuildStealTime/Cache"} do
    pcall(function()
        if not isfolder(Path) then
            makefolder(Path)
        end
    end)
end

local Request = not isfile("NikoletoScripts/BuildStealTime/Cache/Discord.nscache") and (httprequest or http_request or request)
if Request then
    local HttpService = game:GetService("HttpService")
    if pcall(Request, {Url = "http://127.0.0.1:6463/rpc?v=1",  Method = "POST", Headers = {
        ["Content-Type"] = "application/json", Origin = "https://discord.com"
    }, Body = HttpService:JSONEncode({cmd = "INVITE_BROWSER", nonce = HttpService:GenerateGUID(false), args = {code = "DsGCKtxxEN"}})
    }) then
        writefile("NikoletoScripts/BuildStealTime/Cache/Discord.nscache", "DsGCKtxxEN")
    end
end
