local cloneref = cloneref or clone_ref or clonereference or clone_reference or function(...)
	return (...)
end

local LibraryGui = loadstring(game:HttpGet("https://gitlab.com/0x45.xyz/droplib/-/raw/master/drop-minified.lua"))():Init({
   ["HeaderWidth"] = 250,
   ["AccentColor"] = Color3.new(0.6,0,0)
}, cloneref(game:GetService("CoreGui")))

local Main = LibraryGui:CreateCategory("Main")

local SelectedBlock = "LuckyBlock"

Main:CreateSelector("Select Block", function(SelectedOption)
    SelectedBlock = SelectedOption
end, function()
    return {"LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock", "VoidBlock"}
end, "LuckyBlock")

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
Main:CreateButton("Spawn Block", function()
    if SelectedBlock == "VoidBlock" then
        local RainblowBlock = ReplicatedStorage:FindFirstChild("SpawnRainbowBlock")
        local GalaxyBlock = ReplicatedStorage:FindFirstChild("SpawnGalaxyBlock")
        if RainblowBlock and GalaxyBlock then
            for _ = 1, 4 do
                GalaxyBlock:FireServer()
                RainblowBlock:FireServer()
            end
            RainblowBlock:FireServer()
            RainblowBlock:FireServer()
        end
    else
        local RemoteEvent = ReplicatedStorage:FindFirstChild("Spawn" .. SelectedBlock)
        if RemoteEvent then
            RemoteEvent:FireServer()
        end
    end
end)

local LocalPlayer = cloneref(game:GetService("Players")).LocalPlayer
Main:CreateButton("Clear Tools", function()
    local Backpack = LocalPlayer.Backpack
    if Backpack then
        Backpack:ClearAllChildren()
    end
    local Character = LocalPlayer.Character
    if Character then
        for _,Child in ipairs(Character:GetChildren()) do
            if Child:IsA("Tool") then
                Child:Destroy()
            end
        end
    end
end)

Main:CreateButton("Unload Script", function()
    LibraryGui:CleanUp()
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
