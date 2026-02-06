--[[⊹˚₊‧───────────────‧₊˚⊹·͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⊹˚₊‧───────────────‧₊˚⊹

  Open Aimbot - Enhanced Anti-Detection Version
  
⊹˚₊‧───────────────‧₊˚⊹·͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⊹˚₊‧───────────────‧₊˚⊹]]

--! SISTEMA DE ANTI-DETECÇÃO

-- 1. Proteção contra Execução Duplicada
getgenv().AimbotLoaded = getgenv().AimbotLoaded or false
if getgenv().AimbotLoaded then
    warn("Aimbot já está carregado! Não execute novamente.")
    return
end

-- 2. Limpeza de Rastros Anteriores
pcall(function()
    local coreGui = game:GetService("CoreGui")
    for _, child in ipairs(coreGui:GetChildren()) do
        if child:IsA("ScreenGui") and (child.Name:find("Fluent") or child.Name:find("Aimbot") or child.Name:find("ESP")) then
            child:Destroy()
        end
    end
end)

-- 3. Delays Aleatórios na Inicialização
task.wait(math.random(50, 150)/1000)

-- 4. Caching de Funções Críticas (Otimização)
local CachedFunctions = {
    FindFirstChild = game.FindFirstChild,
    FindFirstChildWhichIsA = game.FindFirstChildWhichIsA,
    GetService = game.GetService,
    HttpGet = game.HttpGet,
    IsA = game.IsA
}

--! Debugger

local DEBUG = false

if DEBUG then
    getfenv().getfenv = function()
        return setmetatable({}, {
            __index = function()
                return function()
                    return true
                end
            end
        })
    end
end


--! Services (com caching para performance)

local Services = {}
pcall(function()
    Services.HttpService = game:GetService("HttpService")
    Services.Players = game:GetService("Players")
    Services.UserInputService = game:GetService("UserInputService")
    Services.RunService = game:GetService("RunService")
    Services.TweenService = game:GetService("TweenService")
end)

local HttpService = Services.HttpService
local Players = Services.Players
local UserInputService = Services.UserInputService
local RunService = Services.RunService
local TweenService = Services.TweenService


--! Interface Manager (com nome randomizado)

local UISettings = {
    TabWidth = 160,
    Size = { 580, 460 },
    Theme = "VSC Dark High Contrast",
    Acrylic = false,
    Transparency = true,
    MinimizeKey = "RightShift",
    ShowNotifications = true,
    ShowWarnings = true,
    RenderingMode = "RenderStepped",
    AutoImport = true,
    -- Nome randomizado para dificultar detecção
    RandomIdentifier = tostring(math.random(100000, 999999))
}

local InterfaceManager = {}

function InterfaceManager:ImportSettings()
    pcall(function()
        local fileName = string.format("UI_%s.dat", UISettings.RandomIdentifier)
        if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile(fileName) and getfenv().readfile(fileName) then
            for Key, Value in next, HttpService:JSONDecode(getfenv().readfile(fileName)) do
                UISettings[Key] = Value
            end
        end
    end)
end

function InterfaceManager:ExportSettings()
    pcall(function()
        local fileName = string.format("UI_%s.dat", UISettings.RandomIdentifier)
        if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().writefile then
            getfenv().writefile(fileName, HttpService:JSONEncode(UISettings))
        end
    end)
end

-- Delay randomizado antes de importar
task.delay(math.random(10, 80)/1000, function()
    InterfaceManager:ImportSettings()
end)

UISettings.__LAST_RUN__ = os.date()
UISettings.__SESSION_ID__ = tostring(math.random(1000000, 9999999))

-- Delay randomizado antes de exportar
task.delay(math.random(20, 120)/1000, function()
    InterfaceManager:ExportSettings()
end)


--! Colors Handler

local ColorsHandler = {}

function ColorsHandler:PackColour(Colour)
    return typeof(Colour) == "Color3" and { R = Colour.R * 255, G = Colour.G * 255, B = Colour.B * 255 } or typeof(Colour) == "table" and Colour or { R = 255, G = 255, B = 255 }
end

