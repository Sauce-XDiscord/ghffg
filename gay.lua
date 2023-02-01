-- Library
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/addons/SaveManager.lua'))()
-- Window, Watermark
local Window = Library:CreateWindow({
    Title = 'hello kitty stan',
    Center = true, 
    AutoShow = true,
})
Library:SetWatermark('hello kitty stan')
-- Services
local Players = game:GetService("Players");
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Player Interact
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();
local Camera = workspace.CurrentCamera
local _Character = getrenv()._G.Character;
local Cameras = game:GetService("Workspace").Camera;
local CurrentCamera = game:GetService("Workspace").CurrentCamera
local worldToViewportPoint = CurrentCamera.worldToViewportPoint
-- MetaTables
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldindex = gmt.__index
-- Updaters
local LeavesRemoverOn = false
local HomeRayOn = false
local ZoomOn = false
local AimbotOn = false
local HRTransp = 0.6
-- Cfg
local fovcircle = Drawing.new("Circle")
local Config = {
    Esp = {
        Box               = false,
        BoxOutline        = false,
        BoxColor          = Color3.fromRGB(255,255,255),
        BoxOutlineColor   = Color3.fromRGB(0,0,0),
        HealthBar         = false,
        HealthBarSide     = "Left", -- Left,Bottom,Right
        Names             = false,
        Tool              = false,
        Skeletons         = false,
        SkeletonsColor    = Color3.fromRGB(255,255,255),
        Tracers           = false,
        TracersColor      = Color3.fromRGB(255,255,255),
        NamesOutline      = false,
        NamesColor        = Color3.fromRGB(255,255,255),
        NamesOutlineColor = Color3.fromRGB(0,0,0),
        NamesFont         = 2, -- 1,2,3
        NamesSize         = 13,
    },

	ObjectEsp = {
		Stone          = false,
		Iron           = false,
		Nitrate        = false,
		Loot           = false,
		Lootbags       = false,
	},

    Aimlock = {
        Enabled     = false,
        Smoothness  = 20,
        Distance    = 300,
        AimSleepers = false,
        AimVisible  = false,
    },

    Hitboxes = {
        Transparency     = 0.8,
        XSize            = 3,
        YSize            = 6,
        ZSize            = 2,
    },
}

fovcircle.Visible      = false
fovcircle.Radius       = 120
fovcircle.Color        = Color3.fromRGB(255,255,255)
fovcircle.Thickness    = 1
fovcircle.Filled       = false
fovcircle.Transparency = 1
fovcircle.Position     = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
-- Tabs
local VisualsTab = Window:AddTab('Visuals')
local CombatTab = Window:AddTab('Combat')
local MiscTab = Window:AddTab('Misc')
local UITab = Window:AddTab('UI')
local MenuGroup = UITab:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
Library:OnUnload(function()
    Library.Unloaded = true
end)
-- GetClosestPlayerToPlayer
function getClosestPlayerToPlayer()
    local closestPlayer = nil;
    local shortestDistance = Config.Aimlock.Distance;
    for i, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name then
            if v.Humanoid.Health ~= 0 and v.PrimaryPart ~= nil and v:FindFirstChild("Head") then
                local pos = Cameras.WorldToViewportPoint(Cameras, v.PrimaryPart.Position)
                local magnitude = (_Character.character.Middle.Position - v.PrimaryPart.Position).magnitude
                local fovmagnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude
                
                if magnitude < shortestDistance then
                    if fovmagnitude < 120 then
                        closestPlayer = v
                        shortestDistance = magnitude
                    end
                end
            end
        end
    end
    return closestPlayer
end
--
local Typing = false

local ViewportSize_ = Camera.ViewportSize / 2
local Axis_X, Axis_Y = ViewportSize_.X, ViewportSize_.Y

local HorizontalLine = Drawing.new("Line")
local VerticalLine = Drawing.new("Line")

_G.ToMouse = true

_G.CrosshairVisible = false
_G.CrosshairSize = 10
_G.CrosshairThickness = 1
_G.CrosshairColor = Color3.fromRGB(255, 0, 0)
_G.CrosshairTransparency = 1

RunService.RenderStepped:Connect(function()
    local Real_Size = _G.CrosshairSize / 2

    HorizontalLine.Color = _G.CrosshairColor
    HorizontalLine.Thickness = _G.CrosshairThickness
    HorizontalLine.Visible = _G.CrosshairVisible
    HorizontalLine.Transparency = _G.CrosshairTransparency
    
    VerticalLine.Color = _G.CrosshairColor
    VerticalLine.Thickness = _G.CrosshairThickness
    VerticalLine.Visible = _G.CrosshairVisible
    VerticalLine.Transparency = _G.CrosshairTransparency
    
    if _G.ToMouse == true then
        HorizontalLine.From = Vector2.new(UserInputService:GetMouseLocation().X - Real_Size, UserInputService:GetMouseLocation().Y)
        HorizontalLine.To = Vector2.new(UserInputService:GetMouseLocation().X + Real_Size, UserInputService:GetMouseLocation().Y)
        
        VerticalLine.From = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y - Real_Size)
        VerticalLine.To = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y + Real_Size)
    elseif _G.ToMouse == false then
        HorizontalLine.From = Vector2.new(Axis_X - Real_Size, Axis_Y)
        HorizontalLine.To = Vector2.new(Axis_X + Real_Size, Axis_Y)
    
        VerticalLine.From = Vector2.new(Axis_X, Axis_Y - Real_Size)
        VerticalLine.To = Vector2.new(Axis_X, Axis_Y + Real_Size)
    end
end)

UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)
-- Crosshair
local CrossHairSector = MiscTab:AddLeftGroupbox('Crosshair')

CrossHairSector:AddToggle('Cht', {
    Text = 'Crosshair',
    Default = false,
    Tooltip = 'Off/on crosshair',
})
Toggles.Cht:OnChanged(function(Toggle)
    _G.CrosshairVisible = Toggle
end)

CrossHairSector:AddToggle('Chtmt', {
    Text = 'To Mouse',
    Default = false,
    Tooltip = 'Crosshair to mouse',
})
Toggles.Chtmt:OnChanged(function(Toggle)
    _G.ToMouse = Toggle
end)

CrossHairSector:AddLabel('Color'):AddColorPicker('Chc', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Color',
})
Options.Chc:OnChanged(function(Color)
    _G.CrosshairColor = Color
end)

CrossHairSector:AddSlider('Chs', {
    Text = 'Size',
    Default = 15,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
})
Options.Chs:OnChanged(function(Slider)
    _G.CrosshairSize = Slider
end)

CrossHairSector:AddSlider('chtr', {
    Text = 'Transparency',
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
})
Options.chtr:OnChanged(function(Slider)
    _G.CrosshairTransparency = Slider
end)
--
local WorldGroupTab = VisualsTab:AddRightTabbox("World")
local WorldTab = WorldGroupTab:AddTab('World')
local GameTab = WorldGroupTab:AddTab('Game')
local PlayerTab = WorldGroupTab:AddTab('Player')
-- HomeRay
GameTab:AddLabel('HomeRay'):AddKeyPicker('Hrk', {
    Default = 'T', 
    SyncToggleState = false, 
    Mode = 'Toggle',
    Text = 'HomeRay',
    NoUI = false,
})
Options.Hrk:OnClick(function()
    if HomeRayOn == false then
        HomeRayOn = true
        for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
            if v:FindFirstChild("Hitbox") then
                v.Hitbox.Transparency = HRTransp
            end
        end
    else
        HomeRayOn = false
        for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
            if v:FindFirstChild("Hitbox") then
                v.Hitbox.Transparency = 0
            end
        end
    end
end)
GameTab:AddSlider('Hrts', {
    Text = 'Transparency',
    Default = 0.9,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
})
Options.Hrts:OnChanged(function(Slider)
    HRTransp = Slider
end)
-- Leaves Remove
WorldTab:AddButton('Leaves Remove', function()
    LeavesRemoverOn = true
    while LeavesRemoverOn == true do
        for v, i in pairs(game:GetService("Workspace"):GetChildren()) do
            if i:FindFirstChild("Part") then
                if i:FindFirstChild("top") then
                    i.top:Remove()
                else
                    for x,b in pairs(i:GetChildren()) do
                        if b.ClassName == "MeshPart" and b.MeshId == "rbxassetid://743205322" then
                            b:Remove()
                        end
                    end
                end
            end
        end
    wait(5)
    end
end)
-- Shadows
WorldTab:AddToggle('Gs',{
    Text = 'Shadows',
    Default = true,
    Tooltip = "Off/On GlobalShadows",
})
Toggles.Gs:OnChanged(function(T)
    game:GetService("Lighting").GlobalShadows = T
end)
-- 3D Clouds
WorldTab:AddToggle('Clh',{
    Text = '3D Clouds',
    Default = true,
    Tooltip = "Off/On 3d clouds",
})
Toggles.Clh:OnChanged(function(T)
    if T == true then
        game:GetService("Workspace").Terrain.Clouds.Enabled = true
    elseif T == false then
        game:GetService("Workspace").Terrain.Clouds.Enabled = false
    end
end)
-- Grass
WorldTab:AddToggle('Gr', {
    Text = 'Grass',
    Default = true,
    Tooltip = 'Off/on grass',
})
Toggles.Gr:OnChanged(function(GrassRemove)
    sethiddenproperty(game.Workspace.Terrain, "Decoration", GrassRemove)
end)
-- Color Grass
local Terrain = game:GetService("Workspace").Terrain
local GCEN = Color3.fromRGB(93, 111, 55)
local GRCEND = false
WorldTab:AddToggle('CLRG',{
    Text = 'Color Grass',
    Default = false,
    Tooltip = "Off/On",
})
Toggles.CLRG:OnChanged(function(T)
    if T == true then
        GRCEND = true
        local SetColor = Terrain:SetMaterialColor(Enum.Material.Grass,GCEN)
    elseif T == false then
        GRCEND = false
        local SetColor = Terrain:SetMaterialColor(Enum.Material.Grass,Color3.fromRGB(93, 111, 55))
    end
end)

WorldTab:AddLabel('Colorgrass'):AddColorPicker('ColorGrass', {
    Default = Color3.fromRGB(93, 111, 55),
    Title = 'Changer Color Grass', 
})
Options.ColorGrass:OnChanged(function(Grass1)
    if GRCEND == true then
        GCEN = Grass1
        local SetColor = Terrain:SetMaterialColor(Enum.Material.Grass, Grass1) 
    else
        
    end
end)
-- Fov
local CurrentFovChanged = 70
PlayerTab:AddSlider('Fc', {
    Text = 'Fov Changer',
    Default = 70,
    Min = 0,
    Max = 120,
    Rounding = 0,
    Compact = false,
}):OnChanged(function(t)
    CurrentFovChanged = t
    gmt.__index = newcclosure(function(self,b)
        if b == "FieldOfView" then
            return t
        end
        return oldindex(self,b)
    end)
end)
-- Zoom
PlayerTab:AddLabel('Zoom'):AddKeyPicker('ZoomPick', {
    Default = 'X', 
    SyncToggleState = false, 
    Mode = 'Toggle',
    Text = 'Zoom',
    NoUI = false,
})
Options.ZoomPick:OnClick(function()
    if ZoomOn == false then
        ZoomOn = true
        gmt.__index = newcclosure(function(self,b)
            if b == "FieldOfView" then
                return 1
            end
            return oldindex(self,b)
        end)
    elseif ZoomOn == true then
        ZoomOn = false
        gmt.__index = newcclosure(function(self,b)
            if b == "FieldOfView" then
                return CurrentFovChanged
            end
            return oldindex(self,b)
        end)
    end
end)
-- PickupAll
PlayerTab:AddLabel('PickUp All'):AddKeyPicker('pckk', {
    Default = "F",
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'PickUp All',
    NoUI = false,
})
Options.pckk:OnClick(function()
    game:GetService("ReplicatedStorage").e:FireServer(106, 1,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 2,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 3,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 4,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 5,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 6,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 7,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 8,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 9,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 10,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 11,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 12,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 13,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 14,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 15,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 16,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 17,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 18,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 19,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 20,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 21,true)
    game:GetService("ReplicatedStorage").e:FireServer(106, 22,true)
end)
--
local ChangerGroupTab = VisualsTab:AddRightTabbox("Arm Visuals")
local ArmVisualsTab = ChangerGroupTab:AddTab('Arms')
local GunVisualsTab = ChangerGroupTab:AddTab('Gun')
local SoundVisualsTab = ChangerGroupTab:AddTab('Sound')
-- Arms
ArmVisualsTab:AddButton('Default', function()
    game:GetService("Workspace").Ignore.FPSArms.RightUpperArm.BrickColor = BrickColor.new("Linen")
    game:GetService("Workspace").Ignore.FPSArms.RightLowerArm.BrickColor = BrickColor.new("Linen")
    game:GetService("Workspace").Ignore.FPSArms.RightHand.BrickColor = BrickColor.new("Linen")
    game:GetService("Workspace").Ignore.FPSArms.LeftUpperArm.BrickColor = BrickColor.new("Linen")
    game:GetService("Workspace").Ignore.FPSArms.LeftLowerArm.BrickColor = BrickColor.new("Linen")
    game:GetService("Workspace").Ignore.FPSArms.LeftHand.BrickColor = BrickColor.new("Linen")
    game:GetService("ReplicatedStorage").HandModels.HMAR.Handle.BrickColor = BrickColor.new("Cool yellow")
end)

local CARMS = false

ArmVisualsTab:AddToggle('CLRT',{
    Text = 'Color Arms',
    Default = false,
    Tooltip = "Off/On",
})
Toggles.CLRT:OnChanged(function(T)
    CARMS = T
end)

