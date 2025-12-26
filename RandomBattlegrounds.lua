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

local FileFunctions = {
    makefolder = makefolder or make_folder or createfolder or create_folder or function(...)
        return true
    end,
    isfolder = isfolder or is_folder or function(...)
        return false
    end,
    isfile = isfile or is_file or function(...)
        return false
    end,
    readfile = readfile or read_file or readfileasync or read_file_async or function(...)
        return "{}"
    end,
    writefile = writefile or write_file or writefileasync or write_file_async or function(...)
        return true
    end,
}

if not FileFunctions.isfolder("combat.cc") then
	FileFunctions.makefolder("combat.cc")
end

task.spawn(function()
	local httprequest = httprequest or http_request or request or HttpPost or (http and http.request) or (syn and syn.request) or function(...)
		return (...)
	end
    local HttpService = cloneref(game:GetService("HttpService"))

	local function Invite(InviteCode)
		httprequest({
			Url = 'http://127.0.0.1:6463/rpc?v=1',
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json',
				Origin = 'https://discord.com'
			},
			Body = HttpService:JSONEncode({
				cmd = 'INVITE_BROWSER',
				nonce = HttpService:GenerateGUID(false),
				args = {code = InviteCode}
			})
		})
	end

	local VerifyChannelInvite = "DwRT2nH93D"
	local RulesChannelInvite = "jjEtFhA8PA"

	if FileFunctions.isfile("combat.cc/code") then
		if FileFunctions.readfile("combat.cc/code") == VerifyChannelInvite then
			FileFunctions.writefile("combat.cc/code", RulesChannelInvite)
		elseif FileFunctions.readfile("combat.cc/code") == RulesChannelInvite then
			Invite(RulesChannelInvite)
			return
		else
			FileFunctions.writefile("combat.cc/code", RulesChannelInvite)
			Invite(RulesChannelInvite)
			return
		end
	else
		FileFunctions.writefile("combat.cc/code", VerifyChannelInvite)
	end
	Invite(VerifyChannelInvite)
end)