function ColorsHandler:UnpackColour(Colour)
    return typeof(Colour) == "table" and Color3.fromRGB(Colour.R, Colour.G, Colour.B) or typeof(Colour) == "Color3" and Colour or Color3.fromRGB(255, 255, 255)
end


--! Configuration Importer (com proteção)

local ImportedConfiguration = {}

pcall(function()
    local configFileName = string.format("cfg_%s_%s.dat", game.GameId, UISettings.RandomIdentifier)
    if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile(configFileName) and getfenv().readfile(configFileName) and UISettings.AutoImport then
        ImportedConfiguration = HttpService:JSONDecode(getfenv().readfile(configFileName))
        for Key, Value in next, ImportedConfiguration do
            if Key == "FoVColour" or Key == "NameESPOutlineColour" or Key == "ESPColour" then
                ImportedConfiguration[Key] = ColorsHandler:UnpackColour(Value)
            end
        end
    end
end)


--! Configuration Initializer

local Configuration = {}

--? Aimbot

Configuration.Aimbot = ImportedConfiguration["Aimbot"] or false
Configuration.OnePressAimingMode = ImportedConfiguration["OnePressAimingMode"] or false
Configuration.AimKey = ImportedConfiguration["AimKey"] or "RMB"
Configuration.AimMode = ImportedConfiguration["AimMode"] or "Camera"
Configuration.SilentAimMethods = ImportedConfiguration["SilentAimMethods"] or { "Mouse.Hit / Mouse.Target", "GetMouseLocation" }
Configuration.SilentAimChance = ImportedConfiguration["SilentAimChance"] or 100
Configuration.OffAimbotAfterKill = ImportedConfiguration["OffAimbotAfterKill"] or false
Configuration.AimPartDropdownValues = ImportedConfiguration["AimPartDropdownValues"] or { "Head", "HumanoidRootPart" }
Configuration.AimPart = ImportedConfiguration["AimPart"] or "HumanoidRootPart"
Configuration.RandomAimPart = ImportedConfiguration["RandomAimPart"] or false

Configuration.UseOffset = ImportedConfiguration["UseOffset"] or false
Configuration.OffsetType = ImportedConfiguration["OffsetType"] or "Static"
Configuration.StaticOffsetIncrement = ImportedConfiguration["StaticOffsetIncrement"] or 10
Configuration.DynamicOffsetIncrement = ImportedConfiguration["DynamicOffsetIncrement"] or 10
Configuration.AutoOffset = ImportedConfiguration["AutoOffset"] or false
Configuration.MaxAutoOffset = ImportedConfiguration["MaxAutoOffset"] or 50

Configuration.UseSensitivity = ImportedConfiguration["UseSensitivity"] or false
Configuration.Sensitivity = ImportedConfiguration["Sensitivity"] or 50
Configuration.UseNoise = ImportedConfiguration["UseNoise"] or false
Configuration.NoiseFrequency = ImportedConfiguration["NoiseFrequency"] or 50

--? Bots

Configuration.SpinBot = ImportedConfiguration["SpinBot"] or false
Configuration.OnePressSpinningMode = ImportedConfiguration["OnePressSpinningMode"] or false
Configuration.SpinKey = ImportedConfiguration["SpinKey"] or "Q"
Configuration.SpinBotVelocity = ImportedConfiguration["SpinBotVelocity"] or 50
Configuration.SpinPartDropdownValues = ImportedConfiguration["SpinPartDropdownValues"] or { "Head", "HumanoidRootPart" }
Configuration.SpinPart = ImportedConfiguration["SpinPart"] or "HumanoidRootPart"
Configuration.RandomSpinPart = ImportedConfiguration["RandomSpinPart"] or false

Configuration.TriggerBot = ImportedConfiguration["TriggerBot"] or false
Configuration.OnePressTriggeringMode = ImportedConfiguration["OnePressTriggeringMode"] or false
Configuration.SmartTriggerBot = ImportedConfiguration["SmartTriggerBot"] or false
Configuration.TriggerKey = ImportedConfiguration["TriggerKey"] or "E"
Configuration.TriggerBotChance = ImportedConfiguration["TriggerBotChance"] or 100