ArmVisualsTab:AddLabel('Color'):AddColorPicker('ARCCCC', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Arms Color',
})
Options.ARCCCC:OnChanged(function(ARMC)
    if CARMS then
        game:GetService("Workspace").Ignore.FPSArms.RightUpperArm.Color = ARMC
        game:GetService("Workspace").Ignore.FPSArms.RightLowerArm.Color = ARMC
        game:GetService("Workspace").Ignore.FPSArms.RightHand.Color = ARMC
        game:GetService("Workspace").Ignore.FPSArms.LeftUpperArm.Color = ARMC
        game:GetService("Workspace").Ignore.FPSArms.LeftLowerArm.Color = ARMC
        game:GetService("Workspace").Ignore.FPSArms.LeftHand.Color = ARMC
        game:GetService("ReplicatedStorage").HandModels.HMAR.Handle.Color = ARMC
    else
        game:GetService("Workspace").Ignore.FPSArms.RightUpperArm.BrickColor = BrickColor.new("Linen")
        game:GetService("Workspace").Ignore.FPSArms.RightLowerArm.BrickColor = BrickColor.new("Linen")
        game:GetService("Workspace").Ignore.FPSArms.RightHand.BrickColor = BrickColor.new("Linen")
        game:GetService("Workspace").Ignore.FPSArms.LeftUpperArm.BrickColor = BrickColor.new("Linen")
        game:GetService("Workspace").Ignore.FPSArms.LeftLowerArm.BrickColor = BrickColor.new("Linen")
        game:GetService("Workspace").Ignore.FPSArms.LeftHand.BrickColor = BrickColor.new("Linen")
        game:GetService("ReplicatedStorage").HandModels.HMAR.Handle.BrickColor = BrickColor.new("Cool yellow")
    end
end)
ArmVisualsTab:AddDropdown('MaterialD', {
    Values = { 'Default', 'ForceField', 'Neon', 'CrackedLava' },
    Default = 1, 
    Multi = false, 
    Text = 'Arm Material',
    Tooltip = 'Arms Material', 
}):OnChanged(function()
    if Options.MaterialD.Value == "Default" then
        game:GetService("Workspace").Ignore.FPSArms.RightUpperArm.Material = "Plastic"
        game:GetService("Workspace").Ignore.FPSArms.RightLowerArm.Material = "Plastic"
        game:GetService("Workspace").Ignore.FPSArms.RightHand.Material = "Plastic"
        game:GetService("Workspace").Ignore.FPSArms.LeftUpperArm.Material = "Plastic"
        game:GetService("Workspace").Ignore.FPSArms.LeftLowerArm.Material = "Plastic"
        game:GetService("Workspace").Ignore.FPSArms.LeftHand.Material = "Plastic"
        game:GetService("ReplicatedStorage").HandModels.HMAR.Handle.Material = "Plastic"
    end

    if Options.MaterialD.Value == "ForceField" then
        game:GetService("Workspace").Ignore.FPSArms.RightUpperArm.Material = "ForceField"
        game:GetService("Workspace").Ignore.FPSArms.RightLowerArm.Material = "ForceField"
        game:GetService("Workspace").Ignore.FPSArms.RightHand.Material = "ForceField"
        game:GetService("Workspace").Ignore.FPSArms.LeftUpperArm.Material = "ForceField"
        game:GetService("Workspace").Ignore.FPSArms.LeftLowerArm.Material = "ForceField"
        game:GetService("Workspace").Ignore.FPSArms.LeftHand.Material = "ForceField"
        game:GetService("ReplicatedStorage").HandModels.HMAR.Handle.Material = "ForceField"
    end

    if Options.MaterialD.Value == "Neon" then
        game:GetService("Workspace").Ignore.FPSArms.RightUpperArm.Material = "Neon"
        game:GetService("Workspace").Ignore.FPSArms.RightLowerArm.Material = "Neon"
        game:GetService("Workspace").Ignore.FPSArms.RightHand.Material = "Neon"
        game:GetService("Workspace").Ignore.FPSArms.LeftUpperArm.Material = "Neon"
        game:GetService("Workspace").Ignore.FPSArms.LeftLowerArm.Material = "Neon"
        game:GetService("Workspace").Ignore.FPSArms.LeftHand.Material = "Neon"
        game:GetService("ReplicatedStorage").HandModels.HMAR.Handle.Material = "Neon"
    end

    if Options.MaterialD.Value == "CrackedLava" then
        game:GetService("Workspace").Ignore.FPSArms.RightUpperArm.Material = "CrackedLava"
        game:GetService("Workspace").Ignore.FPSArms.RightLowerArm.Material = "CrackedLava"
        game:GetService("Workspace").Ignore.FPSArms.RightHand.Material = "CrackedLava"
        game:GetService("Workspace").Ignore.FPSArms.LeftUpperArm.Material = "CrackedLava"
        game:GetService("Workspace").Ignore.FPSArms.LeftLowerArm.Material = "CrackedLava"
        game:GetService("Workspace").Ignore.FPSArms.LeftHand.Material = "CrackedLava"
        game:GetService("ReplicatedStorage").HandModels.HMAR.Handle.Material = "CrackedLava"
    end
end)
-- Guns
GunVisualsTab:AddButton('Set Default All', function()
    -- material
    -- hmar
    game:GetService("ReplicatedStorage").HandModels.HMAR.Barrel.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.HMAR.Body.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.HMAR.Bolt.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.HMAR.Stock.Material = Enum.Material.Wood
    game:GetService("ReplicatedStorage").HandModels.HMAR.Grip.Material = Enum.Material.Wood
    game:GetService("ReplicatedStorage").HandModels.HMAR.Mag.Material = Enum.Material.Plastic
    game:GetService("ReplicatedStorage").HandModels.HMAR.Muzzle.Material = Enum.Material.Wood
    game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.ADS.Material = Enum.Material.Plastic
    game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.Union.Material = Enum.Material.Metal
    -- pipesmg
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.ADS.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.Union.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Mag.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Flap.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Muzzle.Material = Enum.Material.Plastic
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Body.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Bolt.Material = Enum.Material.Metal
    -- usp
    game:GetService("ReplicatedStorage").HandModels.USP.IronSights.ADS.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.USP.IronSights.Union.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.USP.Muzzle.Material = Enum.Material.Plastic
    game:GetService("ReplicatedStorage").HandModels.USP.Mag.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Slide"].Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Body"].Material = Enum.Material.Metal
    -- pipe
    game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights.ADS.Material = Enum.Material.Plastic
    game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights["Meshes/PipePistolSights"].Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.PipePistol.Muzzle.Material = Enum.Material.Plastic
    game:GetService("ReplicatedStorage").HandModels.PipePistol.Mag.Material = Enum.Material.Plastic
    game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBody"].Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBolt"].Material = Enum.Material.Metal
    -- crossbow
    game:GetService("ReplicatedStorage").HandModels.Crossbow.Arrow.Material = Enum.Material.Wood
    game:GetService("ReplicatedStorage").HandModels.Crossbow["Meshes/Bow"].Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.Crossbow.Union.Material = Enum.Material.Metal
    game:GetService("ReplicatedStorage").HandModels.Crossbow.Body.Material = Enum.Material.Wood
    game:GetService("ReplicatedStorage").HandModels.Crossbow.Mover.Material = Enum.Material.CorrodedMetal
    -- bow
    game:GetService("ReplicatedStorage").HandModels.Bow.Arrow.Material = Enum.Material.Wood
    game:GetService("ReplicatedStorage").HandModels.Bow["Meshes/Bow"].Material = Enum.Material.Wood 
    game:GetService("ReplicatedStorage").HandModels.Bow.Fabric.Material = Enum.Material.Fabric

    -- color
    -- HMAR
    game:GetService("ReplicatedStorage").HandModels.HMAR.Barrel.BrickColor = BrickColor.new("Dark grey")
    game:GetService("ReplicatedStorage").HandModels.HMAR.Body.BrickColor = BrickColor.new("Dark stone grey")
    game:GetService("ReplicatedStorage").HandModels.HMAR.Bolt.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.HMAR.Stock.BrickColor = BrickColor.new("Bronze")
    game:GetService("ReplicatedStorage").HandModels.HMAR.Grip.BrickColor = BrickColor.new("Bronze")
    game:GetService("ReplicatedStorage").HandModels.HMAR.Mag.BrickColor = BrickColor.new("Dark stone grey")
    game:GetService("ReplicatedStorage").HandModels.HMAR.Muzzle.BrickColor = BrickColor.new("Bronze")
    game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.ADS.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.Union.BrickColor = BrickColor.new("Medium stone grey")
    -----PipeSMG
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.ADS.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.Union.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Mag.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Flap.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Muzzle.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Body.BrickColor = BrickColor.new("Dark stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipeSMG.Bolt.BrickColor = BrickColor.new("Medium stone grey")
    -----USP
    game:GetService("ReplicatedStorage").HandModels.USP.IronSights.ADS.BrickColor = BrickColor.new("Lime green")
    game:GetService("ReplicatedStorage").HandModels.USP.IronSights.Union.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.USP.Muzzle.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.USP.Mag.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Slide"].BrickColor = BrickColor.new("Silver flip/flop")
    game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Body"].BrickColor = BrickColor.new("Dark stone grey")
    -----Pipe
    game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights.ADS.BrickColor = BrickColor.new("Dark stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights["Meshes/PipePistolSights"].BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipePistol.Muzzle.BrickColor = BrickColor.new("Dark stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipePistol.Mag.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBody"].BrickColor = BrickColor.new("Dark stone grey")
    game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBolt"].BrickColor = BrickColor.new("Medium stone grey")
    -----Crossbow
    game:GetService("ReplicatedStorage").HandModels.Crossbow.Arrow.BrickColor = BrickColor.new("Fawn brown")
    game:GetService("ReplicatedStorage").HandModels.Crossbow["Meshes/Bow"].BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.Crossbow.Union.BrickColor = BrickColor.new("Medium stone grey")
    game:GetService("ReplicatedStorage").HandModels.Crossbow.Body.BrickColor = BrickColor.new("Bronze")
    game:GetService("ReplicatedStorage").HandModels.Crossbow.Mover.BrickColor = BrickColor.new("Medium stone grey")
    -----Bow
    game:GetService("ReplicatedStorage").HandModels.Bow.Arrow.BrickColor = BrickColor.new("Fawn brown")
    game:GetService("ReplicatedStorage").HandModels.Bow["Meshes/Bow"].BrickColor = BrickColor.new("Bronze")
    game:GetService("ReplicatedStorage").HandModels.Bow.Fabric.BrickColor = BrickColor.new("Beige")
end)
local GCTG = false
GunVisualsTab:AddToggle('Tgc',{
    Text = 'Gun Color',
    Default = false,
    Tooltip = "Off/On",
})
Toggles.Tgc:OnChanged(function(Toggle)
    GCTG = Toggle
end)

GunVisualsTab:AddLabel('Color'):AddColorPicker('GunColor', {
    Default = Color3.fromRGB(0, 1, 0),
    Title = 'Changes gun colors', 
})
Options.GunColor:OnChanged(function(GunColor)
    if GCTG == true then
        -----HMAR
        game:GetService("ReplicatedStorage").HandModels.HMAR.Barrel.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.HMAR.Body.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.HMAR.Bolt.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.HMAR.Stock.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.HMAR.Grip.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.HMAR.Mag.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.HMAR.Muzzle.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.ADS.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.Union.Color = GunColor
        -----PipeSMG
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.ADS.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.Union.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Mag.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Flap.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Muzzle.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Body.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Bolt.Color = GunColor
        -----USP
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.ADS.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.Union.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.USP.Muzzle.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.USP.Mag.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Slide"].Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Body"].Color = GunColor
        -----Pipe
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights.ADS.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights["Meshes/PipePistolSights"].Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Muzzle.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Mag.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBody"].Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBolt"].Color = GunColor
        -----Crossbow
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Arrow.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.Crossbow["Meshes/Bow"].Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Union.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Body.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Mover.Color = GunColor
        -----Bow
        game:GetService("ReplicatedStorage").HandModels.Bow.Arrow.Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.Bow["Meshes/Bow"].Color = GunColor
        game:GetService("ReplicatedStorage").HandModels.Bow.Fabric.Color = GunColor
    elseif GCTG == false then
        -- HMAR
        game:GetService("ReplicatedStorage").HandModels.HMAR.Barrel.BrickColor = BrickColor.new("Dark grey")
        game:GetService("ReplicatedStorage").HandModels.HMAR.Body.BrickColor = BrickColor.new("Dark stone grey")
        game:GetService("ReplicatedStorage").HandModels.HMAR.Bolt.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.HMAR.Stock.BrickColor = BrickColor.new("Bronze")
        game:GetService("ReplicatedStorage").HandModels.HMAR.Grip.BrickColor = BrickColor.new("Bronze")
        game:GetService("ReplicatedStorage").HandModels.HMAR.Mag.BrickColor = BrickColor.new("Dark stone grey")
        game:GetService("ReplicatedStorage").HandModels.HMAR.Muzzle.BrickColor = BrickColor.new("Bronze")
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.ADS.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.Union.BrickColor = BrickColor.new("Medium stone grey")
        -----PipeSMG
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.ADS.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.Union.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Mag.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Flap.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Muzzle.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Body.BrickColor = BrickColor.new("Dark stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Bolt.BrickColor = BrickColor.new("Medium stone grey")
        -----USP
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.ADS.BrickColor = BrickColor.new("Lime green")
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.Union.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.USP.Muzzle.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.USP.Mag.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Slide"].BrickColor = BrickColor.new("Silver flip/flop")
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Body"].BrickColor = BrickColor.new("Dark stone grey")
        -----Pipe
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights.ADS.BrickColor = BrickColor.new("Dark stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights["Meshes/PipePistolSights"].BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Muzzle.BrickColor = BrickColor.new("Dark stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Mag.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBody"].BrickColor = BrickColor.new("Dark stone grey")
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBolt"].BrickColor = BrickColor.new("Medium stone grey")
        -----Crossbow
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Arrow.BrickColor = BrickColor.new("Fawn brown")
        game:GetService("ReplicatedStorage").HandModels.Crossbow["Meshes/Bow"].BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Union.BrickColor = BrickColor.new("Medium stone grey")
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Body.BrickColor = BrickColor.new("Bronze")
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Mover.BrickColor = BrickColor.new("Medium stone grey")
        -----Bow
        game:GetService("ReplicatedStorage").HandModels.Bow.Arrow.BrickColor = BrickColor.new("Fawn brown")
        game:GetService("ReplicatedStorage").HandModels.Bow["Meshes/Bow"].BrickColor = BrickColor.new("Bronze")
        game:GetService("ReplicatedStorage").HandModels.Bow.Fabric.BrickColor = BrickColor.new("Beige")
    end
end)

GunVisualsTab:AddDropdown('MaterialV', {
    Values = { 'Default', 'ForceField', 'Neon' },
    Default = 1,
    Multi = false,
    Text = 'Gun Material',
    Tooltip = 'NOT USEFUL WITH CUSTOM SKINS!',
})
Options.MaterialV:OnChanged(function()
    if Options.MaterialV.Value == "Default" then
        -----HMAR
        game:GetService("ReplicatedStorage").HandModels.HMAR.Barrel.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.HMAR.Body.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.HMAR.Bolt.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.HMAR.Stock.Material = Enum.Material.Wood
        game:GetService("ReplicatedStorage").HandModels.HMAR.Grip.Material = Enum.Material.Wood
        game:GetService("ReplicatedStorage").HandModels.HMAR.Mag.Material = Enum.Material.Plastic
        game:GetService("ReplicatedStorage").HandModels.HMAR.Muzzle.Material = Enum.Material.Wood
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.ADS.Material = Enum.Material.Plastic
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.Union.Material = Enum.Material.Metal
        -----PipeSMG
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.ADS.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.Union.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Mag.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Flap.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Muzzle.Material = Enum.Material.Plastic
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Body.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Bolt.Material = Enum.Material.Metal
        -----USP
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.ADS.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.Union.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.USP.Muzzle.Material = Enum.Material.Plastic
        game:GetService("ReplicatedStorage").HandModels.USP.Mag.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Slide"].Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Body"].Material = Enum.Material.Metal
        -----Pipe
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights.ADS.Material = Enum.Material.Plastic
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights["Meshes/PipePistolSights"].Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Muzzle.Material = Enum.Material.Plastic
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Mag.Material = Enum.Material.Plastic
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBody"].Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBolt"].Material = Enum.Material.Metal
        -----Crossbow
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Arrow.Material = Enum.Material.Wood
        game:GetService("ReplicatedStorage").HandModels.Crossbow["Meshes/Bow"].Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Union.Material = Enum.Material.Metal
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Body.Material = Enum.Material.Wood
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Mover.Material = Enum.Material.CorrodedMetal
        -----Bow
        game:GetService("ReplicatedStorage").HandModels.Bow.Arrow.Material = Enum.Material.Wood
        game:GetService("ReplicatedStorage").HandModels.Bow["Meshes/Bow"].Material = Enum.Material.Wood 
        game:GetService("ReplicatedStorage").HandModels.Bow.Fabric.Material = Enum.Material.Fabric
    elseif Options.MaterialV.Value == "ForceField" then
        -----HMAR
        game:GetService("ReplicatedStorage").HandModels.HMAR.Barrel.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.HMAR.Body.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.HMAR.Bolt.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.HMAR.Stock.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.HMAR.Grip.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.HMAR.Mag.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.HMAR.Muzzle.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.ADS.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.Union.Material = Enum.Material.ForceField
        -----PipeSMG
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.ADS.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.Union.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Mag.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Flap.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Muzzle.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Body.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Bolt.Material = Enum.Material.ForceField
        -----USP
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.ADS.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.Union.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.USP.Muzzle.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.USP.Mag.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Slide"].Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Body"].Material = Enum.Material.ForceField
        -----Pipe
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights.ADS.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights["Meshes/PipePistolSights"].Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Muzzle.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Mag.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBody"].Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBolt"].Material = Enum.Material.ForceField
        -----Crossbow
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Arrow.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.Crossbow["Meshes/Bow"].Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Union.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Body.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Mover.Material = Enum.Material.ForceField
        -----Bow
        game:GetService("ReplicatedStorage").HandModels.Bow.Arrow.Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.Bow["Meshes/Bow"].Material = Enum.Material.ForceField
        game:GetService("ReplicatedStorage").HandModels.Bow.Fabric.Material = Enum.Material.ForceField
    elseif Options.MaterialV.Value == "Neon" then
        -----HMAR
        game:GetService("ReplicatedStorage").HandModels.HMAR.Barrel.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.HMAR.Body.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.HMAR.Bolt.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.HMAR.Stock.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.HMAR.Grip.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.HMAR.Mag.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.HMAR.Muzzle.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.ADS.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.HMAR.IronSights.Union.Material = Enum.Material.Neon
        -----PipeSMG
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.ADS.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.IronSights.Union.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Mag.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Flap.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Muzzle.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Body.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipeSMG.Bolt.Material = Enum.Material.Neon
        -----USP
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.ADS.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.USP.IronSights.Union.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.USP.Muzzle.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.USP.Mag.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Slide"].Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.USP["Meshes/USP_Body"].Material = Enum.Material.Neon
        -----Pipe
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights.ADS.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipePistol.IronSights["Meshes/PipePistolSights"].Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Muzzle.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipePistol.Mag.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBody"].Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.PipePistol["Meshes/PipePistolBolt"].Material = Enum.Material.Neon
        -----Crossbow
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Arrow.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.Crossbow["Meshes/Bow"].Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Union.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Body.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.Crossbow.Mover.Material = Enum.Material.Neon
        -----Bow
        game:GetService("ReplicatedStorage").HandModels.Bow.Arrow.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.Bow["Meshes/Bow"].Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage").HandModels.Bow.Fabric.Material = Enum.Material.Neon
    end
