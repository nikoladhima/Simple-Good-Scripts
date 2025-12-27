local cloneref = cloneref or clone_ref or clonereference or clone_reference or function(...)
	return (...)
end

local LibraryGui = loadstring(game:HttpGet("https://gitlab.com/0x45.xyz/droplib/-/raw/master/drop-minified.lua"))():Init({
   ["HeaderWidth"] = 250,
   ["AccentColor"] = Color3.new(0.6,0,0)
}, cloneref(game:GetService("CoreGui")))

local Main = LibraryGui:CreateCategory("Main")

local firetouchinterest = firetouchinterest or fire_touch_interest or firetouch or fire_touch
if firetouchinterest then
    local function GetRoot(Character)
        if not Character then
            return nil
        end
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then
            RootPart = Character:FindFirstChild("Torso")
            if not RootPart then
                Character:FindFirstChild("UpperTorso")
                if not RootPart then
                    RootPart = Character:FindFirstChild("LowerTorso")
                end
            end
        end
        return RootPart
    end

    local Players = cloneref(game:GetService("Players"))
    local LocalPlayer = Players.LocalPlayer

    Main:CreateButton("Hit All [Hold Tool]", function()
        local LocalCharacter = LocalPlayer.Character

        if not LocalCharacter then
            return
        end

        local Tool = LocalCharacter and LocalCharacter:FindFirstChildWhichIsA("Tool")

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

            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                local Root = GetRoot(Character)
                if Root then
                    firetouchinterest(Handle, Root, 1)
                    firetouchinterest(Handle, Root, 0)
                end
            end
        end
    end)

    local LoopHitAll = false

    Main:CreateSwitch("Loop Hit All [Hold Tool]", function(Value)
        LoopHitAll = Value

        while task.wait() do
            if not LoopHitAll then
                break
            end

            local LocalCharacter = LocalPlayer.Character

            if not LocalCharacter then
                return
            end

            local Tool = LocalCharacter and LocalCharacter:FindFirstChildWhichIsA("Tool")

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

                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid and Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                    local Root = GetRoot(Character)
                    if Root then
                        firetouchinterest(Handle, Root, 1)
                        firetouchinterest(Handle, Root, 0)
                    end
                else
                    break
                end
            end
        end
    end, false)

    Main:CreateButton("Grab Time Objects", function()
        local LocalRoot = GetRoot(LocalPlayer.Character)
        if LocalRoot then
            for _,Child in ipairs(workspace:GetChildren()) do
                if Child:IsA("Model") and string.lower(Child.Name) == "time_object" then
                    local Outside = Child:FindFirstChild("outside")
                    if Outside then
                        firetouchinterest(LocalRoot, Outside, 1)
                        firetouchinterest(LocalRoot, Outside, 0)
                    end
                end
            end
        end
    end)

    local LoopGrabTimeObjects = false

    Main:CreateSwitch("Loop Grab Time Objects", function(Value)
        LoopGrabTimeObjects = Value
        while task.wait() do
            if not LoopGrabTimeObjects then
                break
            end
            local LocalRoot = GetRoot(LocalPlayer.Character)
            if LocalRoot then
                for _,Child in ipairs(workspace:GetChildren()) do
                    if Child:IsA("Model") and string.lower(Child.Name) == "time_object" then
                        local Outside = Child:FindFirstChild("outside")
                        if Outside then
                            firetouchinterest(LocalRoot, Outside, 1)
                            firetouchinterest(LocalRoot, Outside, 0)
                        end
                    end
                end
            end
        end
    end, false)
else
    warn("Kill All & Grab Time Objects not supported.")
end

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