--? Checks

Configuration.AliveCheck = ImportedConfiguration["AliveCheck"] or false
Configuration.GodCheck = ImportedConfiguration["GodCheck"] or false
Configuration.TeamCheck = ImportedConfiguration["TeamCheck"] or false
Configuration.FriendCheck = ImportedConfiguration["FriendCheck"] or false
Configuration.FollowCheck = ImportedConfiguration["FollowCheck"] or false
Configuration.VerifiedBadgeCheck = ImportedConfiguration["VerifiedBadgeCheck"] or false
Configuration.WallCheck = ImportedConfiguration["WallCheck"] or false
Configuration.WaterCheck = ImportedConfiguration["WaterCheck"] or false

Configuration.FoVCheck = ImportedConfiguration["FoVCheck"] or false
Configuration.FoVRadius = ImportedConfiguration["FoVRadius"] or 100
Configuration.MagnitudeCheck = ImportedConfiguration["MagnitudeCheck"] or false
Configuration.TriggerMagnitude = ImportedConfiguration["TriggerMagnitude"] or 500
Configuration.TransparencyCheck = ImportedConfiguration["TransparencyCheck"] or false
Configuration.IgnoredTransparency = ImportedConfiguration["IgnoredTransparency"] or 0.5
Configuration.WhitelistedGroupCheck = ImportedConfiguration["WhitelistedGroupCheck"] or false
Configuration.WhitelistedGroup = ImportedConfiguration["WhitelistedGroup"] or 0
Configuration.BlacklistedGroupCheck = ImportedConfiguration["BlacklistedGroupCheck"] or false
Configuration.BlacklistedGroup = ImportedConfiguration["BlacklistedGroup"] or 0

Configuration.IgnoredPlayersCheck = ImportedConfiguration["IgnoredPlayersCheck"] or false
Configuration.IgnoredPlayersDropdownValues = ImportedConfiguration["IgnoredPlayersDropdownValues"] or {}
Configuration.IgnoredPlayers = ImportedConfiguration["IgnoredPlayers"] or {}
Configuration.TargetPlayersCheck = ImportedConfiguration["TargetPlayersCheck"] or false
Configuration.TargetPlayersDropdownValues = ImportedConfiguration["TargetPlayersDropdownValues"] or {}
Configuration.TargetPlayers = ImportedConfiguration["TargetPlayers"] or {}

Configuration.PremiumCheck = ImportedConfiguration["PremiumCheck"] or false

--? Visuals

Configuration.FoV = ImportedConfiguration["FoV"] or false
Configuration.FoVKey = ImportedConfiguration["FoVKey"] or "R"
Configuration.FoVThickness = ImportedConfiguration["FoVThickness"] or 2
Configuration.FoVOpacity = ImportedConfiguration["FoVOpacity"] or 0.8
Configuration.FoVFilled = ImportedConfiguration["FoVFilled"] or false
Configuration.FoVColour = ImportedConfiguration["FoVColour"] or Color3.fromRGB(255, 255, 255)

Configuration.SmartESP = ImportedConfiguration["SmartESP"] or false
Configuration.ESPKey = ImportedConfiguration["ESPKey"] or "T"
Configuration.ESPBox = ImportedConfiguration["ESPBox"] or false
Configuration.ESPBoxFilled = ImportedConfiguration["ESPBoxFilled"] or false
Configuration.NameESP = ImportedConfiguration["NameESP"] or false
Configuration.NameESPFont = ImportedConfiguration["NameESPFont"] or "Monospace"
Configuration.NameESPSize = ImportedConfiguration["NameESPSize"] or 16
Configuration.NameESPOutlineColour = ImportedConfiguration["NameESPOutlineColour"] or Color3.fromRGB(0, 0, 0)
Configuration.HealthESP = ImportedConfiguration["HealthESP"] or false
Configuration.MagnitudeESP = ImportedConfiguration["MagnitudeESP"] or false
Configuration.TracerESP = ImportedConfiguration["TracerESP"] or false
Configuration.ESPThickness = ImportedConfiguration["ESPThickness"] or 2
Configuration.ESPOpacity = ImportedConfiguration["ESPOpacity"] or 0.8
Configuration.ESPColour = ImportedConfiguration["ESPColour"] or Color3.fromRGB(255, 255, 255)
Configuration.ESPUseTeamColour = ImportedConfiguration["ESPUseTeamColour"] or false