end)
-- Sounds
SoundVisualsTab:AddDropdown('HeadshotHit', {
    Values = { 'Default', 'Neverlose', 'Rust', 'TF2', 'Bruh', 'Hm, is nice', 'Osu', 'Weeb', 'Minecraft'},
    Default = 1,
    Multi = false,
    Text = 'Hit Headshot',
    Tooltip = 'Changes player hit headshot sound',
})
Options.HeadshotHit:OnChanged(function()
    if Options.HeadshotHit.Value == "Default" then
        SoundService.PlayerHitHeadshot.SoundId = "rbxassetid://9119561046"
        SoundService.PlayerHitHeadshot.Playing = true
    end

    if Options.HeadshotHit.Value == "Neverlose" then
        SoundService.PlayerHitHeadshot.SoundId = "rbxassetid://6607204501"
        SoundService.PlayerHitHeadshot.Playing = true
    end

    if Options.HeadshotHit.Value == "Rust" then
        SoundService.PlayerHitHeadshot.SoundId = "rbxassetid://1255040462"
        SoundService.PlayerHitHeadshot.Playing = true
    end

    if Options.HeadshotHit.Value == "TF2" then
        SoundService.PlayerHitHeadshot.SoundId = "rbxassetid://2868331684"
        SoundService.PlayerHitHeadshot.Playing = true
    end

    if Options.HeadshotHit.Value == "Bruh" then
        SoundService.PlayerHitHeadshot.SoundId = "rbxassetid://4275842574"
        SoundService.PlayerHitHeadshot.Playing = true
    end

    if Options.HeadshotHit.Value == "Hm, is nice" then
        SoundService.PlayerHitHeadshot.SoundId = "rbxassetid://5570758643"
        SoundService.PlayerHitHeadshot.Playing = true
    end

    if Options.HeadshotHit.Value == "Osu" then
        SoundService.PlayerHitHeadshot.SoundId = ("rbxassetid://7149255551")
        SoundService.PlayerHitHeadshot.Playing = true
    end

    if Options.HeadshotHit.Value == "Weeb" then
        SoundService.PlayerHitHeadshot.SoundId = ("rbxassetid://6442965016")
        SoundService.PlayerHitHeadshot.Playing = true
    end

    if Options.HeadshotHit.Value == "Minecraft" then
        SoundService.PlayerHitHeadshot.SoundId = ("rbxassetid://4018616850")
        SoundService.PlayerHitHeadshot.Playing = true
    end
end)
SoundVisualsTab:AddSlider('CVH', {
    Text = 'Volume',
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,
})
Options.CVH:OnChanged(function(vol)
    SoundService.PlayerHitHeadshot.Volume = vol
end)

--
local ESPGroupbox = VisualsTab:AddLeftTabbox("Player ESP")
local PlayerEspTab = ESPGroupbox:AddTab('Player ESP')
local ObjectEspTab = ESPGroupbox:AddTab('Object ESP')

--rbxassetid://4667191660
function CreateObjectEsp(name,text,color,P)
    local ESP = Instance.new("BillboardGui")
    local EspText = Instance.new("TextLabel")

    ESP.Name = name
    ESP.Parent = P
    ESP.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ESP.Active = true
    ESP.AlwaysOnTop = true
    ESP.LightInfluence = 1.000
    ESP.Size = UDim2.new(0, 200, 0, 50)
    ESP.SizeOffset = Vector2.new(0, 0.3)
    ESP.Adornee = P

    EspText.Name = "EspText"
    EspText.Parent = ESP
    EspText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    EspText.BackgroundTransparency = 1.000
    EspText.Size = UDim2.new(0, 200, 0, 50)
    EspText.Font = Enum.Font.FredokaOne
    EspText.Text = text
    EspText.TextColor3 = color
    EspText.TextSize = 16
    EspText.TextWrapped = true
end

function CreateEsp(Player)
    local Box,BoxOutline,Name,HealthBar,HealthBarOutline = Drawing.new("Square"),Drawing.new("Square"),Drawing.new("Text"),Drawing.new("Square"),Drawing.new("Square")
    local Updater = game:GetService("RunService").RenderStepped:Connect(function()
    if Player ~= nil and Player:FindFirstChild("Humanoid") ~= nil and Player:FindFirstChild("HumanoidRootPart") ~= nil and Player.Humanoid.Health > 0 and Player:FindFirstChild("Head") ~= nil then
        local Target2dPosition,IsVisible = workspace.CurrentCamera:WorldToViewportPoint(Player.HumanoidRootPart.Position)
        local scale_factor = 1 / (Target2dPosition.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2) * 100
        local width, height = math.floor(40 * scale_factor), math.floor(60 * scale_factor)
            if Config.Esp.Box then
                Box.Visible = IsVisible
                Box.Color = Config.Esp.BoxColor
                Box.Size = Vector2.new(width,height)
                Box.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2)
                Box.Filled = false
                Box.Thickness = 1
                Box.ZIndex = 69
                if Config.Esp.BoxOutline then
                    BoxOutline.Visible = IsVisible
                    BoxOutline.Color = Config.Esp.BoxOutlineColor
                    BoxOutline.Size = Vector2.new(width,height)
                    BoxOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2)
                    BoxOutline.Filled = false
                    BoxOutline.Thickness = 3
                    BoxOutline.ZIndex = 1
                else
                    BoxOutline.Visible = false
                end
            else
                Box.Visible = false
                BoxOutline.Visible = false
            end
            if Config.Esp.Names then
                Name.Visible = IsVisible
                Name.Color = Config.Esp.NamesColor
                Name.Text = Player.Head.Nametag.tag.Text
                Name.Center = true
                Name.Outline = Config.Esp.NamesOutline
                Name.OutlineColor = Config.Esp.NamesOutlineColor
                Name.Position = Vector2.new(Target2dPosition.X,Target2dPosition.Y - height * 0.5 + -15)
                Name.Font = Config.Esp.NamesFont
                Name.Size = Config.Esp.NamesSize
            else
                Name.Visible = false
            end
            if Config.Esp.HealthBar then
                HealthBarOutline.Visible = IsVisible
                HealthBarOutline.Color = Color3.fromRGB(0,0,0)
                HealthBarOutline.Filled = true
                HealthBarOutline.ZIndex = 1

                HealthBar.Visible = IsVisible
                HealthBar.Color = Color3.fromRGB(255,0,0):lerp(Color3.fromRGB(0,255,0), Player:FindFirstChild("Humanoid").Health/Player:FindFirstChild("Humanoid").MaxHealth)
                HealthBar.Thickness = 1
                HealthBar.Filled = true
                HealthBar.ZIndex = 69
                if Config.Esp.HealthBarSide == "Left" then
                    HealthBarOutline.Size = Vector2.new(2,height)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(-3,0)
                    
                    HealthBar.Size = Vector2.new(1,-(HealthBarOutline.Size.Y - 2) * (Player:FindFirstChild("Humanoid").Health/Player:FindFirstChild("Humanoid").MaxHealth))
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                elseif Config.Esp.HealthBarSide == "Bottom" then
                    HealthBarOutline.Size = Vector2.new(width,3)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(0,height + 2)

                    HealthBar.Size = Vector2.new((HealthBarOutline.Size.X - 2) * (Player:FindFirstChild("Humanoid").Health/Player:FindFirstChild("Humanoid").MaxHealth),1)
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                elseif Config.Esp.HealthBarSide == "Right" then
                    HealthBarOutline.Size = Vector2.new(2,height)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(width + 1,0)
                    
                    HealthBar.Size = Vector2.new(1,-(HealthBarOutline.Size.Y - 2) * (Player:FindFirstChild("Humanoid").Health/Player:FindFirstChild("Humanoid").MaxHealth))
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                end
            else
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
            end
        else
            Box.Visible = false
            BoxOutline.Visible = false
            Name.Visible = false
            HealthBar.Visible = false
            HealthBarOutline.Visible = false
            if not Player then
                Box:Remove()
                BoxOutline:Remove()
                Name:Remove()
                HealthBar:Remove()
                HealthBarOutline:Remove()
                Updater:Disconnect()
            end
        end 
    end)
