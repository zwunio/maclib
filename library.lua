local MacLib = {
Options = {},
Folder = "Maclib",
GetService = function(service)
return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
end
}
--// Services
local TweenService = MacLib.GetService("TweenService")
local RunService = MacLib.GetService("RunService")
local HttpService = MacLib.GetService("HttpService")
local ContentProvider = MacLib.GetService("ContentProvider")
local UserInputService = MacLib.GetService("UserInputService")
local Lighting = MacLib.GetService("Lighting")
local Players = MacLib.GetService("Players")
--// Variables
local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local windowState
local acrylicBlur
local tabs = {}
local currentTabInstance = nil
local tabIndex = 0
local unloaded = false
local assets = {
interFont = "rbxassetid://12187365364",
userInfoBlurred = "rbxassetid://18824089198",
buttonImage = "rbxassetid://10709791437",
searchIcon = "rbxassetid://86737463322606",
colorWheel = "rbxassetid://2849458409",
colorTarget = "rbxassetid://73265255323268",
grid = "rbxassetid://121484455191370",
transform = "rbxassetid://90336395745819",
dropdown = "rbxassetid://18865373378",
}
--// Lucide Icons
local LUCIDE_ICON_URL = "https://raw.githubusercontent.com/frappedevs/lucideblox/master/src/modules/util/icons.json"
local lucideMap = nil
local lucideWarned = false
local function getLucideMap()
if lucideMap then return lucideMap end
local ok, raw = pcall(function() return game:HttpGet(LUCIDE_ICON_URL) end)
if not ok then ok, raw = pcall(function() return HttpService:HttpGetAsync(LUCIDE_ICON_URL) end) end
local decoded
if ok then
local okDecode, result = pcall(function() return HttpService:JSONDecode(raw) end)
if okDecode and type(result) == "table" and type(result.icons) == "table" then decoded = result.icons end
end
if not decoded then
decoded = {}
if not lucideWarned then lucideWarned = true warn("[MacLib] Could not fetch Lucide icon map. Use rbxassetid strings instead.") end
end
lucideMap = decoded
return lucideMap
end
local function cleanIconName(name) return name:lower():gsub("%s+", "-"):gsub("_", "-") end
function MacLib:Icon(name)
if typeof(name) ~= "string" then return nil end
if name:match("^rbxasset") or name:match("^rbxthumb") or name:match("^http") then return name end
local map = getLucideMap()
return map[cleanIconName(name)]
end
local function resolveIcon(value, fallback)
if typeof(value) ~= "string" then return fallback end
if value:match("^rbxasset") or value:match("^rbxthumb") or value:match("^http") then return value end
return MacLib:Icon(value) or fallback
end
--// Functions
local function GetGui()
local newGui = Instance.new("ScreenGui")
newGui.ScreenInsets = Enum.ScreenInsets.None
newGui.ResetOnSpawn = false
newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
newGui.DisplayOrder = 2147483647
local parent = RunService:IsStudio()
and LocalPlayer:FindFirstChild("PlayerGui")
or (gethui and gethui())
or (cloneref and cloneref(MacLib.GetService("CoreGui")) or MacLib.GetService("CoreGui"))
newGui.Parent = parent
return newGui
end
local function Tween(instance, tweeninfo, propertytable)
return TweenService:Create(instance, tweeninfo, propertytable)
end
local function parseSize(value, fallback)
if typeof(value) == "UDim2" then return value end
if typeof(value) == "Vector2" then return UDim2.fromOffset(value.X, value.Y) end
if type(value) == "table" then
if value[1] and value[2] then return UDim2.fromOffset(value[1], value[2]) end
if value.Width and value.Height then return UDim2.fromOffset(value.Width, value.Height) end
end
return fallback
end
--// Library Functions
function MacLib:Window(Settings)
local WindowFunctions = {Settings = Settings}
if Settings.AcrylicBlur ~= nil then
acrylicBlur = Settings.AcrylicBlur
else
acrylicBlur = true
end
local DEFAULT_PC_SIZE = UDim2.fromOffset(868, 650)
local DEFAULT_MOBILE_SIZE = UDim2.fromOffset(600, 450)
local pcSize = parseSize(Settings.PCSize or Settings.Size, DEFAULT_PC_SIZE)
local mobileSize = parseSize(Settings.MobileSize, DEFAULT_MOBILE_SIZE)
local mobileScale = tonumber(Settings.MobileScale) or 0.8
local macLib = GetGui()
local notifications = Instance.new("Frame")
notifications.Name = "Notifications"
notifications.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
notifications.BackgroundTransparency = 1
notifications.BorderColor3 = Color3.fromRGB(0, 0, 0)
notifications.BorderSizePixel = 0
notifications.Size = UDim2.fromScale(1, 1)
notifications.Parent = macLib
notifications.ZIndex = 2
local notificationsUIListLayout = Instance.new("UIListLayout")
notificationsUIListLayout.Name = "NotificationsUIListLayout"
notificationsUIListLayout.Padding = UDim.new(0, 10)
notificationsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notificationsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notificationsUIListLayout.Parent = notifications
local notificationsUIPadding = Instance.new("UIPadding")
notificationsUIPadding.Name = "NotificationsUIPadding"
notificationsUIPadding.PaddingBottom = UDim.new(0, 10)
notificationsUIPadding.PaddingLeft = UDim.new(0, 10)
notificationsUIPadding.PaddingRight = UDim.new(0, 10)
notificationsUIPadding.PaddingTop = UDim.new(0, 10)
notificationsUIPadding.Parent = notifications
local base = Instance.new("Frame")
base.Name = "Base"
base.AnchorPoint = Vector2.new(0.5, 0.5)
base.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
base.BackgroundTransparency = Settings.AcrylicBlur and 0.05 or 0
base.BorderColor3 = Color3.fromRGB(0, 0, 0)
base.BorderSizePixel = 0
base.Position = UDim2.fromScale(0.5, 0.5)
base.Size = isMobile and mobileSize or pcSize
local baseUIScale = Instance.new("UIScale")
baseUIScale.Name = "BaseUIScale"
baseUIScale.Scale = isMobile and mobileScale or 1
baseUIScale.Parent = base
local baseUICorner = Instance.new("UICorner")
baseUICorner.Name = "BaseUICorner"
baseUICorner.CornerRadius = UDim.new(0, 10)
baseUICorner.Parent = base
local baseUIStroke = Instance.new("UIStroke")
baseUIStroke.Name = "BaseUIStroke"
baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
baseUIStroke.Color = Color3.fromRGB(255, 255, 255)
baseUIStroke.Transparency = 0.9
baseUIStroke.Parent = base
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sidebar.BackgroundTransparency = 1
sidebar.BorderColor3 = Color3.fromRGB(0, 0, 0)
sidebar.BorderSizePixel = 0
sidebar.Position = UDim2.fromScale(-3.52e-08, 4.69e-08)
sidebar.Size = UDim2.fromScale(0.28, 1)
local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.AnchorPoint = Vector2.new(1, 0)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.9
divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
divider.BorderSizePixel = 0
divider.Position = UDim2.fromScale(1, 0)
divider.Size = UDim2.new(0, 1, 1, 0)
divider.Parent = sidebar
local dividerInteract = Instance.new("TextButton")
dividerInteract.Name = "DividerInteract"
dividerInteract.AnchorPoint = Vector2.new(0.5, 0)
dividerInteract.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dividerInteract.BackgroundTransparency = 1
dividerInteract.BorderColor3 = Color3.fromRGB(0, 0, 0)
dividerInteract.BorderSizePixel = 0
dividerInteract.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
dividerInteract.Position = UDim2.fromScale(0.5, 0)
dividerInteract.Size = UDim2.new(1, 6, 1, 0)
dividerInteract.Text = ""
dividerInteract.TextColor3 = Color3.fromRGB(0, 0, 0)
dividerInteract.TextSize = 14
dividerInteract.Parent = divider
local windowControls = Instance.new("Frame")
windowControls.Name = "WindowControls"
windowControls.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
windowControls.BackgroundTransparency = 1
windowControls.BorderColor3 = Color3.fromRGB(0, 0, 0)
windowControls.BorderSizePixel = 0
windowControls.Size = UDim2.new(1, 0, 0, 31)
windowControls.Visible = false
local controls = Instance.new("Frame")
controls.Name = "Controls"
controls.BackgroundColor3 = Color3.fromRGB(119, 174, 94)
controls.BackgroundTransparency = 1
controls.BorderColor3 = Color3.fromRGB(0, 0, 0)
controls.BorderSizePixel = 0
controls.Size = UDim2.fromScale(1, 1)
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "UIListLayout"
uIListLayout.Padding = UDim.new(0, 5)
uIListLayout.FillDirection = Enum.FillDirection.Horizontal
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uIListLayout.Parent = controls
local uIPadding = Instance.new("UIPadding")
uIPadding.Name = "UIPadding"
uIPadding.PaddingLeft = UDim.new(0, 11)
uIPadding.Parent = controls
local windowControlSettings = {
sizes = { enabled = UDim2.fromOffset(8, 8), disabled = UDim2.fromOffset(7, 7) },
transparencies = { enabled = 0, disabled = 1 },
strokeTransparency = 0.9,
}
local stroke = Instance.new("UIStroke")
stroke.Name = "BaseUIStroke"
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = windowControlSettings.strokeTransparency
local exit = Instance.new("TextButton")
exit.Name = "Exit"
exit.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
exit.Text = ""
exit.TextColor3 = Color3.fromRGB(0, 0, 0)
exit.TextSize = 14
exit.AutoButtonColor = false
exit.BackgroundColor3 = Color3.fromRGB(250, 93, 86)
exit.BorderColor3 = Color3.fromRGB(0, 0, 0)
exit.BorderSizePixel = 0
local uICorner = Instance.new("UICorner")
uICorner.Name = "UICorner"
uICorner.CornerRadius = UDim.new(1, 0)
uICorner.Parent = exit
exit.Parent = controls
local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"
minimize.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
minimize.Text = ""
minimize.TextColor3 = Color3.fromRGB(0, 0, 0)
minimize.TextSize = 14
minimize.AutoButtonColor = false
minimize.BackgroundColor3 = Color3.fromRGB(252, 190, 57)
minimize.BorderColor3 = Color3.fromRGB(0, 0, 0)
minimize.BorderSizePixel = 0
minimize.LayoutOrder = 1
local uICorner1 = Instance.new("UICorner")
uICorner1.Name = "UICorner"
uICorner1.CornerRadius = UDim.new(1, 0)
uICorner1.Parent = minimize
minimize.Parent = controls
local maximize = Instance.new("TextButton")
maximize.Name = "Maximize"
maximize.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
maximize.Text = ""
maximize.TextColor3 = Color3.fromRGB(0, 0, 0)
maximize.TextSize = 14
maximize.AutoButtonColor = false
maximize.BackgroundColor3 = Color3.fromRGB(119, 174, 94)
maximize.BorderColor3 = Color3.fromRGB(0, 0, 0)
maximize.BorderSizePixel = 0
maximize.LayoutOrder = 1
local uICorner2 = Instance.new("UICorner")
uICorner2.Name = "UICorner"
uICorner2.CornerRadius = UDim.new(1, 0)
uICorner2.Parent = maximize
maximize.Parent = controls
local function applyState(button, enabled)
local size = enabled and windowControlSettings.sizes.enabled or windowControlSettings.sizes.disabled
local transparency = enabled and windowControlSettings.transparencies.enabled or windowControlSettings.transparencies.disabled
button.Size = size
button.BackgroundTransparency = transparency
button.Active = enabled
button.Interactable = enabled
for _, child in ipairs(button:GetChildren()) do
if child:IsA("UIStroke") then
child.Transparency = transparency
end
end
if not enabled then
stroke:Clone().Parent = button
end
end
applyState(maximize, false)
local controlsList = {exit, minimize}
for _, button in pairs(controlsList) do
local buttonName = button.Name
local isEnabled = true
if Settings.DisabledWindowControls and table.find(Settings.DisabledWindowControls, buttonName) then
isEnabled = false
end
applyState(button, isEnabled)
end
controls.Parent = windowControls
local divider1 = Instance.new("Frame")
divider1.Name = "Divider"
divider1.AnchorPoint = Vector2.new(0, 1)
divider1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider1.BackgroundTransparency = 0.9
divider1.BorderColor3 = Color3.fromRGB(0, 0, 0)
divider1.BorderSizePixel = 0
divider1.Position = UDim2.fromScale(0, 1)
divider1.Size = UDim2.new(1, 0, 0, 1)
divider1.Parent = windowControls
windowControls.Parent = sidebar
local information = Instance.new("Frame")
information.Name = "Information"
information.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
information.BackgroundTransparency = 1
information.BorderColor3 = Color3.fromRGB(0, 0, 0)
information.BorderSizePixel = 0
information.Position = UDim2.fromOffset(0, 0)
information.Size = UDim2.new(1, 0, 0, 75)
local divider2 = Instance.new("Frame")
divider2.Name = "Divider"
divider2.AnchorPoint = Vector2.new(0, 1)
divider2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider2.BackgroundTransparency = 0.9
divider2.BorderColor3 = Color3.fromRGB(0, 0, 0)
divider2.BorderSizePixel = 0
divider2.Position = UDim2.fromScale(0, 1)
divider2.Size = UDim2.new(1, 0, 0, 1)
divider2.Parent = information
local informationHolder = Instance.new("Frame")
informationHolder.Name = "InformationHolder"
informationHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
informationHolder.BackgroundTransparency = 1
informationHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
informationHolder.BorderSizePixel = 0
informationHolder.Size = UDim2.fromScale(1, 1)
local informationHolderUIPadding = Instance.new("UIPadding")
informationHolderUIPadding.Name = "InformationHolderUIPadding"
informationHolderUIPadding.PaddingBottom = UDim.new(0, 10)
informationHolderUIPadding.PaddingLeft = UDim.new(0, 23)
informationHolderUIPadding.PaddingRight = UDim.new(0, 22)
informationHolderUIPadding.PaddingTop = UDim.new(0, 10)
informationHolderUIPadding.Parent = informationHolder
local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
titleFrame.BackgroundTransparency = 1
titleFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
titleFrame.BorderSizePixel = 0
titleFrame.Size = UDim2.fromScale(1, 1)
local title = Instance.new("TextLabel")
title.Name = "Title"
title.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.SemiBold,
Enum.FontStyle.Normal
)
title.Text = Settings.Title
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.RichText = true
title.TextSize = 20
title.TextTransparency = 0.1
title.TextTruncate = Enum.TextTruncate.SplitWord
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Top
title.AutomaticSize = Enum.AutomaticSize.Y
title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.BorderColor3 = Color3.fromRGB(0, 0, 0)
title.BorderSizePixel = 0
title.Size = UDim2.new(1, -20, 0, 0)
title.Parent = titleFrame
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
subtitle.RichText = true
subtitle.Text = Settings.Subtitle
subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
subtitle.TextSize = 13
subtitle.TextTransparency = 0.7
subtitle.TextTruncate = Enum.TextTruncate.SplitWord
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Top
subtitle.AutomaticSize = Enum.AutomaticSize.Y
subtitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
subtitle.BackgroundTransparency = 1
subtitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
subtitle.BorderSizePixel = 0
subtitle.LayoutOrder = 1
subtitle.Size = UDim2.new(1, -20, 0, 0)
subtitle.Parent = titleFrame
local titleFrameUIListLayout = Instance.new("UIListLayout")
titleFrameUIListLayout.Name = "TitleFrameUIListLayout"
titleFrameUIListLayout.Padding = UDim.new(0, 3)
titleFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
titleFrameUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
titleFrameUIListLayout.Parent = titleFrame
titleFrame.Parent = informationHolder
informationHolder.Parent = information
information.Parent = sidebar
local sidebarGroup = Instance.new("Frame")
sidebarGroup.Name = "SidebarGroup"
sidebarGroup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sidebarGroup.BackgroundTransparency = 1
sidebarGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
sidebarGroup.BorderSizePixel = 0
sidebarGroup.Position = UDim2.fromOffset(0, 75)
sidebarGroup.Size = UDim2.new(1, 0, 1, -75)
local userInfo = Instance.new("Frame")
userInfo.Name = "UserInfo"
userInfo.AnchorPoint = Vector2.new(0, 1)
userInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
userInfo.BackgroundTransparency = 1
userInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
userInfo.BorderSizePixel = 0
userInfo.Position = UDim2.fromScale(0, 1)
userInfo.Size = UDim2.new(1, 0, 0, 64)
local userInfoDivider = Instance.new("Frame")
userInfoDivider.Name = "UserInfoDivider"
userInfoDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
userInfoDivider.BackgroundTransparency = 0.92
userInfoDivider.BorderColor3 = Color3.fromRGB(0, 0, 0)
userInfoDivider.BorderSizePixel = 0
userInfoDivider.Position = UDim2.new(0, 10, 0, 0)
userInfoDivider.Size = UDim2.new(1, -20, 0, 1)
userInfoDivider.Parent = userInfo
local informationGroup = Instance.new("Frame")
informationGroup.Name = "InformationGroup"
informationGroup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
informationGroup.BackgroundTransparency = 1
informationGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
informationGroup.BorderSizePixel = 0
informationGroup.Size = UDim2.fromScale(1, 1)
local informationGroupUIPadding = Instance.new("UIPadding")
informationGroupUIPadding.Name = "InformationGroupUIPadding"
informationGroupUIPadding.PaddingBottom = UDim.new(0, 0)
informationGroupUIPadding.PaddingLeft = UDim.new(0, 10)
informationGroupUIPadding.PaddingRight = UDim.new(0, 10)
informationGroupUIPadding.PaddingTop = UDim.new(0, 0)
informationGroupUIPadding.Parent = informationGroup
local informationGroupUIListLayout = Instance.new("UIListLayout")
informationGroupUIListLayout.Name = "InformationGroupUIListLayout"
informationGroupUIListLayout.FillDirection = Enum.FillDirection.Horizontal
informationGroupUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
informationGroupUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
informationGroupUIListLayout.Parent = informationGroup
local userId = LocalPlayer.UserId
local thumbType = Enum.ThumbnailType.AvatarBust
local thumbSize = Enum.ThumbnailSize.Size48x48
local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
local headshot = Instance.new("ImageLabel")
headshot.Name = "Headshot"
headshot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
headshot.BackgroundTransparency = 1
headshot.BorderColor3 = Color3.fromRGB(0, 0, 0)
headshot.BorderSizePixel = 0
headshot.Size = UDim2.fromOffset(36, 36)
headshot.Image = (isReady and headshotImage) or "rbxassetid://0"
local uICorner3 = Instance.new("UICorner")
uICorner3.Name = "UICorner"
uICorner3.CornerRadius = UDim.new(1, 0)
uICorner3.Parent = headshot
local baseUIStroke2 = Instance.new("UIStroke")
baseUIStroke2.Name = "BaseUIStroke"
baseUIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
baseUIStroke2.Color = Color3.fromRGB(255, 255, 255)
baseUIStroke2.Transparency = 0.85
baseUIStroke2.Parent = headshot
headshot.Parent = informationGroup
local userAndDisplayFrame = Instance.new("Frame")
userAndDisplayFrame.Name = "UserAndDisplayFrame"
userAndDisplayFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
userAndDisplayFrame.BackgroundTransparency = 1
userAndDisplayFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
userAndDisplayFrame.BorderSizePixel = 0
userAndDisplayFrame.LayoutOrder = 1
userAndDisplayFrame.Size = UDim2.new(1, -44, 0, 36)
local displayName = Instance.new("TextLabel")
displayName.Name = "DisplayName"
displayName.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.SemiBold,
Enum.FontStyle.Normal
)
displayName.Text = LocalPlayer.DisplayName
displayName.TextColor3 = Color3.fromRGB(255, 255, 255)
displayName.TextSize = 13
displayName.TextTransparency = 0.1
displayName.TextTruncate = Enum.TextTruncate.SplitWord
displayName.TextXAlignment = Enum.TextXAlignment.Left
displayName.TextYAlignment = Enum.TextYAlignment.Top
displayName.AutomaticSize = Enum.AutomaticSize.XY
displayName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
displayName.BackgroundTransparency = 1
displayName.BorderColor3 = Color3.fromRGB(0, 0, 0)
displayName.BorderSizePixel = 0
displayName.Parent = userAndDisplayFrame
displayName.Size = UDim2.fromScale(1,0)
local userAndDisplayFrameUIPadding = Instance.new("UIPadding")
userAndDisplayFrameUIPadding.Name = "UserAndDisplayFrameUIPadding"
userAndDisplayFrameUIPadding.PaddingLeft = UDim.new(0, 8)
userAndDisplayFrameUIPadding.PaddingTop = UDim.new(0, 4)
userAndDisplayFrameUIPadding.Parent = userAndDisplayFrame
local userAndDisplayFrameUIListLayout = Instance.new("UIListLayout")
userAndDisplayFrameUIListLayout.Name = "UserAndDisplayFrameUIListLayout"
userAndDisplayFrameUIListLayout.Padding = UDim.new(0, 1)
userAndDisplayFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
userAndDisplayFrameUIListLayout.Parent = userAndDisplayFrame
local username = Instance.new("TextLabel")
username.Name = "Username"
username.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
username.Text = "@" .. LocalPlayer.Name
username.TextColor3 = Color3.fromRGB(255, 255, 255)
username.TextSize = 11
username.TextTransparency = 0.6
username.TextTruncate = Enum.TextTruncate.SplitWord
username.TextXAlignment = Enum.TextXAlignment.Left
username.TextYAlignment = Enum.TextYAlignment.Top
username.AutomaticSize = Enum.AutomaticSize.XY
username.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
username.BackgroundTransparency = 1
username.BorderColor3 = Color3.fromRGB(0, 0, 0)
username.BorderSizePixel = 0
username.LayoutOrder = 1
username.Parent = userAndDisplayFrame
username.Size = UDim2.fromScale(1,0)
userAndDisplayFrame.Parent = informationGroup
informationGroup.Parent = userInfo
userInfo.Parent = sidebarGroup
local sidebarGroupUIPadding = Instance.new("UIPadding")
sidebarGroupUIPadding.Name = "SidebarGroupUIPadding"
sidebarGroupUIPadding.PaddingLeft = UDim.new(0, 10)
sidebarGroupUIPadding.PaddingRight = UDim.new(0, 10)
sidebarGroupUIPadding.PaddingTop = UDim.new(0, 13)
sidebarGroupUIPadding.Parent = sidebarGroup
local tabSwitchers = Instance.new("Frame")
tabSwitchers.Name = "TabSwitchers"
tabSwitchers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabSwitchers.BackgroundTransparency = 1
tabSwitchers.BorderColor3 = Color3.fromRGB(0, 0, 0)
tabSwitchers.BorderSizePixel = 0
tabSwitchers.Size = UDim2.new(1, 0, 1, -64)
local tabSwitchersScrollingFrame = Instance.new("ScrollingFrame")
tabSwitchersScrollingFrame.Name = "TabSwitchersScrollingFrame"
tabSwitchersScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabSwitchersScrollingFrame.BottomImage = ""
tabSwitchersScrollingFrame.CanvasSize = UDim2.new()
tabSwitchersScrollingFrame.ScrollBarImageTransparency = 0.8
tabSwitchersScrollingFrame.ScrollBarThickness = 1
tabSwitchersScrollingFrame.TopImage = ""
tabSwitchersScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabSwitchersScrollingFrame.BackgroundTransparency = 1
tabSwitchersScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
tabSwitchersScrollingFrame.BorderSizePixel = 0
tabSwitchersScrollingFrame.Size = UDim2.fromScale(1, 1)
local tabSwitchersScrollingFrameUIListLayout = Instance.new("UIListLayout")
tabSwitchersScrollingFrameUIListLayout.Name = "TabSwitchersScrollingFrameUIListLayout"
tabSwitchersScrollingFrameUIListLayout.Padding = UDim.new(0, 17)
tabSwitchersScrollingFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabSwitchersScrollingFrameUIListLayout.Parent = tabSwitchersScrollingFrame
local tabSwitchersScrollingFrameUIPadding = Instance.new("UIPadding")
tabSwitchersScrollingFrameUIPadding.Name = "TabSwitchersScrollingFrameUIPadding"
tabSwitchersScrollingFrameUIPadding.PaddingTop = UDim.new(0, 2)
tabSwitchersScrollingFrameUIPadding.Parent = tabSwitchersScrollingFrame
tabSwitchersScrollingFrame.Parent = tabSwitchers
tabSwitchers.Parent = sidebarGroup
sidebarGroup.Parent = sidebar
sidebar.Parent = base
local content = Instance.new("Frame")
content.Name = "Content"
content.AnchorPoint = Vector2.new(1, 0)
content.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
content.BackgroundTransparency = 1
content.BorderColor3 = Color3.fromRGB(0, 0, 0)
content.BorderSizePixel = 0
content.Position = UDim2.fromScale(1, 4.69e-08)
local function getSidebarWidthUnscaled()
local baseWidth = base.Size.X.Offset
return baseWidth * sidebar.Size.X.Scale + sidebar.Size.X.Offset
end
local function updateContentWidth()
content.Size = UDim2.new(0, base.Size.X.Offset - getSidebarWidthUnscaled(), 1, 0)
end
updateContentWidth()
base:GetPropertyChangedSignal("Size"):Connect(updateContentWidth)
sidebar:GetPropertyChangedSignal("Size"):Connect(updateContentWidth)
local resizingContent = false
local initialMouseX, initialSidebarWidth
local snapRange = 20
local minSidebarWidth = 107
local TweenSettings = {
DefaultTransparency = 0.9,
HoverTransparency = 0.85,
EasingStyle = Enum.EasingStyle.Sine
}
local function ChangeState(State)
Tween(divider, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
BackgroundTransparency = State == "Idle" and TweenSettings.DefaultTransparency or TweenSettings.HoverTransparency
}):Play()
end
dividerInteract.MouseEnter:Connect(function()
ChangeState("Hover")
end)
dividerInteract.MouseLeave:Connect(function()
ChangeState("Idle")
end)
dividerInteract.MouseButton1Down:Connect(function()
resizingContent = true
initialMouseX = UserInputService:GetMouseLocation().X
initialSidebarWidth = getSidebarWidthUnscaled()
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
resizingContent = false
end
end)
UserInputService.InputChanged:Connect(function(input)
if resizingContent and input.UserInputType == Enum.UserInputType.MouseMovement then
local scale = baseUIScale.Scale
local deltaX = (UserInputService:GetMouseLocation().X - initialMouseX) / scale
local defaultSidebarWidth = base.Size.X.Offset * 0.28
local newSidebarWidth = initialSidebarWidth + deltaX
if math.abs(newSidebarWidth - defaultSidebarWidth) < snapRange then
newSidebarWidth = defaultSidebarWidth
else
newSidebarWidth = math.clamp(newSidebarWidth, minSidebarWidth, base.Size.X.Offset - minSidebarWidth)
end
sidebar.Size = UDim2.new(0, newSidebarWidth, 1, 0)
updateContentWidth()
end
end)
local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
topbar.BackgroundTransparency = 1
topbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
topbar.BorderSizePixel = 0
topbar.Size = UDim2.new(1, 0, 0, 75)
local divider4 = Instance.new("Frame")
divider4.Name = "Divider"
divider4.AnchorPoint = Vector2.new(0, 1)
divider4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider4.BackgroundTransparency = 0.9
divider4.BorderColor3 = Color3.fromRGB(0, 0, 0)
divider4.BorderSizePixel = 0
divider4.Position = UDim2.fromScale(0, 1)
divider4.Size = UDim2.new(1, 0, 0, 1)
divider4.Parent = topbar
local elements = Instance.new("Frame")
elements.Name = "Elements"
elements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
elements.BackgroundTransparency = 1
elements.BorderColor3 = Color3.fromRGB(0, 0, 0)
elements.BorderSizePixel = 0
elements.Size = UDim2.fromScale(1, 1)
local uIPadding2 = Instance.new("UIPadding")
uIPadding2.Name = "UIPadding"
uIPadding2.PaddingLeft = UDim.new(0, 20)
uIPadding2.PaddingRight = UDim.new(0, 20)
uIPadding2.Parent = elements
local moveIcon = Instance.new("ImageButton")
moveIcon.Name = "MoveIcon"
moveIcon.Image = assets.transform
moveIcon.ImageTransparency = 0.7
moveIcon.AnchorPoint = Vector2.new(1, 0)
moveIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
moveIcon.BackgroundTransparency = 1
moveIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
moveIcon.BorderSizePixel = 0
moveIcon.Position = UDim2.new(1, 0, 0, 24)
moveIcon.Size = UDim2.fromOffset(15, 15)
moveIcon.Parent = elements
moveIcon.Visible = not Settings.DragStyle or Settings.DragStyle == 1
local interact = Instance.new("TextButton")
interact.Name = "Interact"
interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
interact.Text = ""
interact.TextColor3 = Color3.fromRGB(0, 0, 0)
interact.TextSize = 14
interact.AnchorPoint = Vector2.new(0.5, 0.5)
interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
interact.BackgroundTransparency = 1
interact.BorderColor3 = Color3.fromRGB(0, 0, 0)
interact.BorderSizePixel = 0
interact.Position = UDim2.fromScale(0.5, 0.5)
interact.Size = UDim2.fromOffset(40, 40)
interact.Parent = moveIcon
local function ChangemoveIconState(State)
if State == "Default" then
Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
ImageTransparency = 0.7
}):Play()
elseif State == "Hover" then
Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
ImageTransparency = 0.4
}):Play()
end
end
interact.MouseEnter:Connect(function()
ChangemoveIconState("Hover")
end)
interact.MouseLeave:Connect(function()
ChangemoveIconState("Default")
end)
local dragging_ = false
local dragInput
local dragStart
local startPos
local function update(input)
local delta = input.Position - dragStart
base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
local function onDragStart(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging_ = true
dragStart = input.Position
startPos = base.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging_ = false
end
end)
end
end
local function onDragUpdate(input)
if dragging_ and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
dragInput = input
end
end
if not Settings.DragStyle or Settings.DragStyle == 1 then
interact.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
onDragStart(input)
end
end)
interact.InputChanged:Connect(onDragUpdate)
UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging_ then
update(input)
end
end)
interact.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging_ = false
end
end)
elseif Settings.DragStyle == 2 then
base.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
onDragStart(input)
end
end)
base.InputChanged:Connect(onDragUpdate)
UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging_ then
update(input)
end
end)
base.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging_ = false
end
end)
end
local currentTab = Instance.new("TextLabel")
currentTab.Name = "CurrentTab"
currentTab.FontFace = Font.new(assets.interFont)
currentTab.RichText = true
currentTab.Text = ""
currentTab.TextColor3 = Color3.fromRGB(255, 255, 255)
currentTab.TextSize = 15
currentTab.TextTransparency = 0.5
currentTab.TextTruncate = Enum.TextTruncate.SplitWord
currentTab.TextXAlignment = Enum.TextXAlignment.Left
currentTab.TextYAlignment = Enum.TextYAlignment.Top
currentTab.AnchorPoint = Vector2.new(0, 0.5)
currentTab.AutomaticSize = Enum.AutomaticSize.Y
currentTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
currentTab.BackgroundTransparency = 1
currentTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
currentTab.BorderSizePixel = 0
currentTab.Position = UDim2.new(0, 0, 0.5, 0)
currentTab.Size = UDim2.new(0.9, 0, 0, 0)
currentTab.Parent = elements
elements.Parent = topbar
topbar.Parent = content
content.Parent = base
base.Parent = macLib
function WindowFunctions:UpdateTitle(NewTitle)
title.Text = NewTitle
end
function WindowFunctions:UpdateSubtitle(NewSubtitle)
subtitle.Text = NewSubtitle
end
local BlurTarget = base
local HS = HttpService
local camera = workspace.CurrentCamera
local MTREL = "Glass"
local binds = {}
local wedgeguid = HS:GenerateGUID(true)
local DepthOfField
for _,v in pairs(Lighting:GetChildren()) do
if not v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
DepthOfField = Instance.new('DepthOfFieldEffect')
DepthOfField.FarIntensity = 0
DepthOfField.FocusDistance = 51.6
DepthOfField.InFocusRadius = 50
DepthOfField.NearIntensity = 1
DepthOfField.Name = HS:GenerateGUID(true)
DepthOfField:AddTag(".")
elseif v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
DepthOfField = v
end
end
if not DepthOfField then
DepthOfField = Instance.new('DepthOfFieldEffect')
DepthOfField.FarIntensity = 0
DepthOfField.FocusDistance = 51.6
DepthOfField.InFocusRadius = 50
DepthOfField.NearIntensity = 1
DepthOfField.Name = HS:GenerateGUID(true)
DepthOfField:AddTag(".")
end
local frame = Instance.new('Frame')
frame.Parent = BlurTarget
frame.Size = UDim2.new(0.97, 0, 0.97, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundTransparency = 1
frame.Name = HS:GenerateGUID(true)
do
local function IsNotNaN(x)
return x == x
end
local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
while not continue do
RunService.RenderStepped:Wait()
continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
end
end
local DrawQuad; do
local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
local sz = 0.2
local function DrawTriangle(v1, v2, v3, p0, p1)
local s1 = (v1 - v2).magnitude
local s2 = (v2 - v3).magnitude
local s3 = (v3 - v1).magnitude
local smax = max(s1, s2, s3)
local A, B, C
if s1 == smax then
A, B, C = v1, v2, v3
elseif s2 == smax then
A, B, C = v2, v3, v1
elseif s3 == smax then
A, B, C = v3, v1, v2
end
local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
local perp = sqrt((C-A).magnitude^2 - para*para)
local dif_para = (A - B).magnitude - para
local st = CFrame.new(B, A)
local za = CFrame.Angles(pi/2,0,0)
local cf0 = st
local Top_Look = (cf0 * za).lookVector
local Mid_Point = A + CFrame.new(A, B).lookVector * para
local Needed_Look = CFrame.new(Mid_Point, C).lookVector
local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z
local ac = CFrame.Angles(0, 0, acos(dot))
cf0 = cf0 * ac
if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
end
cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))
local cf1 = st * ac * CFrame.Angles(0, math.pi, 0)
if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
end
cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)
if not p0 then
p0 = Instance.new('Part')
p0.FormFactor = 'Custom'
p0.TopSurface = 0
p0.BottomSurface = 0
p0.Anchored = true
p0.CanCollide = false
p0.CastShadow = false
p0.Material = MTREL
p0.Size = Vector3.new(sz, sz, sz)
p0.Name = HS:GenerateGUID(true)
local mesh = Instance.new('SpecialMesh', p0)
mesh.MeshType = 2
mesh.Name = wedgeguid
end
p0[wedgeguid].Scale = Vector3.new(0, perp/sz, para/sz)
p0.CFrame = cf0
if not p1 then
p1 = p0:clone()
end
p1[wedgeguid].Scale = Vector3.new(0, perp/sz, dif_para/sz)
p1.CFrame = cf1
return p0, p1
end
function DrawQuad(v1, v2, v3, v4, parts)
parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
end
end
if binds[frame] then
return binds[frame].parts
end
local parts = {}
local parents = {}
do
local function add(child)
if child:IsA'GuiObject' then
parents[#parents + 1] = child
add(child.Parent)
end
end
add(frame)
end
local function IsVisible(instance)
while instance do
if instance:IsA("GuiObject") then
if not instance.Visible then
return false
end
elseif instance:IsA("ScreenGui") then
if not instance.Enabled then
return false
end
break
end
instance = instance.Parent
end
return true
end
local function UpdateOrientation(fetchProps)
if not IsVisible(frame) or not acrylicBlur or unloaded then
for _, pt in pairs(parts) do
pt.Parent = nil
DepthOfField.Enabled = false
DepthOfField.Parent = nil
end
return
end
if not DepthOfField.Parent then
DepthOfField.Parent = Lighting
end
DepthOfField.Enabled = true
local properties = {
Transparency = 0.98;
BrickColor = BrickColor.new('Institutional white');
}
local zIndex = 1 - 0.05*frame.ZIndex
local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
do
local rot = 0;
for _, v in ipairs(parents) do
rot = rot + v.Rotation
end
if rot ~= 0 and rot%180 ~= 0 then
local mid = tl:lerp(br, 0.5)
local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
local vec = tl
tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
end
end
DrawQuad(
camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
parts
)
if fetchProps then
for _, pt in pairs(parts) do
pt.Parent = camera
end
for propName, propValue in pairs(properties) do
for _, pt in pairs(parts) do
pt[propName] = propValue
end
end
end
end
UpdateOrientation(true)
RunService.RenderStepped:Connect(UpdateOrientation)
function WindowFunctions:GlobalSetting(Settings)
return {UpdateName = function() end, UpdateState = function() end}
end
function WindowFunctions:TabGroup()
local TOPBAR_CLOSED = 75
local CHIP_HEIGHT = 38
local CHIP_TOP = 18
local EXPAND_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local SectionFunctions = {}
local tabGroup = Instance.new("Frame")
tabGroup.Name = "Section"
tabGroup.AutomaticSize = Enum.AutomaticSize.Y
tabGroup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabGroup.BackgroundTransparency = 1
tabGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
tabGroup.BorderSizePixel = 0
tabGroup.Size = UDim2.fromScale(1, 0)
local divider3 = Instance.new("Frame")
divider3.Name = "Divider"
divider3.AnchorPoint = Vector2.new(0.5, 1)
divider3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider3.BackgroundTransparency = 0.9
divider3.BorderColor3 = Color3.fromRGB(0, 0, 0)
divider3.BorderSizePixel = 0
divider3.Position = UDim2.fromScale(0.5, 1)
divider3.Size = UDim2.new(1, -21, 0, 1)
divider3.Parent = tabGroup
local sectionTabSwitchers = Instance.new("Frame")
sectionTabSwitchers.Name = "SectionTabSwitchers"
sectionTabSwitchers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sectionTabSwitchers.BackgroundTransparency = 1
sectionTabSwitchers.BorderColor3 = Color3.fromRGB(0, 0, 0)
sectionTabSwitchers.BorderSizePixel = 0
sectionTabSwitchers.Size = UDim2.fromScale(1, 1)
local uIListLayout1 = Instance.new("UIListLayout")
uIListLayout1.Name = "UIListLayout"
uIListLayout1.Padding = UDim.new(0, 15)
uIListLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout1.Parent = sectionTabSwitchers
local uIPadding1 = Instance.new("UIPadding")
uIPadding1.Name = "UIPadding"
uIPadding1.PaddingBottom = UDim.new(0, 15)
uIPadding1.Parent = sectionTabSwitchers
sectionTabSwitchers.Parent = tabGroup
tabGroup.Parent = tabSwitchersScrollingFrame
function SectionFunctions:Tab(Settings)
local TabFunctions = {Settings = Settings}
local tabSwitcher = Instance.new("TextButton")
tabSwitcher.Name = "TabSwitcher"
tabSwitcher.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
tabSwitcher.Text = ""
tabSwitcher.TextColor3 = Color3.fromRGB(0, 0, 0)
tabSwitcher.TextSize = 14
tabSwitcher.AutoButtonColor = false
tabSwitcher.AnchorPoint = Vector2.new(0.5, 0)
tabSwitcher.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabSwitcher.BackgroundTransparency = 1
tabSwitcher.BorderColor3 = Color3.fromRGB(0, 0, 0)
tabSwitcher.BorderSizePixel = 0
tabSwitcher.Position = UDim2.fromScale(0.5, 0)
tabSwitcher.Size = UDim2.new(1, -21, 0, 40)
tabIndex += 1
tabSwitcher.LayoutOrder = tabIndex
local tabSwitcherUICorner = Instance.new("UICorner")
tabSwitcherUICorner.Name = "TabSwitcherUICorner"
tabSwitcherUICorner.Parent = tabSwitcher
local tabSwitcherUIStroke = Instance.new("UIStroke")
tabSwitcherUIStroke.Name = "TabSwitcherUIStroke"
tabSwitcherUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tabSwitcherUIStroke.Color = Color3.fromRGB(255, 255, 255)
tabSwitcherUIStroke.Transparency = 1
tabSwitcherUIStroke.Parent = tabSwitcher
local tabSwitcherUIListLayout = Instance.new("UIListLayout")
tabSwitcherUIListLayout.Name = "TabSwitcherUIListLayout"
tabSwitcherUIListLayout.Padding = UDim.new(0, 9)
tabSwitcherUIListLayout.FillDirection = Enum.FillDirection.Horizontal
tabSwitcherUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabSwitcherUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabSwitcherUIListLayout.Parent = tabSwitcher
local tabImage
local tabIconId = Settings.Image and resolveIcon(Settings.Image)
if tabIconId then
tabImage = Instance.new("ImageLabel")
tabImage.Name = "TabImage"
tabImage.Image = tabIconId
tabImage.ImageTransparency = 0.5
tabImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabImage.BackgroundTransparency = 1
tabImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
tabImage.BorderSizePixel = 0
tabImage.Size = UDim2.fromOffset(18, 18)
tabImage.Parent = tabSwitcher
end
local tabSwitcherName = Instance.new("TextLabel")
tabSwitcherName.Name = "TabSwitcherName"
tabSwitcherName.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
tabSwitcherName.Text = Settings.Name
tabSwitcherName.RichText = true
tabSwitcherName.TextColor3 = Color3.fromRGB(255, 255, 255)
tabSwitcherName.TextSize = 16
tabSwitcherName.TextTransparency = 0.5
tabSwitcherName.TextTruncate = Enum.TextTruncate.SplitWord
tabSwitcherName.TextXAlignment = Enum.TextXAlignment.Left
tabSwitcherName.TextYAlignment = Enum.TextYAlignment.Top
tabSwitcherName.AutomaticSize = Enum.AutomaticSize.Y
tabSwitcherName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabSwitcherName.BackgroundTransparency = 1
tabSwitcherName.BorderColor3 = Color3.fromRGB(0, 0, 0)
tabSwitcherName.BorderSizePixel = 0
tabSwitcherName.Size = UDim2.fromScale(1, 0)
tabSwitcherName.Parent = tabSwitcher
tabSwitcherName.LayoutOrder = 1
local tabSwitcherUIPadding = Instance.new("UIPadding")
tabSwitcherUIPadding.Name = "TabSwitcherUIPadding"
tabSwitcherUIPadding.PaddingLeft = UDim.new(0, 18)
tabSwitcherUIPadding.PaddingRight = UDim.new(0, 18)
tabSwitcherUIPadding.PaddingTop = UDim.new(0, 1)
tabSwitcherUIPadding.Parent = tabSwitcher
tabSwitcher.Parent = sectionTabSwitchers
local elements1 = Instance.new("Frame")
elements1.Name = "Elements"
elements1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
elements1.BackgroundTransparency = 1
elements1.BorderColor3 = Color3.fromRGB(0, 0, 0)
elements1.BorderSizePixel = 0
elements1.Position = UDim2.fromOffset(0, TOPBAR_CLOSED)
elements1.Size = UDim2.new(1, 0, 1, -TOPBAR_CLOSED)
elements1.ClipsDescendants = true
local elementsUIPadding = Instance.new("UIPadding")
elementsUIPadding.Name = "ElementsUIPadding"
elementsUIPadding.PaddingRight = UDim.new(0, 5)
elementsUIPadding.PaddingTop = UDim.new(0, 10)
elementsUIPadding.PaddingBottom = UDim.new(0, 10)
elementsUIPadding.Parent = elements1
local elementsScrolling = Instance.new("ScrollingFrame")
elementsScrolling.Name = "ElementsScrolling"
elementsScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
elementsScrolling.BottomImage = ""
elementsScrolling.CanvasSize = UDim2.new()
elementsScrolling.ScrollBarImageTransparency = 0.5
elementsScrolling.ScrollBarThickness = 1
elementsScrolling.TopImage = ""
elementsScrolling.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
elementsScrolling.BackgroundTransparency = 1
elementsScrolling.BorderColor3 = Color3.fromRGB(0, 0, 0)
elementsScrolling.BorderSizePixel = 0
elementsScrolling.Size = UDim2.fromScale(1, 1)
elementsScrolling.ClipsDescendants = false
local elementsScrollingUIPadding = Instance.new("UIPadding")
elementsScrollingUIPadding.Name = "ElementsScrollingUIPadding"
elementsScrollingUIPadding.PaddingBottom = UDim.new(0, 5)
elementsScrollingUIPadding.PaddingLeft = UDim.new(0, 11)
elementsScrollingUIPadding.PaddingRight = UDim.new(0, 3)
elementsScrollingUIPadding.PaddingTop = UDim.new(0, 5)
elementsScrollingUIPadding.Parent = elementsScrolling
local elementsScrollingUIListLayout = Instance.new("UIListLayout")
elementsScrollingUIListLayout.Name = "ElementsScrollingUIListLayout"
elementsScrollingUIListLayout.Padding = UDim.new(0, 15)
elementsScrollingUIListLayout.FillDirection = Enum.FillDirection.Horizontal
elementsScrollingUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
elementsScrollingUIListLayout.Parent = elementsScrolling
local left = Instance.new("Frame")
left.Name = "Left"
left.AutomaticSize = Enum.AutomaticSize.Y
left.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
left.BackgroundTransparency = 1
left.BorderColor3 = Color3.fromRGB(0, 0, 0)
left.BorderSizePixel = 0
left.Position = UDim2.fromScale(0.512, 0)
left.Size = UDim2.new(0.5, -10, 0, 0)
local leftUIListLayout = Instance.new("UIListLayout")
leftUIListLayout.Name = "LeftUIListLayout"
leftUIListLayout.Padding = UDim.new(0, 15)
leftUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftUIListLayout.Parent = left
left.Parent = elementsScrolling
local right = Instance.new("Frame")
right.Name = "Right"
right.AutomaticSize = Enum.AutomaticSize.Y
right.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
right.BackgroundTransparency = 1
right.BorderColor3 = Color3.fromRGB(0, 0, 0)
right.BorderSizePixel = 0
right.LayoutOrder = 1
right.Position = UDim2.fromScale(0.512, 0)
right.Size = UDim2.new(0.5, -10, 0, 0)
local rightUIListLayout = Instance.new("UIListLayout")
rightUIListLayout.Name = "RightUIListLayout"
rightUIListLayout.Padding = UDim.new(0, 15)
rightUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightUIListLayout.Parent = right
right.Parent = elementsScrolling
elementsScrolling.Parent = elements1
--// Subtab system (inline expanding dropdown, aligned to the left column)
local subtabs = {}
local subtabOrder = {}
local currentSubTab = nil
local defaultPage = elementsScrolling
local pageTemplate = elementsScrolling:Clone()
pageTemplate.Name = "SubtabPageTemplate"
pageTemplate.Parent = nil
local function makePage()
local page = pageTemplate:Clone()
page.Name = "SubtabPage"
page.Parent = elements1
page.Visible = false
return page, page:WaitForChild("Left"), page:WaitForChild("Right")
end
local SUBTAB_X = 31
local SUBTAB_WIDTH_SCALE = 0.5
local SUBTAB_WIDTH_OFFSET = -57
local subtabSelector = Instance.new("Frame")
subtabSelector.Name = "SubtabSelector"
subtabSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
subtabSelector.BackgroundTransparency = 0.985
subtabSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
subtabSelector.BorderSizePixel = 0
subtabSelector.AnchorPoint = Vector2.new(0, 0)
subtabSelector.Position = UDim2.new(0, SUBTAB_X, 0, CHIP_TOP)
subtabSelector.Size = UDim2.new(SUBTAB_WIDTH_SCALE, SUBTAB_WIDTH_OFFSET, 0, CHIP_HEIGHT)
subtabSelector.ClipsDescendants = true
subtabSelector.Visible = false
subtabSelector.Parent = topbar
local subtabSelectorCorner = Instance.new("UICorner")
subtabSelectorCorner.Name = "SubtabSelectorCorner"
subtabSelectorCorner.CornerRadius = UDim.new(0, 6)
subtabSelectorCorner.Parent = subtabSelector
local subtabSelectorStroke = Instance.new("UIStroke")
subtabSelectorStroke.Name = "SubtabSelectorStroke"
subtabSelectorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
subtabSelectorStroke.Color = Color3.fromRGB(255, 255, 255)
subtabSelectorStroke.Transparency = 0.95
subtabSelectorStroke.Parent = subtabSelector
local subtabButton = Instance.new("TextButton")
subtabButton.Name = "SubtabButton"
subtabButton.Text = ""
subtabButton.AutoButtonColor = false
subtabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
subtabButton.BackgroundTransparency = 1
subtabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
subtabButton.BorderSizePixel = 0
subtabButton.Position = UDim2.new(0, 0, 0, 0)
subtabButton.Size = UDim2.new(1, 0, 0, CHIP_HEIGHT)
subtabButton.Parent = subtabSelector
local subtabButtonPadding = Instance.new("UIPadding")
subtabButtonPadding.Name = "SubtabButtonPadding"
subtabButtonPadding.PaddingRight = UDim.new(0, 15)
subtabButtonPadding.Parent = subtabButton
local subtabLabel = Instance.new("TextLabel")
subtabLabel.Name = "SubtabLabel"
subtabLabel.FontFace = Font.new(assets.interFont)
subtabLabel.Text = "Subtabs..."
subtabLabel.RichText = true
subtabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
subtabLabel.TextSize = 13
subtabLabel.TextTransparency = 0.5
subtabLabel.TextTruncate = Enum.TextTruncate.SplitWord
subtabLabel.TextXAlignment = Enum.TextXAlignment.Left
subtabLabel.AnchorPoint = Vector2.new(0, 0.5)
subtabLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
subtabLabel.BackgroundTransparency = 1
subtabLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
subtabLabel.BorderSizePixel = 0
subtabLabel.Position = UDim2.new(0, 15, 0.5, 0)
subtabLabel.Size = UDim2.new(1, -35, 0, 0)
subtabLabel.Parent = subtabButton
local subtabArrow = Instance.new("ImageLabel")
subtabArrow.Name = "SubtabArrow"
subtabArrow.Image = assets.dropdown
subtabArrow.ImageTransparency = 0.5
subtabArrow.AnchorPoint = Vector2.new(1, 0)
subtabArrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
subtabArrow.BackgroundTransparency = 1
subtabArrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
subtabArrow.BorderSizePixel = 0
subtabArrow.Position = UDim2.new(1, 0, 0, 12)
subtabArrow.Size = UDim2.fromOffset(14, 14)
subtabArrow.Parent = subtabButton
local subtabList = Instance.new("ScrollingFrame")
subtabList.Name = "SubtabList"
subtabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
subtabList.CanvasSize = UDim2.new()
subtabList.BottomImage = ""
subtabList.TopImage = ""
subtabList.ScrollBarImageTransparency = 0.5
subtabList.ScrollBarThickness = 2
subtabList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
subtabList.BackgroundTransparency = 1
subtabList.BorderColor3 = Color3.fromRGB(0, 0, 0)
subtabList.BorderSizePixel = 0
subtabList.Position = UDim2.new(0, 0, 0, CHIP_HEIGHT)
subtabList.Size = UDim2.new(1, 0, 1, -CHIP_HEIGHT)
subtabList.Parent = subtabSelector
local subtabListLayout = Instance.new("UIListLayout")
subtabListLayout.Name = "SubtabListLayout"
subtabListLayout.Padding = UDim.new(0, 5)
subtabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
subtabListLayout.Parent = subtabList
local subtabListPadding = Instance.new("UIPadding")
subtabListPadding.Name = "SubtabListPadding"
subtabListPadding.PaddingTop = UDim.new(0, 5)
subtabListPadding.PaddingBottom = UDim.new(0, 5)
subtabListPadding.Parent = subtabList
local listOpen = false
local listDb = false
local MAX_LIST_ROWS = 5
local subtabTweensettings = {
duration = 0.2,
easingStyle = Enum.EasingStyle.Quint,
transparencyIn = 0.2,
transparencyOut = 0.5,
checkSizeIncrease = 12,
checkSizeDecrease = -10,
}
local function getListHeight()
local count = #subtabOrder
if count == 0 then return 0 end
local rows = math.min(count, MAX_LIST_ROWS)
return 10 + (rows * 34) + math.max(0, (rows - 1) * 5)
end
local function setTopbarHeight(h)
Tween(topbar, EXPAND_INFO, {Size = UDim2.new(1, 0, 0, h)}):Play()
Tween(elements1, EXPAND_INFO, {Position = UDim2.new(0, 0, 0, h), Size = UDim2.new(1, 0, 1, -h)}):Play()
end
local function setSubTabListOpen(state)
if listDb then return end
if state == listOpen then return end
listDb = true
listOpen = state
local extra = state and getListHeight() or 0
Tween(subtabSelector, EXPAND_INFO, {Size = UDim2.new(SUBTAB_WIDTH_SCALE, SUBTAB_WIDTH_OFFSET, 0, CHIP_HEIGHT + extra)}):Play()
Tween(subtabArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = state and -90 or 0}):Play()
setTopbarHeight(TOPBAR_CLOSED + extra)
if state then
subtabList.CanvasPosition = Vector2.new(0, 0)
end
task.delay(0.2, function()
listDb = false
end)
end
subtabButton.MouseButton1Click:Connect(function() setSubTabListOpen(not listOpen) end)
UserInputService.InputEnded:Connect(function(input)
if not (subtabSelector.Visible and listOpen) then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
task.defer(function()
if not listOpen then return end
local mouse = UserInputService:GetMouseLocation()
local p = subtabSelector.AbsolutePosition
local s = subtabSelector.AbsoluteSize
local insideSel = mouse.X >= p.X and mouse.X <= p.X + s.X and mouse.Y >= p.Y and mouse.Y <= p.Y + s.Y
if not insideSel then setSubTabListOpen(false) end
end)
end
end)
local function selectSubTab(name)
local data = subtabs[name]
if not data then return end
for otherName, other in pairs(subtabs) do
other.Page.Visible = false
if other.Tweens then
if otherName == name then
other.Checkmark.TextTransparency = 0
other.Tweens.checkIn:Play()
other.Tweens.nameIn:Play()
else
other.Checkmark.TextTransparency = 1
other.Tweens.checkOut:Play()
other.Tweens.nameOut:Play()
end
end
end
data.Page.Visible = true
currentSubTab = name
subtabLabel.Text = name
setSubTabListOpen(false)
end
local function addSubTab(name)
if subtabs[name] then return end
local page, pageLeft, pageRight
if #subtabOrder == 0 then page = defaultPage pageLeft = left pageRight = right else page, pageLeft, pageRight = makePage() end
subtabs[name] = {Name = name, Page = page, Left = pageLeft, Right = pageRight}
table.insert(subtabOrder, name)
local option = Instance.new("TextButton")
option.Name = "Option"
option.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
option.Text = ""
option.TextColor3 = Color3.fromRGB(0, 0, 0)
option.TextSize = 14
option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
option.BackgroundTransparency = 1
option.BorderColor3 = Color3.fromRGB(0, 0, 0)
option.BorderSizePixel = 0
option.Size = UDim2.new(1, 0, 0, 34)
option.LayoutOrder = #subtabOrder
option.Parent = subtabList
local optionUIPadding = Instance.new("UIPadding")
optionUIPadding.Name = "OptionUIPadding"
optionUIPadding.PaddingLeft = UDim.new(0, 15)
optionUIPadding.Parent = option
local optionName = Instance.new("TextLabel")
optionName.Name = "OptionName"
optionName.FontFace = Font.new(assets.interFont)
optionName.Text = name
optionName.RichText = true
optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
optionName.TextSize = 13
optionName.TextTransparency = 0.5
optionName.TextTruncate = Enum.TextTruncate.AtEnd
optionName.TextXAlignment = Enum.TextXAlignment.Left
optionName.TextYAlignment = Enum.TextYAlignment.Top
optionName.AnchorPoint = Vector2.new(0, 0.5)
optionName.AutomaticSize = Enum.AutomaticSize.XY
optionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
optionName.BackgroundTransparency = 1
optionName.BorderColor3 = Color3.fromRGB(0, 0, 0)
optionName.BorderSizePixel = 0
optionName.Position = UDim2.fromScale(1.3e-07, 0.5)
optionName.Parent = option
local optionUIListLayout = Instance.new("UIListLayout")
optionUIListLayout.Name = "OptionUIListLayout"
optionUIListLayout.Padding = UDim.new(0, 10)
optionUIListLayout.FillDirection = Enum.FillDirection.Horizontal
optionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
optionUIListLayout.Parent = option
local checkmark = Instance.new("TextLabel")
checkmark.Name = "Checkmark"
checkmark.FontFace = Font.new(assets.interFont)
checkmark.Text = "✓"
checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
checkmark.TextSize = 13
checkmark.TextTransparency = 1
checkmark.TextXAlignment = Enum.TextXAlignment.Left
checkmark.TextYAlignment = Enum.TextYAlignment.Top
checkmark.AnchorPoint = Vector2.new(0, 0.5)
checkmark.AutomaticSize = Enum.AutomaticSize.Y
checkmark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
checkmark.BackgroundTransparency = 1
checkmark.BorderColor3 = Color3.fromRGB(0, 0, 0)
checkmark.BorderSizePixel = 0
checkmark.LayoutOrder = -1
checkmark.Position = UDim2.fromScale(1.3e-07, 0.5)
checkmark.Size = UDim2.fromOffset(-10, 0)
checkmark.Parent = option
subtabs[name].OptionText = optionName
subtabs[name].Checkmark = checkmark
subtabs[name].Tweens = {
checkIn = Tween(checkmark, TweenInfo.new(subtabTweensettings.duration, subtabTweensettings.easingStyle), {
Size = UDim2.new(checkmark.Size.X.Scale, subtabTweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
}),
checkOut = Tween(checkmark, TweenInfo.new(subtabTweensettings.duration, subtabTweensettings.easingStyle), {
Size = UDim2.new(checkmark.Size.X.Scale, subtabTweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
}),
nameIn = Tween(optionName, TweenInfo.new(subtabTweensettings.duration, subtabTweensettings.easingStyle), {
TextTransparency = subtabTweensettings.transparencyIn
}),
nameOut = Tween(optionName, TweenInfo.new(subtabTweensettings.duration, subtabTweensettings.easingStyle), {
TextTransparency = subtabTweensettings.transparencyOut
}),
}
option.MouseButton1Click:Connect(function() selectSubTab(name) end)
if #subtabOrder == 1 then selectSubTab(name) if currentTabInstance == elements1 then currentTab.Visible = false subtabSelector.Visible = true end end
end
function TabFunctions:SubTab(Settings)
local name = Settings
if type(Settings) == "table" then name = Settings.Name end
if type(name) ~= "string" or name == "" then return end
addSubTab(name)
return {
Name = name,
Select = function() selectSubTab(name) end,
Section = function(_, settings)
settings = settings or {}
settings.Page = name
return TabFunctions:Section(settings)
end,
}
end
subtabSelector.Visible = false
function TabFunctions:Section(Settings)
Settings = Settings or {}
local SectionFunctions = {}
local section = Instance.new("Frame")
section.Name = "Section"
section.AutomaticSize = Enum.AutomaticSize.Y
section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
section.BackgroundTransparency = 0.98
section.BorderColor3 = Color3.fromRGB(0, 0, 0)
section.BorderSizePixel = 0
section.Position = UDim2.fromScale(0, 6.78e-08)
section.Size = UDim2.fromScale(1, 0)
section.ClipsDescendants = true
local targetLeft, targetRight = left, right
if Settings.Page and subtabs[Settings.Page] then
targetLeft = subtabs[Settings.Page].Left
targetRight = subtabs[Settings.Page].Right
elseif currentSubTab and subtabs[currentSubTab] then
targetLeft = subtabs[currentSubTab].Left
targetRight = subtabs[currentSubTab].Right
end
section.Parent = Settings.Side == "Left" and targetLeft or targetRight
local sectionUICorner = Instance.new("UICorner")
sectionUICorner.Name = "SectionUICorner"
sectionUICorner.Parent = section
local sectionUIStroke = Instance.new("UIStroke")
sectionUIStroke.Name = "SectionUIStroke"
sectionUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sectionUIStroke.Color = Color3.fromRGB(255, 255, 255)
sectionUIStroke.Transparency = 0.95
sectionUIStroke.Parent = section
local sectionUIListLayout = Instance.new("UIListLayout")
sectionUIListLayout.Name = "SectionUIListLayout"
sectionUIListLayout.Padding = UDim.new(0, 10)
sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
sectionUIListLayout.Parent = section
local sectionUIPadding = Instance.new("UIPadding")
sectionUIPadding.Name = "SectionUIPadding"
sectionUIPadding.PaddingBottom = UDim.new(0, 20)
sectionUIPadding.PaddingLeft = UDim.new(0, 20)
sectionUIPadding.PaddingRight = UDim.new(0, 18)
sectionUIPadding.PaddingTop = UDim.new(0, 22)
sectionUIPadding.Parent = section
function SectionFunctions:Button(Settings, Flag)
local ButtonFunctions = {Settings = Settings}
local button = Instance.new("Frame")
button.Name = "Button"
button.AutomaticSize = Enum.AutomaticSize.Y
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
button.BackgroundTransparency = 1
button.BorderColor3 = Color3.fromRGB(0, 0, 0)
button.BorderSizePixel = 0
button.Size = UDim2.new(1, 0, 0, 38)
button.Parent = section
local buttonInteract = Instance.new("TextButton")
buttonInteract.Name = "ButtonInteract"
buttonInteract.FontFace = Font.new(assets.interFont)
buttonInteract.RichText = true
buttonInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonInteract.TextSize = 13
buttonInteract.TextTransparency = 0.5
buttonInteract.TextTruncate = Enum.TextTruncate.AtEnd
buttonInteract.TextXAlignment = Enum.TextXAlignment.Left
buttonInteract.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
buttonInteract.BackgroundTransparency = 1
buttonInteract.BorderColor3 = Color3.fromRGB(0, 0, 0)
buttonInteract.BorderSizePixel = 0
buttonInteract.Size = UDim2.fromScale(1, 1)
buttonInteract.Parent = button
buttonInteract.Text = ButtonFunctions.Settings.Name
local buttonImage = Instance.new("ImageLabel")
buttonImage.Name = "ButtonImage"
buttonImage.Image = assets.buttonImage
buttonImage.ImageTransparency = 0.5
buttonImage.AnchorPoint = Vector2.new(1, 0.5)
buttonImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
buttonImage.BackgroundTransparency = 1
buttonImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
buttonImage.BorderSizePixel = 0
buttonImage.Position = UDim2.fromScale(1, 0.5)
buttonImage.Size = UDim2.fromOffset(15, 15)
buttonImage.Parent = button
local TweenSettings = {
DefaultTransparency = 0.5,
HoverTransparency = 0.3,
EasingStyle = Enum.EasingStyle.Sine
}
local function ChangeState(State)
if State == "Idle" then
Tween(buttonInteract, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
TextTransparency = TweenSettings.DefaultTransparency
}):Play()
Tween(buttonImage, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
ImageTransparency = TweenSettings.DefaultTransparency
}):Play()
elseif State == "Hover" then
Tween(buttonInteract, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
TextTransparency = TweenSettings.HoverTransparency
}):Play()
Tween(buttonImage, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
ImageTransparency = TweenSettings.HoverTransparency
}):Play()
end
end
local function Callback()
if ButtonFunctions.Settings.Callback then
ButtonFunctions.Settings.Callback()
end
end
buttonInteract.MouseEnter:Connect(function()
ChangeState("Hover")
end)
buttonInteract.MouseLeave:Connect(function()
ChangeState("Idle")
end)
buttonInteract.MouseButton1Click:Connect(Callback)
function ButtonFunctions:UpdateName(Name)
buttonInteract.Text = Name
end
function ButtonFunctions:SetVisibility(State)
button.Visible = State
end
if Flag then
MacLib.Options[Flag] = ButtonFunctions
end
return ButtonFunctions
end
function SectionFunctions:Toggle(Settings, Flag)
local ToggleFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Toggle" }
local toggle = Instance.new("Frame")
toggle.Name = "Toggle"
toggle.AutomaticSize = Enum.AutomaticSize.Y
toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggle.BackgroundTransparency = 1
toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
toggle.BorderSizePixel = 0
toggle.Size = UDim2.new(1, 0, 0, 38)
toggle.Parent = section
local toggleName = Instance.new("TextLabel")
toggleName.Name = "ToggleName"
toggleName.FontFace = Font.new(assets.interFont)
toggleName.Text = ToggleFunctions.Settings.Name
toggleName.RichText = true
toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleName.TextSize = 13
toggleName.TextTransparency = 0.5
toggleName.TextTruncate = Enum.TextTruncate.AtEnd
toggleName.TextXAlignment = Enum.TextXAlignment.Left
toggleName.TextYAlignment = Enum.TextYAlignment.Top
toggleName.AnchorPoint = Vector2.new(0, 0.5)
toggleName.AutomaticSize = Enum.AutomaticSize.Y
toggleName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleName.BackgroundTransparency = 1
toggleName.BorderColor3 = Color3.fromRGB(0, 0, 0)
toggleName.BorderSizePixel = 0
toggleName.Position = UDim2.fromScale(0, 0.5)
toggleName.Size = UDim2.new(1, -50, 0, 0)
toggleName.Parent = toggle
local toggle1 = Instance.new("TextButton")
toggle1.Name = "Toggle"
toggle1.AutoButtonColor = false
toggle1.Text = ""
toggle1.AnchorPoint = Vector2.new(1, 0.5)
toggle1.BackgroundColor3 = Color3.fromRGB(87, 86, 86)
toggle1.BackgroundTransparency = 0.5
toggle1.BorderColor3 = Color3.fromRGB(0, 0, 0)
toggle1.BorderSizePixel = 0
toggle1.Position = UDim2.fromScale(1, 0.5)
toggle1.Size = UDim2.fromOffset(41, 21)
local toggleTrackCorner = Instance.new("UICorner")
toggleTrackCorner.Name = "ToggleTrackCorner"
toggleTrackCorner.CornerRadius = UDim.new(1, 0)
toggleTrackCorner.Parent = toggle1
local togglerHead = Instance.new("Frame")
togglerHead.Name = "TogglerHead"
togglerHead.AnchorPoint = Vector2.new(1, 0.5)
togglerHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
togglerHead.BackgroundTransparency = 0.85
togglerHead.BorderColor3 = Color3.fromRGB(0, 0, 0)
togglerHead.BorderSizePixel = 0
togglerHead.Position = UDim2.fromScale(0.5, 0.5)
togglerHead.Size = UDim2.fromOffset(15, 15)
togglerHead.ZIndex = 2
togglerHead.Parent = toggle1
local togglerHeadCorner = Instance.new("UICorner")
togglerHeadCorner.Name = "TogglerHeadCorner"
togglerHeadCorner.CornerRadius = UDim.new(1, 0)
togglerHeadCorner.Parent = togglerHead
toggle1.Parent = toggle
local toggle1Transparency = {Enabled = 0, Disabled = 0.5}
local togglerHeadTransparency = {Enabled = 0, Disabled = 0.85}
local TweenSettings = {
Info = TweenInfo.new(0.15, Enum.EasingStyle.Quad),
EnabledPosition = UDim2.new(1, 0, 0.5, 0),
DisabledPosition = UDim2.new(0.5, 0, 0.5, 0),
}
local togglebool = ToggleFunctions.Settings.Default
local function NewState(State, callback)
local transparencyValues = State and {toggle1Transparency.Enabled, togglerHeadTransparency.Enabled}
or {toggle1Transparency.Disabled, togglerHeadTransparency.Disabled}
local position = State and TweenSettings.EnabledPosition or TweenSettings.DisabledPosition
Tween(toggle1, TweenSettings.Info, {
BackgroundTransparency = transparencyValues[1]
}):Play()
Tween(togglerHead, TweenSettings.Info, {
BackgroundTransparency = transparencyValues[2]
}):Play()
Tween(togglerHead, TweenSettings.Info, {
Position = position
}):Play()
ToggleFunctions.State = State
if callback then
callback(togglebool)
end
end
NewState(togglebool)
local function Toggle()
togglebool = not togglebool
NewState(togglebool, ToggleFunctions.Settings.Callback)
end
toggle1.MouseButton1Click:Connect(Toggle)
function ToggleFunctions:Toggle()
Toggle()
end
function ToggleFunctions:UpdateState(State)
togglebool = State
NewState(togglebool, ToggleFunctions.Settings.Callback)
end
function ToggleFunctions:GetState()
return togglebool
end
function ToggleFunctions:UpdateName(Name)
toggleName.Text = Name
end
function ToggleFunctions:SetVisibility(State)
toggle.Visible = State
end
if Flag then
MacLib.Options[Flag] = ToggleFunctions
end
return ToggleFunctions
end
function SectionFunctions:Slider(Settings, Flag)
local SliderFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Slider" }
local sliderMin = tonumber(SliderFunctions.Settings.Minimum) or 0
local sliderMax = tonumber(SliderFunctions.Settings.Maximum) or 100
if sliderMax <= sliderMin then sliderMax = sliderMin + 1 end
local slider = Instance.new("Frame")
slider.Name = "Slider"
slider.AutomaticSize = Enum.AutomaticSize.Y
slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
slider.BackgroundTransparency = 1
slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
slider.BorderSizePixel = 0
slider.Size = UDim2.new(1, 0, 0, 38)
slider.Parent = section
local sliderName = Instance.new("TextLabel")
sliderName.Name = "SliderName"
sliderName.FontFace = Font.new(assets.interFont)
sliderName.Text = SliderFunctions.Settings.Name
sliderName.RichText = true
sliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderName.TextSize = 13
sliderName.TextTransparency = 0.5
sliderName.TextTruncate = Enum.TextTruncate.AtEnd
sliderName.TextXAlignment = Enum.TextXAlignment.Left
sliderName.TextYAlignment = Enum.TextYAlignment.Top
sliderName.AnchorPoint = Vector2.new(0, 0.5)
sliderName.AutomaticSize = Enum.AutomaticSize.XY
sliderName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderName.BackgroundTransparency = 1
sliderName.BorderColor3 = Color3.fromRGB(0, 0, 0)
sliderName.BorderSizePixel = 0
sliderName.Position = UDim2.fromScale(1.3e-07, 0.5)
sliderName.Parent = slider
local sliderElements = Instance.new("Frame")
sliderElements.Name = "SliderElements"
sliderElements.AnchorPoint = Vector2.new(1, 0)
sliderElements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderElements.BackgroundTransparency = 1
sliderElements.BorderColor3 = Color3.fromRGB(0, 0, 0)
sliderElements.BorderSizePixel = 0
sliderElements.Position = UDim2.fromScale(1, 0)
sliderElements.Size = UDim2.fromScale(1, 1)
local sliderValue = Instance.new("TextBox")
sliderValue.Name = "SliderValue"
sliderValue.FontFace = Font.new(assets.interFont)
sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderValue.TextSize = 12
sliderValue.TextTransparency = 0.1
sliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderValue.BackgroundTransparency = 0.95
sliderValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
sliderValue.BorderSizePixel = 0
sliderValue.LayoutOrder = 1
sliderValue.Position = UDim2.fromScale(-0.0789, 0.171)
sliderValue.Size = UDim2.fromOffset(41, 21)
sliderValue.ClipsDescendants = true
local sliderValueUICorner = Instance.new("UICorner")
sliderValueUICorner.Name = "SliderValueUICorner"
sliderValueUICorner.CornerRadius = UDim.new(0, 4)
sliderValueUICorner.Parent = sliderValue
local sliderValueUIStroke = Instance.new("UIStroke")
sliderValueUIStroke.Name = "SliderValueUIStroke"
sliderValueUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sliderValueUIStroke.Color = Color3.fromRGB(255, 255, 255)
sliderValueUIStroke.Transparency = 0.9
sliderValueUIStroke.Parent = sliderValue
local sliderValueUIPadding = Instance.new("UIPadding")
sliderValueUIPadding.Name = "SliderValueUIPadding"
sliderValueUIPadding.PaddingLeft = UDim.new(0, 2)
sliderValueUIPadding.PaddingRight = UDim.new(0, 2)
sliderValueUIPadding.Parent = sliderValue
sliderValue.Parent = sliderElements
local sliderElementsUIListLayout = Instance.new("UIListLayout")
sliderElementsUIListLayout.Name = "SliderElementsUIListLayout"
sliderElementsUIListLayout.Padding = UDim.new(0, 20)
sliderElementsUIListLayout.FillDirection = Enum.FillDirection.Horizontal
sliderElementsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
sliderElementsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
sliderElementsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
sliderElementsUIListLayout.Parent = sliderElements
local sliderBar = Instance.new("Frame")
sliderBar.Name = "SliderBar"
sliderBar.BackgroundColor3 = Color3.fromRGB(87, 86, 86)
sliderBar.BackgroundTransparency = 0
sliderBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
sliderBar.BorderSizePixel = 0
sliderBar.ClipsDescendants = false
sliderBar.Position = UDim2.fromScale(0.219, 0.457)
sliderBar.Size = UDim2.fromOffset(123, 3)
local sliderBarCorner = Instance.new("UICorner")
sliderBarCorner.Name = "SliderBarCorner"
sliderBarCorner.CornerRadius = UDim.new(1, 0)
sliderBarCorner.Parent = sliderBar
local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderFill.BackgroundTransparency = 0.4
sliderFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
sliderFill.BorderSizePixel = 0
sliderFill.Position = UDim2.fromScale(0, 0)
sliderFill.Size = UDim2.fromScale(0, 1)
local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.Name = "SliderFillCorner"
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill
sliderFill.Parent = sliderBar
local sliderHead = Instance.new("TextButton")
sliderHead.Name = "SliderHead"
sliderHead.Text = ""
sliderHead.AutoButtonColor = false
sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
sliderHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderHead.BackgroundTransparency = 0
sliderHead.BorderColor3 = Color3.fromRGB(0, 0, 0)
sliderHead.BorderSizePixel = 0
sliderHead.Position = UDim2.fromScale(1, 0.5)
sliderHead.Size = UDim2.fromOffset(isMobile and 16 or 12, isMobile and 16 or 12)
sliderHead.ZIndex = 2
local sliderHeadCorner = Instance.new("UICorner")
sliderHeadCorner.Name = "SliderHeadCorner"
sliderHeadCorner.CornerRadius = UDim.new(1, 0)
sliderHeadCorner.Parent = sliderHead
sliderHead.Parent = sliderBar
local sliderTouchArea = Instance.new("Frame")
sliderTouchArea.Name = "SliderTouchArea"
sliderTouchArea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderTouchArea.BackgroundTransparency = 1
sliderTouchArea.BorderColor3 = Color3.fromRGB(0, 0, 0)
sliderTouchArea.BorderSizePixel = 0
sliderTouchArea.AnchorPoint = Vector2.new(0.5, 0.5)
sliderTouchArea.Position = UDim2.fromScale(0.5, 0.5)
sliderTouchArea.Size = UDim2.new(1, 0, 1, 30)
sliderTouchArea.Parent = sliderBar
sliderBar.LayoutOrder = 0
sliderBar.Parent = sliderElements
local sliderElementsUIPadding = Instance.new("UIPadding")
sliderElementsUIPadding.Name = "SliderElementsUIPadding"
sliderElementsUIPadding.PaddingTop = UDim.new(0, 3)
sliderElementsUIPadding.Parent = sliderElements
sliderElements.Parent = slider
local dragging = false
local DisplayMethods = {
Hundredths = function(v) return string.format("%.2f", v) end,
Tenths = function(v) return string.format("%.1f", v) end,
Round = function(v, precision) if precision then return string.format("%." .. precision .. "f", v) else return tostring(math.round(v)) end end,
Degrees = function(v, precision) local f = precision and string.format("%." .. precision .. "f", v) or tostring(v) return f .. "°" end,
Percent = function(v, precision) local p = (v - sliderMin) / (sliderMax - sliderMin) * 100 return precision and string.format("%." .. precision .. "f", p) .. "%" or tostring(math.round(p)) .. "%" end,
Value = function(v, precision) return precision and string.format("%." .. precision .. "f", v) or tostring(v) end
}
local ValueDisplayMethod = DisplayMethods[SliderFunctions.Settings.DisplayMethod] or DisplayMethods.Value
local finalValue = sliderMin
local function roundValue(v)
local precision = SliderFunctions.Settings.Precision
if precision then
local mult = 10 ^ precision
return math.floor(v * mult + 0.5) / mult
end
return math.floor(v + 0.5)
end
local function updateText()
sliderValue.Text = (Settings.Prefix or "") .. ValueDisplayMethod(finalValue, SliderFunctions.Settings.Precision) .. (Settings.Suffix or "")
end
local function SetValue(val, ignorecallback)
local posXScale
if typeof(val) == "number" then
posXScale = math.clamp((val - sliderMin) / (sliderMax - sliderMin), 0, 1)
elseif typeof(val) == "Instance" then
local barWidth = sliderBar.AbsoluteSize.X
if barWidth <= 0 then barWidth = 1 end
posXScale = math.clamp((val.Position.X - sliderBar.AbsolutePosition.X) / barWidth, 0, 1)
else
return
end
sliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
sliderFill.Size = UDim2.new(posXScale, 0, 1, 0)
finalValue = math.clamp(roundValue(sliderMin + posXScale * (sliderMax - sliderMin)), sliderMin, sliderMax)
updateText()
if not ignorecallback then
task.spawn(function()
if SliderFunctions.Settings.Callback then
SliderFunctions.Settings.Callback(finalValue)
end
end)
end
SliderFunctions.Value = finalValue
end
SetValue(tonumber(SliderFunctions.Settings.Default) or sliderMin, true)
local function startDrag(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
SetValue(input)
end
end
sliderHead.InputBegan:Connect(startDrag)
sliderTouchArea.InputBegan:Connect(startDrag)
sliderBar.InputBegan:Connect(startDrag)
UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
SetValue(input)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
if dragging then
dragging = false
if SliderFunctions.Settings.onInputComplete then
SliderFunctions.Settings.onInputComplete(finalValue)
end
end
end
end)
sliderValue.FocusLost:Connect(function()
local inputText = sliderValue.Text
local num, isPercent = inputText:match("^(%-?%d+%.?%d*)(%%?)$")
if num then
num = tonumber(num)
if isPercent == "%" then
num = sliderMin + (num / 100) * (sliderMax - sliderMin)
end
SetValue(math.clamp(num, sliderMin, sliderMax))
else
SetValue(finalValue)
end
if SliderFunctions.Settings.onInputComplete then
SliderFunctions.Settings.onInputComplete(finalValue)
end
end)
local function updateSliderBarSize()
local padding = sliderElementsUIListLayout.Padding.Offset
local sliderValueWidth = sliderValue.AbsoluteSize.X
local sliderNameWidth = sliderName.AbsoluteSize.X
local totalWidth = sliderElements.AbsoluteSize.X
local scale = baseUIScale.Scale
if scale <= 0 then scale = 1 end
local newBarWidth = (totalWidth - (padding + sliderValueWidth + sliderNameWidth + 20)) / scale
if newBarWidth < 40 then newBarWidth = 40 end
sliderBar.Size = UDim2.new(sliderBar.Size.X.Scale, newBarWidth, sliderBar.Size.Y.Scale, sliderBar.Size.Y.Offset)
end
updateSliderBarSize()
sliderName:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)
section:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)
function SliderFunctions:UpdateName(Name)
sliderName.Text = Name
end
function SliderFunctions:SetVisibility(State)
slider.Visible = State
end
function SliderFunctions:UpdateValue(Value)
SetValue(tonumber(Value) or sliderMin, true)
end
function SliderFunctions:GetValue()
return finalValue
end
if Flag then
MacLib.Options[Flag] = SliderFunctions
end
return SliderFunctions
end
function SectionFunctions:Input(Settings, Flag)
local InputFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Input" }
local input = Instance.new("Frame")
input.Name = "Input"
input.AutomaticSize = Enum.AutomaticSize.Y
input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
input.BackgroundTransparency = 1
input.BorderColor3 = Color3.fromRGB(0, 0, 0)
input.BorderSizePixel = 0
input.Size = UDim2.new(1, 0, 0, 38)
input.Parent = section
local inputName = Instance.new("TextLabel")
inputName.Name = "InputName"
inputName.FontFace = Font.new(assets.interFont)
inputName.Text = InputFunctions.Settings.Name
inputName.RichText = true
inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
inputName.TextSize = 13
inputName.TextTransparency = 0.5
inputName.TextTruncate = Enum.TextTruncate.AtEnd
inputName.TextXAlignment = Enum.TextXAlignment.Left
inputName.TextYAlignment = Enum.TextYAlignment.Top
inputName.AnchorPoint = Vector2.new(0, 0.5)
inputName.AutomaticSize = Enum.AutomaticSize.XY
inputName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputName.BackgroundTransparency = 1
inputName.BorderColor3 = Color3.fromRGB(0, 0, 0)
inputName.BorderSizePixel = 0
inputName.Position = UDim2.fromScale(0, 0.5)
inputName.Parent = input
local inputBox = Instance.new("TextBox")
inputBox.Name = "InputBox"
inputBox.FontFace = Font.new(assets.interFont)
inputBox.Text = "Hello world!"
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.TextSize = 12
inputBox.TextTransparency = 0.1
inputBox.AnchorPoint = Vector2.new(1, 0.5)
inputBox.AutomaticSize = Enum.AutomaticSize.X
inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputBox.BackgroundTransparency = 0.95
inputBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
inputBox.BorderSizePixel = 0
inputBox.ClipsDescendants = true
inputBox.LayoutOrder = 1
inputBox.Position = UDim2.fromScale(1, 0.5)
inputBox.Size = UDim2.fromOffset(21, 21)
inputBox.TextXAlignment = Enum.TextXAlignment.Right
local inputBoxUICorner = Instance.new("UICorner")
inputBoxUICorner.Name = "InputBoxUICorner"
inputBoxUICorner.CornerRadius = UDim.new(0, 4)
inputBoxUICorner.Parent = inputBox
local inputBoxUIStroke = Instance.new("UIStroke")
inputBoxUIStroke.Name = "InputBoxUIStroke"
inputBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
inputBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
inputBoxUIStroke.Transparency = 0.9
inputBoxUIStroke.Parent = inputBox
local inputBoxUIPadding = Instance.new("UIPadding")
inputBoxUIPadding.Name = "InputBoxUIPadding"
inputBoxUIPadding.PaddingLeft = UDim.new(0, 5)
inputBoxUIPadding.PaddingRight = UDim.new(0, 5)
inputBoxUIPadding.Parent = inputBox
local inputBoxUISizeConstraint = Instance.new("UISizeConstraint")
inputBoxUISizeConstraint.Name = "InputBoxUISizeConstraint"
inputBoxUISizeConstraint.Parent = inputBox
inputBox.Parent = input
local Input = input
local InputBox = inputBox
local InputName = inputName
local Constraint = inputBoxUISizeConstraint
local function applyCharacterLimit(value)
if InputFunctions.Settings.CharacterLimit then
return value:sub(1, InputFunctions.Settings.CharacterLimit)
end
return value
end
local CharacterSubs = {
All = function(value)
return applyCharacterLimit(value)
end,
Numeric = function(value)
local result = value:match("^%-?%d*$") and value or value:gsub("[^%d-]", ""):gsub("(%-)", function(match, pos)
return pos == 1 and match or ""
end)
return applyCharacterLimit(result)
end,
Alphabetic = function(value)
return applyCharacterLimit(value:gsub("[^a-zA-Z ]", ""))
end,
AlphaNumeric = function(value)
return applyCharacterLimit(value:gsub("[^a-zA-Z0-9]", ""))
end,
}
local AcceptedCharacters
if type(InputFunctions.Settings.AcceptedCharacters) == "function" then
AcceptedCharacters = InputFunctions.Settings.AcceptedCharacters
else
AcceptedCharacters = CharacterSubs[InputFunctions.Settings.AcceptedCharacters] or CharacterSubs.All
end
InputBox.AutomaticSize = Enum.AutomaticSize.X
local function checkSize()
local nameWidth = InputName.AbsoluteSize.X
local totalWidth = Input.AbsoluteSize.X
local maxWidth = (totalWidth - nameWidth - 20) / baseUIScale.Scale
Constraint.MaxSize = Vector2.new(maxWidth, 9e9)
end
checkSize()
InputName:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkSize)
InputBox.FocusLost:Connect(function()
local inputText = InputBox.Text
local filteredText = AcceptedCharacters(inputText)
InputBox.Text = filteredText
task.spawn(function()
if InputFunctions.Settings.Callback then
InputFunctions.Settings.Callback(filteredText)
end
end)
end)
InputBox.Text = InputFunctions.Settings.Default or ""
InputBox.PlaceholderText = InputFunctions.Settings.Placeholder or ""
InputBox:GetPropertyChangedSignal("Text"):Connect(function()
InputBox.Text = AcceptedCharacters(InputBox.Text)
if InputFunctions.Settings.onChanged then
InputFunctions.Settings.onChanged(InputBox.Text)
end
InputFunctions.Text = InputBox.Text
end)
function InputFunctions:UpdateName(Name)
inputName.Text = Name
end
function InputFunctions:SetVisibility(State)
input.Visible = State
end
function InputFunctions:GetInput()
return InputBox.Text
end
function InputFunctions:UpdatePlaceholder(Placeholder)
inputBox.PlaceholderText = Placeholder
end
function InputFunctions:UpdateText(Text)
local filteredText = AcceptedCharacters(Text)
InputBox.Text = filteredText
InputFunctions.Text = filteredText
task.spawn(function()
if InputFunctions.Settings.Callback then
InputFunctions.Settings.Callback(filteredText)
end
end)
end
if Flag then
MacLib.Options[Flag] = InputFunctions
end
return InputFunctions
end
function SectionFunctions:Keybind(Settings, Flag)
local KeybindFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Keybind" }
local keybind = Instance.new("Frame")
keybind.Name = "Keybind"
keybind.AutomaticSize = Enum.AutomaticSize.Y
keybind.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
keybind.BackgroundTransparency = 1
keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
keybind.BorderSizePixel = 0
keybind.Size = UDim2.new(1, 0, 0, 38)
keybind.Parent = section
local keybindName = Instance.new("TextLabel")
keybindName.Name = "KeybindName"
keybindName.FontFace = Font.new(assets.interFont)
keybindName.Text = KeybindFunctions.Settings.Name
keybindName.RichText = true
keybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindName.TextSize = 13
keybindName.TextTransparency = 0.5
keybindName.TextTruncate = Enum.TextTruncate.AtEnd
keybindName.TextXAlignment = Enum.TextXAlignment.Left
keybindName.TextYAlignment = Enum.TextYAlignment.Top
keybindName.AnchorPoint = Vector2.new(0, 0.5)
keybindName.AutomaticSize = Enum.AutomaticSize.XY
keybindName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
keybindName.BackgroundTransparency = 1
keybindName.BorderColor3 = Color3.fromRGB(0, 0, 0)
keybindName.BorderSizePixel = 0
keybindName.Position = UDim2.fromScale(0, 0.5)
keybindName.Parent = keybind
local binderBox = Instance.new("TextBox")
binderBox.Name = "BinderBox"
binderBox.CursorPosition = -1
binderBox.FontFace = Font.new(assets.interFont)
binderBox.PlaceholderText = "..."
binderBox.Text = ""
binderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
binderBox.TextSize = 12
binderBox.TextTransparency = 0.1
binderBox.AnchorPoint = Vector2.new(1, 0.5)
binderBox.AutomaticSize = Enum.AutomaticSize.X
binderBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
binderBox.BackgroundTransparency = 0.95
binderBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
binderBox.BorderSizePixel = 0
binderBox.ClipsDescendants = true
binderBox.LayoutOrder = 1
binderBox.Position = UDim2.fromScale(1, 0.5)
binderBox.Size = UDim2.fromOffset(21, 21)
local binderBoxUICorner = Instance.new("UICorner")
binderBoxUICorner.Name = "BinderBoxUICorner"
binderBoxUICorner.CornerRadius = UDim.new(0, 4)
binderBoxUICorner.Parent = binderBox
local binderBoxUIStroke = Instance.new("UIStroke")
binderBoxUIStroke.Name = "BinderBoxUIStroke"
binderBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
binderBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
binderBoxUIStroke.Transparency = 0.9
binderBoxUIStroke.Parent = binderBox
local binderBoxUIPadding = Instance.new("UIPadding")
binderBoxUIPadding.Name = "BinderBoxUIPadding"
binderBoxUIPadding.PaddingLeft = UDim.new(0, 5)
binderBoxUIPadding.PaddingRight = UDim.new(0, 5)
binderBoxUIPadding.Parent = binderBox
local binderBoxUISizeConstraint = Instance.new("UISizeConstraint")
binderBoxUISizeConstraint.Name = "BinderBoxUISizeConstraint"
binderBoxUISizeConstraint.Parent = binderBox
binderBox.Parent = keybind
local focused
local isBinding = false
local reset = false
local binded = KeybindFunctions.Settings.Default
local function resetFocusState()
focused = false
isBinding = false
binderBox:ReleaseFocus()
end
if binded then
binderBox.Text = binded.Name
end
binderBox.Focused:Connect(function()
focused = true
end)
binderBox.FocusLost:Connect(function()
focused = false
end)
UserInputService.InputBegan:Connect(function(inp)
if focused and not isBinding then
isBinding = true
local Event
Event = UserInputService.InputBegan:Connect(function(input)
if KeybindFunctions.Settings.Blacklist and (table.find(KeybindFunctions.Settings.Blacklist, input.KeyCode) or table.find(KeybindFunctions.Settings.Blacklist, input.UserInputType)) then
binderBox:ReleaseFocus()
resetFocusState()
Event:Disconnect()
return
end
if input.UserInputType == Enum.UserInputType.Keyboard then
binded = input.KeyCode
binderBox.Text = input.KeyCode.Name
elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
binded = input.UserInputType
binderBox.Text = input.UserInputType.Name
end
if KeybindFunctions.Settings.onBinded then
KeybindFunctions.Settings.onBinded(binded)
end
reset = true
resetFocusState()
Event:Disconnect()
end)
else
if not reset and (inp.KeyCode == binded or inp.UserInputType == binded) then
if KeybindFunctions.Settings.Callback then
KeybindFunctions.Settings.Callback(binded)
end
if KeybindFunctions.Settings.onBindHeld then
KeybindFunctions.Settings.onBindHeld(true, binded)
end
else
reset = false
end
end
end)
UserInputService.InputEnded:Connect(function(inp)
if not focused and not isBinding then
if inp.KeyCode == binded or inp.UserInputType == binded then
if Settings.onBindHeld then
Settings.onBindHeld(false, binded)
end
end
end
end)
function KeybindFunctions:Bind(Key)
binded = Key
binderBox.Text = Key.Name
end
function KeybindFunctions:Unbind()
binded = nil
binderBox.Text = ""
end
function KeybindFunctions:GetBind()
return binded
end
function KeybindFunctions:UpdateName(Name)
keybindName = Name
end
function KeybindFunctions:SetVisibility(State)
keybind.Visible = State
end
if Flag then
MacLib.Options[Flag] = KeybindFunctions
end
return KeybindFunctions
end
function SectionFunctions:Dropdown(Settings, Flag)
local DropdownFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Dropdown" }
local Selected = {}
local OptionObjs = {}
local dropdown = Instance.new("Frame")
dropdown.Name = "Dropdown"
dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dropdown.BackgroundTransparency = 0.985
dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
dropdown.BorderSizePixel = 0
dropdown.Size = UDim2.new(1, 0, 0, 38)
dropdown.Parent = section
dropdown.ClipsDescendants = true
local dropdownUIPadding = Instance.new("UIPadding")
dropdownUIPadding.Name = "DropdownUIPadding"
dropdownUIPadding.PaddingLeft = UDim.new(0, 15)
dropdownUIPadding.PaddingRight = UDim.new(0, 15)
dropdownUIPadding.Parent = dropdown
local interact = Instance.new("TextButton")
interact.Name = "Interact"
interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
interact.Text = ""
interact.TextColor3 = Color3.fromRGB(0, 0, 0)
interact.TextSize = 14
interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
interact.BackgroundTransparency = 1
interact.BorderColor3 = Color3.fromRGB(0, 0, 0)
interact.BorderSizePixel = 0
interact.Size = UDim2.new(1, 0, 0, 38)
interact.Parent = dropdown
local dropdownName = Instance.new("TextLabel")
dropdownName.Name = "DropdownName"
dropdownName.FontFace = Font.new(assets.interFont)
dropdownName.Text = Settings.Default and (DropdownFunctions.Settings.Name .. " • " .. table.concat(Selected, ", ")) or (DropdownFunctions.Settings.Name .. "...")
dropdownName.RichText = true
dropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownName.TextSize = 13
dropdownName.TextTransparency = 0.5
dropdownName.TextTruncate = Enum.TextTruncate.SplitWord
dropdownName.TextXAlignment = Enum.TextXAlignment.Left
dropdownName.AutomaticSize = Enum.AutomaticSize.Y
dropdownName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dropdownName.BackgroundTransparency = 1
dropdownName.BorderColor3 = Color3.fromRGB(0, 0, 0)
dropdownName.BorderSizePixel = 0
dropdownName.Size = UDim2.new(1, -20, 0, 38)
dropdownName.Parent = dropdown
local dropdownUIStroke = Instance.new("UIStroke")
dropdownUIStroke.Name = "DropdownUIStroke"
dropdownUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
dropdownUIStroke.Color = Color3.fromRGB(255, 255, 255)
dropdownUIStroke.Transparency = 0.95
dropdownUIStroke.Parent = dropdown
local dropdownUICorner = Instance.new("UICorner")
dropdownUICorner.Name = "DropdownUICorner"
dropdownUICorner.CornerRadius = UDim.new(0, 6)
dropdownUICorner.Parent = dropdown
local dropdownImage = Instance.new("ImageLabel")
dropdownImage.Name = "DropdownImage"
dropdownImage.Image = assets.dropdown
dropdownImage.ImageTransparency = 0.5
dropdownImage.AnchorPoint = Vector2.new(1, 0)
dropdownImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dropdownImage.BackgroundTransparency = 1
dropdownImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
dropdownImage.BorderSizePixel = 0
dropdownImage.Position = UDim2.new(1, 0, 0, 12)
dropdownImage.Size = UDim2.fromOffset(14, 14)
dropdownImage.Parent = dropdown
local dropdownFrame = Instance.new("ScrollingFrame")
dropdownFrame.Name = "DropdownFrame"
dropdownFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownFrame.CanvasSize = UDim2.new()
dropdownFrame.BottomImage = ""
dropdownFrame.TopImage = ""
dropdownFrame.ScrollBarImageTransparency = 0.8
dropdownFrame.ScrollBarThickness = 2
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dropdownFrame.BackgroundTransparency = 1
dropdownFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.ClipsDescendants = true
dropdownFrame.Position = UDim2.new(0, 0, 0, 38)
dropdownFrame.Size = UDim2.new(1, 0, 1, -38)
dropdownFrame.Visible = false
local dropdownFrameUIPadding = Instance.new("UIPadding")
dropdownFrameUIPadding.Name = "DropdownFrameUIPadding"
dropdownFrameUIPadding.PaddingTop = UDim.new(0, 0)
dropdownFrameUIPadding.PaddingBottom = UDim.new(0, 10)
dropdownFrameUIPadding.Parent = dropdownFrame
local dropdownFrameUIListLayout = Instance.new("UIListLayout")
dropdownFrameUIListLayout.Name = "DropdownFrameUIListLayout"
dropdownFrameUIListLayout.Padding = UDim.new(0, 5)
dropdownFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownFrameUIListLayout.Parent = dropdownFrame
local search = Instance.new("Frame")
search.Name = "Search"
search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
search.BackgroundTransparency = 0.95
search.BorderColor3 = Color3.fromRGB(0, 0, 0)
search.BorderSizePixel = 0
search.LayoutOrder = -1
search.Size = UDim2.new(1, 0, 0, 30)
search.Parent = dropdownFrame
search.Visible = DropdownFunctions.Settings.Search
local sectionUICorner = Instance.new("UICorner")
sectionUICorner.Name = "SectionUICorner"
sectionUICorner.Parent = search
local searchIcon = Instance.new("ImageLabel")
searchIcon.Name = "SearchIcon"
searchIcon.Image = assets.searchIcon
searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
searchIcon.AnchorPoint = Vector2.new(0, 0.5)
searchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchIcon.BackgroundTransparency = 1
searchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
searchIcon.BorderSizePixel = 0
searchIcon.Position = UDim2.fromScale(0, 0.5)
searchIcon.Size = UDim2.fromOffset(12, 12)
searchIcon.Parent = search
local uIPadding = Instance.new("UIPadding")
uIPadding.Name = "UIPadding"
uIPadding.PaddingLeft = UDim.new(0, 15)
uIPadding.Parent = search
local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.CursorPosition = -1
searchBox.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
searchBox.PlaceholderText = "Search..."
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
searchBox.TextSize = 14
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchBox.BackgroundTransparency = 1
searchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
searchBox.BorderSizePixel = 0
searchBox.Size = UDim2.fromScale(1, 1)
local function CalculateDropdownSize()
local totalHeight = 0
local visibleChildrenCount = 0
for _, v in pairs(dropdownFrame:GetChildren()) do
if not v:IsA("UIComponent") and v.Visible then
totalHeight += v.AbsoluteSize.Y
visibleChildrenCount += 1
end
end
local spacing = dropdownFrameUIListLayout.Padding.Offset * math.max(0, visibleChildrenCount - 1)
local contentHeight = totalHeight + spacing + dropdownFrameUIPadding.PaddingBottom.Offset
local maxContent = (5 * 30) + (4 * 5) + dropdownFrameUIPadding.PaddingBottom.Offset
return 38 + math.min(contentHeight, maxContent)
end
local function findOption()
local searchTerm = searchBox.Text:lower()
for _, v in pairs(OptionObjs) do
local optionText = v.NameLabel.Text:lower()
local isVisible = string.find(optionText, searchTerm) ~= nil
if v.Button.Visible ~= isVisible then
v.Button.Visible = isVisible
end
end
dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
end
searchBox:GetPropertyChangedSignal("Text"):Connect(findOption)
local uIPadding1 = Instance.new("UIPadding")
uIPadding1.Name = "UIPadding"
uIPadding1.PaddingLeft = UDim.new(0, 23)
uIPadding1.Parent = searchBox
searchBox.Parent = search
local tweensettings = {
duration = 0.2,
easingStyle = Enum.EasingStyle.Quint,
transparencyIn = 0.2,
transparencyOut = 0.5,
checkSizeIncrease = 12,
checkSizeDecrease = -13,
waitTime = 1
}
local function Toggle(optionName, State)
local option = OptionObjs[optionName]
if not option then return end
local checkmark = option.Checkmark
local optionNameLabel = option.NameLabel
if State then
if DropdownFunctions.Settings.Multi then
if not table.find(Selected, optionName) then
table.insert(Selected, optionName)
DropdownFunctions.Value = Selected
end
else
for name, opt in pairs(OptionObjs) do
if name ~= optionName then
Tween(opt.Checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
Size = UDim2.new(opt.Checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, opt.Checkmark.Size.Y.Scale, opt.Checkmark.Size.Y.Offset)
}):Play()
Tween(opt.NameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
TextTransparency = tweensettings.transparencyOut
}):Play()
opt.Checkmark.TextTransparency = 1
end
end
Selected = {optionName}
DropdownFunctions.Value = Selected[1]
end
Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
}):Play()
Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
TextTransparency = tweensettings.transparencyIn
}):Play()
checkmark.TextTransparency = 0
else
if DropdownFunctions.Settings.Multi then
local idx = table.find(Selected, optionName)
if idx then
table.remove(Selected, idx)
end
else
Selected = {}
end
Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
}):Play()
Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
TextTransparency = tweensettings.transparencyOut
}):Play()
checkmark.TextTransparency = 1
end
if Settings.Required and #Selected == 0 and not State then
return
end
if #Selected > 0 then
dropdownName.Text = DropdownFunctions.Settings.Name .. " • " .. table.concat(Selected, ", ")
else
dropdownName.Text = DropdownFunctions.Settings.Name .. "..."
end
end
local dropped = false
local db = false
local function ToggleDropdown()
if db then return end
db = true
local defaultDropdownSize = 38
local isDropdownOpen = not dropped
local targetSize = isDropdownOpen and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, defaultDropdownSize)
local dropTween = Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
Size = targetSize
})
local iconTween = Tween(dropdownImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
Rotation = isDropdownOpen and -90 or 0
})
dropTween:Play()
iconTween:Play()
if isDropdownOpen then
dropdownFrame.Visible = true
dropTween.Completed:Connect(function()
db = false
end)
else
dropTween.Completed:Connect(function()
dropdownFrame.Visible = false
db = false
end)
end
dropped = isDropdownOpen
end
interact.MouseButton1Click:Connect(ToggleDropdown)
local function addOption(i, v)
local option = Instance.new("TextButton")
option.Name = "Option"
option.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
option.Text = ""
option.TextColor3 = Color3.fromRGB(0, 0, 0)
option.TextSize = 14
option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
option.BackgroundTransparency = 1
option.BorderColor3 = Color3.fromRGB(0, 0, 0)
option.BorderSizePixel = 0
option.Size = UDim2.new(1, 0, 0, 30)
local optionUIPadding = Instance.new("UIPadding")
optionUIPadding.Name = "OptionUIPadding"
optionUIPadding.PaddingLeft = UDim.new(0, 15)
optionUIPadding.Parent = option
local optionName = Instance.new("TextLabel")
optionName.Name = "OptionName"
optionName.FontFace = Font.new(assets.interFont)
optionName.Text = v
optionName.RichText = true
optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
optionName.TextSize = 13
optionName.TextTransparency = 0.5
optionName.TextTruncate = Enum.TextTruncate.AtEnd
optionName.TextXAlignment = Enum.TextXAlignment.Left
optionName.TextYAlignment = Enum.TextYAlignment.Top
optionName.AnchorPoint = Vector2.new(0, 0.5)
optionName.AutomaticSize = Enum.AutomaticSize.XY
optionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
optionName.BackgroundTransparency = 1
optionName.BorderColor3 = Color3.fromRGB(0, 0, 0)
optionName.BorderSizePixel = 0
optionName.Position = UDim2.fromScale(1.3e-07, 0.5)
optionName.Parent = option
local optionUIListLayout = Instance.new("UIListLayout")
optionUIListLayout.Name = "OptionUIListLayout"
optionUIListLayout.Padding = UDim.new(0, 10)
optionUIListLayout.FillDirection = Enum.FillDirection.Horizontal
optionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
optionUIListLayout.Parent = option
local checkmark = Instance.new("TextLabel")
checkmark.Name = "Checkmark"
checkmark.FontFace = Font.new(assets.interFont)
checkmark.Text = "✓"
checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
checkmark.TextSize = 13
checkmark.TextTransparency = 1
checkmark.TextXAlignment = Enum.TextXAlignment.Left
checkmark.TextYAlignment = Enum.TextYAlignment.Top
checkmark.AnchorPoint = Vector2.new(0, 0.5)
checkmark.AutomaticSize = Enum.AutomaticSize.Y
checkmark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
checkmark.BackgroundTransparency = 1
checkmark.BorderColor3 = Color3.fromRGB(0, 0, 0)
checkmark.BorderSizePixel = 0
checkmark.LayoutOrder = -1
checkmark.Position = UDim2.fromScale(1.3e-07, 0.5)
checkmark.Size = UDim2.fromOffset(-10, 0)
checkmark.Parent = option
option.Parent = dropdownFrame
dropdownFrame.Parent = dropdown
OptionObjs[v] = {
Index = i,
Button = option,
NameLabel = optionName,
Checkmark = checkmark
}
local tweensettings = {
duration = 0.2,
easingStyle = Enum.EasingStyle.Quint,
transparencyIn = 0.2,
transparencyOut = 0.5,
checkSizeIncrease = 12,
checkSizeDecrease = -optionUIListLayout.Padding.Offset,
waitTime = 1
}
local tweens = {
checkIn = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
}),
checkOut = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
}),
nameIn = Tween(optionName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
TextTransparency = tweensettings.transparencyIn
}),
nameOut = Tween(optionName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
TextTransparency = tweensettings.transparencyOut
})
}
local isSelected = false
if DropdownFunctions.Settings.Default then
if DropdownFunctions.Settings.Multi then
isSelected = table.find(DropdownFunctions.Settings.Default, v) and true or false
else
isSelected = (DropdownFunctions.Settings.Default == i) and true or false
end
end
Toggle(v, isSelected)
local option = OptionObjs[v].Button
option.MouseButton1Click:Connect(function()
local isSelected = table.find(Selected, v) and true or false
local newSelected = not isSelected
if DropdownFunctions.Settings.Required and not newSelected and #Selected <= 1 then
return
end
Toggle(v, newSelected)
task.spawn(function()
if DropdownFunctions.Settings.Multi then
local Return = {}
for _, opt in ipairs(Selected) do
Return[opt] = true
end
if DropdownFunctions.Settings.Callback then
DropdownFunctions.Settings.Callback(Return)
end
else
if newSelected and DropdownFunctions.Settings.Callback then
DropdownFunctions.Settings.Callback(Selected[1] or nil)
end
end
end)
end)
if dropped then
dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
end
end
if DropdownFunctions.Settings.Options then
for i, v in pairs(DropdownFunctions.Settings.Options) do
addOption(i, v)
end
end
function DropdownFunctions:UpdateName(New)
dropdownName.Text = New
end
function DropdownFunctions:SetVisibility(State)
dropdown.Visible = State
end
function DropdownFunctions:UpdateSelection(newSelection)
if not newSelection then return end
for option, _ in pairs(OptionObjs) do
Toggle(option, false)
end
local selectedOptions = {}
if type(newSelection) == "number" then
for option, data in pairs(OptionObjs) do
local isSelected = data.Index == newSelection
Toggle(option, isSelected)
if isSelected then
table.insert(selectedOptions, option)
end
end
elseif type(newSelection) == "string" then
for option, data in pairs(OptionObjs) do
local isSelected = option == newSelection
Toggle(option, isSelected)
if isSelected then
table.insert(selectedOptions, option)
end
end
elseif type(newSelection) == "table" then
for option, _ in pairs(OptionObjs) do
local isSelected = table.find(newSelection, option) ~= nil
Toggle(option, isSelected)
if isSelected then
table.insert(selectedOptions, option)
end
end
end
if DropdownFunctions.Settings.Callback then
if DropdownFunctions.Settings.Multi then
local Return = {}
for _, opt in ipairs(selectedOptions) do
Return[opt] = true
end
DropdownFunctions.Settings.Callback(Return)
else
DropdownFunctions.Settings.Callback(selectedOptions[1] or nil)
end
end
end
function DropdownFunctions:InsertOptions(newOptions)
if not newOptions then return end
DropdownFunctions.Settings.Options = newOptions
for i, v in pairs(newOptions) do
addOption(i, v)
end
end
function DropdownFunctions:ClearOptions()
for _, optionData in pairs(OptionObjs) do
optionData.Button:Destroy()
end
OptionObjs = {}
Selected = {}
if dropped then
dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
end
end
function DropdownFunctions:GetOptions()
local optionsStatus = {}
for option, data in pairs(OptionObjs) do
local isSelected = table.find(Selected, option) and true or false
optionsStatus[option] = isSelected
end
return optionsStatus
end
function DropdownFunctions:RemoveOptions(remove)
if not remove then return end
for _, optionName in ipairs(remove) do
local optionData = OptionObjs[optionName]
if optionData then
for i = #Selected, 1, -1 do
if Selected[i] == optionName then
table.remove(Selected, i)
end
end
optionData.Button:Destroy()
OptionObjs[optionName] = nil
end
end
if dropped then
dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
end
end
function DropdownFunctions:IsOption(optionName)
if not optionName then return end
return OptionObjs[optionName] ~= nil
end
if Flag then
MacLib.Options[Flag] = DropdownFunctions
end
return DropdownFunctions
end
function SectionFunctions:Colorpicker(Settings, Flag)
local ColorpickerFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Colorpicker" }
local isAlpha = ColorpickerFunctions.Settings.Alpha and true or false
ColorpickerFunctions.Color = ColorpickerFunctions.Settings.Default
ColorpickerFunctions.Alpha = isAlpha and ColorpickerFunctions.Settings.Alpha
local colorpicker = Instance.new("Frame")
colorpicker.Name = "Colorpicker"
colorpicker.AutomaticSize = Enum.AutomaticSize.Y
colorpicker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
colorpicker.BackgroundTransparency = 1
colorpicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
colorpicker.BorderSizePixel = 0
colorpicker.Size = UDim2.new(1, 0, 0, 38)
colorpicker.Parent = section
local colorpickerName = Instance.new("TextLabel")
colorpickerName.Name = "KeybindName"
colorpickerName.FontFace = Font.new(assets.interFont)
colorpickerName.Text = Settings.Name
colorpickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
colorpickerName.TextSize = 13
colorpickerName.TextTransparency = 0.5
colorpickerName.RichText = true
colorpickerName.TextTruncate = Enum.TextTruncate.AtEnd
colorpickerName.TextXAlignment = Enum.TextXAlignment.Left
colorpickerName.TextYAlignment = Enum.TextYAlignment.Top
colorpickerName.AnchorPoint = Vector2.new(0, 0.5)
colorpickerName.AutomaticSize = Enum.AutomaticSize.XY
colorpickerName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
colorpickerName.BackgroundTransparency = 1
colorpickerName.BorderColor3 = Color3.fromRGB(0, 0, 0)
colorpickerName.BorderSizePixel = 0
colorpickerName.Position = UDim2.fromScale(0, 0.5)
colorpickerName.Parent = colorpicker
local colorCbg = Instance.new("ImageLabel")
colorCbg.Name = "NewColor"
colorCbg.Image = assets.grid
colorCbg.ScaleType = Enum.ScaleType.Tile
colorCbg.TileSize = UDim2.fromOffset(500, 500)
colorCbg.AnchorPoint = Vector2.new(1, 0.5)
colorCbg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
colorCbg.BackgroundTransparency = 1
colorCbg.BorderColor3 = Color3.fromRGB(0, 0, 0)
colorCbg.BorderSizePixel = 0
colorCbg.Position = UDim2.fromScale(1, 0.5)
colorCbg.Size = UDim2.fromOffset(21, 21)
local colorC = Instance.new("Frame")
colorC.Name = "Color"
colorC.AnchorPoint = Vector2.new(0.5, 0.5)
colorC.BackgroundColor3 = ColorpickerFunctions.Color
colorC.BorderSizePixel = 0
colorC.Position = UDim2.fromScale(0.5, 0.5)
colorC.Size = UDim2.fromScale(1, 1)
colorC.BackgroundTransparency = ColorpickerFunctions.Alpha or 0
local uICorner = Instance.new("UICorner")
uICorner.Name = "UICorner"
uICorner.CornerRadius = UDim.new(0, 6)
uICorner.Parent = colorC
local interact = Instance.new("TextButton")
interact.Name = "Interact"
interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
interact.Text = ""
interact.TextColor3 = Color3.fromRGB(0, 0, 0)
interact.TextSize = 14
interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
interact.BackgroundTransparency = 1
interact.BorderColor3 = Color3.fromRGB(0, 0, 0)
interact.BorderSizePixel = 0
interact.Size = UDim2.fromScale(1, 1)
interact.Parent = colorC
colorC.Parent = colorCbg
local uICorner1 = Instance.new("UICorner")
uICorner1.Name = "UICorner"
uICorner1.CornerRadius = UDim.new(0, 8)
uICorner1.Parent = colorCbg
colorCbg.Parent = colorpicker
local colorPicker = Instance.new("Frame")
colorPicker.Name = "ColorPicker"
colorPicker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
colorPicker.BackgroundTransparency = 0.5
colorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
colorPicker.BorderSizePixel = 0
colorPicker.Size = UDim2.fromScale(1, 1)
colorPicker.Visible = false
local baseUICorner = Instance.new("UICorner")
baseUICorner.Name = "BaseUICorner"
baseUICorner.CornerRadius = UDim.new(0, 10)
baseUICorner.Parent = colorPicker
local prompt = Instance.new("Frame")
prompt.Name = "Prompt"
prompt.AnchorPoint = Vector2.new(0.5, 0.5)
prompt.AutomaticSize = Enum.AutomaticSize.Y
prompt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
prompt.BackgroundTransparency = 0
prompt.BorderColor3 = Color3.fromRGB(0, 0, 0)
prompt.BorderSizePixel = 0
prompt.Position = UDim2.fromScale(0.5, 0.5)
prompt.Size = UDim2.fromOffset(420, 0)
local promptUIScale = Instance.new("UIScale")
promptUIScale.Name = "BaseUIScale"
promptUIScale.Parent = prompt
promptUIScale.Scale = 0.95
local promptUIStroke = Instance.new("UIStroke")
promptUIStroke.Name = "PromptUIStroke"
promptUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
promptUIStroke.Color = Color3.fromRGB(255, 255, 255)
promptUIStroke.Transparency = 0.9
promptUIStroke.Parent = prompt
local promptUICorner = Instance.new("UICorner")
promptUICorner.Name = "PromptUICorner"
promptUICorner.CornerRadius = UDim.new(0, 10)
promptUICorner.Parent = prompt
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "UIListLayout"
uIListLayout.Padding = UDim.new(0, 10)
uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = prompt
local colorOptions = Instance.new("Frame")
colorOptions.Name = "ColorOptions"
colorOptions.AutomaticSize = Enum.AutomaticSize.XY
colorOptions.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
colorOptions.BackgroundTransparency = 1
colorOptions.BorderColor3 = Color3.fromRGB(0, 0, 0)
colorOptions.BorderSizePixel = 0
colorOptions.LayoutOrder = 1
colorOptions.Size = UDim2.fromScale(1, 0)
local value = Instance.new("TextButton")
value.Name = "Value"
value.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
value.Text = ""
value.TextColor3 = Color3.fromRGB(0, 0, 0)
value.TextSize = 14
value.AutoButtonColor = false
value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
value.BorderColor3 = Color3.fromRGB(0, 0, 0)
value.BorderSizePixel = 0
value.LayoutOrder = 1
value.Position = UDim2.fromScale(0.092, 0.886)
value.Size = UDim2.new(1, 0, 0, 15)
local uIGradient = Instance.new("UIGradient")
uIGradient.Name = "UIGradient"
uIGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
})
uIGradient.Parent = value
local slide = Instance.new("Frame")
slide.Name = "Slide"
slide.AnchorPoint = Vector2.new(0, 0.5)
slide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
slide.BorderColor3 = Color3.fromRGB(27, 42, 53)
slide.BorderSizePixel = 0
slide.Position = UDim2.fromScale(0, 0.5)
slide.Size = UDim2.new(0, 13, 1, 8)
local uICorner = Instance.new("UICorner")
uICorner.Name = "UICorner"
uICorner.CornerRadius = UDim.new(1, 0)
uICorner.Parent = slide
local uIStroke = Instance.new("UIStroke")
uIStroke.Name = "UIStroke"
uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uIStroke.Transparency = 0.5
uIStroke.Parent = slide
slide.Parent = value
local uICorner1 = Instance.new("UICorner")
uICorner1.Name = "UICorner"
uICorner1.CornerRadius = UDim.new(0, 6)
uICorner1.Parent = value
local uIStroke1 = Instance.new("UIStroke")
uIStroke1.Name = "UIStroke"
uIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uIStroke1.Color = Color3.fromRGB(255, 255, 255)
uIStroke1.Transparency = 0.9
local uIGradient1 = Instance.new("UIGradient")
uIGradient1.Name = "UIGradient"
uIGradient1.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
})
uIGradient1.Rotation = 180
uIGradient1.Parent = uIStroke1
uIStroke1.Parent = value
value.Parent = colorOptions
local uIListLayout1 = Instance.new("UIListLayout")
uIListLayout1.Name = "UIListLayout"
uIListLayout1.Padding = UDim.new(0, 25)
uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout1.Parent = colorOptions
local wheel = Instance.new("Frame")
wheel.Name = "Wheel"
wheel.AutomaticSize = Enum.AutomaticSize.Y
wheel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
wheel.BackgroundTransparency = 1
wheel.BorderColor3 = Color3.fromRGB(0, 0, 0)
wheel.BorderSizePixel = 0
wheel.Size = UDim2.new(1, 0, 0, 100)
local wheel1 = Instance.new("ImageButton")
wheel1.Name = "Wheel"
wheel1.Image = assets.colorWheel
wheel1.AutoButtonColor = false
wheel1.Active = false
wheel1.BackgroundColor3 = Color3.fromRGB(248, 248, 248)
wheel1.BackgroundTransparency = 1
wheel1.BorderColor3 = Color3.fromRGB(27, 42, 53)
wheel1.Selectable = false
wheel1.Size = UDim2.fromOffset(220, 220)
wheel1.SizeConstraint = Enum.SizeConstraint.RelativeYY
local target = Instance.new("ImageLabel")
target.Name = "Target"
target.Image = assets.colorTarget
target.ImageColor3 = Color3.fromRGB(0, 0, 0)
target.AnchorPoint = Vector2.new(0.5, 0.5)
target.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
target.BackgroundTransparency = 1
target.BorderColor3 = Color3.fromRGB(27, 42, 53)
target.Position = UDim2.fromScale(0.5, 0.5)
target.Size = UDim2.fromOffset(22, 22)
target.SizeConstraint = Enum.SizeConstraint.RelativeYY
target.Parent = wheel1
wheel1.Parent = wheel
local inputs = Instance.new("Frame")
inputs.Name = "Inputs"
inputs.AnchorPoint = Vector2.new(1, 0.5)
inputs.AutomaticSize = Enum.AutomaticSize.XY
inputs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputs.BackgroundTransparency = 1
inputs.BorderColor3 = Color3.fromRGB(0, 0, 0)
inputs.BorderSizePixel = 0
inputs.LayoutOrder = 1
inputs.Position = UDim2.fromScale(1, 0.5)
local uIListLayout2 = Instance.new("UIListLayout")
uIListLayout2.Name = "UIListLayout"
uIListLayout2.Padding = UDim.new(0, 5)
uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout2.Parent = inputs
local function makeColorInput(labelText, layoutOrder, defaultText, visible)
local rowFrame = Instance.new("Frame")
rowFrame.Name = labelText
rowFrame.AutomaticSize = Enum.AutomaticSize.XY
rowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rowFrame.BackgroundTransparency = 1
rowFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
rowFrame.BorderSizePixel = 0
rowFrame.LayoutOrder = layoutOrder
rowFrame.Size = UDim2.fromOffset(0, 38)
rowFrame.Visible = visible
local rowLabel = Instance.new("TextLabel")
rowLabel.Name = "InputName"
rowLabel.FontFace = Font.new(assets.interFont)
rowLabel.Text = labelText
rowLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rowLabel.TextSize = 13
rowLabel.TextTransparency = 0.5
rowLabel.TextTruncate = Enum.TextTruncate.AtEnd
rowLabel.TextXAlignment = Enum.TextXAlignment.Left
rowLabel.TextYAlignment = Enum.TextYAlignment.Top
rowLabel.AnchorPoint = Vector2.new(0, 0.5)
rowLabel.AutomaticSize = Enum.AutomaticSize.XY
rowLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rowLabel.BackgroundTransparency = 1
rowLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
rowLabel.BorderSizePixel = 0
rowLabel.LayoutOrder = 2
rowLabel.Position = UDim2.fromScale(0, 0.5)
rowLabel.Parent = rowFrame
local rowLayout = Instance.new("UIListLayout")
rowLayout.Name = "RowLayout"
rowLayout.Padding = UDim.new(0, 15)
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
rowLayout.Parent = rowFrame
local rowBox = Instance.new("TextBox")
rowBox.Name = "InputBox"
rowBox.ClearTextOnFocus = false
rowBox.CursorPosition = -1
rowBox.FontFace = Font.new(assets.interFont)
rowBox.Text = defaultText
rowBox.TextColor3 = Color3.fromRGB(255, 255, 255)
rowBox.TextSize = 12
rowBox.TextTransparency = 0.1
rowBox.TextXAlignment = Enum.TextXAlignment.Left
rowBox.AnchorPoint = Vector2.new(1, 0.5)
rowBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rowBox.BackgroundTransparency = 0.95
rowBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
rowBox.BorderSizePixel = 0
rowBox.ClipsDescendants = true
rowBox.LayoutOrder = 1
rowBox.Position = UDim2.fromScale(1, 0.5)
rowBox.Size = UDim2.fromOffset(75, 25)
local rowBoxCorner = Instance.new("UICorner")
rowBoxCorner.CornerRadius = UDim.new(0, 4)
rowBoxCorner.Parent = rowBox
local rowBoxStroke = Instance.new("UIStroke")
rowBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rowBoxStroke.Color = Color3.fromRGB(255, 255, 255)
rowBoxStroke.Transparency = 0.9
rowBoxStroke.Parent = rowBox
local rowBoxConstraint = Instance.new("UISizeConstraint")
rowBoxConstraint.Parent = rowBox
local rowBoxPadding = Instance.new("UIPadding")
rowBoxPadding.PaddingLeft = UDim.new(0, 8)
rowBoxPadding.PaddingRight = UDim.new(0, 10)
rowBoxPadding.Parent = rowBox
rowBox.Parent = rowFrame
rowFrame.Parent = inputs
return rowBox
end
local redBox = makeColorInput("Red", 1, "255", true)
local greenBox = makeColorInput("Green", 2, "255", true)
local blueBox = makeColorInput("Blue", 3, "255", true)
local alphaBox = makeColorInput("Alpha", 4, "0", isAlpha)
local hexBox = makeColorInput("Hex", 5, "#FFFFFF", true)
inputs.Parent = wheel
local uIPadding = Instance.new("UIPadding")
uIPadding.Name = "UIPadding"
uIPadding.PaddingRight = UDim.new(0, 5)
uIPadding.Parent = wheel
wheel.Parent = colorOptions
local colorWells = Instance.new("Frame")
colorWells.Name = "ColorWells"
colorWells.AutomaticSize = Enum.AutomaticSize.Y
colorWells.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
colorWells.BackgroundTransparency = 1
colorWells.BorderColor3 = Color3.fromRGB(0, 0, 0)
colorWells.BorderSizePixel = 0
colorWells.LayoutOrder = 2
colorWells.Size = UDim2.fromScale(1, 0)
local uIGridLayout = Instance.new("UIGridLayout")
uIGridLayout.Name = "UIGridLayout"
uIGridLayout.CellPadding = UDim2.fromOffset(10, 0)
uIGridLayout.CellSize = UDim2.new(0.5, -5, 0, 30)
uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIGridLayout.Parent = colorWells
local newColor = Instance.new("ImageLabel")
newColor.Name = "NewColor"
newColor.Image = assets.grid
newColor.ScaleType = Enum.ScaleType.Tile
newColor.TileSize = UDim2.fromOffset(500, 500)
newColor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
newColor.BackgroundTransparency = 1
newColor.BorderColor3 = Color3.fromRGB(0, 0, 0)
newColor.BorderSizePixel = 0
newColor.Size = UDim2.fromOffset(100, 100)
local uICorner2 = Instance.new("UICorner")
uICorner2.Name = "UICorner"
uICorner2.Parent = newColor
local color = Instance.new("Frame")
color.Name = "Color"
color.AnchorPoint = Vector2.new(0.5, 0.5)
color.BorderColor3 = Color3.fromRGB(27, 42, 53)
color.BorderSizePixel = 0
color.Position = UDim2.fromScale(0.5, 0.5)
color.Size = UDim2.new(1, 1, 1, 1)
local uICorner3 = Instance.new("UICorner")
uICorner3.Name = "UICorner"
uICorner3.Parent = color
color.Parent = newColor
newColor.Parent = colorWells
local oldColor = Instance.new("ImageLabel")
oldColor.Name = "OldColor"
oldColor.Image = assets.grid
oldColor.ScaleType = Enum.ScaleType.Tile
oldColor.TileSize = UDim2.fromOffset(500, 500)
oldColor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
oldColor.BackgroundTransparency = 1
oldColor.BorderColor3 = Color3.fromRGB(0, 0, 0)
oldColor.BorderSizePixel = 0
oldColor.LayoutOrder = 1
oldColor.Size = UDim2.fromOffset(100, 100)
local uICorner4 = Instance.new("UICorner")
uICorner4.Name = "UICorner"
uICorner4.Parent = oldColor
local color1 = Instance.new("Frame")
color1.Name = "Color"
color1.AnchorPoint = Vector2.new(0.5, 0.5)
color1.BorderColor3 = Color3.fromRGB(27, 42, 53)
color1.BorderSizePixel = 0
color1.Position = UDim2.fromScale(0.5, 0.5)
color1.Size = UDim2.new(1, 1, 1, 1)
local uICorner5 = Instance.new("UICorner")
uICorner5.Name = "UICorner"
uICorner5.Parent = color1
color1.Parent = oldColor
oldColor.Parent = colorWells
colorWells.Parent = colorOptions
colorOptions.Parent = prompt
local interactions = Instance.new("Frame")
interactions.Name = "Interactions"
interactions.AutomaticSize = Enum.AutomaticSize.Y
interactions.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
interactions.BackgroundTransparency = 1
interactions.BorderColor3 = Color3.fromRGB(0, 0, 0)
interactions.BorderSizePixel = 0
interactions.LayoutOrder = 2
interactions.Size = UDim2.fromScale(1, 0)
local uIListLayout8 = Instance.new("UIListLayout")
uIListLayout8.Name = "UIListLayout"
uIListLayout8.Padding = UDim.new(0, 10)
uIListLayout8.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout8.Parent = interactions
local confirm = Instance.new("TextButton")
confirm.Name = "Confirm"
confirm.FontFace = Font.new(
"rbxassetid://12187365364",
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
confirm.Text = "Confirm"
confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
confirm.TextSize = 15
confirm.TextTransparency = 0.5
confirm.TextTruncate = Enum.TextTruncate.AtEnd
confirm.AutoButtonColor = false
confirm.AutomaticSize = Enum.AutomaticSize.Y
confirm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
confirm.BorderColor3 = Color3.fromRGB(0, 0, 0)
confirm.BorderSizePixel = 0
confirm.Size = UDim2.fromScale(1, 0)
local uIPadding1 = Instance.new("UIPadding")
uIPadding1.Name = "UIPadding"
uIPadding1.PaddingBottom = UDim.new(0, 9)
uIPadding1.PaddingLeft = UDim.new(0, 10)
uIPadding1.PaddingRight = UDim.new(0, 10)
uIPadding1.PaddingTop = UDim.new(0, 9)
uIPadding1.Parent = confirm
local confirmUICorner = Instance.new("UICorner")
confirmUICorner.Name = "ConfirmUICorner"
confirmUICorner.CornerRadius = UDim.new(0, 10)
confirmUICorner.Parent = confirm
confirm.Parent = interactions
local cancel = Instance.new("TextButton")
cancel.Name = "Cancel"
cancel.FontFace = Font.new(
"rbxassetid://12187365364",
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
cancel.Text = "Cancel"
cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
cancel.TextSize = 15
cancel.TextTransparency = 0.5
cancel.TextTruncate = Enum.TextTruncate.AtEnd
cancel.AutoButtonColor = false
cancel.AutomaticSize = Enum.AutomaticSize.Y
cancel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
cancel.BorderColor3 = Color3.fromRGB(0, 0, 0)
cancel.BorderSizePixel = 0
cancel.Size = UDim2.fromScale(1, 0)
local cancelUICorner = Instance.new("UICorner")
cancelUICorner.Name = "CancelUICorner"
cancelUICorner.CornerRadius = UDim.new(0, 10)
cancelUICorner.Parent = cancel
local uIPadding2 = Instance.new("UIPadding")
uIPadding2.Name = "UIPadding"
uIPadding2.PaddingBottom = UDim.new(0, 9)
uIPadding2.PaddingLeft = UDim.new(0, 10)
uIPadding2.PaddingRight = UDim.new(0, 10)
uIPadding2.PaddingTop = UDim.new(0, 9)
uIPadding2.Parent = cancel
cancel.Parent = interactions
local uIPadding3 = Instance.new("UIPadding")
uIPadding3.Name = "UIPadding"
uIPadding3.PaddingTop = UDim.new(0, 10)
uIPadding3.Parent = interactions
interactions.Parent = prompt
local promptUIPadding = Instance.new("UIPadding")
promptUIPadding.Name = "PromptUIPadding"
promptUIPadding.PaddingBottom = UDim.new(0, 20)
promptUIPadding.PaddingLeft = UDim.new(0, 20)
promptUIPadding.PaddingRight = UDim.new(0, 20)
promptUIPadding.PaddingTop = UDim.new(0, 20)
promptUIPadding.Parent = prompt
local paragraph = Instance.new("Frame")
paragraph.Name = "Paragraph"
paragraph.AutomaticSize = Enum.AutomaticSize.Y
paragraph.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
paragraph.BackgroundTransparency = 1
paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
paragraph.BorderSizePixel = 0
paragraph.Size = UDim2.fromScale(1, 0)
local paragraphHeader = Instance.new("TextLabel")
paragraphHeader.Name = "ParagraphHeader"
paragraphHeader.FontFace = Font.new(
"rbxassetid://12187365364",
Enum.FontWeight.SemiBold,
Enum.FontStyle.Normal
)
paragraphHeader.RichText = true
paragraphHeader.Text = ColorpickerFunctions.Settings.Name
paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphHeader.TextSize = 18
paragraphHeader.TextTransparency = 0.4
paragraphHeader.TextWrapped = true
paragraphHeader.TextYAlignment = Enum.TextYAlignment.Top
paragraphHeader.AutomaticSize = Enum.AutomaticSize.XY
paragraphHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
paragraphHeader.BackgroundTransparency = 1
paragraphHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
paragraphHeader.BorderSizePixel = 0
paragraphHeader.Size = UDim2.fromScale(1, 0)
paragraphHeader.Parent = paragraph
local uIListLayout9 = Instance.new("UIListLayout")
uIListLayout9.Name = "UIListLayout"
uIListLayout9.Padding = UDim.new(0, 15)
uIListLayout9.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout9.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout9.Parent = paragraph
local uIPadding4 = Instance.new("UIPadding")
uIPadding4.Name = "UIPadding"
uIPadding4.PaddingBottom = UDim.new(0, 15)
uIPadding4.Parent = paragraph
local line = Instance.new("Frame")
line.Name = "Line"
line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
line.BackgroundTransparency = 0.9
line.BorderColor3 = Color3.fromRGB(0, 0, 0)
line.BorderSizePixel = 0
line.LayoutOrder = 1
line.Size = UDim2.new(1, 0, 0, 1)
line.Parent = paragraph
paragraph.Parent = prompt
prompt.Parent = colorPicker
colorPicker.Parent = base
local fromHSV, fromRGB, v2, udim2 = Color3.fromHSV, Color3.fromRGB, Vector2.new, UDim2.new
local wheel = wheel1
local ring = target
local slider = value
local colour = color
local modifierInputs = {
Hex = hexBox,
Red = redBox,
Green = greenBox,
Blue = blueBox,
Alpha = alphaBox,
}
local Mouse = LocalPlayer:GetMouse()
local WheelDown, SlideDown = false, false
local hue, saturation, value = 0, 0, 1
local function toPolar(v)
return math.atan2(v.y, v.x), v.magnitude
end
local function radToDeg(x)
return ((x + math.pi) / (2 * math.pi)) * 360
end
local function degToRad(degrees)
return degrees * (math.pi / 180)
end
local function hexToRGB(hex)
hex = hex:gsub("#","")
if #hex ~= 6 then return 0, 0, 0 end
local r = tonumber(hex:sub(1, 2), 16) or 0
local g = tonumber(hex:sub(3, 4), 16) or 0
local b = tonumber(hex:sub(5, 6), 16) or 0
return r, g, b
end
local function clampInput(value, min, max)
local num = tonumber(value)
if num then
return math.clamp(num, min, max)
end
return min
end
local function update()
local c = fromHSV(hue, saturation, value)
colour.BackgroundColor3 = c
colour.BackgroundTransparency = clampInput(modifierInputs.Alpha.Text, 0, 1)
modifierInputs.Red.Text = tostring(math.floor(c.r * 255 + 0.5))
modifierInputs.Green.Text = tostring(math.floor(c.g * 255 + 0.5))
modifierInputs.Blue.Text = tostring(math.floor(c.b * 255 + 0.5))
modifierInputs.Alpha.Text = clampInput(modifierInputs.Alpha.Text, 0, 1)
local hexColor = string.format("#%02X%02X%02X",
math.floor(c.r * 255 + 0.5),
math.floor(c.g * 255 + 0.5),
math.floor(c.b * 255 + 0.5))
modifierInputs.Hex.Text = hexColor
end
local function UpdateSlide(iX)
local rY = iX - slider.AbsolutePosition.X
local cY = math.clamp(rY, 0, slider.AbsoluteSize.X - slide.AbsoluteSize.X)
slide.Position = udim2(0, cY, 0.5, 0)
value = 1 - (cY / (slider.AbsoluteSize.X - slide.AbsoluteSize.X))
update()
end
local function UpdateRing(iX, iY)
local r = wheel.AbsoluteSize.x / 2
local d = v2(iX, iY) - wheel.AbsolutePosition - wheel.AbsoluteSize / 2
if d:Dot(d) > r * r then
d = d.unit * r
end
ring.Position = udim2(0.5, d.x, 0.5, d.y)
local phi, len = toPolar(d * v2(1, -1))
hue, saturation = radToDeg(phi) / 360, math.clamp(len / r, 0, 1)
slider.BackgroundColor3 = fromHSV(hue, saturation, 1)
update()
end
local function UpdateSlideFromValue(value)
local cY = (1 - value) * (slider.AbsoluteSize.X - slide.AbsoluteSize.X)
slide.Position = UDim2.new(0, cY, 0.5, 0)
end
local function UpdateRingFromHSV(hue, saturation)
local r = wheel.AbsoluteSize.X / 2
local phi = degToRad(hue * 360)
local len = saturation * r
local x = len * math.cos(phi)
local y = len * math.sin(phi)
ring.Position = UDim2.new(0.5, -x, 0.5, y)
slider.BackgroundColor3 = fromHSV(hue, saturation, 1)
end
local function updateFromRGB()
local r = clampInput(modifierInputs.Red.Text, 0, 255)
local g = clampInput(modifierInputs.Green.Text, 0, 255)
local b = clampInput(modifierInputs.Blue.Text, 0, 255)
modifierInputs.Red.Text = r
modifierInputs.Green.Text = g
modifierInputs.Blue.Text = b
hue, saturation, value = Color3.fromRGB(r, g, b):ToHSV()
UpdateSlideFromValue(value)
UpdateRingFromHSV(hue, saturation)
update()
end
local function updateFromHex()
local hex = modifierInputs.Hex.Text
local r, g, b = hexToRGB(hex)
r = clampInput(r, 0, 255)
g = clampInput(g, 0, 255)
b = clampInput(b, 0, 255)
modifierInputs.Red.Text = r
modifierInputs.Green.Text = g
modifierInputs.Blue.Text = b
hue, saturation, value = Color3.fromRGB(r, g, b):ToHSV()
UpdateSlideFromValue(value)
UpdateRingFromHSV(hue, saturation)
update()
end
local function updateFromSettings()
local r = math.floor(ColorpickerFunctions.Color.R * 255 + 0.5)
local g = math.floor(ColorpickerFunctions.Color.G * 255 + 0.5)
local b = math.floor(ColorpickerFunctions.Color.B * 255 + 0.5)
modifierInputs.Red.Text = r
modifierInputs.Green.Text = g
modifierInputs.Blue.Text = b
modifierInputs.Alpha.Text = isAlpha and ColorpickerFunctions.Alpha or 0
local hexColor = string.format("#%02X%02X%02X", r,g,b)
modifierInputs.Hex.Text = hexColor
hue, saturation, value = Color3.fromRGB(r, g, b):ToHSV()
color1.BackgroundColor3 = ColorpickerFunctions.Color
color1.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
colour.BackgroundColor3 = Color3.fromRGB(r,g,b)
colour.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
UpdateSlideFromValue(value)
UpdateRingFromHSV(hue, saturation)
end
wheel.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
WheelDown = true
UpdateRing(Mouse.X, Mouse.Y)
end
end)
slider.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
SlideDown = true
UpdateSlide(Mouse.X)
end
end)
slider.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
SlideDown = false
end
end)
wheel.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
WheelDown = false
end
end)
UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
if SlideDown then
UpdateSlide(Mouse.X)
elseif WheelDown then
UpdateRing(Mouse.X, Mouse.Y)
end
end
end)
local function onFocusEnter(instance)
local placeholder = instance.Text
instance.Text = ""
instance.PlaceholderText = placeholder
end
modifierInputs.Hex.FocusLost:Connect(updateFromHex)
modifierInputs.Red.FocusLost:Connect(updateFromRGB)
modifierInputs.Green.FocusLost:Connect(updateFromRGB)
modifierInputs.Blue.FocusLost:Connect(updateFromRGB)
modifierInputs.Alpha.FocusLost:Connect(update)
modifierInputs.Hex.Focused:Connect(function()
onFocusEnter(modifierInputs.Hex)
end)
modifierInputs.Red.Focused:Connect(function()
onFocusEnter(modifierInputs.Red)
end)
modifierInputs.Green.Focused:Connect(function()
onFocusEnter(modifierInputs.Green)
end)
modifierInputs.Blue.Focused:Connect(function()
onFocusEnter(modifierInputs.Blue)
end)
modifierInputs.Alpha.Focused:Connect(function()
onFocusEnter(modifierInputs.Alpha)
end)
local function makeCanvas()
local ColorPickerCanvas = Instance.new("CanvasGroup")
ColorPickerCanvas.Name = "ColorPickerCanvas"
ColorPickerCanvas.BackgroundTransparency = 1
ColorPickerCanvas.BorderSizePixel = 0
ColorPickerCanvas.Size = UDim2.fromScale(1, 1)
ColorPickerCanvas.ZIndex = 5
ColorPickerCanvas.GroupTransparency = 1
ColorPickerCanvas.Parent = base
ColorPickerCanvas.Visible = false
return ColorPickerCanvas
end
local function transition(isIn)
local canvas = makeCanvas()
local tweenTransparency = isIn and 0 or 1
local tweenScale = isIn and 1 or 0.95
local stateTransparency = isIn and 1 or 0
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine)
local canvasTween = Tween(canvas, tweenInfo, { GroupTransparency = tweenTransparency })
local scaleTween = Tween(promptUIScale, tweenInfo, { Scale = tweenScale })
colorPicker.Visible = true
colorPicker.Parent = canvas
canvas.Visible = true
canvas.GroupTransparency = stateTransparency
canvasTween:Play()
scaleTween:Play()
canvasTween.Completed:Wait()
if not isIn then
colorPicker.Visible = false
canvas.Visible = false
end
colorPicker.Parent = base
canvas:Destroy()
end
local function colorpickerIn()
transition(true)
end
local function colorpickerOut()
transition(false)
end
interact.MouseButton1Click:Connect(colorpickerIn)
cancel.MouseButton1Click:Connect(colorpickerOut)
confirm.MouseButton1Click:Connect(function()
colorpickerOut()
local c = fromHSV(hue, saturation, value)
ColorpickerFunctions.Color = Color3.fromRGB(c.r * 255, c.g * 255, c.b * 255)
ColorpickerFunctions.Alpha = isAlpha and clampInput(modifierInputs.Alpha.Text, 0, 1)
color1.BackgroundColor3 = ColorpickerFunctions.Color
color1.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
colorC.BackgroundColor3 = ColorpickerFunctions.Color
colorC.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
if ColorpickerFunctions.Settings.Callback then
task.spawn(function()
ColorpickerFunctions.Settings.Callback(ColorpickerFunctions.Color, isAlpha and ColorpickerFunctions.Alpha)
end)
end
end)
updateFromSettings()
function ColorpickerFunctions:UpdateName(New)
colorpickerName.Text = New
end
function ColorpickerFunctions:SetVisibility(State)
colorpicker.Visible = State
end
function ColorpickerFunctions:SetColor(color3)
ColorpickerFunctions.Color = color3
colorC.BackgroundColor3 = color3
local r = math.floor(ColorpickerFunctions.Color.R * 255 + 0.5)
local g = math.floor(ColorpickerFunctions.Color.G * 255 + 0.5)
local b = math.floor(ColorpickerFunctions.Color.B * 255 + 0.5)
modifierInputs.Red.Text = r
modifierInputs.Green.Text = g
modifierInputs.Blue.Text = b
local hexColor = string.format("#%02X%02X%02X", r,g,b)
modifierInputs.Hex.Text = hexColor
hue, saturation, value = Color3.fromRGB(r, g, b):ToHSV()
color1.BackgroundColor3 = ColorpickerFunctions.Color
colour.BackgroundColor3 = Color3.fromRGB(r,g,b)
UpdateSlideFromValue(value)
UpdateRingFromHSV(hue, saturation)
if ColorpickerFunctions.Settings.Callback then
task.spawn(function()
ColorpickerFunctions.Settings.Callback(ColorpickerFunctions.Color, isAlpha and ColorpickerFunctions.Alpha)
end)
end
end
function ColorpickerFunctions:SetAlpha(alpha)
ColorpickerFunctions.Alpha = alpha
colorC.Transparency = alpha
updateFromSettings()
end
if Flag then
MacLib.Options[Flag] = ColorpickerFunctions
end
return ColorpickerFunctions
end
function SectionFunctions:Header(Settings, Flag)
local HeaderFunctions = {Settings = Settings}
local header = Instance.new("Frame")
header.Name = "Header"
header.AutomaticSize = Enum.AutomaticSize.Y
header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
header.BackgroundTransparency = 1
header.BorderColor3 = Color3.fromRGB(0, 0, 0)
header.BorderSizePixel = 0
header.LayoutOrder = 0
header.Size = UDim2.fromScale(1, 0)
header.Parent = section
local uIPadding = Instance.new("UIPadding")
uIPadding.Name = "UIPadding"
uIPadding.PaddingBottom = UDim.new(0, 5)
uIPadding.Parent = header
local headerText = Instance.new("TextLabel")
headerText.Name = "HeaderText"
headerText.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
headerText.RichText = true
headerText.Text = HeaderFunctions.Settings.Text or HeaderFunctions.Settings.Name
headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
headerText.TextSize = 16
headerText.TextTransparency = 0.3
headerText.TextWrapped = true
headerText.TextXAlignment = Enum.TextXAlignment.Left
headerText.AutomaticSize = Enum.AutomaticSize.Y
headerText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
headerText.BackgroundTransparency = 1
headerText.BorderColor3 = Color3.fromRGB(0, 0, 0)
headerText.BorderSizePixel = 0
headerText.Size = UDim2.fromScale(1, 0)
headerText.Parent = header
function HeaderFunctions:UpdateName(New)
headerText.Text = New
end
function HeaderFunctions:SetVisibility(State)
header.Visible = State
end
if Flag then
MacLib.Options[Flag] = HeaderFunctions
end
return HeaderFunctions
end
function SectionFunctions:Label(Settings, Flag)
local LabelFunctions = {Settings = Settings}
local label = Instance.new("Frame")
label.Name = "Label"
label.AutomaticSize = Enum.AutomaticSize.Y
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 1
label.BorderColor3 = Color3.fromRGB(0, 0, 0)
label.BorderSizePixel = 0
label.Size = UDim2.new(1, 0, 0, 38)
label.Parent = section
local labelText = Instance.new("TextLabel")
labelText.Name = "LabelText"
labelText.FontFace = Font.new(assets.interFont)
labelText.RichText = true
labelText.Text = LabelFunctions.Settings.Text or LabelFunctions.Settings.Name
labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
labelText.TextSize = 13
labelText.TextTransparency = 0.5
labelText.TextWrapped = true
labelText.TextXAlignment = Enum.TextXAlignment.Left
labelText.AutomaticSize = Enum.AutomaticSize.Y
labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
labelText.BackgroundTransparency = 1
labelText.BorderColor3 = Color3.fromRGB(0, 0, 0)
labelText.BorderSizePixel = 0
labelText.Size = UDim2.fromScale(1, 1)
labelText.Parent = label
function LabelFunctions:UpdateName(New)
labelText.Text = New
end
function LabelFunctions:SetVisibility(State)
label.Visible = State
end
if Flag then
MacLib.Options[Flag] = LabelFunctions
end
return LabelFunctions
end
function SectionFunctions:SubLabel(Settings, Flag)
local SubLabelFunctions = {Settings = Settings}
local subLabel = Instance.new("Frame")
subLabel.Name = "SubLabel"
subLabel.AutomaticSize = Enum.AutomaticSize.Y
subLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
subLabel.BackgroundTransparency = 1
subLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
subLabel.BorderSizePixel = 0
subLabel.Size = UDim2.new(1, 0, 0, 0)
subLabel.Parent = section
local subLabelText = Instance.new("TextLabel")
subLabelText.Name = "SubLabelText"
subLabelText.FontFace = Font.new(assets.interFont)
subLabelText.RichText = true
subLabelText.Text = SubLabelFunctions.Settings.Text or SubLabelFunctions.Settings.Name
subLabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
subLabelText.TextSize = 12
subLabelText.TextTransparency = 0.7
subLabelText.TextWrapped = true
subLabelText.TextXAlignment = Enum.TextXAlignment.Left
subLabelText.AutomaticSize = Enum.AutomaticSize.Y
subLabelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
subLabelText.BackgroundTransparency = 1
subLabelText.BorderColor3 = Color3.fromRGB(0, 0, 0)
subLabelText.BorderSizePixel = 0
subLabelText.Size = UDim2.fromScale(1, 1)
subLabelText.Parent = subLabel
function SubLabelFunctions:UpdateName(New)
subLabelText.Text = New
end
function SubLabelFunctions:SetVisibility(State)
subLabel.Visible = State
end
if Flag then
MacLib.Options[Flag] = SubLabelFunctions
end
return SubLabelFunctions
end
function SectionFunctions:Paragraph(Settings, Flag)
local ParagraphFunctions = {Settings = Settings}
local paragraph = Instance.new("Frame")
paragraph.Name = "Paragraph"
paragraph.AutomaticSize = Enum.AutomaticSize.Y
paragraph.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
paragraph.BackgroundTransparency = 1
paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
paragraph.BorderSizePixel = 0
paragraph.Size = UDim2.new(1, 0, 0, 38)
paragraph.Parent = section
local paragraphHeader = Instance.new("TextLabel")
paragraphHeader.Name = "ParagraphHeader"
paragraphHeader.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
paragraphHeader.RichText = true
paragraphHeader.Text = ParagraphFunctions.Settings.Header
paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphHeader.TextSize = 15
paragraphHeader.TextTransparency = 0.4
paragraphHeader.TextWrapped = true
paragraphHeader.TextXAlignment = Enum.TextXAlignment.Left
paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
paragraphHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
paragraphHeader.BackgroundTransparency = 1
paragraphHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
paragraphHeader.BorderSizePixel = 0
paragraphHeader.Size = UDim2.fromScale(1, 0)
paragraphHeader.Parent = paragraph
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "UIListLayout"
uIListLayout.Padding = UDim.new(0, 5)
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = paragraph
local paragraphBody = Instance.new("TextLabel")
paragraphBody.Name = "ParagraphBody"
paragraphBody.FontFace = Font.new(assets.interFont)
paragraphBody.RichText = true
paragraphBody.Text = ParagraphFunctions.Settings.Body
paragraphBody.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphBody.TextSize = 13
paragraphBody.TextTransparency = 0.5
paragraphBody.TextWrapped = true
paragraphBody.TextXAlignment = Enum.TextXAlignment.Left
paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
paragraphBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
paragraphBody.BackgroundTransparency = 1
paragraphBody.BorderColor3 = Color3.fromRGB(0, 0, 0)
paragraphBody.BorderSizePixel = 0
paragraphBody.LayoutOrder = 1
paragraphBody.Size = UDim2.fromScale(1, 0)
paragraphBody.Parent = paragraph
function ParagraphFunctions:UpdateHeader(New)
paragraphHeader.Text = New
end
function ParagraphFunctions:UpdateBody(New)
paragraphBody.Text = New
end
function ParagraphFunctions:SetVisibility(State)
paragraph.Visible = State
end
if Flag then
MacLib.Options[Flag] = ParagraphFunctions
end
return ParagraphFunctions
end
function SectionFunctions:Divider()
local DividerFunctions = {}
local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.AnchorPoint = Vector2.new(0, 1)
divider.AutomaticSize = Enum.AutomaticSize.Y
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 1
divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
divider.BorderSizePixel = 0
divider.Position = UDim2.fromScale(0, 1)
divider.Size = UDim2.new(1, 0, 0, 1)
divider.Parent = section
local uIPadding = Instance.new("UIPadding")
uIPadding.Name = "UIPadding"
uIPadding.PaddingBottom = UDim.new(0, 8)
uIPadding.PaddingTop = UDim.new(0, 8)
uIPadding.Parent = divider
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "UIListLayout"
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = divider
local line = Instance.new("Frame")
line.Name = "Line"
line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
line.BackgroundTransparency = 0.9
line.BorderColor3 = Color3.fromRGB(0, 0, 0)
line.BorderSizePixel = 0
line.Size = UDim2.new(1, 0, 0, 1)
line.Parent = divider
function DividerFunctions:Remove()
divider:Destroy()
end
function DividerFunctions:SetVisibility(State)
divider.Visible = State
end
return DividerFunctions
end
function SectionFunctions:Spacer()
local SpacerFunctions = {}
local spacer = Instance.new("Frame")
spacer.Name = "Spacer"
spacer.AnchorPoint = Vector2.new(0, 1)
spacer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
spacer.BackgroundTransparency = 1
spacer.BorderColor3 = Color3.fromRGB(0, 0, 0)
spacer.BorderSizePixel = 0
spacer.Position = UDim2.fromScale(0, 1)
spacer.Parent = section
function SpacerFunctions:Remove()
spacer:Destroy()
end
function SpacerFunctions:SetVisibility(State)
spacer.Visible = State
end
return SpacerFunctions
end
return SectionFunctions
end
local function SelectCurrentTab()
local easetime = 0.15
if currentTabInstance then
currentTabInstance.Parent = nil
end
for i, tabInfo in pairs(tabs) do
Tween(i, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
BackgroundTransparency = (i == tabSwitcher and 0.98 or 1)
}):Play()
if tabInfo.tabStroke then
Tween(tabInfo.tabStroke, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
Transparency = (i == tabSwitcher and 0.95 or 1)
}):Play()
end
if tabInfo.switcherImage then
Tween(tabInfo.switcherImage, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
ImageTransparency = (i == tabSwitcher and 0.1 or 0.5)
}):Play()
end
if tabInfo.switcherName then
Tween(tabInfo.switcherName, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
TextTransparency = (i == tabSwitcher and 0.1 or 0.5)
}):Play()
end
if tabInfo.selector then
tabInfo.selector.Visible = false
end
if tabInfo.closeSelector then
tabInfo.closeSelector()
end
end
tabs[tabSwitcher].tabContent.Parent = content
currentTabInstance = tabs[tabSwitcher].tabContent
currentTab.Text = Settings.Name
currentTab.Visible = (#subtabOrder == 0)
if subtabSelector then
subtabSelector.Visible = (#subtabOrder > 0)
end
end
tabSwitcher.MouseButton1Click:Connect(function()
SelectCurrentTab()
end)
function TabFunctions:Select()
SelectCurrentTab()
end
function TabFunctions:InsertConfigSection(Side)
local configSection = TabFunctions:Section({ Side = "Left" })
if isStudio then
configSection:Label({Text = "Config system unavailable. (Environment isStudio)"})
return "Config system unavailable."
end
local inputPath = nil
local selectedConfig = nil
configSection:Input({
Name = "Config Name",
Placeholder = "Name",
AcceptedCharacters = "All",
Callback = function(input)
inputPath = input
end,
})
local configSelection = configSection:Dropdown({
Name = "Select Config",
Multi = false,
Required = false,
Options = MacLib:RefreshConfigList(),
Callback = function(Value)
selectedConfig = Value
end,
})
configSection:Button({
Name = "Create Config",
Callback = function()
if not inputPath or string.gsub(inputPath, " ", "") == "" then
WindowFunctions:Notify({
Title = "Interface",
Description = "Config name cannot be empty."
})
return
end
local success, returned = MacLib:SaveConfig(inputPath)
if not success then
WindowFunctions:Notify({
Title = "Interface",
Description = "Unable to save config, return error: " .. returned
})
end
WindowFunctions:Notify({
Title = "Interface",
Description = string.format("Created config %q", inputPath),
})
configSelection:ClearOptions()
configSelection:InsertOptions(MacLib:RefreshConfigList())
end,
})
configSection:Button({
Name = "Load Config",
Callback = function()
local success, returned = MacLib:LoadConfig(configSelection.Value)
if not success then
WindowFunctions:Notify({
Title = "Interface",
Description = "Unable to load config, return error: " .. returned
})
return
end
WindowFunctions:Notify({
Title = "Interface",
Description = string.format("Loaded config %q", configSelection.Value),
})
end,
})
configSection:Button({
Name = "Overwrite Config",
Callback = function()
local success, returned = MacLib:SaveConfig(configSelection.Value)
if not success then
WindowFunctions:Notify({
Title = "Interface",
Description = "Unable to overwrite config, return error: " .. returned
})
return
end
WindowFunctions:Notify({
Title = "Interface",
Description = string.format("Overwrote config %q", configSelection.Value),
})
end,
})
configSection:Button({
Name = "Refresh Config List",
Callback = function()
configSelection:ClearOptions()
configSelection:InsertOptions(MacLib:RefreshConfigList())
end,
})
local autoloadLabel
configSection:Button({
Name = "Set as autoload",
Callback = function()
local name = configSelection.Value
writefile(MacLib.Folder .. "/settings/autoload.txt", name)
autoloadLabel:UpdateName("Autoload config: " .. name)
WindowFunctions:Notify({
Title = "Interface",
Description = string.format("Set %q as autoload", name),
})
end,
})
autoloadLabel = configSection:Label({Text = "Autoload config: None"})
if isfile(MacLib.Folder .. "/settings/autoload.txt") then
local name = readfile(MacLib.Folder .. "/settings/autoload.txt")
autoloadLabel:UpdateName("Autoload config: " .. name)
end
end
tabs[tabSwitcher] = {
tabContent = elements1,
tabStroke = tabSwitcherUIStroke,
switcherImage = tabImage,
switcherName = tabSwitcherName,
selector = subtabSelector,
closeSelector = function()
setSubTabListOpen(false)
end,
}
return TabFunctions
end
return SectionFunctions
end
function WindowFunctions:Notify(Settings)
local NotificationFunctions = {}
local notification = Instance.new("Frame")
notification.Name = "Notification"
notification.AnchorPoint = Vector2.new(0.5, 0.5)
notification.AutomaticSize = Enum.AutomaticSize.Y
notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
notification.BackgroundTransparency = 0
notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
notification.BorderSizePixel = 0
notification.Position = UDim2.fromScale(0.5, 0.5)
notification.Size = UDim2.fromOffset(Settings.SizeX or 250, 0)
notification.Parent = notifications
local notificationUIStroke = Instance.new("UIStroke")
notificationUIStroke.Name = "NotificationUIStroke"
notificationUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
notificationUIStroke.Color = Color3.fromRGB(255, 255, 255)
notificationUIStroke.Transparency = 0.9
notificationUIStroke.Parent = notification
local notificationUICorner = Instance.new("UICorner")
notificationUICorner.Name = "NotificationUICorner"
notificationUICorner.CornerRadius = UDim.new(0, 10)
notificationUICorner.Parent = notification
local notificationUIScale = Instance.new("UIScale")
notificationUIScale.Name = "NotificationUIScale"
notificationUIScale.Parent = notification
notificationUIScale.Scale = 0
local notificationInformation = Instance.new("Frame")
notificationInformation.Name = "NotificationInformation"
notificationInformation.AutomaticSize = Enum.AutomaticSize.Y
notificationInformation.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
notificationInformation.BackgroundTransparency = 1
notificationInformation.BorderColor3 = Color3.fromRGB(0, 0, 0)
notificationInformation.BorderSizePixel = 0
notificationInformation.Size = UDim2.fromScale(1, 1)
local notificationTitle = Instance.new("TextLabel")
notificationTitle.Name = "NotificationTitle"
notificationTitle.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.SemiBold,
Enum.FontStyle.Normal
)
notificationTitle.RichText = true
notificationTitle.Text = Settings.Title
notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationTitle.TextSize = 13
notificationTitle.TextTransparency = 0.2
notificationTitle.TextTruncate = Enum.TextTruncate.SplitWord
notificationTitle.TextXAlignment = Enum.TextXAlignment.Left
notificationTitle.TextYAlignment = Enum.TextYAlignment.Top
notificationTitle.AutomaticSize = Enum.AutomaticSize.XY
notificationTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
notificationTitle.BackgroundTransparency = 1
notificationTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
notificationTitle.BorderSizePixel = 0
notificationTitle.Size = UDim2.new(1, -12, 0, 0)
local notificationTitleUIPadding = Instance.new("UIPadding")
notificationTitleUIPadding.Name = "NotificationTitleUIPadding"
notificationTitleUIPadding.PaddingRight = UDim.new(0, 25)
notificationTitleUIPadding.Parent = notificationTitle
notificationTitle.Parent = notificationInformation
local notificationDescription = Instance.new("TextLabel")
notificationDescription.Name = "NotificationDescription"
notificationDescription.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
notificationDescription.Text = Settings.Description
notificationDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationDescription.TextSize = 11
notificationDescription.TextTransparency = 0.5
notificationDescription.TextWrapped = true
notificationDescription.RichText = true
notificationDescription.TextXAlignment = Enum.TextXAlignment.Left
notificationDescription.TextYAlignment = Enum.TextYAlignment.Top
notificationDescription.AutomaticSize = Enum.AutomaticSize.XY
notificationDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
notificationDescription.BackgroundTransparency = 1
notificationDescription.BorderColor3 = Color3.fromRGB(0, 0, 0)
notificationDescription.BorderSizePixel = 0
notificationDescription.Size = UDim2.new(1, -12, 0, 0)
local notificationDescriptionUIPadding = Instance.new("UIPadding")
notificationDescriptionUIPadding.Name = "NotificationDescriptionUIPadding"
notificationDescriptionUIPadding.PaddingRight = UDim.new(0, 25)
notificationDescriptionUIPadding.PaddingTop = UDim.new(0, 17)
notificationDescriptionUIPadding.Parent = notificationDescription
notificationDescription.Parent = notificationInformation
local notificationUIPadding = Instance.new("UIPadding")
notificationUIPadding.Name = "NotificationUIPadding"
notificationUIPadding.PaddingBottom = UDim.new(0, 12)
notificationUIPadding.PaddingLeft = UDim.new(0, 10)
notificationUIPadding.PaddingRight = UDim.new(0, 10)
notificationUIPadding.PaddingTop = UDim.new(0, 10)
notificationUIPadding.Parent = notificationInformation
notificationInformation.Parent = notification
local notificationControls = Instance.new("Frame")
notificationControls.Name = "NotificationControls"
notificationControls.AutomaticSize = Enum.AutomaticSize.Y
notificationControls.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
notificationControls.BackgroundTransparency = 1
notificationControls.BorderColor3 = Color3.fromRGB(0, 0, 0)
notificationControls.BorderSizePixel = 0
notificationControls.Size = UDim2.fromScale(1, 1)
local interactable = Instance.new("TextButton")
interactable.Name = "Interactable"
interactable.FontFace = Font.new(assets.interFont)
interactable.Text = "✓"
interactable.TextColor3 = Color3.fromRGB(255, 255, 255)
interactable.TextSize = 17
interactable.TextTransparency = 0.2
interactable.AnchorPoint = Vector2.new(1, 0.5)
interactable.AutomaticSize = Enum.AutomaticSize.XY
interactable.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
interactable.BackgroundTransparency = 1
interactable.BorderColor3 = Color3.fromRGB(0, 0, 0)
interactable.BorderSizePixel = 0
interactable.LayoutOrder = 1
interactable.Position = UDim2.fromScale(1, 0.5)
interactable.Parent = notificationControls
local uIPadding = Instance.new("UIPadding")
uIPadding.Name = "UIPadding"
uIPadding.PaddingBottom = UDim.new(0, 6)
uIPadding.PaddingRight = UDim.new(0, 13)
uIPadding.PaddingTop = UDim.new(0, 6)
uIPadding.Parent = notificationControls
notificationControls.Parent = notification
local tweens = {
In = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
Scale = Settings.Scale or baseUIScale.Scale
}),
Out = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
Scale = 0
}),
}
local styles = {
None = function() interactable:Destroy() end,
Confirm = function() interactable.Text = "✓" end,
Cancel = function() interactable.Text = "✗" end
}
local style = styles[Settings.Style] or function() interactable:Destroy() end
style()
if interactable then
interactable.MouseButton1Click:Connect(function()
NotificationFunctions:Cancel()
if Settings.Callback then
task.spawn(Settings.Callback)
end
end)
end
local AnimateNotification = task.spawn(function()
tweens.In:Play()
Settings.Lifetime = Settings.Lifetime or 3
if Settings.Lifetime ~= 0 then
task.wait(Settings.Lifetime)
local out = tweens.Out
out:Play()
out.Completed:Wait()
notification:Destroy()
end
end)
function NotificationFunctions:UpdateTitle(New)
notificationTitle.Text = New
end
function NotificationFunctions:UpdateDescription(New)
notificationDescription.Text = New
end
function NotificationFunctions:Resize(X)
local targ = X or 250
notification.Size = UDim2.fromOffset(targ, 0)
end
function NotificationFunctions:Cancel()
task.cancel(AnimateNotification)
local out = tweens.Out
out:Play()
out.Completed:Wait()
notification:Destroy()
end
return NotificationFunctions
end
function WindowFunctions:Dialog(Settings)
local DialogFunctions = {}
local dialogCanvas = Instance.new("CanvasGroup")
dialogCanvas.Name = "DialogCanvas"
dialogCanvas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dialogCanvas.BackgroundTransparency = 1
dialogCanvas.BorderColor3 = Color3.fromRGB(0, 0, 0)
dialogCanvas.BorderSizePixel = 0
dialogCanvas.Size = UDim2.fromScale(1, 1)
dialogCanvas.GroupTransparency = 1
dialogCanvas.Parent = base
local dialog = Instance.new("Frame")
dialog.Name = "Dialog"
dialog.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dialog.BackgroundTransparency = 0.5
dialog.BorderColor3 = Color3.fromRGB(0, 0, 0)
dialog.BorderSizePixel = 0
dialog.Size = UDim2.fromScale(1, 1)
local dialogUICorner = Instance.new("UICorner")
dialogUICorner.Name = "BaseUICorner"
dialogUICorner.CornerRadius = UDim.new(0, 10)
dialogUICorner.Parent = dialog
local prompt = Instance.new("Frame")
prompt.Name = "Prompt"
prompt.AnchorPoint = Vector2.new(0.5, 0.5)
prompt.AutomaticSize = Enum.AutomaticSize.Y
prompt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
prompt.BackgroundTransparency = 0
prompt.BorderColor3 = Color3.fromRGB(0, 0, 0)
prompt.BorderSizePixel = 0
prompt.Position = UDim2.fromScale(0.5, 0.5)
prompt.Size = UDim2.fromOffset(280, 0)
local promptUIScale = Instance.new("UIScale")
promptUIScale.Name = "BaseUIScale"
promptUIScale.Parent = prompt
promptUIScale.Scale = 0.95
local promptUIStroke = Instance.new("UIStroke")
promptUIStroke.Name = "PromptUIStroke"
promptUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
promptUIStroke.Color = Color3.fromRGB(255, 255, 255)
promptUIStroke.Transparency = 0.9
promptUIStroke.Parent = prompt
local promptUICorner = Instance.new("UICorner")
promptUICorner.Name = "PromptUICorner"
promptUICorner.CornerRadius = UDim.new(0, 10)
promptUICorner.Parent = prompt
local promptUIPadding = Instance.new("UIPadding")
promptUIPadding.Name = "PromptUIPadding"
promptUIPadding.PaddingBottom = UDim.new(0, 20)
promptUIPadding.PaddingLeft = UDim.new(0, 20)
promptUIPadding.PaddingRight = UDim.new(0, 20)
promptUIPadding.PaddingTop = UDim.new(0, 20)
promptUIPadding.Parent = prompt
local paragraph = Instance.new("Frame")
paragraph.Name = "Paragraph"
paragraph.AutomaticSize = Enum.AutomaticSize.Y
paragraph.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
paragraph.BackgroundTransparency = 1
paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
paragraph.BorderSizePixel = 0
paragraph.Size = UDim2.new(1, 0, 0, 38)
local paragraphHeader = Instance.new("TextLabel")
paragraphHeader.Name = "ParagraphHeader"
paragraphHeader.FontFace = Font.new(
assets.interFont,
Enum.FontWeight.Medium,
Enum.FontStyle.Normal
)
paragraphHeader.RichText = true
paragraphHeader.Text = Settings.Title
paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphHeader.TextSize = 18
paragraphHeader.TextTransparency = 0.4
paragraphHeader.TextWrapped = true
paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
paragraphHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
paragraphHeader.BackgroundTransparency = 1
paragraphHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
paragraphHeader.BorderSizePixel = 0
paragraphHeader.Size = UDim2.fromScale(1, 0)
paragraphHeader.Parent = paragraph
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "UIListLayout"
uIListLayout.Padding = UDim.new(0, 15)
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = paragraph
local paragraphBody = Instance.new("TextLabel")
paragraphBody.Name = "ParagraphBody"
paragraphBody.FontFace = Font.new(assets.interFont)
paragraphBody.RichText = true
paragraphBody.Text = Settings.Description
paragraphBody.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphBody.TextSize = 14
paragraphBody.TextTransparency = 0.5
paragraphBody.TextWrapped = true
paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
paragraphBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
paragraphBody.BackgroundTransparency = 1
paragraphBody.BorderColor3 = Color3.fromRGB(0, 0, 0)
paragraphBody.BorderSizePixel = 0
paragraphBody.LayoutOrder = 1
paragraphBody.Size = UDim2.fromScale(1, 0)
paragraphBody.Parent = paragraph
paragraph.Parent = prompt
local interactions = Instance.new("Frame")
interactions.Name = "Interactions"
interactions.AutomaticSize = Enum.AutomaticSize.Y
interactions.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
interactions.BackgroundTransparency = 1
interactions.BorderColor3 = Color3.fromRGB(0, 0, 0)
interactions.BorderSizePixel = 0
interactions.LayoutOrder = 1
interactions.Size = UDim2.fromScale(1, 0)
local uIListLayout1 = Instance.new("UIListLayout")
uIListLayout1.Name = "UIListLayout"
uIListLayout1.Padding = UDim.new(0, 10)
uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout1.Parent = interactions
local uIPadding = Instance.new("UIPadding")
uIPadding.Name = "UIPadding"
uIPadding.PaddingTop = UDim.new(0, 20)
uIPadding.Parent = interactions
interactions.Parent = prompt
local uIListLayout2 = Instance.new("UIListLayout")
uIListLayout2.Name = "UIListLayout"
uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout2.Parent = prompt
prompt.Parent = dialog
dialog.Parent = dialogCanvas
local canvasIn = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 0 })
local canvasOut = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 1 })
local scaleIn = Tween(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 1 })
local scaleOut = Tween(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 0.95 })
local function dialogIn()
canvasIn:Play()
scaleIn:Play()
canvasIn.Completed:Wait()
dialog.Parent = base
end
local function dialogOut()
if not dialog.Parent then return end
dialog.Parent = dialogCanvas
canvasOut:Play()
scaleOut:Play()
canvasOut.Completed:Wait()
dialogCanvas:Destroy()
end
for _, v in pairs(Settings.Buttons) do
local button = Instance.new("TextButton")
button.Name = "Button"
button.FontFace = Font.new(assets.interFont)
button.Text = v.Name
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 15
button.TextTransparency = 0.5
button.TextTruncate = Enum.TextTruncate.AtEnd
button.AutoButtonColor = false
button.AutomaticSize = Enum.AutomaticSize.Y
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.BorderColor3 = Color3.fromRGB(0, 0, 0)
button.BorderSizePixel = 0
button.Size = UDim2.fromScale(1, 0)
local uIPadding1 = Instance.new("UIPadding")
uIPadding1.Name = "UIPadding"
uIPadding1.PaddingBottom = UDim.new(0, 9)
uIPadding1.PaddingLeft = UDim.new(0, 10)
uIPadding1.PaddingRight = UDim.new(0, 10)
uIPadding1.PaddingTop = UDim.new(0, 9)
uIPadding1.Parent = button
local baseUICorner1 = Instance.new("UICorner")
baseUICorner1.Name = "BaseUICorner"
baseUICorner1.CornerRadius = UDim.new(0, 10)
baseUICorner1.Parent = button
button.Parent = interactions
local TweenSettings = {
DefaultTransparency = 0,
DefaultTransparency2 = 0.5,
HoverTransparency = 0.3,
HoverTransparency2 = 0.6,
EasingStyle = Enum.EasingStyle.Sine
}
local function ChangeState(State)
if State == "Idle" then
Tween(button, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
BackgroundTransparency = TweenSettings.DefaultTransparency,
TextTransparency = TweenSettings.DefaultTransparency2
}):Play()
elseif State == "Hover" then
Tween(button, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
BackgroundTransparency = TweenSettings.HoverTransparency,
TextTransparency = TweenSettings.HoverTransparency2
}):Play()
end
end
button.MouseButton1Click:Connect(function()
if dialogCanvas.GroupTransparency ~= 0 then return end
if v.Callback then
v.Callback()
end
dialogOut()
end)
button.MouseEnter:Connect(function()
ChangeState("Hover")
end)
button.MouseLeave:Connect(function()
ChangeState("Idle")
end)
end
dialogIn()
function DialogFunctions:UpdateTitle(New)
paragraphHeader.Text = New
end
function DialogFunctions:UpdateDescription(New)
paragraphBody.Text = New
end
function DialogFunctions:Cancel()
dialogOut()
end
return DialogFunctions
end
function WindowFunctions:SetNotificationsState(State)
notifications.Visible = State
end
function WindowFunctions:GetNotificationsState(State)
return notifications.Visible
end
function WindowFunctions:SetState(State)
windowState = State
base.Visible = State
end
function WindowFunctions:GetState()
return windowState
end
local onUnloadCallback
function WindowFunctions:Unload()
if onUnloadCallback then
onUnloadCallback()
end
macLib:Destroy()
unloaded = true
end
function WindowFunctions.onUnloaded(callback)
onUnloadCallback = callback
end
local MenuKeybind = Settings.Keybind or Enum.KeyCode.RightControl
local function ToggleMenu()
local state = not WindowFunctions:GetState()
WindowFunctions:SetState(state)
WindowFunctions:Notify({
Title = Settings.Title,
Description = (state and "Maximized " or "Minimized ") .. "the menu. Use " .. tostring(MenuKeybind.Name) .. " to toggle it.",
Lifetime = 5
})
end
UserInputService.InputEnded:Connect(function(inp, gpe)
if gpe then return end
if inp.KeyCode == MenuKeybind then
ToggleMenu()
end
end)
minimize.MouseButton1Click:Connect(ToggleMenu)
exit.MouseButton1Click:Connect(function()
WindowFunctions:Dialog({
Title = Settings.Title,
Description = "Are you sure you want to exit the menu? You will lose any unsaved configurations.",
Buttons = {
{
Name = "Confirm",
Callback = function()
WindowFunctions:Unload()
end,
},
{
Name = "Cancel"
}
}
})
end)
function WindowFunctions:SetKeybind(Keycode)
MenuKeybind = Keycode
end
function WindowFunctions:SetAcrylicBlurState(State)
acrylicBlur = State
base.BackgroundTransparency = State and 0.05 or 0
end
function WindowFunctions:GetAcrylicBlurState()
return acrylicBlur
end
local function _SetUserInfoState(State)
if State then
headshot.Image = (isReady and headshotImage) or "rbxassetid://0"
username.Text = "@" .. LocalPlayer.Name
displayName.Text = LocalPlayer.DisplayName
else
headshot.Image = assets.userInfoBlurred
local nameLength = #LocalPlayer.Name
local displayNameLength = #LocalPlayer.DisplayName
username.Text = "@" .. string.rep(".", nameLength)
displayName.Text = string.rep(".", displayNameLength)
end
end
local showUserInfo
if Settings.ShowUserInfo ~= nil then
showUserInfo = Settings.ShowUserInfo
else
showUserInfo = true
end
_SetUserInfoState(showUserInfo)
function WindowFunctions:SetUserInfoState(State)
_SetUserInfoState(State)
end
function WindowFunctions:GetUserInfoState(State)
return showUserInfo
end
function WindowFunctions:SetSize(Size)
base.Size = parseSize(Size, base.Size)
updateContentWidth()
end
function WindowFunctions:GetSize(Size)
return base.Size
end
function WindowFunctions:SetScale(Scale)
if isMobile then
baseUIScale.Scale = tonumber(Scale) or baseUIScale.Scale
end
end
function WindowFunctions:GetScale()
return baseUIScale.Scale
end
function WindowFunctions:GetPlatform()
return isMobile and "Mobile" or "PC"
end
local ClassParser = {
["Toggle"] = {
Save = function(Flag, data)
return {
type = "Toggle",
flag = Flag,
state = data.State or false
}
end,
Load = function(Flag, data)
if MacLib.Options[Flag] and data.state then
MacLib.Options[Flag]:UpdateState(data.state)
end
end
},
["Slider"] = {
Save = function(Flag, data)
return {
type = "Slider",
flag = Flag,
value = (data.Value and tostring(data.Value)) or false
}
end,
Load = function(Flag, data)
if MacLib.Options[Flag] and data.value then
MacLib.Options[Flag]:UpdateValue(data.value)
end
end
},
["Input"] = {
Save = function(Flag, data)
return {
type = "Input",
flag = Flag,
text = data.Text
}
end,
Load = function(Flag, data)
if MacLib.Options[Flag] and data.text and type(data.text) == "string" then
MacLib.Options[Flag]:UpdateText(data.text)
end
end
},
["Keybind"] = {
Save = function(Flag, data)
return {
type = "Keybind",
flag = Flag,
bind = (typeof(data.Bind) == "EnumItem" and data.Bind.Name) or nil
}
end,
Load = function(Flag, data)
if MacLib.Options[Flag] and data.bind then
MacLib.Options[Flag]:Bind(Enum.KeyCode[data.bind])
end
end
},
["Dropdown"] = {
Save = function(Flag, data)
return {
type = "Dropdown",
flag = Flag,
value = data.Value
}
end,
Load = function(Flag, data)
if MacLib.Options[Flag] and data.value then
MacLib.Options[Flag]:UpdateSelection(data.value)
end
end
},
["Colorpicker"] = {
Save = function(Flag, data)
local function Color3ToHex(color)
return string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
end
return {
type = "Colorpicker",
flag = Flag,
color = Color3ToHex(data.Color) or nil,
alpha = data.Alpha
}
end,
Load = function(Flag, data)
local function HexToColor3(hex)
local r = tonumber(hex:sub(2, 3), 16) / 255
local g = tonumber(hex:sub(4, 5), 16) / 255
local b = tonumber(hex:sub(6, 7), 16) / 255
return Color3.new(r, g, b)
end
if MacLib.Options[Flag] and data.color then
MacLib.Options[Flag]:SetColor(HexToColor3(data.color))
if data.alpha then
MacLib.Options[Flag]:SetAlpha(data.alpha)
end
end
end
}
}
local function BuildFolderTree()
if isStudio or not (isfolder and makefolder) then return "Config system unavailable." end
local paths = {
MacLib.Folder,
MacLib.Folder .. "/settings"
}
for i = 1, #paths do
local str = paths[i]
if not isfolder(str) then
makefolder(str)
end
end
end
function MacLib:LoadAutoLoadConfig()
if isStudio or not (isfile and readfile) then return "Config system unavailable." end
if isfile(MacLib.Folder .. "/settings/autoload.txt") then
local name = readfile(MacLib.Folder .. "/settings/autoload.txt")
local suc, err = MacLib:LoadConfig(name)
if not suc then
WindowFunctions:Notify({
Title = "Interface",
Description = "Error loading autoload config: " .. err
})
end
WindowFunctions:Notify({
Title = "Interface",
Description = string.format("Autoloaded config: %q", name),
})
end
end
function MacLib:SetFolder(Folder)
if isStudio then return "Config system unavailable." end
MacLib.Folder = Folder;
BuildFolderTree()
end
function MacLib:SaveConfig(Path)
if isStudio or not writefile then return "Config system unavailable." end
if (not Path) then
return false, "Please select a config file."
end
local fullPath = MacLib.Folder .. "/settings/" .. Path .. ".json"
local data = {
objects = {}
}
for flag, option in next, MacLib.Options do
if not ClassParser[option.Class] then continue end
if option.IgnoreConfig then continue end
table.insert(data.objects, ClassParser[option.Class].Save(flag, option))
end
local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
if not success then
return false, "Unable to encode into JSON data"
end
writefile(fullPath, encoded)
return true
end
function MacLib:LoadConfig(Path)
if isStudio or not (isfile and readfile) then return "Config system unavailable." end
if (not Path) then
return false, "Please select a config file."
end
local file = MacLib.Folder .. "/settings/" .. Path .. ".json"
if not isfile(file) then return false, "Invalid file" end
local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
if not success then return false, "Unable to decode JSON data." end
for _, option in next, decoded.objects do
if ClassParser[option.type] then
task.spawn(function()
ClassParser[option.type].Load(option.flag, option)
end)
end
end
return true
end
function MacLib:RefreshConfigList()
if isStudio or not (isfolder and listfiles) then return "Config system unavailable." end
local list = (isfolder(MacLib.Folder) and isfolder(MacLib.Folder .. "/settings")) and listfiles(MacLib.Folder .. "/settings") or {}
local out = {}
for i = 1, #list do
local file = list[i]
if file:sub(-5) == ".json" then
local pos = file:find(".json", 1, true)
local start = pos
local char = file:sub(pos, pos)
while char ~= "/" and char ~= "\\" and char ~= "" do
pos = pos - 1
char = file:sub(pos, pos)
end
if char == "/" or char == "\\" then
local name = file:sub(pos + 1, start - 1)
if name ~= "options" then
table.insert(out, name)
end
end
end
end
return out
end
macLib.Enabled = false
local assetList = {}
for _, assetId in pairs(assets) do
table.insert(assetList, assetId)
end
ContentProvider:PreloadAsync(assetList)
macLib.Enabled = true
windowState = true
return WindowFunctions
end
return MacLib