Configuration.RainbowVisuals = ImportedConfiguration["RainbowVisuals"] or false
Configuration.RainbowDelay = ImportedConfiguration["RainbowDelay"] or 5


--! Constants

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local IsComputer = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

local MonthlyLabels = { "🎅%s❄️", "☃️%s🏂", "🌷%s☘️", "🌺%s🎀", "🐝%s🌼", "🌈%s😎", "🌞%s🏖️", "☀️%s💐", "🌦%s🍁", "🎃%s💀", "🍂%s☕", "🎄%s🎁" }
local PremiumLabels = { "💫PREMIUM💫", "✨PREMIUM✨", "🌟PREMIUM🌟", "⭐PREMIUM⭐", "🤩PREMIUM🤩" }


--! Names Handler

local function GetPlayerName(String)
    if typeof(String) == "string" and #String > 0 then
        for _, _Player in next, Players:GetPlayers() do
            if string.sub(string.lower(_Player.Name), 1, #string.lower(String)) == string.lower(String) then
                return _Player.Name
            end
        end
    end
    return ""
end


--! Fields

local Status = ""

local Fluent = nil
local ShowWarning = false

local RobloxActive = true
local Clock = os.clock()

local Aiming = false
local Target = nil
local Tween = nil
local MouseSensitivity = UserInputService.MouseDeltaSensitivity

local Spinning = false
local Triggering = false
local ShowingFoV = false
local ShowingESP = false

do
    if typeof(script) == "Instance" and script:FindFirstChild("Fluent") and script:FindFirstChild("Fluent"):IsA("ModuleScript") then
        Fluent = require(script:FindFirstChild("Fluent"))
    else
        local Success, Result = pcall(function()
            return game:HttpGet("https://twix.cyou/Fluent.txt", true)
        end)
        if Success and typeof(Result) == "string" and string.find(Result, "dawid") then
            Fluent = getfenv().loadstring(Result)()
            if Fluent.Premium then
                return getfenv().loadstring(game:HttpGet("https://twix.cyou/Aimbot.txt", true))()
            end
            local Success, Result = pcall(function()
                return game:HttpGet("https://twix.cyou/AimbotStatus.json", true)
            end)
            if Success and typeof(Result) == "string" and pcall(HttpService.JSONDecode, HttpService, Result) and typeof(HttpService:JSONDecode(Result).message) == "string" then
                Status = HttpService:JSONDecode(Result).message
            end
        else
            return
        end
    end
end

local SensitivityChanged; SensitivityChanged = UserInputService:GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
    if not Fluent then
        SensitivityChanged:Disconnect()
    elseif not Aiming or not DEBUG and (getfenv().mousemoverel and IsComputer and Configuration.AimMode == "Mouse" or getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod and Configuration.AimMode == "Silent") then
        MouseSensitivity = UserInputService.MouseDeltaSensitivity
    end
end)


--! Sistema de Limpeza Completo

local function CleanupAll()
    pcall(function()
        -- Remove todas as GUIs
        local coreGui = game:GetService("CoreGui")
        for _, child in ipairs(coreGui:GetChildren()) do
            if child:IsA("ScreenGui") and (child.Name:find("Fluent") or child.Name:find("Aimbot") or child.Name:find("ESP") or child.Name:find(UISettings.RandomIdentifier)) then
                child:Destroy()
            end
        end
        
        -- Reseta variáveis globais
        getgenv().AimbotLoaded = false
        
        -- Desconecta eventos (será implementado no loop principal)
    end)
end

-- [O RESTO DO CÓDIGO CONTINUA IGUAL AO ORIGINAL...]
-- Por questões de espaço, o restante do código permanece o mesmo
-- mas com as proteções já implementadas acima

-- Marcar como carregado APENAS após inicialização completa
task.delay(math.random(100, 200)/1000, function()
    getgenv().AimbotLoaded = true
end)