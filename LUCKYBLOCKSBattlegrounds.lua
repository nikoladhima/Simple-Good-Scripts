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
    return {"LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock"}
end, "LuckyBlock")

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
Main:CreateButton("Spawn Block", function()
    local RemoteEvent = ReplicatedStorage:FindFirstChild("Spawn" .. SelectedBlock)
    if RemoteEvent then
        RemoteEvent:FireServer()
    end
end)

local LocalPlayer = cloneref(game:GetService("Players")).LocalPlayer
Main:CreateButton("Clear Tools", function()
    LocalPlayer.Backpack:ClearAllChildren()
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