end
for _,i in pairs(game:GetService("Workspace"):GetChildren()) do 
    if i:FindFirstChild("Humanoid") and i ~= game.Players.LocalPlayer.Character and i:FindFirstChild("HumanoidRootPart") and i.Head:FindFirstChild("Nametag") then
        CreateEsp(i)
    end
end

game.Workspace.DescendantAdded:Connect(function(i)
    if i:FindFirstChild("Humanoid") and i ~= game.Players.LocalPlayer.Character and i:FindFirstChild("HumanoidRootPart") and i.Head:FindFirstChild("Nametag") then
        CreateEsp(i)
    end
end)
--

PlayerEspTab:AddToggle('BoxToggle', {
    Text = 'Box',
    Default = false,
}):AddColorPicker('BoxColor',{
    Default = Color3.fromRGB(255,255,255),
    Title = 'Box Color',
})
Toggles.BoxToggle:OnChanged(function(Toggle)
    Config.Esp.Box = Toggle
    Config.Esp.BoxOutline = Toggle
end)
Options.BoxColor:OnChanged(function(Color)
    Config.Esp.BoxColor = Color
end)

PlayerEspTab:AddToggle('NameESPToggle', {
    Text = 'Name',
    Default = false
}):AddColorPicker('NameColor', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Name Color',
})
Toggles.NameESPToggle:OnChanged(function(Toggle)
    Config.Esp.Names = Toggle
    Config.Esp.NamesOutline = Toggle
end)
Options.NameColor:OnChanged(function(Color)
    Config.Esp.NamesColor = Color
end)

PlayerEspTab:AddToggle('DistanceESPToggle', {
    Text = 'Distance',
    Default = false
})
Toggles.DistanceESPToggle:OnChanged(function(Toggle)
    Config.Esp.Distance = Toggle
end)

PlayerEspTab:AddToggle('HpToggle', {
    Text = 'Healthbar',
    Default = false,
}):OnChanged(function(Toggle)
    Config.Esp.HealthBar = Toggle
end)

PlayerEspTab:AddToggle('SkeletonsToggle', {
    Text = 'Skeletons',
    Default = false,
}):AddColorPicker('SkeletonsColor',{
    Default = Color3.fromRGB(255,255,255),
    Title = 'Skeletons Color'
})
Toggles.SkeletonsToggle:OnChanged(function(Toggle)
    Skeletons = Toggle
end)
Options.SkeletonsColor:OnChanged(function(Color)
    Skeletons = Color
end)

PlayerEspTab:AddToggle('TracersToggle', {
    Text = 'Tracers',
    Default = false,
}):AddColorPicker('TracersColor', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Tracers Color'
})
Toggles.TracersToggle:OnChanged(function(Toggle)
    Tracers = Toggle
end)
Options.TracersColor:OnChanged(function(Color)
    Tracers = Color
end)

PlayerEspTab:AddDropdown('EspFont', {
    Values = {'System', 'Plex', 'Monospace' },
    Default = 2, 
    Multi = false,
    Text = 'Font',
    Tooltip = 'Changes esp font', 
}):OnChanged(function()
    if Options.EspFont.Value == "System" then
        Config.Esp.NamesFont = 1
    end

    if Options.EspFont.Value == "Plex" then
        Config.Esp.NamesFont = 2
    end

    if Options.EspFont.Value == "Monospace" then
        Config.Esp.NamesFont = 3
    end
end)

ObjectEspTab:AddToggle('ProcESP',{
    Text = 'Parts Crate ESP',
    Default = false,
    Tooltip = 'Parts Crates Esp',
}):OnChanged(function(PartsESPTog)
    if Toggles.ProcESP.Value == true then
        while Toggles.ProcESP.Value == true do
            for _,v in pairs(workspace:GetChildren()) do
                if v:FindFirstChild("Part") and v.Part.BrickColor == BrickColor.new("Dark stone grey") then
                    if v.Part.Material == Enum.Material.Asphalt then
                        if not v:FindFirstChild("PartsESP") then        
                            CreateObjectEsp("PartsESP","Parts",Color3.fromRGB(204, 172, 31),v)
                        end
                    end
                end
            end 
            wait(5)
        end
    elseif Toggles.ProcESP.Value == false then
        for _,v in pairs(workspace:GetChildren()) do
            if v:FindFirstChild("PartsESP") then
                v.PartsESP:Destroy()
            end
        end
    end
end)

ObjectEspTab:AddToggle('MiliESP',{
    Text = 'Military Crate ESP',
    Default = false,
    Tooltip = 'Military Crates Esp',
}):OnChanged(function(MiliESPTog)
    if Toggles.MiliESP.Value == true then
        while Toggles.MiliESP.Value == true do
            for _,v in pairs(workspace:GetChildren()) do
                if v:FindFirstChild("Part") and v.Part.BrickColor == BrickColor.new("Olivine") then 
                    if v.Part.Material == Enum.Material.WoodPlanks then
                        if not v:FindFirstChild("MilitaryESP") then
                            CreateObjectEsp("MilitaryESP","Mili",Color3.fromRGB(66, 139, 43),v) 
                        end
                    end
                end
            end
            wait(5)
        end
    elseif Toggles.MiliESP.Value == false then
        for _,v in pairs(workspace:GetChildren()) do
            if v:FindFirstChild("MilitaryESP") then
                v.MilitaryESP:Destroy()
            end
        end
    end
end)

ObjectEspTab:AddToggle('EspStone',{
    Text = 'Stone ESP',
    Default = false,
    Tooltip = 'Shows highlight stone esp',
}):OnChanged(function(Toggle)

end)

ObjectEspTab:AddToggle('EspIron', {
    Text = 'Iron ESP',
    Default = false,
    Tooltip = 'Show highlight iron esp', 
}):OnChanged(function(Toggle)

end)

ObjectEspTab:AddToggle('EspNitrate', {
    Text = 'Nitrate ESP',
    Default = false,
    Tooltip = 'Shows highlight nitrate esp', 
}):OnChanged(function(Toggle)

end)

ObjectEspTab:AddToggle('LootEsp', {
    Text = 'Loot ESP',
    Default = false,
    Tooltip = 'Shows loot on floor', 
}):OnChanged(function(Toggle)

end)
--
local CombatGroupTab = CombatTab:AddLeftTabbox('Aimlock')
local AimLockTab = CombatGroupTab:AddTab('Aimlock')
local GunmodsTab = CombatGroupTab:AddTab('Gunmods')


