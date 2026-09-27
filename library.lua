local MacLib = {
Options = {},
Folder = "Maclib",
GetService = function(service)
return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
end
}
local TweenService = MacLib.GetService("TweenService")
local RunService = MacLib.GetService("RunService")
local HttpService = MacLib.GetService("HttpService")
local ContentProvider = MacLib.GetService("ContentProvider")
local UserInputService = MacLib.GetService("UserInputService")
local Lighting = MacLib.GetService("Lighting")
local Players = MacLib.GetService("Players")
local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local windowState, acrylicBlur
local tabs = {}
local currentTabInstance = nil
local tabIndex = 0
local unloaded = false
local assets = {
interFont = "rbxassetid://12187365364",
userInfoBlurred = "rbxassetid://18824089198",
toggleBackground = "rbxassetid://18772190202",
togglerHead = "rbxassetid://18772309008",
buttonImage = "rbxassetid://10709791437",
searchIcon = "rbxassetid://86737463322606",
colorWheel = "rbxassetid://2849458409",
colorTarget = "rbxassetid://73265255323268",
grid = "rbxassetid://121484455191370",
transform = "rbxassetid://90336395745819",
dropdown = "rbxassetid://18865373378",
sliderbar = "rbxassetid://18772615246",
sliderhead = "rbxassetid://18772834246",
}
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
local function GetGui()
local newGui = Instance.new("ScreenGui")
newGui.ScreenInsets = Enum.ScreenInsets.None
newGui.ResetOnSpawn = false
newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
newGui.DisplayOrder = 2147483647
local parent = RunService:IsStudio() and LocalPlayer:FindFirstChild("PlayerGui") or (gethui and gethui()) or (cloneref and cloneref(MacLib.GetService("CoreGui")) or MacLib.GetService("CoreGui"))
newGui.Parent = parent
return newGui
end
local function Tween(instance, tweeninfo, propertytable) return TweenService:Create(instance, tweeninfo, propertytable) end
local function parseSize(value, fallback)
if typeof(value) == "UDim2" then return value end
if typeof(value) == "Vector2" then return UDim2.fromOffset(value.X, value.Y) end
if type(value) == "table" then
if value[1] and value[2] then return UDim2.fromOffset(value[1], value[2]) end
if value.Width and value.Height then return UDim2.fromOffset(value.Width, value.Height) end
end
return fallback
end
function MacLib:Window(Settings)
local WindowFunctions = {Settings = Settings}
if Settings.AcrylicBlur ~= nil then acrylicBlur = Settings.AcrylicBlur else acrylicBlur = true end
local DEFAULT_PC_SIZE = UDim2.fromOffset(868, 650)
local DEFAULT_MOBILE_SIZE = UDim2.fromOffset(600, 450)
local pcSize = parseSize(Settings.PCSize or Settings.Size, DEFAULT_PC_SIZE)
local mobileSize = parseSize(Settings.MobileSize, DEFAULT_MOBILE_SIZE)
local mobileScale = tonumber(Settings.MobileScale) or 0.8
local macLib = GetGui()
local notifications = Instance.new("Frame")
notifications.Name = "Notifications"
notifications.BackgroundTransparency = 1
notifications.Size = UDim2.fromScale(1, 1)
notifications.Parent = macLib
notifications.ZIndex = 2
local notificationsUIListLayout = Instance.new("UIListLayout")
notificationsUIListLayout.Padding = UDim.new(0, 10)
notificationsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notificationsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notificationsUIListLayout.Parent = notifications
local notificationsUIPadding = Instance.new("UIPadding")
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
base.BorderSizePixel = 0
base.Position = UDim2.fromScale(0.5, 0.5)
base.Size = isMobile and mobileSize or pcSize
local baseUIScale = Instance.new("UIScale")
baseUIScale.Scale = isMobile and mobileScale or 1
baseUIScale.Parent = base
local baseUICorner = Instance.new("UICorner")
baseUICorner.CornerRadius = UDim.new(0, 10)
baseUICorner.Parent = base
local baseUIStroke = Instance.new("UIStroke")
baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
baseUIStroke.Color = Color3.fromRGB(255, 255, 255)
baseUIStroke.Transparency = 0.9
baseUIStroke.Parent = base
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.BackgroundTransparency = 1
sidebar.Position = UDim2.fromScale(0, 0)
sidebar.Size = UDim2.fromScale(0.28, 1)
local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.AnchorPoint = Vector2.new(1, 0)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.9
divider.BorderSizePixel = 0
divider.Position = UDim2.fromScale(1, 0)
divider.Size = UDim2.new(0, 1, 1, 0)
divider.Parent = sidebar
local dividerInteract = Instance.new("TextButton")
dividerInteract.AnchorPoint = Vector2.new(0.5, 0)
dividerInteract.BackgroundTransparency = 1
dividerInteract.Position = UDim2.fromScale(0.5, 0)
dividerInteract.Size = UDim2.new(1, 6, 1, 0)
dividerInteract.Text = ""
dividerInteract.Parent = divider
local windowControls = Instance.new("Frame")
windowControls.Size = UDim2.new(1, 0, 0, 31)
windowControls.Visible = false
windowControls.BackgroundTransparency = 1
local controls = Instance.new("Frame")
controls.Size = UDim2.fromScale(1, 1)
controls.BackgroundTransparency = 1
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Padding = UDim.new(0, 5)
uIListLayout.FillDirection = Enum.FillDirection.Horizontal
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uIListLayout.Parent = controls
local uIPadding = Instance.new("UIPadding")
uIPadding.PaddingLeft = UDim.new(0, 11)
uIPadding.Parent = controls
local windowControlSettings = {sizes = { enabled = UDim2.fromOffset(8, 8), disabled = UDim2.fromOffset(7, 7) }, transparencies = { enabled = 0, disabled = 1 }, strokeTransparency = 0.9}
local stroke = Instance.new("UIStroke")
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = windowControlSettings.strokeTransparency
local exit = Instance.new("TextButton")
exit.Text = ""
exit.AutoButtonColor = false
exit.BackgroundColor3 = Color3.fromRGB(250, 93, 86)
exit.BorderSizePixel = 0
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(1, 0)
uICorner.Parent = exit
exit.Parent = controls
local minimize = Instance.new("TextButton")
minimize.Text = ""
minimize.AutoButtonColor = false
minimize.BackgroundColor3 = Color3.fromRGB(252, 190, 57)
minimize.BorderSizePixel = 0
minimize.LayoutOrder = 1
local uICorner1 = Instance.new("UICorner")
uICorner1.CornerRadius = UDim.new(1, 0)
uICorner1.Parent = minimize
minimize.Parent = controls
local maximize = Instance.new("TextButton")
maximize.Text = ""
maximize.AutoButtonColor = false
maximize.BackgroundColor3 = Color3.fromRGB(119, 174, 94)
maximize.BorderSizePixel = 0
maximize.LayoutOrder = 1
local uICorner2 = Instance.new("UICorner")
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
for _, child in ipairs(button:GetChildren()) do if child:IsA("UIStroke") then child.Transparency = transparency end end
if not enabled then stroke:Clone().Parent = button end
end
applyState(maximize, false)
local controlsList = {exit, minimize}
for _, button in pairs(controlsList) do
local isEnabled = true
if Settings.DisabledWindowControls and table.find(Settings.DisabledWindowControls, button.Name) then isEnabled = false end
applyState(button, isEnabled)
end
controls.Parent = windowControls
local divider1 = Instance.new("Frame")
divider1.AnchorPoint = Vector2.new(0, 1)
divider1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider1.BackgroundTransparency = 0.9
divider1.BorderSizePixel = 0
divider1.Position = UDim2.fromScale(0, 1)
divider1.Size = UDim2.new(1, 0, 0, 1)
divider1.Parent = windowControls
windowControls.Parent = sidebar
local information = Instance.new("Frame")
information.Name = "Information"
information.BackgroundTransparency = 1
information.Position = UDim2.fromOffset(0, 0)
information.Size = UDim2.new(1, 0, 0, 63)
local divider2 = Instance.new("Frame")
divider2.AnchorPoint = Vector2.new(0, 1)
divider2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider2.BackgroundTransparency = 0.9
divider2.BorderSizePixel = 0
divider2.Position = UDim2.fromScale(0, 1)
divider2.Size = UDim2.new(1, 0, 0, 1)
divider2.Parent = information
local informationHolder = Instance.new("Frame")
informationHolder.Size = UDim2.fromScale(1, 1)
informationHolder.BackgroundTransparency = 1
local informationHolderUIPadding = Instance.new("UIPadding")
informationHolderUIPadding.PaddingBottom = UDim.new(0, 10)
informationHolderUIPadding.PaddingLeft = UDim.new(0, 23)
informationHolderUIPadding.PaddingRight = UDim.new(0, 22)
informationHolderUIPadding.PaddingTop = UDim.new(0, 12)
informationHolderUIPadding.Parent = informationHolder
local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.fromScale(1, 1)
titleFrame.BackgroundTransparency = 1
local title = Instance.new("TextLabel")
title.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
title.Text = Settings.Title
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.RichText = true
title.TextSize = 18
title.TextTransparency = 0.1
title.TextTruncate = Enum.TextTruncate.SplitWord
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Top
title.AutomaticSize = Enum.AutomaticSize.Y
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 0)
title.Parent = titleFrame
local subtitle = Instance.new("TextLabel")
subtitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
subtitle.RichText = true
subtitle.Text = Settings.Subtitle
subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
subtitle.TextSize = 12
subtitle.TextTransparency = 0.7
subtitle.TextTruncate = Enum.TextTruncate.SplitWord
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Top
subtitle.AutomaticSize = Enum.AutomaticSize.Y
subtitle.BackgroundTransparency = 1
subtitle.LayoutOrder = 1
subtitle.Size = UDim2.new(1, -20, 0, 0)
subtitle.Parent = titleFrame
local titleFrameUIListLayout = Instance.new("UIListLayout")
titleFrameUIListLayout.Padding = UDim.new(0, 3)
titleFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
titleFrameUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
titleFrameUIListLayout.Parent = titleFrame
titleFrame.Parent = informationHolder
informationHolder.Parent = information
information.Parent = sidebar
local sidebarGroup = Instance.new("Frame")
sidebarGroup.Name = "SidebarGroup"
sidebarGroup.BackgroundTransparency = 1
sidebarGroup.Position = UDim2.fromOffset(0, 63)
sidebarGroup.Size = UDim2.new(1, 0, 1, -63)
local userInfo = Instance.new("Frame")
userInfo.Name = "UserInfo"
userInfo.AnchorPoint = Vector2.new(0, 1)
userInfo.BackgroundTransparency = 1
userInfo.Position = UDim2.fromScale(0, 1)
userInfo.Size = UDim2.new(1, 0, 0, 64)
local userInfoDivider = Instance.new("Frame")
userInfoDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
userInfoDivider.BackgroundTransparency = 0.92
userInfoDivider.BorderSizePixel = 0
userInfoDivider.Position = UDim2.new(0, 10, 0, 0)
userInfoDivider.Size = UDim2.new(1, -20, 0, 1)
userInfoDivider.Parent = userInfo
local informationGroup = Instance.new("Frame")
informationGroup.Size = UDim2.fromScale(1, 1)
informationGroup.BackgroundTransparency = 1
local informationGroupUIPadding = Instance.new("UIPadding")
informationGroupUIPadding.PaddingLeft = UDim.new(0, 28)
informationGroupUIPadding.PaddingRight = UDim.new(0, 12)
informationGroupUIPadding.PaddingTop = UDim.new(0, 8)
informationGroupUIPadding.Parent = informationGroup
local informationGroupUIListLayout = Instance.new("UIListLayout")
informationGroupUIListLayout.FillDirection = Enum.FillDirection.Horizontal
informationGroupUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
informationGroupUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
informationGroupUIListLayout.Parent = informationGroup
local userId = LocalPlayer.UserId
local thumbType = Enum.ThumbnailType.AvatarBust
local thumbSize = Enum.ThumbnailSize.Size48x48
local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
local headshot = Instance.new("ImageLabel")
headshot.BackgroundTransparency = 1
headshot.Size = UDim2.fromOffset(36, 36)
headshot.Image = (isReady and headshotImage) or "rbxassetid://0"
local uICorner3 = Instance.new("UICorner")
uICorner3.CornerRadius = UDim.new(1, 0)
uICorner3.Parent = headshot
local baseUIStroke2 = Instance.new("UIStroke")
baseUIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
baseUIStroke2.Color = Color3.fromRGB(255, 255, 255)
baseUIStroke2.Transparency = 0.85
baseUIStroke2.Parent = headshot
headshot.Parent = informationGroup
local userAndDisplayFrame = Instance.new("Frame")
userAndDisplayFrame.BackgroundTransparency = 1
userAndDisplayFrame.LayoutOrder = 1
userAndDisplayFrame.Size = UDim2.new(1, -44, 0, 36)
local displayName = Instance.new("TextLabel")
displayName.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
displayName.Text = LocalPlayer.DisplayName
displayName.TextColor3 = Color3.fromRGB(255, 255, 255)
displayName.TextSize = 13
displayName.TextTransparency = 0.1
displayName.TextTruncate = Enum.TextTruncate.SplitWord
displayName.TextXAlignment = Enum.TextXAlignment.Left
displayName.TextYAlignment = Enum.TextYAlignment.Top
displayName.AutomaticSize = Enum.AutomaticSize.XY
displayName.BackgroundTransparency = 1
displayName.Size = UDim2.fromScale(1,0)
displayName.Parent = userAndDisplayFrame
local userAndDisplayFrameUIPadding = Instance.new("UIPadding")
userAndDisplayFrameUIPadding.PaddingLeft = UDim.new(0, 10)
userAndDisplayFrameUIPadding.PaddingTop = UDim.new(0, 4)
userAndDisplayFrameUIPadding.Parent = userAndDisplayFrame
local userAndDisplayFrameUIListLayout = Instance.new("UIListLayout")
userAndDisplayFrameUIListLayout.Padding = UDim.new(0, 1)
userAndDisplayFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
userAndDisplayFrameUIListLayout.Parent = userAndDisplayFrame
local username = Instance.new("TextLabel")
username.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
username.Text = "@" .. LocalPlayer.Name
username.TextColor3 = Color3.fromRGB(255, 255, 255)
username.TextSize = 11
username.TextTransparency = 0.6
username.TextTruncate = Enum.TextTruncate.SplitWord
username.TextXAlignment = Enum.TextXAlignment.Left
username.TextYAlignment = Enum.TextYAlignment.Top
username.AutomaticSize = Enum.AutomaticSize.XY
username.BackgroundTransparency = 1
username.LayoutOrder = 1
username.Size = UDim2.fromScale(1,0)
username.Parent = userAndDisplayFrame
userAndDisplayFrame.Parent = informationGroup
informationGroup.Parent = userInfo
userInfo.Parent = sidebarGroup
local sidebarGroupUIPadding = Instance.new("UIPadding")
sidebarGroupUIPadding.PaddingLeft = UDim.new(0, 10)
sidebarGroupUIPadding.PaddingRight = UDim.new(0, 10)
sidebarGroupUIPadding.PaddingTop = UDim.new(0, 31)
sidebarGroupUIPadding.Parent = sidebarGroup
local tabSwitchers = Instance.new("Frame")
tabSwitchers.BackgroundTransparency = 1
tabSwitchers.Size = UDim2.new(1, 0, 1, -64)
local tabSwitchersScrollingFrame = Instance.new("ScrollingFrame")
tabSwitchersScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabSwitchersScrollingFrame.BottomImage = ""
tabSwitchersScrollingFrame.CanvasSize = UDim2.new()
tabSwitchersScrollingFrame.ScrollBarImageTransparency = 0.8
tabSwitchersScrollingFrame.ScrollBarThickness = 1
tabSwitchersScrollingFrame.TopImage = ""
tabSwitchersScrollingFrame.BackgroundTransparency = 1
tabSwitchersScrollingFrame.Size = UDim2.fromScale(1, 1)
local tabSwitchersScrollingFrameUIListLayout = Instance.new("UIListLayout")
tabSwitchersScrollingFrameUIListLayout.Padding = UDim.new(0, 17)
tabSwitchersScrollingFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabSwitchersScrollingFrameUIListLayout.Parent = tabSwitchersScrollingFrame
local tabSwitchersScrollingFrameUIPadding = Instance.new("UIPadding")
tabSwitchersScrollingFrameUIPadding.PaddingTop = UDim.new(0, 2)
tabSwitchersScrollingFrameUIPadding.Parent = tabSwitchersScrollingFrame
tabSwitchersScrollingFrame.Parent = tabSwitchers
tabSwitchers.Parent = sidebarGroup
sidebarGroup.Parent = sidebar
sidebar.Parent = base
local content = Instance.new("Frame")
content.AnchorPoint = Vector2.new(1, 0)
content.BackgroundTransparency = 1
content.Position = UDim2.fromScale(1, 0)
local function getSidebarWidthUnscaled() return base.Size.X.Offset * sidebar.Size.X.Scale + sidebar.Size.X.Offset end
local function updateContentWidth() content.Size = UDim2.new(0, base.Size.X.Offset - getSidebarWidthUnscaled(), 1, 0) end
updateContentWidth()
base:GetPropertyChangedSignal("Size"):Connect(updateContentWidth)
sidebar:GetPropertyChangedSignal("Size"):Connect(updateContentWidth)
local resizingContent = false
local initialMouseX, initialSidebarWidth
local snapRange = 20
local minSidebarWidth = 107
local TweenSettings = {DefaultTransparency = 0.9, HoverTransparency = 0.85, EasingStyle = Enum.EasingStyle.Sine}
local function ChangeState(State) Tween(divider, TweenInfo.new(0.2, TweenSettings.EasingStyle), {BackgroundTransparency = State == "Idle" and TweenSettings.DefaultTransparency or TweenSettings.HoverTransparency}):Play() end
dividerInteract.MouseEnter:Connect(function() ChangeState("Hover") end)
dividerInteract.MouseLeave:Connect(function() ChangeState("Idle") end)
dividerInteract.MouseButton1Down:Connect(function() resizingContent = true initialMouseX = UserInputService:GetMouseLocation().X initialSidebarWidth = getSidebarWidthUnscaled() end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then resizingContent = false end end)
UserInputService.InputChanged:Connect(function(input)
if resizingContent and input.UserInputType == Enum.UserInputType.MouseMovement then
local scale = baseUIScale.Scale
local deltaX = (UserInputService:GetMouseLocation().X - initialMouseX) / scale
local defaultSidebarWidth = base.Size.X.Offset * 0.28
local newSidebarWidth = initialSidebarWidth + deltaX
if math.abs(newSidebarWidth - defaultSidebarWidth) < snapRange then newSidebarWidth = defaultSidebarWidth else newSidebarWidth = math.clamp(newSidebarWidth, minSidebarWidth, base.Size.X.Offset - minSidebarWidth) end
sidebar.Size = UDim2.new(0, newSidebarWidth, 1, 0)
updateContentWidth()
end
end)
local topbar = Instance.new("Frame")
topbar.BackgroundTransparency = 1
topbar.Size = UDim2.new(1, 0, 0, 63)
local divider4 = Instance.new("Frame")
divider4.AnchorPoint = Vector2.new(0, 1)
divider4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider4.BackgroundTransparency = 0.9
divider4.BorderSizePixel = 0
divider4.Position = UDim2.fromScale(0, 1)
divider4.Size = UDim2.new(1, 0, 0, 1)
divider4.Parent = topbar
local elements = Instance.new("Frame")
elements.BackgroundTransparency = 1
elements.Size = UDim2.fromScale(1, 1)
local uIPadding2 = Instance.new("UIPadding")
uIPadding2.PaddingLeft = UDim.new(0, 20)
uIPadding2.PaddingRight = UDim.new(0, 20)
uIPadding2.Parent = elements
local moveIcon = Instance.new("ImageButton")
moveIcon.Image = assets.transform
moveIcon.ImageTransparency = 0.7
moveIcon.AnchorPoint = Vector2.new(1, 0.5)
moveIcon.BackgroundTransparency = 1
moveIcon.Position = UDim2.fromScale(1, 0.5)
moveIcon.Size = UDim2.fromOffset(15, 15)
moveIcon.Parent = elements
moveIcon.Visible = not Settings.DragStyle or Settings.DragStyle == 1
local interact = Instance.new("TextButton")
interact.Text = ""
interact.AnchorPoint = Vector2.new(0.5, 0.5)
interact.BackgroundTransparency = 1
interact.Position = UDim2.fromScale(0.5, 0.5)
interact.Size = UDim2.fromOffset(40, 40)
interact.Parent = moveIcon
local function ChangemoveIconState(State) Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ImageTransparency = State == "Default" and 0.7 or 0.4}):Play() end
interact.MouseEnter:Connect(function() ChangemoveIconState("Hover") end)
interact.MouseLeave:Connect(function() ChangemoveIconState("Default") end)
local dragging_ = false
local dragInput, dragStart, startPos
local function update(input) local delta = input.Position - dragStart base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end
local function onDragStart(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging_ = true dragStart = input.Position startPos = base.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging_ = false end end) end end
local function onDragUpdate(input) if dragging_ and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then dragInput = input end end
if not Settings.DragStyle or Settings.DragStyle == 1 then
interact.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then onDragStart(input) end end)
interact.InputChanged:Connect(onDragUpdate)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging_ then update(input) end end)
interact.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging_ = false end end)
elseif Settings.DragStyle == 2 then
base.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then onDragStart(input) end end)
base.InputChanged:Connect(onDragUpdate)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging_ then update(input) end end)
base.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging_ = false end end)
end
local currentTab = Instance.new("TextLabel")
currentTab.FontFace = Font.new(assets.interFont)
currentTab.RichText = true
currentTab.TextColor3 = Color3.fromRGB(255, 255, 255)
currentTab.TextSize = 15
currentTab.TextTransparency = 0.5
currentTab.TextTruncate = Enum.TextTruncate.SplitWord
currentTab.TextXAlignment = Enum.TextXAlignment.Left
currentTab.AnchorPoint = Vector2.new(0, 0.5)
currentTab.AutomaticSize = Enum.AutomaticSize.Y
currentTab.BackgroundTransparency = 1
currentTab.Position = UDim2.fromScale(0, 0.5)
currentTab.Size = UDim2.fromScale(0.9, 0)
currentTab.Parent = elements
elements.Parent = topbar
topbar.Parent = content
content.Parent = base
base.Parent = macLib
function WindowFunctions:UpdateTitle(NewTitle) title.Text = NewTitle end
function WindowFunctions:UpdateSubtitle(NewSubtitle) subtitle.Text = NewSubtitle end
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
elseif v:IsA("DepthOfFieldEffect") and v:HasTag(".") then DepthOfField = v end
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
do local function IsNotNaN(x) return x == x end local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x) while not continue do RunService.RenderStepped:Wait() continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x) end end
local DrawQuad; do
local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
local sz = 0.2
local function DrawTriangle(v1, v2, v3, p0, p1)
local s1 = (v1 - v2).magnitude
local s2 = (v2 - v3).magnitude
local s3 = (v3 - v1).magnitude
local smax = max(s1, s2, s3)
local A, B, C
if s1 == smax then A, B, C = v1, v2, v3 elseif s2 == smax then A, B, C = v2, v3, v1 elseif s3 == smax then A, B, C = v3, v1, v2 end
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
if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot)) end
cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))
local cf1 = st * ac * CFrame.Angles(0, math.pi, 0)
if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot)) end
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
if not p1 then p1 = p0:clone() end
p1[wedgeguid].Scale = Vector3.new(0, perp/sz, dif_para/sz)
p1.CFrame = cf1
return p0, p1
end
function DrawQuad(v1, v2, v3, v4, parts)
parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
end
end
if binds[frame] then return binds[frame].parts end
local parts = {}
local parents = {}
do local function add(child) if child:IsA'GuiObject' then parents[#parents + 1] = child add(child.Parent) end end add(frame) end
local function IsVisible(instance) while instance do if instance:IsA("GuiObject") then if not instance.Visible then return false end elseif instance:IsA("ScreenGui") then if not instance.Enabled then return false end break end instance = instance.Parent end return true end
local function UpdateOrientation(fetchProps)
if not IsVisible(frame) or not acrylicBlur or unloaded then for _, pt in pairs(parts) do pt.Parent = nil DepthOfField.Enabled = false DepthOfField.Parent = nil end return end
if not DepthOfField.Parent then DepthOfField.Parent = Lighting end
DepthOfField.Enabled = true
local properties = { Transparency = 0.98; BrickColor = BrickColor.new('Institutional white'); }
local zIndex = 1 - 0.05*frame.ZIndex
local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
do
local rot = 0;
for _, v in ipairs(parents) do rot = rot + v.Rotation end
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
DrawQuad(camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, camera:ScreenPointToRay(br.x, br.y, zIndex).Origin, parts)
if fetchProps then for _, pt in pairs(parts) do pt.Parent = camera end for propName, propValue in pairs(properties) do for _, pt in pairs(parts) do pt[propName] = propValue end end end
end
UpdateOrientation(true)
RunService.RenderStepped:Connect(UpdateOrientation)
function WindowFunctions:TabGroup()
local SectionFunctions = {}
local tabGroup = Instance.new("Frame")
tabGroup.AutomaticSize = Enum.AutomaticSize.Y
tabGroup.BackgroundTransparency = 1
tabGroup.Size = UDim2.fromScale(1, 0)
local divider3 = Instance.new("Frame")
divider3.AnchorPoint = Vector2.new(0.5, 1)
divider3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider3.BackgroundTransparency = 0.9
divider3.BorderSizePixel = 0
divider3.Position = UDim2.fromScale(0.5, 1)
divider3.Size = UDim2.new(1, -21, 0, 1)
divider3.Parent = tabGroup
local sectionTabSwitchers = Instance.new("Frame")
sectionTabSwitchers.BackgroundTransparency = 1
sectionTabSwitchers.Size = UDim2.fromScale(1, 1)
local uIListLayout1 = Instance.new("UIListLayout")
uIListLayout1.Padding = UDim.new(0, 15)
uIListLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout1.Parent = sectionTabSwitchers
local uIPadding1 = Instance.new("UIPadding")
uIPadding1.PaddingBottom = UDim.new(0, 15)
uIPadding1.Parent = sectionTabSwitchers
sectionTabSwitchers.Parent = tabGroup
tabGroup.Parent = tabSwitchersScrollingFrame
function SectionFunctions:Tab(Settings)
local TabFunctions = {Settings = Settings}
local tabSwitcher = Instance.new("TextButton")
tabSwitcher.Text = ""
tabSwitcher.AutoButtonColor = false
tabSwitcher.AnchorPoint = Vector2.new(0.5, 0)
tabSwitcher.BackgroundTransparency = 1
tabSwitcher.Position = UDim2.fromScale(0.5, 0)
tabSwitcher.Size = UDim2.new(1, -21, 0, 40)
tabIndex += 1
tabSwitcher.LayoutOrder = tabIndex
local tabSwitcherUICorner = Instance.new("UICorner")
tabSwitcherUICorner.Parent = tabSwitcher
local tabSwitcherUIStroke = Instance.new("UIStroke")
tabSwitcherUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tabSwitcherUIStroke.Color = Color3.fromRGB(255, 255, 255)
tabSwitcherUIStroke.Transparency = 1
tabSwitcherUIStroke.Parent = tabSwitcher
local tabSwitcherUIListLayout = Instance.new("UIListLayout")
tabSwitcherUIListLayout.Padding = UDim.new(0, 9)
tabSwitcherUIListLayout.FillDirection = Enum.FillDirection.Horizontal
tabSwitcherUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabSwitcherUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabSwitcherUIListLayout.Parent = tabSwitcher
local tabImage
local tabIconId = Settings.Image and resolveIcon(Settings.Image)
if tabIconId then
tabImage = Instance.new("ImageLabel")
tabImage.Image = tabIconId
tabImage.ImageTransparency = 0.5
tabImage.BackgroundTransparency = 1
tabImage.Size = UDim2.fromOffset(18, 18)
tabImage.Parent = tabSwitcher
end
local tabSwitcherName = Instance.new("TextLabel")
tabSwitcherName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
tabSwitcherName.Text = Settings.Name
tabSwitcherName.RichText = true
tabSwitcherName.TextColor3 = Color3.fromRGB(255, 255, 255)
tabSwitcherName.TextSize = 16
tabSwitcherName.TextTransparency = 0.5
tabSwitcherName.TextTruncate = Enum.TextTruncate.SplitWord
tabSwitcherName.TextXAlignment = Enum.TextXAlignment.Left
tabSwitcherName.AutomaticSize = Enum.AutomaticSize.Y
tabSwitcherName.BackgroundTransparency = 1
tabSwitcherName.Size = UDim2.fromScale(1, 0)
tabSwitcherName.Parent = tabSwitcher
tabSwitcherName.LayoutOrder = 1
local tabSwitcherUIPadding = Instance.new("UIPadding")
tabSwitcherUIPadding.PaddingLeft = UDim.new(0, 18)
tabSwitcherUIPadding.PaddingRight = UDim.new(0, 18)
tabSwitcherUIPadding.PaddingTop = UDim.new(0, 1)
tabSwitcherUIPadding.Parent = tabSwitcher
tabSwitcher.Parent = sectionTabSwitchers
local elements1 = Instance.new("Frame")
elements1.BackgroundTransparency = 1
elements1.Position = UDim2.fromOffset(0, 63)
elements1.Size = UDim2.new(1, 0, 1, -63)
elements1.ClipsDescendants = true
local elementsUIPadding = Instance.new("UIPadding")
elementsUIPadding.PaddingRight = UDim.new(0, 5)
elementsUIPadding.PaddingTop = UDim.new(0, 10)
elementsUIPadding.PaddingBottom = UDim.new(0, 10)
elementsUIPadding.Parent = elements1
local elementsScrolling = Instance.new("ScrollingFrame")
elementsScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
elementsScrolling.BottomImage = ""
elementsScrolling.CanvasSize = UDim2.new()
elementsScrolling.ScrollBarImageTransparency = 0.5
elementsScrolling.ScrollBarThickness = 1
elementsScrolling.TopImage = ""
elementsScrolling.BackgroundTransparency = 1
elementsScrolling.Size = UDim2.fromScale(1, 1)
elementsScrolling.ClipsDescendants = false
local elementsScrollingUIPadding = Instance.new("UIPadding")
elementsScrollingUIPadding.PaddingBottom = UDim.new(0, 5)
elementsScrollingUIPadding.PaddingLeft = UDim.new(0, 11)
elementsScrollingUIPadding.PaddingRight = UDim.new(0, 3)
elementsScrollingUIPadding.PaddingTop = UDim.new(0, 5)
elementsScrollingUIPadding.Parent = elementsScrolling
local elementsScrollingUIListLayout = Instance.new("UIListLayout")
elementsScrollingUIListLayout.Padding = UDim.new(0, 15)
elementsScrollingUIListLayout.FillDirection = Enum.FillDirection.Horizontal
elementsScrollingUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
elementsScrollingUIListLayout.Parent = elementsScrolling
local left = Instance.new("Frame")
left.AutomaticSize = Enum.AutomaticSize.Y
left.BackgroundTransparency = 1
left.Position = UDim2.fromScale(0.512, 0)
left.Size = UDim2.new(0.5, -10, 0, 0)
local leftUIListLayout = Instance.new("UIListLayout")
leftUIListLayout.Padding = UDim.new(0, 15)
leftUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftUIListLayout.Parent = left
left.Parent = elementsScrolling
local right = Instance.new("Frame")
right.AutomaticSize = Enum.AutomaticSize.Y
right.BackgroundTransparency = 1
right.LayoutOrder = 1
right.Position = UDim2.fromScale(0.512, 0)
right.Size = UDim2.new(0.5, -10, 0, 0)
local rightUIListLayout = Instance.new("UIListLayout")
rightUIListLayout.Padding = UDim.new(0, 15)
rightUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightUIListLayout.Parent = right
right.Parent = elementsScrolling
elementsScrolling.Parent = elements1
local subtabs = {}
local subtabOrder = {}
local currentSubTab = nil
local defaultPage = elementsScrolling
local pageTemplate = elementsScrolling:Clone()
pageTemplate.Name = "SubtabPageTemplate"
pageTemplate.Parent = nil
local function makePage() local page = pageTemplate:Clone() page.Name = "SubtabPage" page.Parent = elements1 page.Visible = false return page, page:WaitForChild("Left"), page:WaitForChild("Right") end
topbar.ZIndex = 10
elements.ZIndex = 10
local subtabSelector = Instance.new("Frame")
subtabSelector.BackgroundTransparency = 1
subtabSelector.AnchorPoint = Vector2.new(0, 0.5)
subtabSelector.Position = UDim2.new(0, 0, 0.5, 0)
subtabSelector.Size = UDim2.fromOffset(200, 34)
subtabSelector.Visible = false
subtabSelector.ZIndex = 100
subtabSelector.Parent = elements
local subtabButton = Instance.new("TextButton")
subtabButton.Text = ""
subtabButton.AutoButtonColor = false
subtabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
subtabButton.BackgroundTransparency = 0.985
subtabButton.BorderSizePixel = 0
subtabButton.Size = UDim2.fromScale(1, 1)
subtabButton.ZIndex = 101
subtabButton.Parent = subtabSelector
local subtabButtonCorner = Instance.new("UICorner")
subtabButtonCorner.CornerRadius = UDim.new(0, 6)
subtabButtonCorner.Parent = subtabButton
local subtabButtonStroke = Instance.new("UIStroke")
subtabButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
subtabButtonStroke.Color = Color3.fromRGB(255, 255, 255)
subtabButtonStroke.Transparency = 0.95
subtabButtonStroke.Parent = subtabButton
local subtabButtonPadding = Instance.new("UIPadding")
subtabButtonPadding.PaddingRight = UDim.new(0, 15)
subtabButtonPadding.Parent = subtabButton
local subtabLabel = Instance.new("TextLabel")
subtabLabel.FontFace = Font.new(assets.interFont)
subtabLabel.Text = "Subtabs..."
subtabLabel.RichText = true
subtabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
subtabLabel.TextSize = 13
subtabLabel.TextTransparency = 0.5
subtabLabel.TextTruncate = Enum.TextTruncate.SplitWord
subtabLabel.TextXAlignment = Enum.TextXAlignment.Left
subtabLabel.AnchorPoint = Vector2.new(0, 0.5)
subtabLabel.BackgroundTransparency = 1
subtabLabel.Position = UDim2.new(0, 15, 0.5, 0)
subtabLabel.Size = UDim2.new(1, -35, 0, 0)
subtabLabel.ZIndex = 102
subtabLabel.Parent = subtabButton
local subtabArrow = Instance.new("ImageLabel")
subtabArrow.Image = assets.dropdown
subtabArrow.ImageTransparency = 0.5
subtabArrow.AnchorPoint = Vector2.new(1, 0)
subtabArrow.BackgroundTransparency = 1
subtabArrow.Position = UDim2.new(1, 0, 0, 10)
subtabArrow.Size = UDim2.fromOffset(14, 14)
subtabArrow.ZIndex = 102
subtabArrow.Parent = subtabButton
local subtabList = Instance.new("ScrollingFrame")
subtabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
subtabList.CanvasSize = UDim2.new()
subtabList.BottomImage = ""
subtabList.TopImage = ""
subtabList.ScrollBarImageTransparency = 0.5
subtabList.ScrollBarThickness = 2
subtabList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
subtabList.BackgroundTransparency = 0
subtabList.BorderSizePixel = 0
subtabList.ClipsDescendants = true
subtabList.Position = UDim2.new(0, 0, 1, 4)
subtabList.Size = UDim2.new(1, 0, 0, 0)
subtabList.Visible = false
subtabList.ZIndex = 110
subtabList.Parent = subtabButton
local subtabListCorner = Instance.new("UICorner")
subtabListCorner.CornerRadius = UDim.new(0, 6)
subtabListCorner.Parent = subtabList
local subtabListStroke = Instance.new("UIStroke")
subtabListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
subtabListStroke.Color = Color3.fromRGB(255, 255, 255)
subtabListStroke.Transparency = 0.9
subtabListStroke.Parent = subtabList
local subtabListLayout = Instance.new("UIListLayout")
subtabListLayout.Padding = UDim.new(0, 5)
subtabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
subtabListLayout.Parent = subtabList
local subtabListPadding = Instance.new("UIPadding")
subtabListPadding.PaddingTop = UDim.new(0, 5)
subtabListPadding.PaddingBottom = UDim.new(0, 5)
subtabListPadding.Parent = subtabList
local listOpen = false
local listDb = false
local MAX_LIST_ROWS = 5
local subtabTweensettings = {duration = 0.2, easingStyle = Enum.EasingStyle.Quint, transparencyIn = 0.2, transparencyOut = 0.5}
local function getListHeight() local count = #subtabOrder if count == 0 then return 0 end local rows = math.min(count, MAX_LIST_ROWS) return 10 + (rows * 30) + math.max(0, (rows - 1) * 5) end
local function setSubTabListOpen(state)
if listDb then return end
if state == listOpen then return end
listDb = true
listOpen = state
local targetSize = state and UDim2.new(1, 0, 0, getListHeight()) or UDim2.new(1, 0, 0, 0)
local dropTween = Tween(subtabList, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = targetSize})
local iconTween = Tween(subtabArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = state and -90 or 0})
if state then subtabList.CanvasPosition = Vector2.new(0, 0) subtabList.Visible = true end
dropTween:Play()
iconTween:Play()
dropTween.Completed:Connect(function() if not state then subtabList.Visible = false end listDb = false end)
end
subtabButton.MouseButton1Click:Connect(function() setSubTabListOpen(not listOpen) end)
UserInputService.InputEnded:Connect(function(input)
if not (subtabSelector.Visible and listOpen) then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
task.defer(function()
if not subtabList.Visible then return end
local mouse = UserInputService:GetMouseLocation()
local function inside(gui) local p = gui.AbsolutePosition local s = gui.AbsoluteSize return mouse.X >= p.X and mouse.X <= p.X + s.X and mouse.Y >= p.Y and mouse.Y <= p.Y + s.Y end
if not inside(subtabSelector) and not inside(subtabList) then setSubTabListOpen(false) end
end)
end
end)
local function selectSubTab(name)
local data = subtabs[name]
if not data then return end
for otherName, other in pairs(subtabs) do
other.Page.Visible = false
if other.Tweens then
if otherName == name then other.Tweens.checkIn:Play() other.Tweens.nameIn:Play() else other.Tweens.checkOut:Play() other.Tweens.nameOut:Play() end
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
option.Text = ""
option.BackgroundTransparency = 1
option.Size = UDim2.new(1, 0, 0, 30)
option.LayoutOrder = #subtabOrder
option.ZIndex = 111
option.Parent = subtabList
local optionUIPadding = Instance.new("UIPadding")
optionUIPadding.PaddingLeft = UDim.new(0, 15)
optionUIPadding.PaddingRight = UDim.new(0, 15)
optionUIPadding.Parent = option
local optionName = Instance.new("TextLabel")
optionName.FontFace = Font.new(assets.interFont)
optionName.Text = name
optionName.RichText = true
optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
optionName.TextSize = 13
optionName.TextTransparency = 0.5
optionName.TextTruncate = Enum.TextTruncate.AtEnd
optionName.TextXAlignment = Enum.TextXAlignment.Left
optionName.AnchorPoint = Vector2.new(0, 0.5)
optionName.BackgroundTransparency = 1
optionName.Position = UDim2.new(0, 0, 0.5, 0)
optionName.Size = UDim2.new(1, -20, 1, 0)
optionName.ZIndex = 112
optionName.Parent = option
local checkmark = Instance.new("TextLabel")
checkmark.FontFace = Font.new(assets.interFont)
checkmark.Text = "✓"
checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
checkmark.TextSize = 13
checkmark.TextTransparency = 1
checkmark.TextXAlignment = Enum.TextXAlignment.Right
checkmark.AnchorPoint = Vector2.new(1, 0.5)
checkmark.BackgroundTransparency = 1
checkmark.Position = UDim2.new(1, 0, 0.5, 0)
checkmark.Size = UDim2.fromOffset(14, 14)
checkmark.ZIndex = 112
checkmark.Parent = option
subtabs[name].OptionText = optionName
subtabs[name].Checkmark = checkmark
subtabs[name].Tweens = {
checkIn = Tween(checkmark, TweenInfo.new(0.15, subtabTweensettings.easingStyle), {TextTransparency = 0}),
checkOut = Tween(checkmark, TweenInfo.new(0.15, subtabTweensettings.easingStyle), {TextTransparency = 1}),
nameIn = Tween(optionName, TweenInfo.new(subtabTweensettings.duration, subtabTweensettings.easingStyle), {TextTransparency = subtabTweensettings.transparencyIn}),
nameOut = Tween(optionName, TweenInfo.new(subtabTweensettings.duration, subtabTweensettings.easingStyle), {TextTransparency = subtabTweensettings.transparencyOut})
}
option.MouseEnter:Connect(function() if currentSubTab ~= name then Tween(option, TweenInfo.new(0.15, Enum.EasingStyle.Sine), { BackgroundTransparency = 0.95 }):Play() end end)
option.MouseLeave:Connect(function() Tween(option, TweenInfo.new(0.15, Enum.EasingStyle.Sine), { BackgroundTransparency = 1 }):Play() end)
option.MouseButton1Click:Connect(function() selectSubTab(name) end)
if #subtabOrder == 1 then selectSubTab(name) if currentTabInstance == elements1 then currentTab.Visible = false subtabSelector.Visible = true end end
end
function TabFunctions:SubTab(Settings)
local name = Settings
if type(Settings) == "table" then name = Settings.Name end
if type(name) ~= "string" or name == "" then return end
addSubTab(name)
return {Name = name, Select = function() selectSubTab(name) end, Section = function(_, settings) settings = settings or {} settings.Page = name return TabFunctions:Section(settings) end}
end
subtabSelector.Visible = false
function TabFunctions:Section(Settings)
Settings = Settings or {}
local SectionFunctions = {}
local section = Instance.new("Frame")
section.AutomaticSize = Enum.AutomaticSize.Y
section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
section.BackgroundTransparency = 0.98
section.BorderSizePixel = 0
section.Size = UDim2.fromScale(1, 0)
section.ClipsDescendants = true
local targetLeft, targetRight = left, right
if Settings.Page and subtabs[Settings.Page] then targetLeft = subtabs[Settings.Page].Left targetRight = subtabs[Settings.Page].Right elseif currentSubTab and subtabs[currentSubTab] then targetLeft = subtabs[currentSubTab].Left targetRight = subtabs[currentSubTab].Right end
section.Parent = Settings.Side == "Left" and targetLeft or targetRight
local sectionUICorner = Instance.new("UICorner")
sectionUICorner.Parent = section
local sectionUIStroke = Instance.new("UIStroke")
sectionUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sectionUIStroke.Color = Color3.fromRGB(255, 255, 255)
sectionUIStroke.Transparency = 0.95
sectionUIStroke.Parent = section
local sectionUIListLayout = Instance.new("UIListLayout")
sectionUIListLayout.Padding = UDim.new(0, 10)
sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
sectionUIListLayout.Parent = section
local sectionUIPadding = Instance.new("UIPadding")
sectionUIPadding.PaddingBottom = UDim.new(0, 20)
sectionUIPadding.PaddingLeft = UDim.new(0, 20)
sectionUIPadding.PaddingRight = UDim.new(0, 18)
sectionUIPadding.PaddingTop = UDim.new(0, 22)
sectionUIPadding.Parent = section
function SectionFunctions:Button(Settings, Flag)
local ButtonFunctions = {Settings = Settings}
local button = Instance.new("Frame")
button.AutomaticSize = Enum.AutomaticSize.Y
button.BackgroundTransparency = 1
button.Size = UDim2.new(1, 0, 0, 38)
button.Parent = section
local buttonInteract = Instance.new("TextButton")
buttonInteract.FontFace = Font.new(assets.interFont)
buttonInteract.RichText = true
buttonInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonInteract.TextSize = 13
buttonInteract.TextTransparency = 0.5
buttonInteract.TextTruncate = Enum.TextTruncate.AtEnd
buttonInteract.TextXAlignment = Enum.TextXAlignment.Left
buttonInteract.BackgroundTransparency = 1
buttonInteract.Size = UDim2.fromScale(1, 1)
buttonInteract.Parent = button
buttonInteract.Text = ButtonFunctions.Settings.Name
local buttonImage = Instance.new("ImageLabel")
buttonImage.Image = assets.buttonImage
buttonImage.ImageTransparency = 0.5
buttonImage.AnchorPoint = Vector2.new(1, 0.5)
buttonImage.BackgroundTransparency = 1
buttonImage.Position = UDim2.fromScale(1, 0.5)
buttonImage.Size = UDim2.fromOffset(15, 15)
buttonImage.Parent = button
local TweenSettings = {DefaultTransparency = 0.5, HoverTransparency = 0.3, EasingStyle = Enum.EasingStyle.Sine}
local function ChangeState(State) Tween(buttonInteract, TweenInfo.new(0.2, TweenSettings.EasingStyle), {TextTransparency = State == "Idle" and TweenSettings.DefaultTransparency or TweenSettings.HoverTransparency}):Play() Tween(buttonImage, TweenInfo.new(0.2, TweenSettings.EasingStyle), {ImageTransparency = State == "Idle" and TweenSettings.DefaultTransparency or TweenSettings.HoverTransparency}):Play() end
local function Callback() if ButtonFunctions.Settings.Callback then ButtonFunctions.Settings.Callback() end end
buttonInteract.MouseEnter:Connect(function() ChangeState("Hover") end)
buttonInteract.MouseLeave:Connect(function() ChangeState("Idle") end)
buttonInteract.MouseButton1Click:Connect(Callback)
function ButtonFunctions:UpdateName(Name) buttonInteract.Text = Name end
function ButtonFunctions:SetVisibility(State) button.Visible = State end
if Flag then MacLib.Options[Flag] = ButtonFunctions end
return ButtonFunctions
end
function SectionFunctions:Toggle(Settings, Flag)
local ToggleFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Toggle" }
local toggle = Instance.new("Frame")
toggle.AutomaticSize = Enum.AutomaticSize.Y
toggle.BackgroundTransparency = 1
toggle.Size = UDim2.new(1, 0, 0, 38)
toggle.Parent = section
local toggleName = Instance.new("TextLabel")
toggleName.FontFace = Font.new(assets.interFont)
toggleName.Text = ToggleFunctions.Settings.Name
toggleName.RichText = true
toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleName.TextSize = 13
toggleName.TextTransparency = 0.5
toggleName.TextTruncate = Enum.TextTruncate.AtEnd
toggleName.TextXAlignment = Enum.TextXAlignment.Left
toggleName.AnchorPoint = Vector2.new(0, 0.5)
toggleName.AutomaticSize = Enum.AutomaticSize.Y
toggleName.BackgroundTransparency = 1
toggleName.Position = UDim2.fromScale(0, 0.5)
toggleName.Size = UDim2.new(1, -50, 0, 0)
toggleName.Parent = toggle
local toggle1 = Instance.new("ImageButton")
toggle1.Image = assets.toggleBackground
toggle1.ImageColor3 = Color3.fromRGB(87, 86, 86)
toggle1.AutoButtonColor = false
toggle1.AnchorPoint = Vector2.new(1, 0.5)
toggle1.BackgroundTransparency = 1
toggle1.Position = UDim2.fromScale(1, 0.5)
toggle1.Size = UDim2.fromOffset(41, 21)
toggle1.ImageTransparency = 0.5
local toggleUIPadding = Instance.new("UIPadding")
toggleUIPadding.PaddingBottom = UDim.new(0, 1)
toggleUIPadding.PaddingLeft = UDim.new(0, -2)
toggleUIPadding.PaddingRight = UDim.new(0, 3)
toggleUIPadding.PaddingTop = UDim.new(0, 1)
toggleUIPadding.Parent = toggle1
local togglerHead = Instance.new("ImageLabel")
togglerHead.Image = assets.togglerHead
togglerHead.ImageColor3 = Color3.fromRGB(255, 255, 255)
togglerHead.AnchorPoint = Vector2.new(1, 0.5)
togglerHead.BackgroundTransparency = 1
togglerHead.Position = UDim2.fromScale(0.5, 0.5)
togglerHead.Size = UDim2.fromOffset(15, 15)
togglerHead.ZIndex = 2
togglerHead.Parent = toggle1
togglerHead.ImageTransparency = 0.8
toggle1.Parent = toggle
local toggle1Transparency = {Enabled = 0, Disabled = 0.5}
local togglerHeadTransparency = {Enabled = 0, Disabled = 0.85}
local TweenSettings = {Info = TweenInfo.new(0.15, Enum.EasingStyle.Quad), EnabledPosition = UDim2.new(1, 0, 0.5, 0), DisabledPosition = UDim2.new(0.5, 0, 0.5, 0)}
local togglebool = ToggleFunctions.Settings.Default
local function NewState(State, callback)
local transparencyValues = State and {toggle1Transparency.Enabled, togglerHeadTransparency.Enabled} or {toggle1Transparency.Disabled, togglerHeadTransparency.Disabled}
local position = State and TweenSettings.EnabledPosition or TweenSettings.DisabledPosition
Tween(toggle1, TweenSettings.Info, {ImageTransparency = transparencyValues[1]}):Play()
Tween(togglerHead, TweenSettings.Info, {ImageTransparency = transparencyValues[2]}):Play()
Tween(togglerHead, TweenSettings.Info, {Position = position}):Play()
ToggleFunctions.State = State
if callback then callback(togglebool) end
end
NewState(togglebool)
local function Toggle() togglebool = not togglebool NewState(togglebool, ToggleFunctions.Settings.Callback) end
toggle1.MouseButton1Click:Connect(Toggle)
function ToggleFunctions:Toggle() Toggle() end
function ToggleFunctions:UpdateState(State) togglebool = State NewState(togglebool, ToggleFunctions.Settings.Callback) end
function ToggleFunctions:GetState() return togglebool end
function ToggleFunctions:UpdateName(Name) toggleName.Text = Name end
function ToggleFunctions:SetVisibility(State) toggle.Visible = State end
if Flag then MacLib.Options[Flag] = ToggleFunctions end
return ToggleFunctions
end
function SectionFunctions:Slider(Settings, Flag)
local SliderFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Slider" }
local sliderMin = tonumber(SliderFunctions.Settings.Minimum) or 0
local sliderMax = tonumber(SliderFunctions.Settings.Maximum) or 100
if sliderMax <= sliderMin then sliderMax = sliderMin + 1 end
local slider = Instance.new("Frame")
slider.AutomaticSize = Enum.AutomaticSize.Y
slider.BackgroundTransparency = 1
slider.Size = UDim2.new(1, 0, 0, 38)
slider.Parent = section
local sliderName = Instance.new("TextLabel")
sliderName.FontFace = Font.new(assets.interFont)
sliderName.Text = SliderFunctions.Settings.Name
sliderName.RichText = true
sliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderName.TextSize = 13
sliderName.TextTransparency = 0.5
sliderName.TextTruncate = Enum.TextTruncate.AtEnd
sliderName.TextXAlignment = Enum.TextXAlignment.Left
sliderName.AnchorPoint = Vector2.new(0, 0.5)
sliderName.AutomaticSize = Enum.AutomaticSize.XY
sliderName.BackgroundTransparency = 1
sliderName.Position = UDim2.fromScale(0, 0.5)
sliderName.Parent = slider
local sliderElements = Instance.new("Frame")
sliderElements.AnchorPoint = Vector2.new(1, 0)
sliderElements.BackgroundTransparency = 1
sliderElements.Position = UDim2.fromScale(1, 0)
sliderElements.Size = UDim2.fromScale(1, 1)
local sliderValue = Instance.new("TextBox")
sliderValue.FontFace = Font.new(assets.interFont)
sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderValue.TextSize = 12
sliderValue.TextTransparency = 0.1
sliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderValue.BackgroundTransparency = 0.95
sliderValue.LayoutOrder = 1
sliderValue.Position = UDim2.fromScale(-0.0789, 0.171)
sliderValue.Size = UDim2.fromOffset(41, 21)
sliderValue.ClipsDescendants = true
local sliderValueUICorner = Instance.new("UICorner")
sliderValueUICorner.CornerRadius = UDim.new(0, 4)
sliderValueUICorner.Parent = sliderValue
local sliderValueUIStroke = Instance.new("UIStroke")
sliderValueUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sliderValueUIStroke.Color = Color3.fromRGB(255, 255, 255)
sliderValueUIStroke.Transparency = 0.9
sliderValueUIStroke.Parent = sliderValue
local sliderValueUIPadding = Instance.new("UIPadding")
sliderValueUIPadding.PaddingLeft = UDim.new(0, 2)
sliderValueUIPadding.PaddingRight = UDim.new(0, 2)
sliderValueUIPadding.Parent = sliderValue
sliderValue.Parent = sliderElements
local sliderElementsUIListLayout = Instance.new("UIListLayout")
sliderElementsUIListLayout.Padding = UDim.new(0, 20)
sliderElementsUIListLayout.FillDirection = Enum.FillDirection.Horizontal
sliderElementsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
sliderElementsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
sliderElementsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
sliderElementsUIListLayout.Parent = sliderElements
local sliderBar = Instance.new("ImageLabel")
sliderBar.Image = assets.sliderbar
sliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
sliderBar.BackgroundTransparency = 1
sliderBar.Position = UDim2.fromScale(0.219, 0.457)
sliderBar.Size = UDim2.fromOffset(123, 3)
local sliderHead = Instance.new("ImageButton")
sliderHead.Image = assets.sliderhead
sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
sliderHead.BackgroundTransparency = 1
sliderHead.Position = UDim2.fromScale(1, 0.5)
sliderHead.Size = UDim2.fromOffset(isMobile and 16 or 12, isMobile and 16 or 12)
sliderHead.Parent = sliderBar
local sliderTouchArea = Instance.new("Frame")
sliderTouchArea.BackgroundTransparency = 1
sliderTouchArea.AnchorPoint = Vector2.new(0.5, 0.5)
sliderTouchArea.Position = UDim2.fromScale(0.5, 0.5)
sliderTouchArea.Size = UDim2.new(1, 0, 1, 30)
sliderTouchArea.Parent = sliderBar
sliderBar.Parent = sliderElements
local sliderElementsUIPadding = Instance.new("UIPadding")
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
local function roundValue(v) local precision = SliderFunctions.Settings.Precision if precision then local mult = 10 ^ precision return math.floor(v * mult + 0.5) / mult end return math.floor(v + 0.5) end
local function updateText() sliderValue.Text = (Settings.Prefix or "") .. ValueDisplayMethod(finalValue, SliderFunctions.Settings.Precision) .. (Settings.Suffix or "") end
local function SetValue(val, ignorecallback)
local posXScale
if typeof(val) == "number" then posXScale = math.clamp((val - sliderMin) / (sliderMax - sliderMin), 0, 1)
elseif typeof(val) == "Instance" then local barWidth = sliderBar.AbsoluteSize.X if barWidth <= 0 then barWidth = 1 end posXScale = math.clamp((val.Position.X - sliderBar.AbsolutePosition.X) / barWidth, 0, 1)
else return end
sliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
finalValue = math.clamp(roundValue(sliderMin + posXScale * (sliderMax - sliderMin)), sliderMin, sliderMax)
updateText()
if not ignorecallback then task.spawn(function() if SliderFunctions.Settings.Callback then SliderFunctions.Settings.Callback(finalValue) end end) end
SliderFunctions.Value = finalValue
end
SetValue(tonumber(SliderFunctions.Settings.Default) or sliderMin, true)
local function startDrag(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true SetValue(input) end end
sliderHead.InputBegan:Connect(startDrag)
sliderTouchArea.InputBegan:Connect(startDrag)
sliderBar.InputBegan:Connect(startDrag)
UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then SetValue(input) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then if dragging then dragging = false if SliderFunctions.Settings.onInputComplete then SliderFunctions.Settings.onInputComplete(finalValue) end end end end)
sliderValue.FocusLost:Connect(function()
local inputText = sliderValue.Text
local num, isPercent = inputText:match("^(%-?%d+%.?%d*)(%%?)$")
if num then num = tonumber(num) if isPercent == "%" then num = sliderMin + (num / 100) * (sliderMax - sliderMin) end SetValue(math.clamp(num, sliderMin, sliderMax)) else SetValue(finalValue) end
if SliderFunctions.Settings.onInputComplete then SliderFunctions.Settings.onInputComplete(finalValue) end
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
function SliderFunctions:UpdateName(Name) sliderName.Text = Name end
function SliderFunctions:SetVisibility(State) slider.Visible = State end
function SliderFunctions:UpdateValue(Value) SetValue(tonumber(Value) or sliderMin, true) end
function SliderFunctions:GetValue() return finalValue end
if Flag then MacLib.Options[Flag] = SliderFunctions end
return SliderFunctions
end
function SectionFunctions:Input(Settings, Flag)
local InputFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Input" }
local input = Instance.new("Frame")
input.AutomaticSize = Enum.AutomaticSize.Y
input.BackgroundTransparency = 1
input.Size = UDim2.new(1, 0, 0, 38)
input.Parent = section
local inputName = Instance.new("TextLabel")
inputName.FontFace = Font.new(assets.interFont)
inputName.Text = InputFunctions.Settings.Name
inputName.RichText = true
inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
inputName.TextSize = 13
inputName.TextTransparency = 0.5
inputName.TextTruncate = Enum.TextTruncate.AtEnd
inputName.TextXAlignment = Enum.TextXAlignment.Left
inputName.AnchorPoint = Vector2.new(0, 0.5)
inputName.AutomaticSize = Enum.AutomaticSize.XY
inputName.BackgroundTransparency = 1
inputName.Position = UDim2.fromScale(0, 0.5)
inputName.Parent = input
local inputBox = Instance.new("TextBox")
inputBox.FontFace = Font.new(assets.interFont)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.TextSize = 12
inputBox.TextTransparency = 0.1
inputBox.AnchorPoint = Vector2.new(1, 0.5)
inputBox.AutomaticSize = Enum.AutomaticSize.X
inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputBox.BackgroundTransparency = 0.95
inputBox.ClipsDescendants = true
inputBox.LayoutOrder = 1
inputBox.Position = UDim2.fromScale(1, 0.5)
inputBox.Size = UDim2.fromOffset(21, 21)
inputBox.TextXAlignment = Enum.TextXAlignment.Right
local inputBoxUICorner = Instance.new("UICorner")
inputBoxUICorner.CornerRadius = UDim.new(0, 4)
inputBoxUICorner.Parent = inputBox
local inputBoxUIStroke = Instance.new("UIStroke")
inputBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
inputBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
inputBoxUIStroke.Transparency = 0.9
inputBoxUIStroke.Parent = inputBox
local inputBoxUIPadding = Instance.new("UIPadding")
inputBoxUIPadding.PaddingLeft = UDim.new(0, 5)
inputBoxUIPadding.PaddingRight = UDim.new(0, 5)
inputBoxUIPadding.Parent = inputBox
local inputBoxUISizeConstraint = Instance.new("UISizeConstraint")
inputBoxUISizeConstraint.Parent = inputBox
inputBox.Parent = input
local Input = input
local InputBox = inputBox
local InputName = inputName
local Constraint = inputBoxUISizeConstraint
local function applyCharacterLimit(value) if InputFunctions.Settings.CharacterLimit then return value:sub(1, InputFunctions.Settings.CharacterLimit) end return value end
local CharacterSubs = {
All = function(value) return applyCharacterLimit(value) end,
Numeric = function(value) local result = value:match("^%-?%d*$") and value or value:gsub("[^%d-]", ""):gsub("(%-)", function(match, pos) return pos == 1 and match or "" end) return applyCharacterLimit(result) end,
Alphabetic = function(value) return applyCharacterLimit(value:gsub("[^a-zA-Z ]", "")) end,
AlphaNumeric = function(value) return applyCharacterLimit(value:gsub("[^a-zA-Z0-9]", "")) end,
}
local AcceptedCharacters
if type(InputFunctions.Settings.AcceptedCharacters) == "function" then AcceptedCharacters = InputFunctions.Settings.AcceptedCharacters else AcceptedCharacters = CharacterSubs[InputFunctions.Settings.AcceptedCharacters] or CharacterSubs.All end
InputBox.AutomaticSize = Enum.AutomaticSize.X
local function checkSize() local nameWidth = InputName.AbsoluteSize.X local totalWidth = Input.AbsoluteSize.X local maxWidth = (totalWidth - nameWidth - 20) / baseUIScale.Scale Constraint.MaxSize = Vector2.new(maxWidth, 9e9) end
checkSize()
InputName:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkSize)
InputBox.FocusLost:Connect(function() local inputText = InputBox.Text local filteredText = AcceptedCharacters(inputText) InputBox.Text = filteredText task.spawn(function() if InputFunctions.Settings.Callback then InputFunctions.Settings.Callback(filteredText) end end) end)
InputBox.Text = InputFunctions.Settings.Default or ""
InputBox.PlaceholderText = InputFunctions.Settings.Placeholder or ""
InputBox:GetPropertyChangedSignal("Text"):Connect(function() InputBox.Text = AcceptedCharacters(InputBox.Text) if InputFunctions.Settings.onChanged then InputFunctions.Settings.onChanged(InputBox.Text) end InputFunctions.Text = InputBox.Text end)
function InputFunctions:UpdateName(Name) inputName.Text = Name end
function InputFunctions:SetVisibility(State) input.Visible = State end
function InputFunctions:GetInput() return InputBox.Text end
function InputFunctions:UpdatePlaceholder(Placeholder) inputBox.PlaceholderText = Placeholder end
function InputFunctions:UpdateText(Text) local filteredText = AcceptedCharacters(Text) InputBox.Text = filteredText InputFunctions.Text = filteredText task.spawn(function() if InputFunctions.Settings.Callback then InputFunctions.Settings.Callback(filteredText) end end) end
if Flag then MacLib.Options[Flag] = InputFunctions end
return InputFunctions
end
function SectionFunctions:Keybind(Settings, Flag)
local KeybindFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Keybind" }
local keybind = Instance.new("Frame")
keybind.AutomaticSize = Enum.AutomaticSize.Y
keybind.BackgroundTransparency = 1
keybind.Size = UDim2.new(1, 0, 0, 38)
keybind.Parent = section
local keybindName = Instance.new("TextLabel")
keybindName.FontFace = Font.new(assets.interFont)
keybindName.Text = KeybindFunctions.Settings.Name
keybindName.RichText = true
keybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindName.TextSize = 13
keybindName.TextTransparency = 0.5
keybindName.TextTruncate = Enum.TextTruncate.AtEnd
keybindName.TextXAlignment = Enum.TextXAlignment.Left
keybindName.AnchorPoint = Vector2.new(0, 0.5)
keybindName.AutomaticSize = Enum.AutomaticSize.XY
keybindName.BackgroundTransparency = 1
keybindName.Position = UDim2.fromScale(0, 0.5)
keybindName.Parent = keybind
local binderBox = Instance.new("TextBox")
binderBox.CursorPosition = -1
binderBox.FontFace = Font.new(assets.interFont)
binderBox.PlaceholderText = "..."
binderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
binderBox.TextSize = 12
binderBox.TextTransparency = 0.1
binderBox.AnchorPoint = Vector2.new(1, 0.5)
binderBox.AutomaticSize = Enum.AutomaticSize.X
binderBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
binderBox.BackgroundTransparency = 0.95
binderBox.ClipsDescendants = true
binderBox.LayoutOrder = 1
binderBox.Position = UDim2.fromScale(1, 0.5)
binderBox.Size = UDim2.fromOffset(21, 21)
local binderBoxUICorner = Instance.new("UICorner")
binderBoxUICorner.CornerRadius = UDim.new(0, 4)
binderBoxUICorner.Parent = binderBox
local binderBoxUIStroke = Instance.new("UIStroke")
binderBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
binderBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
binderBoxUIStroke.Transparency = 0.9
binderBoxUIStroke.Parent = binderBox
local binderBoxUIPadding = Instance.new("UIPadding")
binderBoxUIPadding.PaddingLeft = UDim.new(0, 5)
binderBoxUIPadding.PaddingRight = UDim.new(0, 5)
binderBoxUIPadding.Parent = binderBox
local binderBoxUISizeConstraint = Instance.new("UISizeConstraint")
binderBoxUISizeConstraint.Parent = binderBox
binderBox.Parent = keybind
local focused, isBinding, reset = false, false, false
local binded = KeybindFunctions.Settings.Default
local function resetFocusState() focused = false isBinding = false binderBox:ReleaseFocus() end
if binded then binderBox.Text = binded.Name end
binderBox.Focused:Connect(function() focused = true end)
binderBox.FocusLost:Connect(function() focused = false end)
UserInputService.InputBegan:Connect(function(inp)
if focused and not isBinding then
isBinding = true
local Event
Event = UserInputService.InputBegan:Connect(function(input)
if KeybindFunctions.Settings.Blacklist and (table.find(KeybindFunctions.Settings.Blacklist, input.KeyCode) or table.find(KeybindFunctions.Settings.Blacklist, input.UserInputType)) then binderBox:ReleaseFocus() resetFocusState() Event:Disconnect() return end
if input.UserInputType == Enum.UserInputType.Keyboard then binded = input.KeyCode binderBox.Text = input.KeyCode.Name elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then binded = input.UserInputType binderBox.Text = input.UserInputType.Name end
if KeybindFunctions.Settings.onBinded then KeybindFunctions.Settings.onBinded(binded) end
reset = true
resetFocusState()
Event:Disconnect()
end)
else
if not reset and (inp.KeyCode == binded or inp.UserInputType == binded) then
if KeybindFunctions.Settings.Callback then KeybindFunctions.Settings.Callback(binded) end
if KeybindFunctions.Settings.onBindHeld then KeybindFunctions.Settings.onBindHeld(true, binded) end
else reset = false end
end
end)
UserInputService.InputEnded:Connect(function(inp) if not focused and not isBinding then if inp.KeyCode == binded or inp.UserInputType == binded then if Settings.onBindHeld then Settings.onBindHeld(false, binded) end end end end)
function KeybindFunctions:Bind(Key) binded = Key binderBox.Text = Key.Name end
function KeybindFunctions:Unbind() binded = nil binderBox.Text = "" end
function KeybindFunctions:GetBind() return binded end
function KeybindFunctions:UpdateName(Name) keybindName.Text = Name end
function KeybindFunctions:SetVisibility(State) keybind.Visible = State end
if Flag then MacLib.Options[Flag] = KeybindFunctions end
return KeybindFunctions
end
function SectionFunctions:Dropdown(Settings, Flag)
local DropdownFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Dropdown" }
local Selected = {}
local OptionObjs = {}
local dropdown = Instance.new("Frame")
dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dropdown.BackgroundTransparency = 0.985
dropdown.BorderSizePixel = 0
dropdown.Size = UDim2.new(1, 0, 0, 38)
dropdown.Parent = section
dropdown.ClipsDescendants = true
local dropdownUIPadding = Instance.new("UIPadding")
dropdownUIPadding.PaddingLeft = UDim.new(0, 15)
dropdownUIPadding.PaddingRight = UDim.new(0, 15)
dropdownUIPadding.Parent = dropdown
local interact = Instance.new("TextButton")
interact.Text = ""
interact.BackgroundTransparency = 1
interact.Size = UDim2.new(1, 0, 0, 38)
interact.Parent = dropdown
local dropdownName = Instance.new("TextLabel")
dropdownName.FontFace = Font.new(assets.interFont)
dropdownName.Text = Settings.Default and (DropdownFunctions.Settings.Name .. " • " .. table.concat(Selected, ", ")) or (DropdownFunctions.Settings.Name .. "...")
dropdownName.RichText = true
dropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownName.TextSize = 13
dropdownName.TextTransparency = 0.5
dropdownName.TextTruncate = Enum.TextTruncate.SplitWord
dropdownName.TextXAlignment = Enum.TextXAlignment.Left
dropdownName.AutomaticSize = Enum.AutomaticSize.Y
dropdownName.BackgroundTransparency = 1
dropdownName.Size = UDim2.new(1, -20, 0, 38)
dropdownName.Parent = dropdown
local dropdownUIStroke = Instance.new("UIStroke")
dropdownUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
dropdownUIStroke.Color = Color3.fromRGB(255, 255, 255)
dropdownUIStroke.Transparency = 0.95
dropdownUIStroke.Parent = dropdown
local dropdownUICorner = Instance.new("UICorner")
dropdownUICorner.CornerRadius = UDim.new(0, 6)
dropdownUICorner.Parent = dropdown
local dropdownImage = Instance.new("ImageLabel")
dropdownImage.Image = assets.dropdown
dropdownImage.ImageTransparency = 0.5
dropdownImage.AnchorPoint = Vector2.new(1, 0)
dropdownImage.BackgroundTransparency = 1
dropdownImage.Position = UDim2.new(1, 0, 0, 12)
dropdownImage.Size = UDim2.fromOffset(14, 14)
dropdownImage.Parent = dropdown
local dropdownFrame = Instance.new("ScrollingFrame")
dropdownFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownFrame.CanvasSize = UDim2.new()
dropdownFrame.BottomImage = ""
dropdownFrame.TopImage = ""
dropdownFrame.ScrollBarImageTransparency = 0.8
dropdownFrame.ScrollBarThickness = 2
dropdownFrame.BackgroundTransparency = 1
dropdownFrame.ClipsDescendants = true
dropdownFrame.Position = UDim2.new(0, 0, 0, 38)
dropdownFrame.Size = UDim2.new(1, 0, 1, -38)
dropdownFrame.Visible = false
local dropdownFrameUIPadding = Instance.new("UIPadding")
dropdownFrameUIPadding.PaddingTop = UDim.new(0, 0)
dropdownFrameUIPadding.PaddingBottom = UDim.new(0, 10)
dropdownFrameUIPadding.Parent = dropdownFrame
local dropdownFrameUIListLayout = Instance.new("UIListLayout")
dropdownFrameUIListLayout.Padding = UDim.new(0, 5)
dropdownFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownFrameUIListLayout.Parent = dropdownFrame
local search = Instance.new("Frame")
search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
search.BackgroundTransparency = 0.95
search.LayoutOrder = -1
search.Size = UDim2.new(1, 0, 0, 30)
search.Parent = dropdownFrame
search.Visible = DropdownFunctions.Settings.Search
local sectionUICorner = Instance.new("UICorner")
sectionUICorner.Parent = search
local searchIcon = Instance.new("ImageLabel")
searchIcon.Image = assets.searchIcon
searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
searchIcon.AnchorPoint = Vector2.new(0, 0.5)
searchIcon.BackgroundTransparency = 1
searchIcon.Position = UDim2.fromScale(0, 0.5)
searchIcon.Size = UDim2.fromOffset(12, 12)
searchIcon.Parent = search
local uIPadding = Instance.new("UIPadding")
uIPadding.PaddingLeft = UDim.new(0, 15)
uIPadding.Parent = search
local searchBox = Instance.new("TextBox")
searchBox.CursorPosition = -1
searchBox.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
searchBox.PlaceholderText = "Search..."
searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
searchBox.TextSize = 14
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.BackgroundTransparency = 1
searchBox.Size = UDim2.fromScale(1, 1)
local function CalculateDropdownSize()
local totalHeight = 0
local visibleChildrenCount = 0
for _, v in pairs(dropdownFrame:GetChildren()) do if not v:IsA("UIComponent") and v.Visible then totalHeight += v.AbsoluteSize.Y visibleChildrenCount += 1 end end
local spacing = dropdownFrameUIListLayout.Padding.Offset * math.max(0, visibleChildrenCount - 1)
local contentHeight = totalHeight + spacing + dropdownFrameUIPadding.PaddingBottom.Offset
local maxContent = (5 * 30) + (4 * 5) + dropdownFrameUIPadding.PaddingBottom.Offset
return 38 + math.min(contentHeight, maxContent)
end
local function findOption()
local searchTerm = searchBox.Text:lower()
for _, v in pairs(OptionObjs) do local optionText = v.NameLabel.Text:lower() local isVisible = string.find(optionText, searchTerm) ~= nil if v.Button.Visible ~= isVisible then v.Button.Visible = isVisible end end
dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
end
searchBox:GetPropertyChangedSignal("Text"):Connect(findOption)
local uIPadding1 = Instance.new("UIPadding")
uIPadding1.PaddingLeft = UDim.new(0, 23)
uIPadding1.Parent = searchBox
searchBox.Parent = search
local tweensettings = {duration = 0.2, easingStyle = Enum.EasingStyle.Quint, transparencyIn = 0.2, transparencyOut = 0.5, checkSizeIncrease = 12, checkSizeDecrease = -13, waitTime = 1}
local function Toggle(optionName, State)
local option = OptionObjs[optionName]
if not option then return end
local checkmark = option.Checkmark
local optionNameLabel = option.NameLabel
if State then
if DropdownFunctions.Settings.Multi then if not table.find(Selected, optionName) then table.insert(Selected, optionName) DropdownFunctions.Value = Selected end
else for name, opt in pairs(OptionObjs) do if name ~= optionName then Tween(opt.Checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {Size = UDim2.new(opt.Checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, opt.Checkmark.Size.Y.Scale, opt.Checkmark.Size.Y.Offset)}):Play() Tween(opt.NameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {TextTransparency = tweensettings.transparencyOut}):Play() opt.Checkmark.TextTransparency = 1 end end Selected = {optionName} DropdownFunctions.Value = Selected[1] end
Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)}):Play()
Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {TextTransparency = tweensettings.transparencyIn}):Play()
checkmark.TextTransparency = 0
else
if DropdownFunctions.Settings.Multi then local idx = table.find(Selected, optionName) if idx then table.remove(Selected, idx) end else Selected = {} end
Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)}):Play()
Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {TextTransparency = tweensettings.transparencyOut}):Play()
checkmark.TextTransparency = 1
end
if Settings.Required and #Selected == 0 and not State then return end
if #Selected > 0 then dropdownName.Text = DropdownFunctions.Settings.Name .. " • " .. table.concat(Selected, ", ") else dropdownName.Text = DropdownFunctions.Settings.Name .. "..." end
end
local dropped = false
local db = false
local function ToggleDropdown()
if db then return end
db = true
local defaultDropdownSize = 38
local isDropdownOpen = not dropped
local targetSize = isDropdownOpen and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, defaultDropdownSize)
local dropTween = Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = targetSize})
local iconTween = Tween(dropdownImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = isDropdownOpen and -90 or 0})
dropTween:Play()
iconTween:Play()
if isDropdownOpen then dropdownFrame.Visible = true dropTween.Completed:Connect(function() db = false end) else dropTween.Completed:Connect(function() dropdownFrame.Visible = false db = false end) end
dropped = isDropdownOpen
end
interact.MouseButton1Click:Connect(ToggleDropdown)
local function addOption(i, v)
local option = Instance.new("TextButton")
option.Text = ""
option.BackgroundTransparency = 1
option.Size = UDim2.new(1, 0, 0, 30)
local optionUIPadding = Instance.new("UIPadding")
optionUIPadding.PaddingLeft = UDim.new(0, 15)
optionUIPadding.Parent = option
local optionName = Instance.new("TextLabel")
optionName.FontFace = Font.new(assets.interFont)
optionName.Text = v
optionName.RichText = true
optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
optionName.TextSize = 13
optionName.TextTransparency = 0.5
optionName.TextTruncate = Enum.TextTruncate.AtEnd
optionName.TextXAlignment = Enum.TextXAlignment.Left
optionName.AnchorPoint = Vector2.new(0, 0.5)
optionName.AutomaticSize = Enum.AutomaticSize.XY
optionName.BackgroundTransparency = 1
optionName.Position = UDim2.fromScale(0, 0.5)
optionName.Parent = option
local optionUIListLayout = Instance.new("UIListLayout")
optionUIListLayout.Padding = UDim.new(0, 10)
optionUIListLayout.FillDirection = Enum.FillDirection.Horizontal
optionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
optionUIListLayout.Parent = option
local checkmark = Instance.new("TextLabel")
checkmark.FontFace = Font.new(assets.interFont)
checkmark.Text = "✓"
checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
checkmark.TextSize = 13
checkmark.TextTransparency = 1
checkmark.AnchorPoint = Vector2.new(0, 0.5)
checkmark.AutomaticSize = Enum.AutomaticSize.Y
checkmark.BackgroundTransparency = 1
checkmark.LayoutOrder = -1
checkmark.Position = UDim2.fromScale(0, 0.5)
checkmark.Size = UDim2.fromOffset(-10, 0)
checkmark.Parent = option
option.Parent = dropdownFrame
dropdownFrame.Parent = dropdown
OptionObjs[v] = {Index = i, Button = option, NameLabel = optionName, Checkmark = checkmark}
local tweensettings2 = {duration = 0.2, easingStyle = Enum.EasingStyle.Quint, transparencyIn = 0.2, transparencyOut = 0.5, checkSizeIncrease = 12, checkSizeDecrease = -optionUIListLayout.Padding.Offset, waitTime = 1}
local tweens = {
checkIn = Tween(checkmark, TweenInfo.new(tweensettings2.duration, tweensettings2.easingStyle), {Size = UDim2.new(checkmark.Size.X.Scale, tweensettings2.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)}),
checkOut = Tween(checkmark, TweenInfo.new(tweensettings2.duration, tweensettings2.easingStyle),{Size = UDim2.new(checkmark.Size.X.Scale, tweensettings2.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)}),
nameIn = Tween(optionName, TweenInfo.new(tweensettings2.duration, tweensettings2.easingStyle),{TextTransparency = tweensettings2.transparencyIn}),
nameOut = Tween(optionName, TweenInfo.new(tweensettings2.duration, tweensettings2.easingStyle),{TextTransparency = tweensettings2.transparencyOut})
}
local isSelected = false
if DropdownFunctions.Settings.Default then if DropdownFunctions.Settings.Multi then isSelected = table.find(DropdownFunctions.Settings.Default, v) and true or false else isSelected = (DropdownFunctions.Settings.Default == i) and true or false end end
Toggle(v, isSelected)
local opt = OptionObjs[v].Button
opt.MouseButton1Click:Connect(function()
local isSel = table.find(Selected, v) and true or false
local newSelected = not isSel
if DropdownFunctions.Settings.Required and not newSelected and #Selected <= 1 then return end
Toggle(v, newSelected)
task.spawn(function()
if DropdownFunctions.Settings.Multi then local Return = {} for _, o in ipairs(Selected) do Return[o] = true end if DropdownFunctions.Settings.Callback then DropdownFunctions.Settings.Callback(Return) end
else if newSelected and DropdownFunctions.Settings.Callback then DropdownFunctions.Settings.Callback(Selected[1] or nil) end end
end)
end)
if dropped then dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize()) end
end
if DropdownFunctions.Settings.Options then for i, v in pairs(DropdownFunctions.Settings.Options) do addOption(i, v) end end
function DropdownFunctions:UpdateName(New) dropdownName.Text = New end
function DropdownFunctions:SetVisibility(State) dropdown.Visible = State end
function DropdownFunctions:UpdateSelection(newSelection)
if not newSelection then return end
for option, _ in pairs(OptionObjs) do Toggle(option, false) end
local selectedOptions = {}
if type(newSelection) == "number" then for option, data in pairs(OptionObjs) do local isSelected = data.Index == newSelection Toggle(option, isSelected) if isSelected then table.insert(selectedOptions, option) end end
elseif type(newSelection) == "string" then for option, data in pairs(OptionObjs) do local isSelected = option == newSelection Toggle(option, isSelected) if isSelected then table.insert(selectedOptions, option) end end
elseif type(newSelection) == "table" then for option, _ in pairs(OptionObjs) do local isSelected = table.find(newSelection, option) ~= nil Toggle(option, isSelected) if isSelected then table.insert(selectedOptions, option) end end end
if DropdownFunctions.Settings.Callback then if DropdownFunctions.Settings.Multi then local Return = {} for _, opt in ipairs(selectedOptions) do Return[opt] = true end DropdownFunctions.Settings.Callback(Return) else DropdownFunctions.Settings.Callback(selectedOptions[1] or nil) end end
end
function DropdownFunctions:InsertOptions(newOptions) if not newOptions then return end DropdownFunctions.Settings.Options = newOptions for i, v in pairs(newOptions) do addOption(i, v) end end
function DropdownFunctions:ClearOptions() for _, optionData in pairs(OptionObjs) do optionData.Button:Destroy() end OptionObjs = {} Selected = {} if dropped then dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize()) end end
function DropdownFunctions:GetOptions() local optionsStatus = {} for option, data in pairs(OptionObjs) do local isSelected = table.find(Selected, option) and true or false optionsStatus[option] = isSelected end return optionsStatus end
function DropdownFunctions:RemoveOptions(remove) if not remove then return end for _, optionName in ipairs(remove) do local optionData = OptionObjs[optionName] if optionData then for i = #Selected, 1, -1 do if Selected[i] == optionName then table.remove(Selected, i) end end optionData.Button:Destroy() OptionObjs[optionName] = nil end end if dropped then dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize()) end end
function DropdownFunctions:IsOption(optionName) if not optionName then return end return OptionObjs[optionName] ~= nil end
if Flag then MacLib.Options[Flag] = DropdownFunctions end
return DropdownFunctions
end
function SectionFunctions:Colorpicker(Settings, Flag)
local ColorpickerFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Colorpicker" }
local isAlpha = ColorpickerFunctions.Settings.Alpha and true or false
ColorpickerFunctions.Color = ColorpickerFunctions.Settings.Default
ColorpickerFunctions.Alpha = isAlpha and ColorpickerFunctions.Settings.Alpha
local colorpicker = Instance.new("Frame")
colorpicker.AutomaticSize = Enum.AutomaticSize.Y
colorpicker.BackgroundTransparency = 1
colorpicker.Size = UDim2.new(1, 0, 0, 38)
colorpicker.Parent = section
local colorpickerName = Instance.new("TextLabel")
colorpickerName.FontFace = Font.new(assets.interFont)
colorpickerName.Text = Settings.Name
colorpickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
colorpickerName.TextSize = 13
colorpickerName.TextTransparency = 0.5
colorpickerName.RichText = true
colorpickerName.TextTruncate = Enum.TextTruncate.AtEnd
colorpickerName.TextXAlignment = Enum.TextXAlignment.Left
colorpickerName.AnchorPoint = Vector2.new(0, 0.5)
colorpickerName.AutomaticSize = Enum.AutomaticSize.XY
colorpickerName.BackgroundTransparency = 1
colorpickerName.Position = UDim2.fromScale(0, 0.5)
colorpickerName.Parent = colorpicker
local colorCbg = Instance.new("ImageLabel")
colorCbg.Image = assets.grid
colorCbg.ScaleType = Enum.ScaleType.Tile
colorCbg.TileSize = UDim2.fromOffset(500, 500)
colorCbg.AnchorPoint = Vector2.new(1, 0.5)
colorCbg.BackgroundTransparency = 1
colorCbg.Position = UDim2.fromScale(1, 0.5)
colorCbg.Size = UDim2.fromOffset(21, 21)
local colorC = Instance.new("Frame")
colorC.AnchorPoint = Vector2.new(0.5, 0.5)
colorC.BackgroundColor3 = ColorpickerFunctions.Color
colorC.BorderSizePixel = 0
colorC.Position = UDim2.fromScale(0.5, 0.5)
colorC.Size = UDim2.fromScale(1, 1)
colorC.BackgroundTransparency = ColorpickerFunctions.Alpha or 0
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 6)
uICorner.Parent = colorC
local interact = Instance.new("TextButton")
interact.Text = ""
interact.BackgroundTransparency = 1
interact.Size = UDim2.fromScale(1, 1)
interact.Parent = colorC
colorC.Parent = colorCbg
local uICorner1 = Instance.new("UICorner")
uICorner1.CornerRadius = UDim.new(0, 8)
uICorner1.Parent = colorCbg
colorCbg.Parent = colorpicker
local colorPicker = Instance.new("Frame")
colorPicker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
colorPicker.BackgroundTransparency = 0.5
colorPicker.Size = UDim2.fromScale(1, 1)
colorPicker.Visible = false
local baseUICorner = Instance.new("UICorner")
baseUICorner.CornerRadius = UDim.new(0, 10)
baseUICorner.Parent = colorPicker
local prompt = Instance.new("Frame")
prompt.AnchorPoint = Vector2.new(0.5, 0.5)
prompt.AutomaticSize = Enum.AutomaticSize.Y
prompt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
prompt.BorderSizePixel = 0
prompt.Position = UDim2.fromScale(0.5, 0.5)
prompt.Size = UDim2.fromOffset(420, 0)
local promptUIScale = Instance.new("UIScale")
promptUIScale.Parent = prompt
promptUIScale.Scale = 0.95
local promptUIStroke = Instance.new("UIStroke")
promptUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
promptUIStroke.Color = Color3.fromRGB(255, 255, 255)
promptUIStroke.Transparency = 0.9
promptUIStroke.Parent = prompt
local promptUICorner = Instance.new("UICorner")
promptUICorner.CornerRadius = UDim.new(0, 10)
promptUICorner.Parent = prompt
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Padding = UDim.new(0, 10)
uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = prompt
local colorOptions = Instance.new("Frame")
colorOptions.AutomaticSize = Enum.AutomaticSize.XY
colorOptions.BackgroundTransparency = 1
colorOptions.LayoutOrder = 1
colorOptions.Size = UDim2.fromScale(1, 0)
local value = Instance.new("TextButton")
value.Text = ""
value.AutoButtonColor = false
value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
value.LayoutOrder = 1
value.Position = UDim2.fromScale(0.092, 0.886)
value.Size = UDim2.new(1, 0, 0, 15)
local uIGradient = Instance.new("UIGradient")
uIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))})
uIGradient.Parent = value
local slide = Instance.new("Frame")
slide.AnchorPoint = Vector2.new(0, 0.5)
slide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
slide.BorderSizePixel = 0
slide.Position = UDim2.fromScale(0, 0.5)
slide.Size = UDim2.new(0, 13, 1, 8)
local uICorner2 = Instance.new("UICorner")
uICorner2.CornerRadius = UDim.new(1, 0)
uICorner2.Parent = slide
local uIStroke = Instance.new("UIStroke")
uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uIStroke.Transparency = 0.5
uIStroke.Parent = slide
slide.Parent = value
local uICorner3 = Instance.new("UICorner")
uICorner3.CornerRadius = UDim.new(0, 6)
uICorner3.Parent = value
local uIStroke1 = Instance.new("UIStroke")
uIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uIStroke1.Color = Color3.fromRGB(255, 255, 255)
uIStroke1.Transparency = 0.9
local uIGradient1 = Instance.new("UIGradient")
uIGradient1.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))})
uIGradient1.Rotation = 180
uIGradient1.Parent = uIStroke1
uIStroke1.Parent = value
value.Parent = colorOptions
local uIListLayout1 = Instance.new("UIListLayout")
uIListLayout1.Padding = UDim.new(0, 25)
uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout1.Parent = colorOptions
local wheel = Instance.new("Frame")
wheel.AutomaticSize = Enum.AutomaticSize.Y
wheel.BackgroundTransparency = 1
wheel.Size = UDim2.new(1, 0, 0, 100)
local wheel1 = Instance.new("ImageButton")
wheel1.Image = assets.colorWheel
wheel1.AutoButtonColor = false
wheel1.Active = false
wheel1.BackgroundTransparency = 1
wheel1.Selectable = false
wheel1.Size = UDim2.fromOffset(220, 220)
wheel1.SizeConstraint = Enum.SizeConstraint.RelativeYY
local target = Instance.new("ImageLabel")
target.Image = assets.colorTarget
target.ImageColor3 = Color3.fromRGB(0, 0, 0)
target.AnchorPoint = Vector2.new(0.5, 0.5)
target.BackgroundTransparency = 1
target.Position = UDim2.fromScale(0.5, 0.5)
target.Size = UDim2.fromOffset(22, 22)
target.SizeConstraint = Enum.SizeConstraint.RelativeYY
target.Parent = wheel1
wheel1.Parent = wheel
local inputs = Instance.new("Frame")
inputs.AnchorPoint = Vector2.new(1, 0.5)
inputs.AutomaticSize = Enum.AutomaticSize.XY
inputs.BackgroundTransparency = 1
inputs.LayoutOrder = 1
inputs.Position = UDim2.fromScale(1, 0.5)
local uIListLayout2 = Instance.new("UIListLayout")
uIListLayout2.Padding = UDim.new(0, 5)
uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout2.Parent = inputs
local function makeInput(name, layoutOrder, default)
local f = Instance.new("Frame")
f.AutomaticSize = Enum.AutomaticSize.XY
f.BackgroundTransparency = 1
f.LayoutOrder = layoutOrder
f.Size = UDim2.fromOffset(0, 38)
local l = Instance.new("TextLabel")
l.FontFace = Font.new(assets.interFont)
l.Text = name
l.TextColor3 = Color3.fromRGB(255, 255, 255)
l.TextSize = 13
l.TextTransparency = 0.5
l.TextXAlignment = Enum.TextXAlignment.Left
l.AnchorPoint = Vector2.new(0, 0.5)
l.AutomaticSize = Enum.AutomaticSize.XY
l.BackgroundTransparency = 1
l.LayoutOrder = 2
l.Position = UDim2.fromScale(0, 0.5)
l.Parent = f
local ul = Instance.new("UIListLayout")
ul.Padding = UDim.new(0, 15)
ul.FillDirection = Enum.FillDirection.Horizontal
ul.SortOrder = Enum.SortOrder.LayoutOrder
ul.VerticalAlignment = Enum.VerticalAlignment.Center
ul.Parent = f
local b = Instance.new("TextBox")
b.ClearTextOnFocus = false
b.CursorPosition = -1
b.FontFace = Font.new(assets.interFont)
b.Text = default
b.TextColor3 = Color3.fromRGB(255, 255, 255)
b.TextSize = 12
b.TextTransparency = 0.1
b.TextXAlignment = Enum.TextXAlignment.Left
b.AnchorPoint = Vector2.new(1, 0.5)
b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
b.BackgroundTransparency = 0.95
b.ClipsDescendants = true
b.LayoutOrder = 1
b.Position = UDim2.fromScale(1, 0.5)
b.Size = UDim2.fromOffset(75, 25)
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 4)
c.Parent = b
local s = Instance.new("UIStroke")
s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
s.Color = Color3.fromRGB(255, 255, 255)
s.Transparency = 0.9
s.Parent = b
local sc = Instance.new("UISizeConstraint")
sc.Parent = b
local p = Instance.new("UIPadding")
p.PaddingLeft = UDim.new(0, 8)
p.PaddingRight = UDim.new(0, 10)
p.Parent = b
b.Parent = f
f.Parent = inputs
return b
end
local redBox = makeInput("Red", 1, "255")
local greenBox = makeInput("Green", 2, "255")
local blueBox = makeInput("Blue", 3, "255")
local alphaBox = makeInput("Alpha", 4, "0")
alphaBox.Parent.Parent.Visible = isAlpha
local hexBox = makeInput("Hex", 5, "#FFFFFF")
inputs.Parent = wheel
local uIPadding2 = Instance.new("UIPadding")
uIPadding2.PaddingRight = UDim.new(0, 5)
uIPadding2.Parent = wheel
wheel.Parent = colorOptions
local colorWells = Instance.new("Frame")
colorWells.AutomaticSize = Enum.AutomaticSize.Y
colorWells.BackgroundTransparency = 1
colorWells.LayoutOrder = 2
colorWells.Size = UDim2.fromScale(1, 0)
local uIGridLayout = Instance.new("UIGridLayout")
uIGridLayout.CellPadding = UDim2.fromOffset(10, 0)
uIGridLayout.CellSize = UDim2.new(0.5, -5, 0, 30)
uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIGridLayout.Parent = colorWells
local newColor = Instance.new("ImageLabel")
newColor.Image = assets.grid
newColor.ScaleType = Enum.ScaleType.Tile
newColor.TileSize = UDim2.fromOffset(500, 500)
newColor.BackgroundTransparency = 1
local uICorner4 = Instance.new("UICorner")
uICorner4.Parent = newColor
local color = Instance.new("Frame")
color.AnchorPoint = Vector2.new(0.5, 0.5)
color.Position = UDim2.fromScale(0.5, 0.5)
color.Size = UDim2.new(1, 1, 1, 1)
local uICorner5 = Instance.new("UICorner")
uICorner5.Parent = color
color.Parent = newColor
newColor.Parent = colorWells
local oldColor = Instance.new("ImageLabel")
oldColor.Image = assets.grid
oldColor.ScaleType = Enum.ScaleType.Tile
oldColor.TileSize = UDim2.fromOffset(500, 500)
oldColor.BackgroundTransparency = 1
oldColor.LayoutOrder = 1
local uICorner6 = Instance.new("UICorner")
uICorner6.Parent = oldColor
local color1 = Instance.new("Frame")
color1.AnchorPoint = Vector2.new(0.5, 0.5)
color1.Position = UDim2.fromScale(0.5, 0.5)
color1.Size = UDim2.new(1, 1, 1, 1)
local uICorner7 = Instance.new("UICorner")
uICorner7.Parent = color1
color1.Parent = oldColor
oldColor.Parent = colorWells
colorWells.Parent = colorOptions
colorOptions.Parent = prompt
local interactions = Instance.new("Frame")
interactions.AutomaticSize = Enum.AutomaticSize.Y
interactions.BackgroundTransparency = 1
interactions.LayoutOrder = 2
interactions.Size = UDim2.fromScale(1, 0)
local uIListLayout8 = Instance.new("UIListLayout")
uIListLayout8.Padding = UDim.new(0, 10)
uIListLayout8.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout8.Parent = interactions
local confirm = Instance.new("TextButton")
confirm.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
confirm.Text = "Confirm"
confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
confirm.TextSize = 15
confirm.TextTransparency = 0.5
confirm.AutoButtonColor = false
confirm.AutomaticSize = Enum.AutomaticSize.Y
confirm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
confirm.Size = UDim2.fromScale(1, 0)
local uIPadding3 = Instance.new("UIPadding")
uIPadding3.PaddingBottom = UDim.new(0, 9)
uIPadding3.PaddingLeft = UDim.new(0, 10)
uIPadding3.PaddingRight = UDim.new(0, 10)
uIPadding3.PaddingTop = UDim.new(0, 9)
uIPadding3.Parent = confirm
local confirmCorner = Instance.new("UICorner")
confirmCorner.CornerRadius = UDim.new(0, 10)
confirmCorner.Parent = confirm
confirm.Parent = interactions
local cancel = Instance.new("TextButton")
cancel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
cancel.Text = "Cancel"
cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
cancel.TextSize = 15
cancel.TextTransparency = 0.5
cancel.AutoButtonColor = false
cancel.AutomaticSize = Enum.AutomaticSize.Y
cancel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
cancel.Size = UDim2.fromScale(1, 0)
local cancelCorner = Instance.new("UICorner")
cancelCorner.CornerRadius = UDim.new(0, 10)
cancelCorner.Parent = cancel
local uIPadding4 = Instance.new("UIPadding")
uIPadding4.PaddingBottom = UDim.new(0, 9)
uIPadding4.PaddingLeft = UDim.new(0, 10)
uIPadding4.PaddingRight = UDim.new(0, 10)
uIPadding4.PaddingTop = UDim.new(0, 9)
uIPadding4.Parent = cancel
cancel.Parent = interactions
local uIPadding5 = Instance.new("UIPadding")
uIPadding5.PaddingTop = UDim.new(0, 10)
uIPadding5.Parent = interactions
interactions.Parent = prompt
local promptUIPadding = Instance.new("UIPadding")
promptUIPadding.PaddingBottom = UDim.new(0, 20)
promptUIPadding.PaddingLeft = UDim.new(0, 20)
promptUIPadding.PaddingRight = UDim.new(0, 20)
promptUIPadding.PaddingTop = UDim.new(0, 20)
promptUIPadding.Parent = prompt
local paragraph = Instance.new("Frame")
paragraph.AutomaticSize = Enum.AutomaticSize.Y
paragraph.BackgroundTransparency = 1
paragraph.Size = UDim2.fromScale(1, 0)
local paragraphHeader = Instance.new("TextLabel")
paragraphHeader.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
paragraphHeader.RichText = true
paragraphHeader.Text = ColorpickerFunctions.Settings.Name
paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphHeader.TextSize = 18
paragraphHeader.TextTransparency = 0.4
paragraphHeader.TextWrapped = true
paragraphHeader.AutomaticSize = Enum.AutomaticSize.XY
paragraphHeader.BackgroundTransparency = 1
paragraphHeader.Size = UDim2.fromScale(1, 0)
paragraphHeader.Parent = paragraph
local uIListLayout9 = Instance.new("UIListLayout")
uIListLayout9.Padding = UDim.new(0, 15)
uIListLayout9.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout9.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout9.Parent = paragraph
local uIPadding6 = Instance.new("UIPadding")
uIPadding6.PaddingBottom = UDim.new(0, 15)
uIPadding6.Parent = paragraph
local line = Instance.new("Frame")
line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
line.BackgroundTransparency = 0.9
line.LayoutOrder = 1
line.Size = UDim2.new(1, 0, 0, 1)
line.Parent = paragraph
paragraph.Parent = prompt
prompt.Parent = colorPicker
colorPicker.Parent = base
local fromHSV, fromRGB, v2, udim2 = Color3.fromHSV, Color3.fromRGB, Vector2.new, UDim2.new
local wheelRef = wheel1
local ring = target
local sliderRef = value
local colour = color
local modifierInputs = {Hex = hexBox, Red = redBox, Green = greenBox, Blue = blueBox, Alpha = alphaBox}
local Mouse = LocalPlayer:GetMouse()
local WheelDown, SlideDown = false, false
local hue, saturation, val = 0, 0, 1
local function toPolar(v) return math.atan2(v.y, v.x), v.magnitude end
local function radToDeg(x) return ((x + math.pi) / (2 * math.pi)) * 360 end
local function degToRad(degrees) return degrees * (math.pi / 180) end
local function hexToRGB(hex) hex = hex:gsub("#","") if #hex ~= 6 then return 0, 0, 0 end return tonumber(hex:sub(1, 2), 16) or 0, tonumber(hex:sub(3, 4), 16) or 0, tonumber(hex:sub(5, 6), 16) or 0 end
local function clampInput(value, min, max) local num = tonumber(value) if num then return math.clamp(num, min, max) end return min end
local function update()
local c = fromHSV(hue, saturation, val)
colour.BackgroundColor3 = c
colour.BackgroundTransparency = clampInput(modifierInputs.Alpha.Text, 0, 1)
modifierInputs.Red.Text = tostring(math.floor(c.r * 255 + 0.5))
modifierInputs.Green.Text = tostring(math.floor(c.g * 255 + 0.5))
modifierInputs.Blue.Text = tostring(math.floor(c.b * 255 + 0.5))
modifierInputs.Alpha.Text = clampInput(modifierInputs.Alpha.Text, 0, 1)
modifierInputs.Hex.Text = string.format("#%02X%02X%02X", math.floor(c.r * 255 + 0.5), math.floor(c.g * 255 + 0.5), math.floor(c.b * 255 + 0.5))
end
local function UpdateSlide(iX) local rY = iX - sliderRef.AbsolutePosition.X local cY = math.clamp(rY, 0, sliderRef.AbsoluteSize.X - slide.AbsoluteSize.X) slide.Position = udim2(0, cY, 0.5, 0) val = 1 - (cY / (sliderRef.AbsoluteSize.X - slide.AbsoluteSize.X)) update() end
local function UpdateRing(iX, iY) local r = wheelRef.AbsoluteSize.x / 2 local d = v2(iX, iY) - wheelRef.AbsolutePosition - wheelRef.AbsoluteSize / 2 if d:Dot(d) > r * r then d = d.unit * r end ring.Position = udim2(0.5, d.x, 0.5, d.y) local phi, len = toPolar(d * v2(1, -1)) hue, saturation = radToDeg(phi) / 360, math.clamp(len / r, 0, 1) sliderRef.BackgroundColor3 = fromHSV(hue, saturation, 1) update() end
local function UpdateSlideFromValue(v) local cY = (1 - v) * (sliderRef.AbsoluteSize.X - slide.AbsoluteSize.X) slide.Position = UDim2.new(0, cY, 0.5, 0) end
local function UpdateRingFromHSV(h, s) local r = wheelRef.AbsoluteSize.X / 2 local phi = degToRad(h * 360) local len = s * r local x = len * math.cos(phi) local y = len * math.sin(phi) ring.Position = UDim2.new(0.5, -x, 0.5, y) sliderRef.BackgroundColor3 = fromHSV(h, s, 1) end
local function updateFromRGB() local r = clampInput(modifierInputs.Red.Text, 0, 255) local g = clampInput(modifierInputs.Green.Text, 0, 255) local b = clampInput(modifierInputs.Blue.Text, 0, 255) modifierInputs.Red.Text = r modifierInputs.Green.Text = g modifierInputs.Blue.Text = b hue, saturation, val = Color3.fromRGB(r, g, b):ToHSV() UpdateSlideFromValue(val) UpdateRingFromHSV(hue, saturation) update() end
local function updateFromHex() local hex = modifierInputs.Hex.Text local r, g, b = hexToRGB(hex) r = clampInput(r, 0, 255) g = clampInput(g, 0, 255) b = clampInput(b, 0, 255) modifierInputs.Red.Text = r modifierInputs.Green.Text = g modifierInputs.Blue.Text = b hue, saturation, val = Color3.fromRGB(r, g, b):ToHSV() UpdateSlideFromValue(val) UpdateRingFromHSV(hue, saturation) update() end
local function updateFromSettings()
local r = math.floor(ColorpickerFunctions.Color.R * 255 + 0.5)
local g = math.floor(ColorpickerFunctions.Color.G * 255 + 0.5)
local b = math.floor(ColorpickerFunctions.Color.B * 255 + 0.5)
modifierInputs.Red.Text = r
modifierInputs.Green.Text = g
modifierInputs.Blue.Text = b
modifierInputs.Alpha.Text = isAlpha and ColorpickerFunctions.Alpha or 0
modifierInputs.Hex.Text = string.format("#%02X%02X%02X", r,g,b)
hue, saturation, val = Color3.fromRGB(r, g, b):ToHSV()
color1.BackgroundColor3 = ColorpickerFunctions.Color
color1.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
colour.BackgroundColor3 = Color3.fromRGB(r,g,b)
colour.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
UpdateSlideFromValue(val)
UpdateRingFromHSV(hue, saturation)
end
wheelRef.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then WheelDown = true UpdateRing(Mouse.X, Mouse.Y) end end)
sliderRef.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then SlideDown = true UpdateSlide(Mouse.X) end end)
sliderRef.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then SlideDown = false end end)
wheelRef.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then WheelDown = false end end)
UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then if SlideDown then UpdateSlide(Mouse.X) elseif WheelDown then UpdateRing(Mouse.X, Mouse.Y) end end end)
local function onFocusEnter(instance) local placeholder = instance.Text instance.Text = "" instance.PlaceholderText = placeholder end
modifierInputs.Hex.FocusLost:Connect(updateFromHex)
modifierInputs.Red.FocusLost:Connect(updateFromRGB)
modifierInputs.Green.FocusLost:Connect(updateFromRGB)
modifierInputs.Blue.FocusLost:Connect(updateFromRGB)
modifierInputs.Alpha.FocusLost:Connect(update)
modifierInputs.Hex.Focused:Connect(function() onFocusEnter(modifierInputs.Hex) end)
modifierInputs.Red.Focused:Connect(function() onFocusEnter(modifierInputs.Red) end)
modifierInputs.Green.Focused:Connect(function() onFocusEnter(modifierInputs.Green) end)
modifierInputs.Blue.Focused:Connect(function() onFocusEnter(modifierInputs.Blue) end)
modifierInputs.Alpha.Focused:Connect(function() onFocusEnter(modifierInputs.Alpha) end)
local function makeCanvas() local ColorPickerCanvas = Instance.new("CanvasGroup") ColorPickerCanvas.BackgroundTransparency = 1 ColorPickerCanvas.Size = UDim2.fromScale(1, 1) ColorPickerCanvas.ZIndex = 5 ColorPickerCanvas.GroupTransparency = 1 ColorPickerCanvas.Parent = base ColorPickerCanvas.Visible = false return ColorPickerCanvas end
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
if not isIn then colorPicker.Visible = false canvas.Visible = false end
colorPicker.Parent = base
canvas:Destroy()
end
local function colorpickerIn() transition(true) end
local function colorpickerOut() transition(false) end
interact.MouseButton1Click:Connect(colorpickerIn)
cancel.MouseButton1Click:Connect(colorpickerOut)
confirm.MouseButton1Click:Connect(function()
colorpickerOut()
local c = fromHSV(hue, saturation, val)
ColorpickerFunctions.Color = Color3.fromRGB(c.r * 255, c.g * 255, c.b * 255)
ColorpickerFunctions.Alpha = isAlpha and clampInput(modifierInputs.Alpha.Text, 0, 1)
color1.BackgroundColor3 = ColorpickerFunctions.Color
color1.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
colorC.BackgroundColor3 = ColorpickerFunctions.Color
colorC.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
if ColorpickerFunctions.Settings.Callback then task.spawn(function() ColorpickerFunctions.Settings.Callback(ColorpickerFunctions.Color, isAlpha and ColorpickerFunctions.Alpha) end) end
end)
updateFromSettings()
function ColorpickerFunctions:UpdateName(New) colorpickerName.Text = New end
function ColorpickerFunctions:SetVisibility(State) colorpicker.Visible = State end
function ColorpickerFunctions:SetColor(color3)
ColorpickerFunctions.Color = color3
colorC.BackgroundColor3 = color3
local r = math.floor(ColorpickerFunctions.Color.R * 255 + 0.5)
local g = math.floor(ColorpickerFunctions.Color.G * 255 + 0.5)
local b = math.floor(ColorpickerFunctions.Color.B * 255 + 0.5)
modifierInputs.Red.Text = r
modifierInputs.Green.Text = g
modifierInputs.Blue.Text = b
modifierInputs.Hex.Text = string.format("#%02X%02X%02X", r,g,b)
hue, saturation, val = Color3.fromRGB(r, g, b):ToHSV()
color1.BackgroundColor3 = ColorpickerFunctions.Color
colour.BackgroundColor3 = Color3.fromRGB(r,g,b)
UpdateSlideFromValue(val)
UpdateRingFromHSV(hue, saturation)
if ColorpickerFunctions.Settings.Callback then task.spawn(function() ColorpickerFunctions.Settings.Callback(ColorpickerFunctions.Color, isAlpha and ColorpickerFunctions.Alpha) end) end
end
function ColorpickerFunctions:SetAlpha(alpha) ColorpickerFunctions.Alpha = alpha colorC.Transparency = alpha updateFromSettings() end
if Flag then MacLib.Options[Flag] = ColorpickerFunctions end
return ColorpickerFunctions
end
function SectionFunctions:Header(Settings, Flag)
local HeaderFunctions = {Settings = Settings}
local header = Instance.new("Frame")
header.AutomaticSize = Enum.AutomaticSize.Y
header.BackgroundTransparency = 1
header.LayoutOrder = 0
header.Size = UDim2.fromScale(1, 0)
header.Parent = section
local uIPadding7 = Instance.new("UIPadding")
uIPadding7.PaddingBottom = UDim.new(0, 5)
uIPadding7.Parent = header
local headerText = Instance.new("TextLabel")
headerText.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
headerText.RichText = true
headerText.Text = HeaderFunctions.Settings.Text or HeaderFunctions.Settings.Name
headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
headerText.TextSize = 16
headerText.TextTransparency = 0.3
headerText.TextWrapped = true
headerText.TextXAlignment = Enum.TextXAlignment.Left
headerText.AutomaticSize = Enum.AutomaticSize.Y
headerText.BackgroundTransparency = 1
headerText.Size = UDim2.fromScale(1, 0)
headerText.Parent = header
function HeaderFunctions:UpdateName(New) headerText.Text = New end
function HeaderFunctions:SetVisibility(State) header.Visible = State end
if Flag then MacLib.Options[Flag] = HeaderFunctions end
return HeaderFunctions
end
function SectionFunctions:Label(Settings, Flag)
local LabelFunctions = {Settings = Settings}
local label = Instance.new("Frame")
label.AutomaticSize = Enum.AutomaticSize.Y
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, 0, 0, 38)
label.Parent = section
local labelText = Instance.new("TextLabel")
labelText.FontFace = Font.new(assets.interFont)
labelText.RichText = true
labelText.Text = LabelFunctions.Settings.Text or LabelFunctions.Settings.Name
labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
labelText.TextSize = 13
labelText.TextTransparency = 0.5
labelText.TextWrapped = true
labelText.TextXAlignment = Enum.TextXAlignment.Left
labelText.AutomaticSize = Enum.AutomaticSize.Y
labelText.BackgroundTransparency = 1
labelText.Size = UDim2.fromScale(1, 1)
labelText.Parent = label
function LabelFunctions:UpdateName(New) labelText.Text = New end
function LabelFunctions:SetVisibility(State) label.Visible = State end
if Flag then MacLib.Options[Flag] = LabelFunctions end
return LabelFunctions
end
function SectionFunctions:SubLabel(Settings, Flag)
local SubLabelFunctions = {Settings = Settings}
local subLabel = Instance.new("Frame")
subLabel.AutomaticSize = Enum.AutomaticSize.Y
subLabel.BackgroundTransparency = 1
subLabel.Size = UDim2.new(1, 0, 0, 0)
subLabel.Parent = section
local subLabelText = Instance.new("TextLabel")
subLabelText.FontFace = Font.new(assets.interFont)
subLabelText.RichText = true
subLabelText.Text = SubLabelFunctions.Settings.Text or SubLabelFunctions.Settings.Name
subLabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
subLabelText.TextSize = 12
subLabelText.TextTransparency = 0.7
subLabelText.TextWrapped = true
subLabelText.TextXAlignment = Enum.TextXAlignment.Left
subLabelText.AutomaticSize = Enum.AutomaticSize.Y
subLabelText.BackgroundTransparency = 1
subLabelText.Size = UDim2.fromScale(1, 1)
subLabelText.Parent = subLabel
function SubLabelFunctions:UpdateName(New) subLabelText.Text = New end
function SubLabelFunctions:SetVisibility(State) subLabel.Visible = State end
if Flag then MacLib.Options[Flag] = SubLabelFunctions end
return SubLabelFunctions
end
function SectionFunctions:Paragraph(Settings, Flag)
local ParagraphFunctions = {Settings = Settings}
local paragraph = Instance.new("Frame")
paragraph.AutomaticSize = Enum.AutomaticSize.Y
paragraph.BackgroundTransparency = 1
paragraph.Size = UDim2.new(1, 0, 0, 38)
paragraph.Parent = section
local paragraphHeader = Instance.new("TextLabel")
paragraphHeader.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
paragraphHeader.RichText = true
paragraphHeader.Text = ParagraphFunctions.Settings.Header
paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphHeader.TextSize = 15
paragraphHeader.TextTransparency = 0.4
paragraphHeader.TextWrapped = true
paragraphHeader.TextXAlignment = Enum.TextXAlignment.Left
paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
paragraphHeader.BackgroundTransparency = 1
paragraphHeader.Size = UDim2.fromScale(1, 0)
paragraphHeader.Parent = paragraph
local uIListLayout10 = Instance.new("UIListLayout")
uIListLayout10.Padding = UDim.new(0, 5)
uIListLayout10.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout10.Parent = paragraph
local paragraphBody = Instance.new("TextLabel")
paragraphBody.FontFace = Font.new(assets.interFont)
paragraphBody.RichText = true
paragraphBody.Text = ParagraphFunctions.Settings.Body
paragraphBody.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphBody.TextSize = 13
paragraphBody.TextTransparency = 0.5
paragraphBody.TextWrapped = true
paragraphBody.TextXAlignment = Enum.TextXAlignment.Left
paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
paragraphBody.BackgroundTransparency = 1
paragraphBody.LayoutOrder = 1
paragraphBody.Size = UDim2.fromScale(1, 0)
paragraphBody.Parent = paragraph
function ParagraphFunctions:UpdateHeader(New) paragraphHeader.Text = New end
function ParagraphFunctions:UpdateBody(New) paragraphBody.Text = New end
function ParagraphFunctions:SetVisibility(State) paragraph.Visible = State end
if Flag then MacLib.Options[Flag] = ParagraphFunctions end
return ParagraphFunctions
end
function SectionFunctions:Divider()
local DividerFunctions = {}
local divider = Instance.new("Frame")
divider.AnchorPoint = Vector2.new(0, 1)
divider.AutomaticSize = Enum.AutomaticSize.Y
divider.BackgroundTransparency = 1
divider.Position = UDim2.fromScale(0, 1)
divider.Size = UDim2.new(1, 0, 0, 1)
divider.Parent = section
local uIPadding8 = Instance.new("UIPadding")
uIPadding8.PaddingBottom = UDim.new(0, 8)
uIPadding8.PaddingTop = UDim.new(0, 8)
uIPadding8.Parent = divider
local uIListLayout11 = Instance.new("UIListLayout")
uIListLayout11.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout11.Parent = divider
local line = Instance.new("Frame")
line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
line.BackgroundTransparency = 0.9
line.Size = UDim2.new(1, 0, 0, 1)
line.Parent = divider
function DividerFunctions:Remove() divider:Destroy() end
function DividerFunctions:SetVisibility(State) divider.Visible = State end
return DividerFunctions
end
function SectionFunctions:Spacer()
local SpacerFunctions = {}
local spacer = Instance.new("Frame")
spacer.AnchorPoint = Vector2.new(0, 1)
spacer.BackgroundTransparency = 1
spacer.Position = UDim2.fromScale(0, 1)
spacer.Parent = section
function SpacerFunctions:Remove() spacer:Destroy() end
function SpacerFunctions:SetVisibility(State) spacer.Visible = State end
return SpacerFunctions
end
return SectionFunctions
end
local function SelectCurrentTab()
local easetime = 0.15
if currentTabInstance then currentTabInstance.Parent = nil end
for i, tabInfo in pairs(tabs) do
Tween(i, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {BackgroundTransparency = (i == tabSwitcher and 0.98 or 1)}):Play()
if tabInfo.tabStroke then Tween(tabInfo.tabStroke, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {Transparency = (i == tabSwitcher and 0.95 or 1)}):Play() end
if tabInfo.switcherImage then Tween(tabInfo.switcherImage, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {ImageTransparency = (i == tabSwitcher and 0.1 or 0.5)}):Play() end
if tabInfo.switcherName then Tween(tabInfo.switcherName, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {TextTransparency = (i == tabSwitcher and 0.1 or 0.5)}):Play() end
if tabInfo.selector then tabInfo.selector.Visible = false end
if tabInfo.closeSelector then tabInfo.closeSelector() end
end
tabs[tabSwitcher].tabContent.Parent = content
currentTabInstance = tabs[tabSwitcher].tabContent
currentTab.Text = Settings.Name
currentTab.Visible = (#subtabOrder == 0)
if subtabSelector then subtabSelector.Visible = (#subtabOrder > 0) end
end
tabSwitcher.MouseButton1Click:Connect(function() SelectCurrentTab() end)
function TabFunctions:Select() SelectCurrentTab() end
function TabFunctions:InsertConfigSection(Side)
local configSection = TabFunctions:Section({ Side = "Left" })
if isStudio then configSection:Label({Text = "Config system unavailable. (Environment isStudio)"}) return "Config system unavailable." end
local inputPath = nil
local selectedConfig = nil
configSection:Input({Name = "Config Name", Placeholder = "Name", AcceptedCharacters = "All", Callback = function(input) inputPath = input end})
local configSelection = configSection:Dropdown({Name = "Select Config", Multi = false, Required = false, Options = MacLib:RefreshConfigList(), Callback = function(Value) selectedConfig = Value end})
configSection:Button({Name = "Create Config", Callback = function()
if not inputPath or string.gsub(inputPath, " ", "") == "" then WindowFunctions:Notify({Title = "Interface", Description = "Config name cannot be empty."}) return end
local success, returned = MacLib:SaveConfig(inputPath)
if not success then WindowFunctions:Notify({Title = "Interface", Description = "Unable to save config, return error: " .. returned}) end
WindowFunctions:Notify({Title = "Interface", Description = string.format("Created config %q", inputPath)})
configSelection:ClearOptions()
configSelection:InsertOptions(MacLib:RefreshConfigList())
end})
configSection:Button({Name = "Load Config", Callback = function()
local success, returned = MacLib:LoadConfig(configSelection.Value)
if not success then WindowFunctions:Notify({Title = "Interface", Description = "Unable to load config, return error: " .. returned}) return end
WindowFunctions:Notify({Title = "Interface", Description = string.format("Loaded config %q", configSelection.Value)})
end})
configSection:Button({Name = "Overwrite Config", Callback = function()
local success, returned = MacLib:SaveConfig(configSelection.Value)
if not success then WindowFunctions:Notify({Title = "Interface", Description = "Unable to overwrite config, return error: " .. returned}) return end
WindowFunctions:Notify({Title = "Interface", Description = string.format("Overwrote config %q", configSelection.Value)})
end})
configSection:Button({Name = "Refresh Config List", Callback = function() configSelection:ClearOptions() configSelection:InsertOptions(MacLib:RefreshConfigList()) end})
local autoloadLabel
configSection:Button({Name = "Set as autoload", Callback = function()
local name = configSelection.Value
writefile(MacLib.Folder .. "/settings/autoload.txt", name)
autoloadLabel:UpdateName("Autoload config: " .. name)
WindowFunctions:Notify({Title = "Interface", Description = string.format("Set %q as autoload", name)})
end})
autoloadLabel = configSection:Label({Text = "Autoload config: None"})
if isfile(MacLib.Folder .. "/settings/autoload.txt") then local name = readfile(MacLib.Folder .. "/settings/autoload.txt") autoloadLabel:UpdateName("Autoload config: " .. name) end
end
tabs[tabSwitcher] = {tabContent = elements1, tabStroke = tabSwitcherUIStroke, switcherImage = tabImage, switcherName = tabSwitcherName, selector = subtabSelector, closeSelector = function() setSubTabListOpen(false) end}
return TabFunctions
end
return SectionFunctions
end
function WindowFunctions:Notify(Settings)
local NotificationFunctions = {}
local notification = Instance.new("Frame")
notification.AnchorPoint = Vector2.new(0.5, 0.5)
notification.AutomaticSize = Enum.AutomaticSize.Y
notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
notification.BorderSizePixel = 0
notification.Position = UDim2.fromScale(0.5, 0.5)
notification.Size = UDim2.fromOffset(Settings.SizeX or 250, 0)
notification.Parent = notifications
local notificationUIStroke = Instance.new("UIStroke")
notificationUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
notificationUIStroke.Color = Color3.fromRGB(255, 255, 255)
notificationUIStroke.Transparency = 0.9
notificationUIStroke.Parent = notification
local notificationUICorner = Instance.new("UICorner")
notificationUICorner.CornerRadius = UDim.new(0, 10)
notificationUICorner.Parent = notification
local notificationUIScale = Instance.new("UIScale")
notificationUIScale.Parent = notification
notificationUIScale.Scale = 0
local notificationInformation = Instance.new("Frame")
notificationInformation.AutomaticSize = Enum.AutomaticSize.Y
notificationInformation.BackgroundTransparency = 1
notificationInformation.Size = UDim2.fromScale(1, 1)
local notificationTitle = Instance.new("TextLabel")
notificationTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
notificationTitle.RichText = true
notificationTitle.Text = Settings.Title
notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationTitle.TextSize = 13
notificationTitle.TextTransparency = 0.2
notificationTitle.TextTruncate = Enum.TextTruncate.SplitWord
notificationTitle.TextXAlignment = Enum.TextXAlignment.Left
notificationTitle.AutomaticSize = Enum.AutomaticSize.XY
notificationTitle.BackgroundTransparency = 1
notificationTitle.Size = UDim2.new(1, -12, 0, 0)
local notificationTitleUIPadding = Instance.new("UIPadding")
notificationTitleUIPadding.PaddingRight = UDim.new(0, 25)
notificationTitleUIPadding.Parent = notificationTitle
notificationTitle.Parent = notificationInformation
local notificationDescription = Instance.new("TextLabel")
notificationDescription.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
notificationDescription.Text = Settings.Description
notificationDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationDescription.TextSize = 11
notificationDescription.TextTransparency = 0.5
notificationDescription.TextWrapped = true
notificationDescription.RichText = true
notificationDescription.TextXAlignment = Enum.TextXAlignment.Left
notificationDescription.AutomaticSize = Enum.AutomaticSize.XY
notificationDescription.BackgroundTransparency = 1
notificationDescription.Size = UDim2.new(1, -12, 0, 0)
local notificationDescriptionUIPadding = Instance.new("UIPadding")
notificationDescriptionUIPadding.PaddingRight = UDim.new(0, 25)
notificationDescriptionUIPadding.PaddingTop = UDim.new(0, 17)
notificationDescriptionUIPadding.Parent = notificationDescription
notificationDescription.Parent = notificationInformation
local notificationUIPadding = Instance.new("UIPadding")
notificationUIPadding.PaddingBottom = UDim.new(0, 12)
notificationUIPadding.PaddingLeft = UDim.new(0, 10)
notificationUIPadding.PaddingRight = UDim.new(0, 10)
notificationUIPadding.PaddingTop = UDim.new(0, 10)
notificationUIPadding.Parent = notificationInformation
notificationInformation.Parent = notification
local notificationControls = Instance.new("Frame")
notificationControls.AutomaticSize = Enum.AutomaticSize.Y
notificationControls.BackgroundTransparency = 1
notificationControls.Size = UDim2.fromScale(1, 1)
local interactable = Instance.new("TextButton")
interactable.FontFace = Font.new(assets.interFont)
interactable.Text = "✓"
interactable.TextColor3 = Color3.fromRGB(255, 255, 255)
interactable.TextSize = 17
interactable.TextTransparency = 0.2
interactable.AnchorPoint = Vector2.new(1, 0.5)
interactable.AutomaticSize = Enum.AutomaticSize.XY
interactable.BackgroundTransparency = 1
interactable.LayoutOrder = 1
interactable.Position = UDim2.fromScale(1, 0.5)
interactable.Parent = notificationControls
local uIPadding9 = Instance.new("UIPadding")
uIPadding9.PaddingBottom = UDim.new(0, 6)
uIPadding9.PaddingRight = UDim.new(0, 13)
uIPadding9.PaddingTop = UDim.new(0, 6)
uIPadding9.Parent = notificationControls
notificationControls.Parent = notification
local tweens = {
In = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = Settings.Scale or baseUIScale.Scale}),
Out = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 0})
}
local styles = {None = function() interactable:Destroy() end, Confirm = function() interactable.Text = "✓" end, Cancel = function() interactable.Text = "✗" end}
local style = styles[Settings.Style] or function() interactable:Destroy() end
style()
if interactable then interactable.MouseButton1Click:Connect(function() NotificationFunctions:Cancel() if Settings.Callback then task.spawn(Settings.Callback) end end) end
local AnimateNotification = task.spawn(function()
tweens.In:Play()
Settings.Lifetime = Settings.Lifetime or 3
if Settings.Lifetime ~= 0 then task.wait(Settings.Lifetime) local out = tweens.Out out:Play() out.Completed:Wait() notification:Destroy() end
end)
function NotificationFunctions:UpdateTitle(New) notificationTitle.Text = New end
function NotificationFunctions:UpdateDescription(New) notificationDescription.Text = New end
function NotificationFunctions:Resize(X) notification.Size = UDim2.fromOffset(X or 250, 0) end
function NotificationFunctions:Cancel() task.cancel(AnimateNotification) local out = tweens.Out out:Play() out.Completed:Wait() notification:Destroy() end
return NotificationFunctions
end
function WindowFunctions:Dialog(Settings)
local DialogFunctions = {}
local dialogCanvas = Instance.new("CanvasGroup")
dialogCanvas.BackgroundTransparency = 1
dialogCanvas.Size = UDim2.fromScale(1, 1)
dialogCanvas.GroupTransparency = 1
dialogCanvas.Parent = base
local dialog = Instance.new("Frame")
dialog.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dialog.BackgroundTransparency = 0.5
dialog.Size = UDim2.fromScale(1, 1)
local dialogUICorner = Instance.new("UICorner")
dialogUICorner.CornerRadius = UDim.new(0, 10)
dialogUICorner.Parent = dialog
local prompt = Instance.new("Frame")
prompt.AnchorPoint = Vector2.new(0.5, 0.5)
prompt.AutomaticSize = Enum.AutomaticSize.Y
prompt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
prompt.Position = UDim2.fromScale(0.5, 0.5)
prompt.Size = UDim2.fromOffset(280, 0)
local promptUIScale = Instance.new("UIScale")
promptUIScale.Parent = prompt
promptUIScale.Scale = 0.95
local promptUIStroke = Instance.new("UIStroke")
promptUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
promptUIStroke.Color = Color3.fromRGB(255, 255, 255)
promptUIStroke.Transparency = 0.9
promptUIStroke.Parent = prompt
local promptUICorner = Instance.new("UICorner")
promptUICorner.CornerRadius = UDim.new(0, 10)
promptUICorner.Parent = prompt
local promptUIPadding = Instance.new("UIPadding")
promptUIPadding.PaddingBottom = UDim.new(0, 20)
promptUIPadding.PaddingLeft = UDim.new(0, 20)
promptUIPadding.PaddingRight = UDim.new(0, 20)
promptUIPadding.PaddingTop = UDim.new(0, 20)
promptUIPadding.Parent = prompt
local paragraph = Instance.new("Frame")
paragraph.AutomaticSize = Enum.AutomaticSize.Y
paragraph.BackgroundTransparency = 1
paragraph.Size = UDim2.new(1, 0, 0, 38)
local paragraphHeader = Instance.new("TextLabel")
paragraphHeader.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
paragraphHeader.RichText = true
paragraphHeader.Text = Settings.Title
paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphHeader.TextSize = 18
paragraphHeader.TextTransparency = 0.4
paragraphHeader.TextWrapped = true
paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
paragraphHeader.BackgroundTransparency = 1
paragraphHeader.Size = UDim2.fromScale(1, 0)
paragraphHeader.Parent = paragraph
local uIListLayout12 = Instance.new("UIListLayout")
uIListLayout12.Padding = UDim.new(0, 15)
uIListLayout12.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout12.Parent = paragraph
local paragraphBody = Instance.new("TextLabel")
paragraphBody.FontFace = Font.new(assets.interFont)
paragraphBody.RichText = true
paragraphBody.Text = Settings.Description
paragraphBody.TextColor3 = Color3.fromRGB(255, 255, 255)
paragraphBody.TextSize = 14
paragraphBody.TextTransparency = 0.5
paragraphBody.TextWrapped = true
paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
paragraphBody.BackgroundTransparency = 1
paragraphBody.LayoutOrder = 1
paragraphBody.Size = UDim2.fromScale(1, 0)
paragraphBody.Parent = paragraph
paragraph.Parent = prompt
local interactions = Instance.new("Frame")
interactions.AutomaticSize = Enum.AutomaticSize.Y
interactions.BackgroundTransparency = 1
interactions.LayoutOrder = 1
interactions.Size = UDim2.fromScale(1, 0)
local uIListLayout13 = Instance.new("UIListLayout")
uIListLayout13.Padding = UDim.new(0, 10)
uIListLayout13.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout13.Parent = interactions
local uIPadding10 = Instance.new("UIPadding")
uIPadding10.PaddingTop = UDim.new(0, 20)
uIPadding10.Parent = interactions
interactions.Parent = prompt
local uIListLayout14 = Instance.new("UIListLayout")
uIListLayout14.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout14.Parent = prompt
prompt.Parent = dialog
dialog.Parent = dialogCanvas
local canvasIn = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 0 })
local canvasOut = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 1 })
local scaleIn = Tween(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 1 })
local scaleOut = Tween(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 0.95 })
local function dialogIn() canvasIn:Play() scaleIn:Play() canvasIn.Completed:Wait() dialog.Parent = base end
local function dialogOut() if not dialog.Parent then return end dialog.Parent = dialogCanvas canvasOut:Play() scaleOut:Play() canvasOut.Completed:Wait() dialogCanvas:Destroy() end
for _, v in pairs(Settings.Buttons) do
local button = Instance.new("TextButton")
button.FontFace = Font.new(assets.interFont)
button.Text = v.Name
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 15
button.TextTransparency = 0.5
button.AutoButtonColor = false
button.AutomaticSize = Enum.AutomaticSize.Y
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.Size = UDim2.fromScale(1, 0)
local uIPadding11 = Instance.new("UIPadding")
uIPadding11.PaddingBottom = UDim.new(0, 9)
uIPadding11.PaddingLeft = UDim.new(0, 10)
uIPadding11.PaddingRight = UDim.new(0, 10)
uIPadding11.PaddingTop = UDim.new(0, 9)
uIPadding11.Parent = button
local baseUICorner1 = Instance.new("UICorner")
baseUICorner1.CornerRadius = UDim.new(0, 10)
baseUICorner1.Parent = button
button.Parent = interactions
local TweenSettings = {DefaultTransparency = 0, DefaultTransparency2 = 0.5, HoverTransparency = 0.3, HoverTransparency2 = 0.6, EasingStyle = Enum.EasingStyle.Sine}
local function ChangeState(State) Tween(button, TweenInfo.new(0.2, TweenSettings.EasingStyle), {BackgroundTransparency = State == "Idle" and TweenSettings.DefaultTransparency or TweenSettings.HoverTransparency, TextTransparency = State == "Idle" and TweenSettings.DefaultTransparency2 or TweenSettings.HoverTransparency2}):Play() end
button.MouseButton1Click:Connect(function() if dialogCanvas.GroupTransparency ~= 0 then return end if v.Callback then v.Callback() end dialogOut() end)
button.MouseEnter:Connect(function() ChangeState("Hover") end)
button.MouseLeave:Connect(function() ChangeState("Idle") end)
end
dialogIn()
function DialogFunctions:UpdateTitle(New) paragraphHeader.Text = New end
function DialogFunctions:UpdateDescription(New) paragraphBody.Text = New end
function DialogFunctions:Cancel() dialogOut() end
return DialogFunctions
end
function WindowFunctions:SetNotificationsState(State) notifications.Visible = State end
function WindowFunctions:GetNotificationsState() return notifications.Visible end
function WindowFunctions:SetState(State) windowState = State base.Visible = State end
function WindowFunctions:GetState() return windowState end
local onUnloadCallback
function WindowFunctions:Unload() if onUnloadCallback then onUnloadCallback() end macLib:Destroy() unloaded = true end
function WindowFunctions.onUnloaded(callback) onUnloadCallback = callback end
local MenuKeybind = Settings.Keybind or Enum.KeyCode.RightControl
local function ToggleMenu()
local state = not WindowFunctions:GetState()
WindowFunctions:SetState(state)
WindowFunctions:Notify({Title = Settings.Title, Description = (state and "Maximized " or "Minimized ") .. "the menu. Use " .. tostring(MenuKeybind.Name) .. " to toggle it.", Lifetime = 5})
end
UserInputService.InputEnded:Connect(function(inp, gpe) if gpe then return end if inp.KeyCode == MenuKeybind then ToggleMenu() end end)
minimize.MouseButton1Click:Connect(ToggleMenu)
exit.MouseButton1Click:Connect(function() WindowFunctions:Dialog({Title = Settings.Title, Description = "Are you sure you want to exit the menu? You will lose any unsaved configurations.", Buttons = {{Name = "Confirm", Callback = function() WindowFunctions:Unload() end}, {Name = "Cancel"}}}) end)
function WindowFunctions:SetKeybind(Keycode) MenuKeybind = Keycode end
function WindowFunctions:SetAcrylicBlurState(State) acrylicBlur = State base.BackgroundTransparency = State and 0.05 or 0 end
function WindowFunctions:GetAcrylicBlurState() return acrylicBlur end
local function _SetUserInfoState(State)
if State then headshot.Image = (isReady and headshotImage) or "rbxassetid://0" username.Text = "@" .. LocalPlayer.Name displayName.Text = LocalPlayer.DisplayName
else headshot.Image = assets.userInfoBlurred local nameLength = #LocalPlayer.Name local displayNameLength = #LocalPlayer.DisplayName username.Text = "@" .. string.rep(".", nameLength) displayName.Text = string.rep(".", displayNameLength) end
end
local showUserInfo = Settings.ShowUserInfo ~= nil and Settings.ShowUserInfo or true
_SetUserInfoState(showUserInfo)
function WindowFunctions:SetUserInfoState(State) _SetUserInfoState(State) end
function WindowFunctions:GetUserInfoState() return showUserInfo end
function WindowFunctions:SetSize(Size) base.Size = parseSize(Size, base.Size) updateContentWidth() end
function WindowFunctions:GetSize() return base.Size end
function WindowFunctions:SetScale(Scale) if isMobile then baseUIScale.Scale = tonumber(Scale) or baseUIScale.Scale end end
function WindowFunctions:GetScale() return baseUIScale.Scale end
function WindowFunctions:GetPlatform() return isMobile and "Mobile" or "PC" end
local ClassParser = {
["Toggle"] = {Save = function(Flag, data) return {type = "Toggle", flag = Flag, state = data.State or false} end, Load = function(Flag, data) if MacLib.Options[Flag] and data.state then MacLib.Options[Flag]:UpdateState(data.state) end end},
["Slider"] = {Save = function(Flag, data) return {type = "Slider", flag = Flag, value = (data.Value and tostring(data.Value)) or false} end, Load = function(Flag, data) if MacLib.Options[Flag] and data.value then MacLib.Options[Flag]:UpdateValue(data.value) end end},
["Input"] = {Save = function(Flag, data) return {type = "Input", flag = Flag, text = data.Text} end, Load = function(Flag, data) if MacLib.Options[Flag] and data.text and type(data.text) == "string" then MacLib.Options[Flag]:UpdateText(data.text) end end},
["Keybind"] = {Save = function(Flag, data) return {type = "Keybind", flag = Flag, bind = (typeof(data.Bind) == "EnumItem" and data.Bind.Name) or nil} end, Load = function(Flag, data) if MacLib.Options[Flag] and data.bind then MacLib.Options[Flag]:Bind(Enum.KeyCode[data.bind]) end end},
["Dropdown"] = {Save = function(Flag, data) return {type = "Dropdown", flag = Flag, value = data.Value} end, Load = function(Flag, data) if MacLib.Options[Flag] and data.value then MacLib.Options[Flag]:UpdateSelection(data.value) end end},
["Colorpicker"] = {Save = function(Flag, data) local function Color3ToHex(color) return string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)) end return {type = "Colorpicker", flag = Flag, color = Color3ToHex(data.Color) or nil, alpha = data.Alpha} end, Load = function(Flag, data) local function HexToColor3(hex) local r = tonumber(hex:sub(2, 3), 16) / 255 local g = tonumber(hex:sub(4, 5), 16) / 255 local b = tonumber(hex:sub(6, 7), 16) / 255 return Color3.new(r, g, b) end if MacLib.Options[Flag] and data.color then MacLib.Options[Flag]:SetColor(HexToColor3(data.color)) if data.alpha then MacLib.Options[Flag]:SetAlpha(data.alpha) end end end}
}
local function BuildFolderTree()
if isStudio or not (isfolder and makefolder) then return "Config system unavailable." end
local paths = {MacLib.Folder, MacLib.Folder .. "/settings"}
for i = 1, #paths do local str = paths[i] if not isfolder(str) then makefolder(str) end end
end
function MacLib:LoadAutoLoadConfig()
if isStudio or not (isfile and readfile) then return "Config system unavailable." end
if isfile(MacLib.Folder .. "/settings/autoload.txt") then
local name = readfile(MacLib.Folder .. "/settings/autoload.txt")
local suc, err = MacLib:LoadConfig(name)
if not suc then WindowFunctions:Notify({Title = "Interface", Description = "Error loading autoload config: " .. err}) end
WindowFunctions:Notify({Title = "Interface", Description = string.format("Autoloaded config: %q", name)})
end
end
function MacLib:SetFolder(Folder) if isStudio then return "Config system unavailable." end MacLib.Folder = Folder; BuildFolderTree() end
function MacLib:SaveConfig(Path)
if isStudio or not writefile then return "Config system unavailable." end
if (not Path) then return false, "Please select a config file." end
local fullPath = MacLib.Folder .. "/settings/" .. Path .. ".json"
local data = {objects = {}}
for flag, option in next, MacLib.Options do if not ClassParser[option.Class] then continue end if option.IgnoreConfig then continue end table.insert(data.objects, ClassParser[option.Class].Save(flag, option)) end
local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
if not success then return false, "Unable to encode into JSON data" end
writefile(fullPath, encoded)
return true
end
function MacLib:LoadConfig(Path)
if isStudio or not (isfile and readfile) then return "Config system unavailable." end
if (not Path) then return false, "Please select a config file." end
local file = MacLib.Folder .. "/settings/" .. Path .. ".json"
if not isfile(file) then return false, "Invalid file" end
local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
if not success then return false, "Unable to decode JSON data." end
for _, option in next, decoded.objects do if ClassParser[option.type] then task.spawn(function() ClassParser[option.type].Load(option.flag, option) end) end end
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
while char ~= "/" and char ~= "\\" and char ~= "" do pos = pos - 1 char = file:sub(pos, pos) end
if char == "/" or char == "\\" then local name = file:sub(pos + 1, start - 1) if name ~= "options" then table.insert(out, name) end end
end
end
return out
end
macLib.Enabled = false
local assetList = {}
for _, assetId in pairs(assets) do table.insert(assetList, assetId) end
ContentProvider:PreloadAsync(assetList)
macLib.Enabled = true
windowState = true
return WindowFunctions
end
return MacLib
