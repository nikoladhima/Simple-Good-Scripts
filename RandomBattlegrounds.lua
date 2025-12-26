local Running = true

local fireproximityprompt = fireproximityprompt or fire_proximity_prompt or FireProximityPrompt or Fire_Proximity_Prompt
local hookmetamethod = hookmetamethod or hook_metamethod or hook_metamethod or hook_meta_method
local getnamecallmethod = getnamecallmethod or getnamecall_method or get_namecallmethod or get_namecall_method
local newcclosure = newcclosure or new_cclosure or newc_closure or new_c_closure

if not (fireproximityprompt and hookmetamethod and getnamecallmethod and newcclosure) then
    warn("Executor not supported.")
    return
end

local cloneref = cloneref or clone_ref or clonereference or clone_reference or function(...)
	return (...)
end

local LibraryGui = loadstring(game:HttpGet("https://gitlab.com/0x45.xyz/droplib/-/raw/master/drop-minified.lua"))():Init({
   ["HeaderWidth"] = 250,
   ["AccentColor"] = Color3.new(0.6,0,0)
}, cloneref(game:GetService("CoreGui")))

local Main = LibraryGui:CreateCategory("Main")

if hookmetamethod and getnamecallmethod and newcclosure then
    local AntiWater = false

    Main:CreateSwitch("Anti-Water", function(Value)
        AntiWater = Value
    end, false)

    local RemoteFunction = nil
    task.spawn(function()
        RemoteFunction = cloneref(game:GetService("ReplicatedStorage")):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("CombatService"):WaitForChild("RF"):WaitForChild("DamageOwnPlayer")
    end)

    local __namecall
    __namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if not Running or not AntiWater then
            return __namecall(self, ...)
        end

        local Arguments = {...}
        local NamecallMethod = getnamecallmethod()
        if self == RemoteFunction and NamecallMethod == "InvokeServer" then
            Arguments[1] = -math.huge
            return __namecall(self, unpack(Arguments))
        end

        return __namecall(self, ...)
    end))
else
    warn("Anti-Water not supported.")
end

if fireproximityprompt then
    Main:CreateButton("Collect dropped items", function()
        local Ignore = workspace:FindFirstChild("Ignore")
        if Ignore then
            local SmoothDroppedItems = Ignore:FindFirstChild("SmoothDroppedItems")
            if SmoothDroppedItems then
                for _,Child in next, SmoothDroppedItems:GetChildren() do
                    for _,Child2 in ipairs(Child:GetChildren()) do
                        if Child2:IsA("ProximityPrompt") then
                            fireproximityprompt(Child2)
                        end
                    end
                end
            end
        end
    end)
else
    warn("Collect dropped items not supported.")
end

Main:CreateButton("Unload Script", function()
    LibraryGui:CleanUp()
    Running = false
end)