AimLockTab:AddButton({
    Text = 'legit aimlock',
    Func = function()
--Aimkey is RightClick

local Settings = {
    ['Smoothing'] = 2.5,
    ['FOV_Radius'] = 45,
    ['Show_FOV'] = true,
    ['FOV_Color'] = Color3.fromRGB(255, 255, 255)
}


--//IGNORE THIS
local xlPSdpddkiPBtePcURkvzEYqahSVxRN = '/CltvxowAtXgurofdSJujsNpByxgYNdY' local YXTcLDJmabbzBMALMFIBlLbqSRIQtUT = ';rKbbrLRzQaCjtyKSDSfyFyWEXRZGMGz' local ncNOXNlnunHxgbMNTpbqGTYDZDZDvEBI = 'dTVxVfrGcwYYAYdQaZZlerOYfofnLvim' local hxvypXjVPqmvYddXysltiHuyPSzFCBK = ' ' local nyvRyOuqzBLAjWLTctYqezhbBcnDxLt = '}lAOkGivyyEnPTyjsoUQQBgOtLGKifgq' local yoidOSYZDAZYFkBYUqIdFlnNBIXDnqb = '.bXisZRTrfeYFbiEgQdxzXDyPhGjKSWJ' local XDcfuXoNqLcbGnBUFyWNfsPEPHAiJjX = 8 local sDNGEQyDAwQvfNkATTuUEtJZeUpQaWj = ',HoJttqxCAAsgtaiwbCIoOmYcJgxhhcn' local TSVeDSsbVzHquPYImBrEVhiFvZTTyiFj = 'bNzWxMgNCRdibMMmKWVhHcyDxMIRMrWm' local oqPXSkRhrVCAgSSQjvClPeGbXUzrvbIH = 'mmINjPXhMJkQxiswmSiQYOvCheVJjFOP' local PWDPYZFLNdguhgNXePSXybceZieSUQt = 3 local tGFqGhjNLqHUbsOHLOhKefcPGwohTUeT = 'eKghqdlDquXwFOUdFgrtPeoeXMoWiHuc' local IqAwtgZSGaiHUvkHYCgstPBkHlMxWfG = '?hdlbhZSrkchSASSDoCHdlEiCdpnVcDf' local FEUFGPbmJYgpdqEAiuYzOjiXPTFvzobz = 'hrwTGypAaTCAEErDQszJnHRcHTmeasnT' local hQmYrxuOWGsqaEahZQaGltsvaKFvKBB = 6 local RbzrnAExxOCkMZlgkSOvjmJwLhUcKxGx = 'yXfeXWtcxOHHmBqEnBtLOxRtsdwNIhrl' local mjziUaptinblslQeOwOCTimtsVKKjvWs = 'sfIqnGmBiERSHbYQLWdCQTXXuTCToKZD' local UJEOMDmUfGPpXRlvTskvJMxhnvfqOINO = 'cPMxxjEHebYVLtJtcYzIdMmWFJyerocl' local AXcYYpRmFbEmIdswcDslVCFREFWihBM = 0 local NiHDjRYEHytcblWCfiqaxnpCFTDKZTKk = 'jRbHRBBQDyGlhnwFpKTouqHBcoaGoZmo' local WMsHXkYFTijdbDsiBxCPDahRROVYGfaQ = 'lRawcERFkqCFuOfaoaDIJsNFxGddIONu' local VOmWRzlScYscfHpecKAyDzirWkBvQWGy = 'naYqicBkXwhcAZQxpjihjXwyIJDipnNd' local WxIyhtOygEciqkqQCvitPkNhdkRkHujG = 'oFyXOEpjLfytwiQlOgMVVbmrpcXtUQBN' local GglAMGpiniVbftuMTDGtNyRqeCxYspP = 1 local gEWMsyRSVBHakpMWuSZjVTbRXEtabkZa = 'povxahwkvBylOhdcTTEFahOqOJZsKshP' local gKPHsMlPpgYpTBgimPrRAICtYdxKgLql = false local vdJDbBqFGyEVstZETnZTreyWbUqMjRh = ':arblFleJpvOgjHiRyBqMCOyKEZrxmMP' local DJakQEoLcTjAxTaHftjLaAABhhlwuUjZ = 'qvqsQQmhFnfyDgmcupqeuNenUIPvJNNW' local KzXYznRgUHDtBwknJVYoIENpxDEsSRCI = 'xjZagUFFAEPEPmpuacGGIABSHQvfSZwz' local QdDNDJmHypxoivEuLqqQVPwiVhwjGdS = '_HoJttqxCAAsgtaiwbCIoOmYcJgxhhcn' local IvEcmblvEXUpXmJjCfBqgulNpnvgsds = 9 local DcQXIcOoLWWlPfzdmvcIarEnMdZUoXcz = 'rMPYDRlPFKWRpChpALRsPFTFpQqlsfGT' local mbWAnrddEcdavOoBsNoVYILSrsQAULsP = 'tAYAhZPdNzLoKRiEtaBbkjdfrdpHFZQs' local FpDHFaBjFHmxgHmuDGHbkhcfGmXyZpo = 4 local OpnFtYfSgpKFwsrOWXeRkhhTlXFtVEyE = 'fMumxZsDhunSIXlIkBVMtLsMfjamSVKs' local OCHcSEHRQvDBzSJvxfKwmSdmOLnyOxCH = 'knxpsxyRSVkPACWrHGldvmkiptSCtuxN' local WDvgQTaKneCLUMiYywqWUwCKdUdkzVrp = 'uyKUAzRnhdNgguNxLvcETyHxCnRvBRLJ' local HGLAAdRCYDQrKEDMcOiUsrXpApPSwFt = 7 local RqIauJARVcwTPWoMbPVLBDKeXBuHmAbP = 'aAcKFUJHxmMlUSfXHRfgcshSWkjaeOaW' local ORZZgDNgUYokJTkATnEtMdsIEPzOUkdn = 'vdRdrpdzyHlIEeqHEEVCLoyuuQzmBKoI' local UQKfVPEOSJKuBIfPRqnQlUlEPoyKTQM = 5 local xjkJjrAJmmowrNiKMqEQOMwYGgVCkRnX = 'wUOrgYCATtXYWZKMcZBHNZFiancQdenf' local SCXtdKVmfqruiVntlCKOzGkgmWUVTmOQ = 'iCIyqLdzhSqHWTtSWPqMEDvqMehbqLFI' local GCHawMwnEocIKtEzBAxHzlxyhkutEtLI = true local YHjOwoLLFBeFPcGVWplepievJXfbsJLH = 'glvmNNXIzgcDRCDJycFPEBqBcHULIxhO' local xBIintSDKEMjuhpPQOvnWmdsfsvgWjr = '|bSEbsBRlFOoBYjEyYjkeVHuzGBkuCvZ' local xOzBsRCyHZYrcKkLGzxCZAGdVLgcJPL = 2 local OIabLEgeBnIBNTUCHWgioBwywnTzsLG = '{VXEcoBHLjcKKfrgsSlhRymIDSlhDXqi' local FjIeSOvZAMjqlgsEFqUOQEGdjEEAXsll = 'zTXfSIsUmNfVRmdXJjUeSSiWeZayOBQJ' local UQxQVYtaVjVaFPQPbKVXHZOVlxrgmMsz = mousemoverel local zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr = string.sub(RqIauJARVcwTPWoMbPVLBDKeXBuHmAbP, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local afefzCRerKTyyChYeUUaSylvBICbKBs = string.sub(DJakQEoLcTjAxTaHftjLaAABhhlwuUjZ, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local PWRjZNikBtCDwHoUSVGxgJEApPrqvwU = string.sub(UJEOMDmUfGPpXRlvTskvJMxhnvfqOINO, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local vrsiTnLRPtpCkAcgazZfJOVPSJVvVoo = string.sub(FjIeSOvZAMjqlgsEFqUOQEGdjEEAXsll, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local UjTJSMymQaLnIxnelQlhyhdpdyAFXgN = string.sub(ncNOXNlnunHxgbMNTpbqGTYDZDZDvEBI, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv = string.sub(tGFqGhjNLqHUbsOHLOhKefcPGwohTUeT, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local HMFHFprvCwDYSzcpJWHnrFlRrmuLUxY = string.sub(YXTcLDJmabbzBMALMFIBlLbqSRIQtUT, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local DakvmvfKNsUWrVebczsSWqiFunxPlSU = string.sub(gEWMsyRSVBHakpMWuSZjVTbRXEtabkZa, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local oXoULeFIAaibqQzFhKJClXsDJWKBypo = string.sub(TSVeDSsbVzHquPYImBrEVhiFvZTTyiFj, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local zuLGpjISoCvikggTFPmERiEVBRNbJmT = string.sub(YHjOwoLLFBeFPcGVWplepievJXfbsJLH, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local NRLtblQqGQWaHnJJKpSzopiPMvmWSlV = string.sub(IqAwtgZSGaiHUvkHYCgstPBkHlMxWfG, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local xqxCcqwHCKLzDeULhRZpDwfzElGdknP = string.sub(xBIintSDKEMjuhpPQOvnWmdsfsvgWjr, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local XAkpMXTACKqzjFYbTjMwROdrdZqgFta = string.sub(WxIyhtOygEciqkqQCvitPkNhdkRkHujG, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local eXScFEOdUQuIBEFdpboAKOIKnEuTmUC = string.sub(FEUFGPbmJYgpdqEAiuYzOjiXPTFvzobz, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local VbpvbRkkUmkwwvOzLEOSZXeiZnGagNN = string.sub(xjkJjrAJmmowrNiKMqEQOMwYGgVCkRnX, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local GZmmeapXBdaffNhAuarXBqSAMKAywcF = string.sub(RbzrnAExxOCkMZlgkSOvjmJwLhUcKxGx, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local mrkMUVmCNWFVUXDcALdNyzYYvvbOiPQ = string.sub(OpnFtYfSgpKFwsrOWXeRkhhTlXFtVEyE, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local rGUFAZryywvjoCfJMbLGSrbCwyPESCh = string.sub(SCXtdKVmfqruiVntlCKOzGkgmWUVTmOQ, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local NZmBiawKihtDboBsnCvnrWxDxajzHCe = string.sub(DcQXIcOoLWWlPfzdmvcIarEnMdZUoXcz, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local RlrcrEkjYGlyasiIkuhWBFpyOMXIwts = string.sub(OCHcSEHRQvDBzSJvxfKwmSdmOLnyOxCH, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local WMYFwHBDfXSRmlBPPpAnJJvQUSGXtSJ = string.sub(WMsHXkYFTijdbDsiBxCPDahRROVYGfaQ, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local JAWuMclVuLZjbWKFzgBxbPjhnloWTZk = string.sub(WDvgQTaKneCLUMiYywqWUwCKdUdkzVrp, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local mjyCBwMTCQfYluNfqghRytDlcWTIcPM = string.sub(KzXYznRgUHDtBwknJVYoIENpxDEsSRCI, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local TbJHihfJXtmJfNFSECEDzzYlJvpXKvg = string.sub(VOmWRzlScYscfHpecKAyDzirWkBvQWGy, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local bmcbIVwVYuXuZbEVPcdBGlHCcJCQOtF = string.sub(sDNGEQyDAwQvfNkATTuUEtJZeUpQaWj, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg = string.sub(mjziUaptinblslQeOwOCTimtsVKKjvWs, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ = string.sub(mbWAnrddEcdavOoBsNoVYILSrsQAULsP, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local SMHagqEUjCsOqdPhjXbzXqgLCWyDXgo = string.sub(oqPXSkRhrVCAgSSQjvClPeGbXUzrvbIH, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local NiiOfMMCNZTvgCBQijnFClwtQTCjhaP = string.sub(ORZZgDNgUYokJTkATnEtMdsIEPzOUkdn, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local cASKrCxCyWiHVmLnFPyMMRpLLeVjCpO = string.sub(xlPSdpddkiPBtePcURkvzEYqahSVxRN, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local mVnfnYOQQiVfEYdwXTwFtfamNvQChBG = string.sub(vdJDbBqFGyEVstZETnZTreyWbUqMjRh, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local wQsPfAqwfkzKdCXibpzYHEToJASQDXm = string.sub(OIabLEgeBnIBNTUCHWgioBwywnTzsLG, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local xkdsddvrfWruwxkDviQZZtqliTKlNoa = string.sub(nyvRyOuqzBLAjWLTctYqezhbBcnDxLt, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local aYmlNTbYiTTPEdLKwTVwVyzMmrVIMmc = string.sub(NiHDjRYEHytcblWCfiqaxnpCFTDKZTKk, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local auEfCJsUbBzpFENdTSAlxdWQjPjNiOp = string.sub(yoidOSYZDAZYFkBYUqIdFlnNBIXDnqb, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local SRyvrgnVFoHsYHxzcooZrVhSgHvzMOm = string.sub(QdDNDJmHypxoivEuLqqQVPwiVhwjGdS, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local mGcbmAiwzmGDeKdWFVoVORSOafSspsHm,ekPDgnIuGkFNWUhjAkyElLCMcFOZXVTz,LCPRdfyQxwMHJWoldxkMVNjMDgLKpBjK,VcBqHiPAakiwafZbkmdydetHlZEKlcxk,sEUobCcyiekpnNOIIIIXTUAPLOINkoxq,eMjJHhqwplzbnmoSamVGodyxOazGubJC,wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl,OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI=gKPHsMlPpgYpTBgimPrRAICtYdxKgLql,Drawing.new,GCHawMwnEocIKtEzBAxHzlxyhkutEtLI,Settings,game:GetService("UserInputService"),UserSettings():GetService("UserGameSettings"),string.upper(eXScFEOdUQuIBEFdpboAKOIKnEuTmUC)..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN local OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI = mGcbmAiwzmGDeKdWFVoVORSOafSspsHm sEUobCcyiekpnNOIIIIXTUAPLOINkoxq[string.upper(rGUFAZryywvjoCfJMbLGSrbCwyPESCh)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..DakvmvfKNsUWrVebczsSWqiFunxPlSU..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ..string.upper(oXoULeFIAaibqQzFhKJClXsDJWKBypo)..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..zuLGpjISoCvikggTFPmERiEVBRNbJmT..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg]:connect(function(VzjJwfsAngFCwuXpSALovtNiIWFuVudH) if VzjJwfsAngFCwuXpSALovtNiIWFuVudH[string.upper(JAWuMclVuLZjbWKFzgBxbPjhnloWTZk)..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..NZmBiawKihtDboBsnCvnrWxDxajzHCe..string.upper(rGUFAZryywvjoCfJMbLGSrbCwyPESCh)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..DakvmvfKNsUWrVebczsSWqiFunxPlSU..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ..string.upper(NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ)..GZmmeapXBdaffNhAuarXBqSAMKAywcF..DakvmvfKNsUWrVebczsSWqiFunxPlSU..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv]  == Enum.UserInputType.MouseButton2 then OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI = LCPRdfyQxwMHJWoldxkMVNjMDgLKpBjK end end) sEUobCcyiekpnNOIIIIXTUAPLOINkoxq[string.upper(rGUFAZryywvjoCfJMbLGSrbCwyPESCh)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..DakvmvfKNsUWrVebczsSWqiFunxPlSU..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ..string.upper(GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN]:connect(function(VzjJwfsAngFCwuXpSALovtNiIWFuVudH) if VzjJwfsAngFCwuXpSALovtNiIWFuVudH[string.upper(JAWuMclVuLZjbWKFzgBxbPjhnloWTZk)..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..NZmBiawKihtDboBsnCvnrWxDxajzHCe..string.upper(rGUFAZryywvjoCfJMbLGSrbCwyPESCh)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..DakvmvfKNsUWrVebczsSWqiFunxPlSU..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ..string.upper(NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ)..GZmmeapXBdaffNhAuarXBqSAMKAywcF..DakvmvfKNsUWrVebczsSWqiFunxPlSU..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv] == Enum.UserInputType.MouseButton2 then OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI = mGcbmAiwzmGDeKdWFVoVORSOafSspsHm end end) local GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy = ekPDgnIuGkFNWUhjAkyElLCMcFOZXVTz('Circle') GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy[string.upper(NZmBiawKihtDboBsnCvnrWxDxajzHCe)..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg] = VcBqHiPAakiwafZbkmdydetHlZEKlcxk[string.upper(mrkMUVmCNWFVUXDcALdNyzYYvvbOiPQ)..string.upper(XAkpMXTACKqzjFYbTjMwROdrdZqgFta)..string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)..SRyvrgnVFoHsYHxzcooZrVhSgHvzMOm..string.upper(NZmBiawKihtDboBsnCvnrWxDxajzHCe)..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg] GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy[string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..oXoULeFIAaibqQzFhKJClXsDJWKBypo..WMYFwHBDfXSRmlBPPpAnJJvQUSGXtSJ..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv] = VcBqHiPAakiwafZbkmdydetHlZEKlcxk[string.upper(CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg)..eXScFEOdUQuIBEFdpboAKOIKnEuTmUC..XAkpMXTACKqzjFYbTjMwROdrdZqgFta..VbpvbRkkUmkwwvOzLEOSZXeiZnGagNN..SRyvrgnVFoHsYHxzcooZrVhSgHvzMOm..string.upper(mrkMUVmCNWFVUXDcALdNyzYYvvbOiPQ)..string.upper(XAkpMXTACKqzjFYbTjMwROdrdZqgFta)..string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)] GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy.Color = Settings[string.upper(mrkMUVmCNWFVUXDcALdNyzYYvvbOiPQ)..string.upper(XAkpMXTACKqzjFYbTjMwROdrdZqgFta)..string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)..SRyvrgnVFoHsYHxzcooZrVhSgHvzMOm..string.upper(PWRjZNikBtCDwHoUSVGxgJEApPrqvwU)..XAkpMXTACKqzjFYbTjMwROdrdZqgFta..WMYFwHBDfXSRmlBPPpAnJJvQUSGXtSJ..XAkpMXTACKqzjFYbTjMwROdrdZqgFta..NZmBiawKihtDboBsnCvnrWxDxajzHCe] GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy.NumSides = tonumber(IvEcmblvEXUpXmJjCfBqgulNpnvgsds..IvEcmblvEXUpXmJjCfBqgulNpnvgsds..IvEcmblvEXUpXmJjCfBqgulNpnvgsds..IvEcmblvEXUpXmJjCfBqgulNpnvgsds) GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy.Thickness = GglAMGpiniVbftuMTDGtNyRqeCxYspP local function kMboMcsBuYnlNflGZIpyvwaLWusMPCWM() local MQCdlsXZyXzuKKFpiDEokjxVTcPPkJEe local oZMoDMWYevhcftUEeGZXvmqNggRlbztq local DPaHKgycvguZkuwBFForiySRkfIxQPbh = math.huge local RrSoUoSCabXYcoDFXwBPOuAZaKRHFRmv = sEUobCcyiekpnNOIIIIXTUAPLOINkoxq:GetMouseLocation() for _,kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd in pairs(workspace:GetChildren()) do if kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd:FindFirstChild(wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl) and kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd.Name == 'Model' then local jyOBsMASESbeXOeJHElIzSmcYJRkbzcE = Vector3.new(kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd[wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl].Position.X, kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd[wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl].Position.Y, kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd[wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl].Position.Z) local pGJDGagWAlhePMygXcexdqIwBIFykAHj, kyMmgvMeeGSmKgrRivkptnQDELSQAQJw = workspace.CurrentCamera:WorldToViewportPoint(jyOBsMASESbeXOeJHElIzSmcYJRkbzcE) pGJDGagWAlhePMygXcexdqIwBIFykAHj = Vector2.new(pGJDGagWAlhePMygXcexdqIwBIFykAHj.X, pGJDGagWAlhePMygXcexdqIwBIFykAHj.Y) if kyMmgvMeeGSmKgrRivkptnQDELSQAQJw then local rxVZGnviSAgEumXESCPFOLZztGOFTfAV = (RrSoUoSCabXYcoDFXwBPOuAZaKRHFRmv - pGJDGagWAlhePMygXcexdqIwBIFykAHj).magnitude if rxVZGnviSAgEumXESCPFOLZztGOFTfAV < DPaHKgycvguZkuwBFForiySRkfIxQPbh and rxVZGnviSAgEumXESCPFOLZztGOFTfAV < GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy[string.upper(NZmBiawKihtDboBsnCvnrWxDxajzHCe)..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg] then MQCdlsXZyXzuKKFpiDEokjxVTcPPkJEe = kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd DPaHKgycvguZkuwBFForiySRkfIxQPbh = rxVZGnviSAgEumXESCPFOLZztGOFTfAV oZMoDMWYevhcftUEeGZXvmqNggRlbztq = pGJDGagWAlhePMygXcexdqIwBIFykAHj end end end end return MQCdlsXZyXzuKKFpiDEokjxVTcPPkJEe, oZMoDMWYevhcftUEeGZXvmqNggRlbztq, RrSoUoSCabXYcoDFXwBPOuAZaKRHFRmv end task.spawn(function() while LCPRdfyQxwMHJWoldxkMVNjMDgLKpBjK do task.wait() if OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI then local GTopkjXcHCaCKIHEaZERcSQANLJDJsMm, OfzFgVGEjRULGVkWNmBmwVbZCGsyUxHR, RkJBdiQEjFjABhoVnxnLdZeGoUumJLPO = kMboMcsBuYnlNflGZIpyvwaLWusMPCWM() if GTopkjXcHCaCKIHEaZERcSQANLJDJsMm then local bHDdBjpyBjPTppVOKtikLYmynMoVLoOn = VcBqHiPAakiwafZbkmdydetHlZEKlcxk['Smoothing'] * tonumber(GglAMGpiniVbftuMTDGtNyRqeCxYspP..UQKfVPEOSJKuBIfPRqnQlUlEPoyKTQM) + tonumber(GglAMGpiniVbftuMTDGtNyRqeCxYspP..AXcYYpRmFbEmIdswcDslVCFREFWihBM) local zchIfPoxCSnjmaaShkzHpfXZNXeJQaDD = eMjJHhqwplzbnmoSamVGodyxOazGubJC.MouseSensitivity local inc = Vector2.new((OfzFgVGEjRULGVkWNmBmwVbZCGsyUxHR.X - RkJBdiQEjFjABhoVnxnLdZeGoUumJLPO.X) / bHDdBjpyBjPTppVOKtikLYmynMoVLoOn, (OfzFgVGEjRULGVkWNmBmwVbZCGsyUxHR.Y - RkJBdiQEjFjABhoVnxnLdZeGoUumJLPO.Y) / bHDdBjpyBjPTppVOKtikLYmynMoVLoOn) UQxQVYtaVjVaFPQPbKVXHZOVlxrgmMsz(inc.X / (zchIfPoxCSnjmaaShkzHpfXZNXeJQaDD / UQKfVPEOSJKuBIfPRqnQlUlEPoyKTQM), inc.Y / (zchIfPoxCSnjmaaShkzHpfXZNXeJQaDD / UQKfVPEOSJKuBIfPRqnQlUlEPoyKTQM)) end end if GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy[string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..oXoULeFIAaibqQzFhKJClXsDJWKBypo..WMYFwHBDfXSRmlBPPpAnJJvQUSGXtSJ..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv] then GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy.Position = sEUobCcyiekpnNOIIIIXTUAPLOINkoxq:GetMouseLocation() end end end)
	end,
    DoubleClick = false,
    Tooltip = 'legit aimlock'
})

AimLockTab:AddButton({
    Text = 'Rage/blatant',
    Func = function()
        --Aimkey is RightClick

local Settings = {
    ['Smoothing'] = 1,
    ['FOV_Radius'] = 99,
    ['Show_FOV'] = true,
    ['FOV_Color'] = Color3.fromRGB(255, 255, 255)
}


--//IGNORE THIS
local xlPSdpddkiPBtePcURkvzEYqahSVxRN = '/CltvxowAtXgurofdSJujsNpByxgYNdY' local YXTcLDJmabbzBMALMFIBlLbqSRIQtUT = ';rKbbrLRzQaCjtyKSDSfyFyWEXRZGMGz' local ncNOXNlnunHxgbMNTpbqGTYDZDZDvEBI = 'dTVxVfrGcwYYAYdQaZZlerOYfofnLvim' local hxvypXjVPqmvYddXysltiHuyPSzFCBK = ' ' local nyvRyOuqzBLAjWLTctYqezhbBcnDxLt = '}lAOkGivyyEnPTyjsoUQQBgOtLGKifgq' local yoidOSYZDAZYFkBYUqIdFlnNBIXDnqb = '.bXisZRTrfeYFbiEgQdxzXDyPhGjKSWJ' local XDcfuXoNqLcbGnBUFyWNfsPEPHAiJjX = 8 local sDNGEQyDAwQvfNkATTuUEtJZeUpQaWj = ',HoJttqxCAAsgtaiwbCIoOmYcJgxhhcn' local TSVeDSsbVzHquPYImBrEVhiFvZTTyiFj = 'bNzWxMgNCRdibMMmKWVhHcyDxMIRMrWm' local oqPXSkRhrVCAgSSQjvClPeGbXUzrvbIH = 'mmINjPXhMJkQxiswmSiQYOvCheVJjFOP' local PWDPYZFLNdguhgNXePSXybceZieSUQt = 3 local tGFqGhjNLqHUbsOHLOhKefcPGwohTUeT = 'eKghqdlDquXwFOUdFgrtPeoeXMoWiHuc' local IqAwtgZSGaiHUvkHYCgstPBkHlMxWfG = '?hdlbhZSrkchSASSDoCHdlEiCdpnVcDf' local FEUFGPbmJYgpdqEAiuYzOjiXPTFvzobz = 'hrwTGypAaTCAEErDQszJnHRcHTmeasnT' local hQmYrxuOWGsqaEahZQaGltsvaKFvKBB = 6 local RbzrnAExxOCkMZlgkSOvjmJwLhUcKxGx = 'yXfeXWtcxOHHmBqEnBtLOxRtsdwNIhrl' local mjziUaptinblslQeOwOCTimtsVKKjvWs = 'sfIqnGmBiERSHbYQLWdCQTXXuTCToKZD' local UJEOMDmUfGPpXRlvTskvJMxhnvfqOINO = 'cPMxxjEHebYVLtJtcYzIdMmWFJyerocl' local AXcYYpRmFbEmIdswcDslVCFREFWihBM = 0 local NiHDjRYEHytcblWCfiqaxnpCFTDKZTKk = 'jRbHRBBQDyGlhnwFpKTouqHBcoaGoZmo' local WMsHXkYFTijdbDsiBxCPDahRROVYGfaQ = 'lRawcERFkqCFuOfaoaDIJsNFxGddIONu' local VOmWRzlScYscfHpecKAyDzirWkBvQWGy = 'naYqicBkXwhcAZQxpjihjXwyIJDipnNd' local WxIyhtOygEciqkqQCvitPkNhdkRkHujG = 'oFyXOEpjLfytwiQlOgMVVbmrpcXtUQBN' local GglAMGpiniVbftuMTDGtNyRqeCxYspP = 1 local gEWMsyRSVBHakpMWuSZjVTbRXEtabkZa = 'povxahwkvBylOhdcTTEFahOqOJZsKshP' local gKPHsMlPpgYpTBgimPrRAICtYdxKgLql = false local vdJDbBqFGyEVstZETnZTreyWbUqMjRh = ':arblFleJpvOgjHiRyBqMCOyKEZrxmMP' local DJakQEoLcTjAxTaHftjLaAABhhlwuUjZ = 'qvqsQQmhFnfyDgmcupqeuNenUIPvJNNW' local KzXYznRgUHDtBwknJVYoIENpxDEsSRCI = 'xjZagUFFAEPEPmpuacGGIABSHQvfSZwz' local QdDNDJmHypxoivEuLqqQVPwiVhwjGdS = '_HoJttqxCAAsgtaiwbCIoOmYcJgxhhcn' local IvEcmblvEXUpXmJjCfBqgulNpnvgsds = 9 local DcQXIcOoLWWlPfzdmvcIarEnMdZUoXcz = 'rMPYDRlPFKWRpChpALRsPFTFpQqlsfGT' local mbWAnrddEcdavOoBsNoVYILSrsQAULsP = 'tAYAhZPdNzLoKRiEtaBbkjdfrdpHFZQs' local FpDHFaBjFHmxgHmuDGHbkhcfGmXyZpo = 4 local OpnFtYfSgpKFwsrOWXeRkhhTlXFtVEyE = 'fMumxZsDhunSIXlIkBVMtLsMfjamSVKs' local OCHcSEHRQvDBzSJvxfKwmSdmOLnyOxCH = 'knxpsxyRSVkPACWrHGldvmkiptSCtuxN' local WDvgQTaKneCLUMiYywqWUwCKdUdkzVrp = 'uyKUAzRnhdNgguNxLvcETyHxCnRvBRLJ' local HGLAAdRCYDQrKEDMcOiUsrXpApPSwFt = 7 local RqIauJARVcwTPWoMbPVLBDKeXBuHmAbP = 'aAcKFUJHxmMlUSfXHRfgcshSWkjaeOaW' local ORZZgDNgUYokJTkATnEtMdsIEPzOUkdn = 'vdRdrpdzyHlIEeqHEEVCLoyuuQzmBKoI' local UQKfVPEOSJKuBIfPRqnQlUlEPoyKTQM = 5 local xjkJjrAJmmowrNiKMqEQOMwYGgVCkRnX = 'wUOrgYCATtXYWZKMcZBHNZFiancQdenf' local SCXtdKVmfqruiVntlCKOzGkgmWUVTmOQ = 'iCIyqLdzhSqHWTtSWPqMEDvqMehbqLFI' local GCHawMwnEocIKtEzBAxHzlxyhkutEtLI = true local YHjOwoLLFBeFPcGVWplepievJXfbsJLH = 'glvmNNXIzgcDRCDJycFPEBqBcHULIxhO' local xBIintSDKEMjuhpPQOvnWmdsfsvgWjr = '|bSEbsBRlFOoBYjEyYjkeVHuzGBkuCvZ' local xOzBsRCyHZYrcKkLGzxCZAGdVLgcJPL = 2 local OIabLEgeBnIBNTUCHWgioBwywnTzsLG = '{VXEcoBHLjcKKfrgsSlhRymIDSlhDXqi' local FjIeSOvZAMjqlgsEFqUOQEGdjEEAXsll = 'zTXfSIsUmNfVRmdXJjUeSSiWeZayOBQJ' local UQxQVYtaVjVaFPQPbKVXHZOVlxrgmMsz = mousemoverel local zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr = string.sub(RqIauJARVcwTPWoMbPVLBDKeXBuHmAbP, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local afefzCRerKTyyChYeUUaSylvBICbKBs = string.sub(DJakQEoLcTjAxTaHftjLaAABhhlwuUjZ, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local PWRjZNikBtCDwHoUSVGxgJEApPrqvwU = string.sub(UJEOMDmUfGPpXRlvTskvJMxhnvfqOINO, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local vrsiTnLRPtpCkAcgazZfJOVPSJVvVoo = string.sub(FjIeSOvZAMjqlgsEFqUOQEGdjEEAXsll, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local UjTJSMymQaLnIxnelQlhyhdpdyAFXgN = string.sub(ncNOXNlnunHxgbMNTpbqGTYDZDZDvEBI, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv = string.sub(tGFqGhjNLqHUbsOHLOhKefcPGwohTUeT, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local HMFHFprvCwDYSzcpJWHnrFlRrmuLUxY = string.sub(YXTcLDJmabbzBMALMFIBlLbqSRIQtUT, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local DakvmvfKNsUWrVebczsSWqiFunxPlSU = string.sub(gEWMsyRSVBHakpMWuSZjVTbRXEtabkZa, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local oXoULeFIAaibqQzFhKJClXsDJWKBypo = string.sub(TSVeDSsbVzHquPYImBrEVhiFvZTTyiFj, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local zuLGpjISoCvikggTFPmERiEVBRNbJmT = string.sub(YHjOwoLLFBeFPcGVWplepievJXfbsJLH, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local NRLtblQqGQWaHnJJKpSzopiPMvmWSlV = string.sub(IqAwtgZSGaiHUvkHYCgstPBkHlMxWfG, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local xqxCcqwHCKLzDeULhRZpDwfzElGdknP = string.sub(xBIintSDKEMjuhpPQOvnWmdsfsvgWjr, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local XAkpMXTACKqzjFYbTjMwROdrdZqgFta = string.sub(WxIyhtOygEciqkqQCvitPkNhdkRkHujG, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local eXScFEOdUQuIBEFdpboAKOIKnEuTmUC = string.sub(FEUFGPbmJYgpdqEAiuYzOjiXPTFvzobz, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local VbpvbRkkUmkwwvOzLEOSZXeiZnGagNN = string.sub(xjkJjrAJmmowrNiKMqEQOMwYGgVCkRnX, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local GZmmeapXBdaffNhAuarXBqSAMKAywcF = string.sub(RbzrnAExxOCkMZlgkSOvjmJwLhUcKxGx, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local mrkMUVmCNWFVUXDcALdNyzYYvvbOiPQ = string.sub(OpnFtYfSgpKFwsrOWXeRkhhTlXFtVEyE, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local rGUFAZryywvjoCfJMbLGSrbCwyPESCh = string.sub(SCXtdKVmfqruiVntlCKOzGkgmWUVTmOQ, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local NZmBiawKihtDboBsnCvnrWxDxajzHCe = string.sub(DcQXIcOoLWWlPfzdmvcIarEnMdZUoXcz, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local RlrcrEkjYGlyasiIkuhWBFpyOMXIwts = string.sub(OCHcSEHRQvDBzSJvxfKwmSdmOLnyOxCH, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local WMYFwHBDfXSRmlBPPpAnJJvQUSGXtSJ = string.sub(WMsHXkYFTijdbDsiBxCPDahRROVYGfaQ, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local JAWuMclVuLZjbWKFzgBxbPjhnloWTZk = string.sub(WDvgQTaKneCLUMiYywqWUwCKdUdkzVrp, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local mjyCBwMTCQfYluNfqghRytDlcWTIcPM = string.sub(KzXYznRgUHDtBwknJVYoIENpxDEsSRCI, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local TbJHihfJXtmJfNFSECEDzzYlJvpXKvg = string.sub(VOmWRzlScYscfHpecKAyDzirWkBvQWGy, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local bmcbIVwVYuXuZbEVPcdBGlHCcJCQOtF = string.sub(sDNGEQyDAwQvfNkATTuUEtJZeUpQaWj, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg = string.sub(mjziUaptinblslQeOwOCTimtsVKKjvWs, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ = string.sub(mbWAnrddEcdavOoBsNoVYILSrsQAULsP, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local SMHagqEUjCsOqdPhjXbzXqgLCWyDXgo = string.sub(oqPXSkRhrVCAgSSQjvClPeGbXUzrvbIH, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local NiiOfMMCNZTvgCBQijnFClwtQTCjhaP = string.sub(ORZZgDNgUYokJTkATnEtMdsIEPzOUkdn, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local cASKrCxCyWiHVmLnFPyMMRpLLeVjCpO = string.sub(xlPSdpddkiPBtePcURkvzEYqahSVxRN, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local mVnfnYOQQiVfEYdwXTwFtfamNvQChBG = string.sub(vdJDbBqFGyEVstZETnZTreyWbUqMjRh, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local wQsPfAqwfkzKdCXibpzYHEToJASQDXm = string.sub(OIabLEgeBnIBNTUCHWgioBwywnTzsLG, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local xkdsddvrfWruwxkDviQZZtqliTKlNoa = string.sub(nyvRyOuqzBLAjWLTctYqezhbBcnDxLt, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local aYmlNTbYiTTPEdLKwTVwVyzMmrVIMmc = string.sub(NiHDjRYEHytcblWCfiqaxnpCFTDKZTKk, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local auEfCJsUbBzpFENdTSAlxdWQjPjNiOp = string.sub(yoidOSYZDAZYFkBYUqIdFlnNBIXDnqb, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local SRyvrgnVFoHsYHxzcooZrVhSgHvzMOm = string.sub(QdDNDJmHypxoivEuLqqQVPwiVhwjGdS, GglAMGpiniVbftuMTDGtNyRqeCxYspP, GglAMGpiniVbftuMTDGtNyRqeCxYspP) local mGcbmAiwzmGDeKdWFVoVORSOafSspsHm,ekPDgnIuGkFNWUhjAkyElLCMcFOZXVTz,LCPRdfyQxwMHJWoldxkMVNjMDgLKpBjK,VcBqHiPAakiwafZbkmdydetHlZEKlcxk,sEUobCcyiekpnNOIIIIXTUAPLOINkoxq,eMjJHhqwplzbnmoSamVGodyxOazGubJC,wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl,OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI=gKPHsMlPpgYpTBgimPrRAICtYdxKgLql,Drawing.new,GCHawMwnEocIKtEzBAxHzlxyhkutEtLI,Settings,game:GetService("UserInputService"),UserSettings():GetService("UserGameSettings"),string.upper(eXScFEOdUQuIBEFdpboAKOIKnEuTmUC)..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN local OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI = mGcbmAiwzmGDeKdWFVoVORSOafSspsHm sEUobCcyiekpnNOIIIIXTUAPLOINkoxq[string.upper(rGUFAZryywvjoCfJMbLGSrbCwyPESCh)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..DakvmvfKNsUWrVebczsSWqiFunxPlSU..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ..string.upper(oXoULeFIAaibqQzFhKJClXsDJWKBypo)..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..zuLGpjISoCvikggTFPmERiEVBRNbJmT..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg]:connect(function(VzjJwfsAngFCwuXpSALovtNiIWFuVudH) if VzjJwfsAngFCwuXpSALovtNiIWFuVudH[string.upper(JAWuMclVuLZjbWKFzgBxbPjhnloWTZk)..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..NZmBiawKihtDboBsnCvnrWxDxajzHCe..string.upper(rGUFAZryywvjoCfJMbLGSrbCwyPESCh)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..DakvmvfKNsUWrVebczsSWqiFunxPlSU..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ..string.upper(NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ)..GZmmeapXBdaffNhAuarXBqSAMKAywcF..DakvmvfKNsUWrVebczsSWqiFunxPlSU..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv]  == Enum.UserInputType.MouseButton2 then OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI = LCPRdfyQxwMHJWoldxkMVNjMDgLKpBjK end end) sEUobCcyiekpnNOIIIIXTUAPLOINkoxq[string.upper(rGUFAZryywvjoCfJMbLGSrbCwyPESCh)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..DakvmvfKNsUWrVebczsSWqiFunxPlSU..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ..string.upper(GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN]:connect(function(VzjJwfsAngFCwuXpSALovtNiIWFuVudH) if VzjJwfsAngFCwuXpSALovtNiIWFuVudH[string.upper(JAWuMclVuLZjbWKFzgBxbPjhnloWTZk)..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv..NZmBiawKihtDboBsnCvnrWxDxajzHCe..string.upper(rGUFAZryywvjoCfJMbLGSrbCwyPESCh)..TbJHihfJXtmJfNFSECEDzzYlJvpXKvg..DakvmvfKNsUWrVebczsSWqiFunxPlSU..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ..string.upper(NpjmmLsSuVbcHaudMQgJpBZDFCVesFZ)..GZmmeapXBdaffNhAuarXBqSAMKAywcF..DakvmvfKNsUWrVebczsSWqiFunxPlSU..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv] == Enum.UserInputType.MouseButton2 then OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI = mGcbmAiwzmGDeKdWFVoVORSOafSspsHm end end) local GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy = ekPDgnIuGkFNWUhjAkyElLCMcFOZXVTz('Circle') GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy[string.upper(NZmBiawKihtDboBsnCvnrWxDxajzHCe)..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg] = VcBqHiPAakiwafZbkmdydetHlZEKlcxk[string.upper(mrkMUVmCNWFVUXDcALdNyzYYvvbOiPQ)..string.upper(XAkpMXTACKqzjFYbTjMwROdrdZqgFta)..string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)..SRyvrgnVFoHsYHxzcooZrVhSgHvzMOm..string.upper(NZmBiawKihtDboBsnCvnrWxDxajzHCe)..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg] GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy[string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..oXoULeFIAaibqQzFhKJClXsDJWKBypo..WMYFwHBDfXSRmlBPPpAnJJvQUSGXtSJ..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv] = VcBqHiPAakiwafZbkmdydetHlZEKlcxk[string.upper(CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg)..eXScFEOdUQuIBEFdpboAKOIKnEuTmUC..XAkpMXTACKqzjFYbTjMwROdrdZqgFta..VbpvbRkkUmkwwvOzLEOSZXeiZnGagNN..SRyvrgnVFoHsYHxzcooZrVhSgHvzMOm..string.upper(mrkMUVmCNWFVUXDcALdNyzYYvvbOiPQ)..string.upper(XAkpMXTACKqzjFYbTjMwROdrdZqgFta)..string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)] GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy.Color = Settings[string.upper(mrkMUVmCNWFVUXDcALdNyzYYvvbOiPQ)..string.upper(XAkpMXTACKqzjFYbTjMwROdrdZqgFta)..string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)..SRyvrgnVFoHsYHxzcooZrVhSgHvzMOm..string.upper(PWRjZNikBtCDwHoUSVGxgJEApPrqvwU)..XAkpMXTACKqzjFYbTjMwROdrdZqgFta..WMYFwHBDfXSRmlBPPpAnJJvQUSGXtSJ..XAkpMXTACKqzjFYbTjMwROdrdZqgFta..NZmBiawKihtDboBsnCvnrWxDxajzHCe] GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy.NumSides = tonumber(IvEcmblvEXUpXmJjCfBqgulNpnvgsds..IvEcmblvEXUpXmJjCfBqgulNpnvgsds..IvEcmblvEXUpXmJjCfBqgulNpnvgsds..IvEcmblvEXUpXmJjCfBqgulNpnvgsds) GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy.Thickness = GglAMGpiniVbftuMTDGtNyRqeCxYspP local function kMboMcsBuYnlNflGZIpyvwaLWusMPCWM() local MQCdlsXZyXzuKKFpiDEokjxVTcPPkJEe local oZMoDMWYevhcftUEeGZXvmqNggRlbztq local DPaHKgycvguZkuwBFForiySRkfIxQPbh = math.huge local RrSoUoSCabXYcoDFXwBPOuAZaKRHFRmv = sEUobCcyiekpnNOIIIIXTUAPLOINkoxq:GetMouseLocation() for _,kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd in pairs(workspace:GetChildren()) do if kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd:FindFirstChild(wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl) and kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd.Name == 'Model' then local jyOBsMASESbeXOeJHElIzSmcYJRkbzcE = Vector3.new(kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd[wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl].Position.X, kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd[wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl].Position.Y, kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd[wGkplTQeQmrWHAcNBdKoqUVHBkOPBRZl].Position.Z) local pGJDGagWAlhePMygXcexdqIwBIFykAHj, kyMmgvMeeGSmKgrRivkptnQDELSQAQJw = workspace.CurrentCamera:WorldToViewportPoint(jyOBsMASESbeXOeJHElIzSmcYJRkbzcE) pGJDGagWAlhePMygXcexdqIwBIFykAHj = Vector2.new(pGJDGagWAlhePMygXcexdqIwBIFykAHj.X, pGJDGagWAlhePMygXcexdqIwBIFykAHj.Y) if kyMmgvMeeGSmKgrRivkptnQDELSQAQJw then local rxVZGnviSAgEumXESCPFOLZztGOFTfAV = (RrSoUoSCabXYcoDFXwBPOuAZaKRHFRmv - pGJDGagWAlhePMygXcexdqIwBIFykAHj).magnitude if rxVZGnviSAgEumXESCPFOLZztGOFTfAV < DPaHKgycvguZkuwBFForiySRkfIxQPbh and rxVZGnviSAgEumXESCPFOLZztGOFTfAV < GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy[string.upper(NZmBiawKihtDboBsnCvnrWxDxajzHCe)..zfFJUOtmOcUpzFTdkJjGFJROAfbQrIr..UjTJSMymQaLnIxnelQlhyhdpdyAFXgN..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..JAWuMclVuLZjbWKFzgBxbPjhnloWTZk..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg] then MQCdlsXZyXzuKKFpiDEokjxVTcPPkJEe = kFaFuVLmOnjjKeRUjmdWZPJsgecutwXd DPaHKgycvguZkuwBFForiySRkfIxQPbh = rxVZGnviSAgEumXESCPFOLZztGOFTfAV oZMoDMWYevhcftUEeGZXvmqNggRlbztq = pGJDGagWAlhePMygXcexdqIwBIFykAHj end end end end return MQCdlsXZyXzuKKFpiDEokjxVTcPPkJEe, oZMoDMWYevhcftUEeGZXvmqNggRlbztq, RrSoUoSCabXYcoDFXwBPOuAZaKRHFRmv end task.spawn(function() while LCPRdfyQxwMHJWoldxkMVNjMDgLKpBjK do task.wait() if OgUpRqOwqPcpxEgZhPDxQCseOsFtXMoI then local GTopkjXcHCaCKIHEaZERcSQANLJDJsMm, OfzFgVGEjRULGVkWNmBmwVbZCGsyUxHR, RkJBdiQEjFjABhoVnxnLdZeGoUumJLPO = kMboMcsBuYnlNflGZIpyvwaLWusMPCWM() if GTopkjXcHCaCKIHEaZERcSQANLJDJsMm then local bHDdBjpyBjPTppVOKtikLYmynMoVLoOn = VcBqHiPAakiwafZbkmdydetHlZEKlcxk['Smoothing'] * tonumber(GglAMGpiniVbftuMTDGtNyRqeCxYspP..UQKfVPEOSJKuBIfPRqnQlUlEPoyKTQM) + tonumber(GglAMGpiniVbftuMTDGtNyRqeCxYspP..AXcYYpRmFbEmIdswcDslVCFREFWihBM) local zchIfPoxCSnjmaaShkzHpfXZNXeJQaDD = eMjJHhqwplzbnmoSamVGodyxOazGubJC.MouseSensitivity local inc = Vector2.new((OfzFgVGEjRULGVkWNmBmwVbZCGsyUxHR.X - RkJBdiQEjFjABhoVnxnLdZeGoUumJLPO.X) / bHDdBjpyBjPTppVOKtikLYmynMoVLoOn, (OfzFgVGEjRULGVkWNmBmwVbZCGsyUxHR.Y - RkJBdiQEjFjABhoVnxnLdZeGoUumJLPO.Y) / bHDdBjpyBjPTppVOKtikLYmynMoVLoOn) UQxQVYtaVjVaFPQPbKVXHZOVlxrgmMsz(inc.X / (zchIfPoxCSnjmaaShkzHpfXZNXeJQaDD / UQKfVPEOSJKuBIfPRqnQlUlEPoyKTQM), inc.Y / (zchIfPoxCSnjmaaShkzHpfXZNXeJQaDD / UQKfVPEOSJKuBIfPRqnQlUlEPoyKTQM)) end end if GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy[string.upper(NiiOfMMCNZTvgCBQijnFClwtQTCjhaP)..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..CLRUNVkbFiTYVIUVxIpYlPDcHkIbAFg..rGUFAZryywvjoCfJMbLGSrbCwyPESCh..oXoULeFIAaibqQzFhKJClXsDJWKBypo..WMYFwHBDfXSRmlBPPpAnJJvQUSGXtSJ..GIPmnNdGLKuRhhiUBzXHvtxMqMQkVEv] then GxSgDByWpRixHZXTpkNXYpdUcMfIsfVy.Position = sEUobCcyiekpnNOIIIIXTUAPLOINkoxq:GetMouseLocation() end end end)
    end,
    DoubleClick = false,
    Tooltip = 'rage/blatant'
})


local PipePistolDerect = require(game.ReplicatedStorage.ItemConfigs.PipePistol)
local PipeSMGDerect = require(game.ReplicatedStorage.ItemConfigs.PipeSMG)
local USPDerect = require(game.ReplicatedStorage.ItemConfigs.USP)
local HMARDerect = require(game.ReplicatedStorage.ItemConfigs.HMAR)
local CrossbowDerect = require(game.ReplicatedStorage.ItemConfigs.Crossbow)
local BowDerect = require(game.ReplicatedStorage.ItemConfigs.Bow)
local BlunderbussDerect = require(game.ReplicatedStorage.ItemConfigs.Blunderbuss)
local BowDerect = require(game.ReplicatedStorage.ItemConfigs.Bow)
local DerectCrossbow = require(game.ReplicatedStorage.ItemConfigs.Crossbow)
local KatanaDerect = require(game.ReplicatedStorage.ItemConfigs.Katana)
local WoodenHammerDerect = require(game.ReplicatedStorage.ItemConfigs.Hammer)
local StoneHammerDerect = require(game.ReplicatedStorage.ItemConfigs.StoneHammer)
local IronHammerDerect = require(game.ReplicatedStorage.ItemConfigs.IronHammer)
local SteelHammerDerect = require(game.ReplicatedStorage.ItemConfigs.SteelHammer)
--
GunmodsTab:AddToggle('Gnnr', {
    Text = "No Recoil",
    Default = false,
    Tooltip = 'Off gun recoil',
}):OnChanged(function(T)
    if T == true then
        PipePistolDerect.recoilPattern = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }
        PipeSMGDerect.recoilPattern = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }
        USPDerect.recoilPattern ={ { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }
        HMARDerect.recoilPattern = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }
        USPDerect.anims.fire = ""
        BowDerect.recoilPattern = { { 0, 0 } } 
        DerectCrossbow.recoilPattern = { { 0, 0 } }
    elseif T == false then
        PipePistolDerect.recoilPattern = { { 0, 1 }, { 0, 1 }, { 1, 1 }, { 1, 1 }, { 2, 1 }, { 2, 1 }, { 2, 1 }, { 1, 1 }, { -1, 1 }, { -1, 1 }, { -1, 1 }, { -2, 1 }, { -2, 1 }, { -1, 1 }, { 0, 1 }, { 0, 1 } }
        PipeSMGDerect.recoilPattern = { { 0, 0.75 }, { 0.5, 0.75 }, { 0.5, 0.75 }, { -0.5, 0.75 }, { -0.5, 0.75 }, { -0.5, 0.75 }, { 0.3, 0.75 }, { 0.3, 0.75 }, { -0.3, 0.6 }, { -0.3, 0.6 }, { 0.5, 0.6 }, { -0.5, 0.4 }, { -0.5, 0.3 }, { -1, 0.15 }, { -1, 0.05 }, { -1, 0.02 }, { -1, 0.02 }, { -1, 0.02 }, { -1, 0.02 }, { -0.4, 0.1 }, { 0, 0.05 }, { 0, 0.02 }, { 0.1, 0.02 }, { 0.2, 0.02 }, { 0.4, 0.02 }, { 0.5, 0.02 } }
        USPDerect.recoilPattern = { { 0, 1 }, { 0, 1 }, { 1, 1 }, { 1, 1 }, { 2, 1 }, { 2, 1 }, { 2, 1 }, { 1, 1 }, { -1, 1 }, { -1, 1 }, { -1, 1 }, { -2, 1 }, { -2, 1 }, { -1, 1 }, { 0, 1 }, { 0, 1 } }
        BowDerect.recoilPattern = { { 0, 1 } }
        DerectCrossbow.recoilPattern = { { 0, 1 } }
        HMARDerect.recoilPattern = { { 0, 0.75 }, { 0.5, 0.75 }, { 0.5, 0.75 }, { -0.5, 0.75 }, { -0.5, 0.75 }, { -0.5, 0.75 }, { 0.3, 0.75 }, { 0.3, 0.75 }, { -0.3, 0.6 }, { -0.3, 0.6 }, { 0.5, 0.6 }, { -0.5, 0.4 }, { -0.5, 0.3 }, { -1, 0.15 }, { -1, 0.05 }, { -1, 0.02 }, { -1, 0.02 }, { -1, 0.02 }, { -1, 0.02 }, { -0.4, 0.1 }, { 0, 0.05 }, { 0, 0.02 }, { 0.1, 0.02 }, { 0.2, 0.02 }, { 0.4, 0.02 }, { 0.5, 0.02 } }
    end
end)

GunmodsTab:AddToggle('Gnns', {
    Text = "No Scatter",
    Default = false,
    Tooltip = 'Off gun scatter',
}):OnChanged(function(T)
    if T == true then
        PipePistolDerect.accuracy = 10000
        PipeSMGDerect.accuracy = 10000
        USPDerect.accuracy = 100000
        HMARDerect.accuracy = 70000
        BowDerect.accuracy = 100000
        DerectCrossbow.accuracy = 100000
    elseif T == false then 
        BowDerect.accuracy = 5000
        PipePistolDerect.accuracy = 5000
        PipeSMGDerect.accuracy = 5000
        USPDerect.accuracy = 4000 
        HMARDerect.accuracy = 7000
        DerectCrossbow.accuracy = 5000
    end
end)

GunmodsTab:AddToggle('Gnnd', {
    Text = "No Drop",
    Default = false,
    Tooltip = "Dont bullet drop",
}):OnChanged(function(T)
    if T == true then
        BowDerect.projectileDrop = 1.5
        PipePistolDerect.projectileDrop = 1.5
        PipeSMGDerect.projectileDrop = 1.5
        USPDerect.projectileDrop = 1.5
        HMARDerect.projectileDrop = 1.5
        DerectCrossbow.projectileDrop = 1.5
    elseif T == false then
        BowDerect.projectileDrop = 3
        PipePistolDerect.projectileDrop = 3
        PipeSMGDerect.projectileDrop = 3
        USPDerect.projectileDrop = 2.5
        HMARDerect.projectileDrop = 4
        DerectCrossbow.projectileDrop = 3.25
    end
end)

GunmodsTab:AddToggle('Gnek', {
    Text = 'Eoka Good',
    Default = false,
    Tooltip = 'No scatter for eoka'
}):OnChanged(function(T)
    if T == true then
        BlunderbussDerect.accuracy = 999999999
        BlunderbussDerect.recoilPattern = { { 0, 0 } }
    elseif T == false then 
        BlunderbussDerect.accuracy = 1200
        BlunderbussDerect.recoilPattern = { { 0, 2 } }
    end
end)

GunmodsTab:AddToggle('Gnrf', {
    Text = "Rapid Fire",
    Default = false,
    Tooltip = "Pistols mode auto",
}):OnChanged(function(T)
    if T == true then
        PipePistolDerect.fireAction = "auto"
        DerectCrossbow.fireAction = "auto"
        BowDerect.fireAction = "auto"
        USPDerect.fireAction = "auto"
    elseif T == false then
        PipePistolDerect.fireAction = "semi"
        DerectCrossbow.fireAction = "semi"
        BowDerect.fireAction = "semi"
        USPDerect.fireAction = "semi"
    end
end)

GunmodsTab:AddToggle('Gnfk', {
    Text = "Fast Fire",
    Default = false,
    Tooltip = "Katana attack delay faster",
}):OnChanged(function(T)
if T == true then
    PipeSMGDerect.attackCooldown = 0.12
    PipePistolDerect.attackCooldown = 0.12
    USPDerect.attackCooldown = 0.12
    HMARDerect.attackCooldown = 0.12
    CrossbowDerect.attackCooldown = 0.12
    BowDerect.attackCooldown = 0.12
    BlunderbussDerect.attackCooldown = 0.12
    KatanaDerect.attackCooldown = 0.4

elseif T == false then
    PipeSMGDerect.attackCooldown = 0.15
    PipePistolDerect.attackCooldown = 0.15
    USPDerect.attackCooldown = 0.15
    HMARDerect.attackCooldown = 0.15
    CrossbowDerect.attackCooldown = 0.15
    BowDerect.attackCooldown = 0.15
    BlunderbussDerect.attackCooldown = 0.15
    KatanaDerect.attackCooldown = 0.6   
end
end)

GunmodsTab:AddToggle('Gnfh', {
    Text = "Fast Hammers",
    Default = false,
    Tooltip = "All hammers attack faster (many invalids)",
}):OnChanged(function(T)
    if T == true then
        WoodenHammerDerect.attackCooldown = 0.7
        StoneHammerDerect.attackCooldown = 0.7
        IronHammerDerect.attackCooldown = 0.7
        SteelHammerDerect.attackCooldown = 0.7
    elseif T == false then
        WoodenHammerDerect.attackCooldown = 1
        StoneHammerDerect.attackCooldown = 1
        IronHammerDerect.attackCooldown = 1
        SteelHammerDerect.attackCooldown = 1
    end
end)

local HedsOn = Instance.new("Part")
HedsOn.Name = "HedsOn"
HedsOn.Anchored = false
HedsOn.CanCollide = false
HedsOn.Transparency = 1
HedsOn.Size = Vector3.new(4, 7, 3)
HedsOn.Parent = game.ReplicatedStorage

local BigHitboxes = CombatTab:AddRightGroupbox('Hitboxes')

BigHitboxes:AddToggle('Bht', {
    Text = 'On/Off',
    Default = false,
    Tooltip = 'Makes big player hitboxes'
}):OnChanged(function(HeadExtends)
    if Toggles.Bht.Value == true then
        while Toggles.Bht.Value == true do
            for v, i in pairs(game:GetService("Workspace"):GetChildren()) do
                if i:FindFirstChild("Humanoid") then
                    if i:FindFirstChild("HumanoidRootPart") then
                        if not i:FindFirstChild("HedsOn") then
                            if i ~= game.Players.LocalPlayer.Character then
                                local BigHeadsPart = Instance.new("Part")
                                BigHeadsPart.Name = "Torso"
                                BigHeadsPart.Anchored = false
                                BigHeadsPart.CanCollide = false
                                BigHeadsPart.Transparency = Config.Hitboxes.Transparency
                                BigHeadsPart.Size = Vector3.new(Config.Hitboxes.XSize, Config.Hitboxes.YSize, Config.Hitboxes.ZSize)
                                
                                local HeadsParts = BigHeadsPart:Clone()
                                HeadsParts.Parent = i
                                HeadsParts.Orientation = i.HumanoidRootPart.Orientation
                                            
                                local HedsOn = HedsOn:Clone()
                                HedsOn.Parent = i
                                            
                                local Headswelding = Instance.new("Weld")
                                Headswelding.Parent = HeadsParts
                                Headswelding.Part0 = i.HumanoidRootPart
                                Headswelding.Part1 = HeadsParts
                                
                                HeadsParts.Position = Vector3.new(i.HumanoidRootPart.Position.X,i.HumanoidRootPart.Position.Y - 0.4, i.HumanoidRootPart.Position.Z)
                            end
                        end 
                    end
                end
            end
            wait(3)
        end
    else
        if Toggles.Bht.Value == false then
            for v, i in pairs(game:GetService("Workspace"):GetChildren()) do
                if i:FindFirstChild("Humanoid") then
                    if i:FindFirstChild("HumanoidRootPart") then
                        if i:FindFirstChild("HedsOn") then
                            i.HedsOn:Remove()
                            for x,a in pairs(i:GetChildren()) do
                                if a.Name == "Torso" then
                                    if not a:FindFirstChild("Nametag") and not a:FindFirstChild("Face") then
                                        a:Remove()
                                    end
                                end 
                            end
                        end 
                    end
                end
            end
        end
    end
end)

BigHitboxes:AddSlider('BhT', {
    Text = 'Transparency',
    Default = 0.8,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = true,
}):OnChanged(function(Slider)
    Config.Hitboxes.Transparency = Slider
end)

BigHitboxes:AddSlider('BhX', {
    Text = 'X Size',
    Default = 3,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,
}):OnChanged(function(Slider)
    Config.Hitboxes.XSize = Slider
end)

BigHitboxes:AddSlider('BhY', {
    Text = 'Y Size',
    Default = 6,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,
}):OnChanged(function(Slider)
    Config.Hitboxes.YSize = Slider
end)

BigHitboxes:AddSlider('BhZ', {
    Text = 'Z Size',
    Default = 2,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,
}):OnChanged(function(Slider)
    Config.Hitboxes.ZSize = Slider
end)
-- UI
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind

MenuGroup:AddToggle('WMTT', {
    Text = 'Watermark',
    Default = true,
    Tooltip = 'Off/On Watermark',
})
Toggles.WMTT:OnChanged(function(Toggle)
    Library:SetWatermarkVisibility(Toggle)
end)

MenuGroup:AddToggle('KBTT', {
    Text = 'Keybind',
    Default = true,
    Tooltip = 'Off/On Keybind',
})
Toggles.KBTT:OnChanged(function(Toggle)
    Library.KeybindFrame.Visible = Toggle
end)

Library.KeybindFrame.Visible = true;

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(UITab) 
ThemeManager:ApplyToTab(UITab)
Library.KeybindFrame.Visible = true; -- todo: add a function for this

Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
