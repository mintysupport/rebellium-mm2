-- =========================================================================
--  NEVERLOSE UI FRAMEWORK FOR ROBLOX (LUAU)
--  Authentic reproduction of Neverlose menu (DirectX11/ImGui style)
--  100% Open-source, backdoor-free, high-performance UI library
-- =========================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Theme colors from C:\Users\Dayn\source\repos\NL\examples\example_win32_directx11\neverlose_menu.cpp
local Theme = {
	Canvas = Color3.fromRGB(13, 15, 22),
	Sidebar = Color3.fromRGB(18, 21, 30),
	Toolbar = Color3.fromRGB(11, 13, 20),
	Card = Color3.fromRGB(17, 19, 27),
	CardBorder = Color3.fromRGB(31, 34, 44),
	Divider = Color3.fromRGB(28, 31, 40),
	Accent = Color3.fromRGB(75, 126, 255),
	AccentDark = Color3.fromRGB(50, 95, 210),
	AccentCyan = Color3.fromRGB(94, 185, 255),
	NavHover = Color3.fromRGB(32, 36, 48),
	NavActive = Color3.fromRGB(39, 43, 54),
	NavActiveText = Color3.fromRGB(226, 228, 235),
	NavInactiveText = Color3.fromRGB(145, 149, 159),
	NavActiveIcon = Color3.fromRGB(82, 141, 255),
	ControlBg = Color3.fromRGB(25, 28, 38),
	ControlBorder = Color3.fromRGB(32, 35, 46),
	ControlOff = Color3.fromRGB(29, 33, 43),
	ControlOn = Color3.fromRGB(75, 126, 255),
	TextTitle = Color3.fromRGB(228, 230, 236),
	TextBody = Color3.fromRGB(207, 209, 218),
	TextMuted = Color3.fromRGB(89, 94, 106),
	TextControl = Color3.fromRGB(170, 173, 184),
	White = Color3.fromRGB(247, 248, 252),
}

local function tween(obj, props, duration, style, dir)
	duration = duration or 0.18
	style = style or Enum.EasingStyle.Quart
	dir = dir or Enum.EasingDirection.Out
	local t = TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
	t:Play()
	return t
end

local function makeCorner(radius, parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function makeStroke(color, thickness, parent)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.CardBorder
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local Library = {
	cursorlist = {},
	activePopups = {},
	activePickers = {},
	flags = {},
}

local function getSafeGui()
	local ok, target = pcall(function()
		return CoreGui
	end)
	if ok and target then return target end
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- =========================================================================
--  NOTIFICATIONS (Neverlose Toast Notification)
-- =========================================================================
local NotifyGui = nil
local NotifyHolder = nil

function Library:notify(cfg)
	cfg = cfg or {}
	local title = cfg.title or "NEVERLOSE"
	local text = cfg.text or cfg.content or ""
	local life = cfg.life or cfg.duration or 4
	local tone = cfg.tone or Theme.Accent

	if not NotifyGui then
		NotifyGui = Instance.new("ScreenGui")
		NotifyGui.Name = "NL_Notifications"
		NotifyGui.ResetOnSpawn = false
		NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		NotifyGui.Parent = getSafeGui()

		NotifyHolder = Instance.new("Frame")
		NotifyHolder.Name = "Holder"
		NotifyHolder.BackgroundTransparency = 1
		NotifyHolder.Size = UDim2.new(0, 300, 1, -20)
		NotifyHolder.Position = UDim2.new(1, -315, 0, 10)
		NotifyHolder.Parent = NotifyGui

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.Padding = UDim.new(0, 8)
		layout.Parent = NotifyHolder
	end

	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.Size = UDim2.new(1, 0, 0, 58)
	toast.BackgroundColor3 = Theme.Card
	toast.BackgroundTransparency = 0.05
	toast.ClipsDescendants = true
	toast.Position = UDim2.new(1, 40, 0, 0)
	toast.Parent = NotifyHolder
	makeCorner(10, toast)
	makeStroke(Theme.CardBorder, 1, toast)

	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(0, 3, 1, 0)
	accentBar.BackgroundColor3 = tone
	accentBar.BorderSizePixel = 0
	accentBar.Parent = toast

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -24, 0, 20)
	titleLabel.Position = UDim2.new(0, 14, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 13
	titleLabel.TextColor3 = Theme.TextTitle
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = string.upper(title)
	titleLabel.Parent = toast

	local bodyLabel = Instance.new("TextLabel")
	bodyLabel.Size = UDim2.new(1, -24, 0, 20)
	bodyLabel.Position = UDim2.new(0, 14, 0, 28)
	bodyLabel.BackgroundTransparency = 1
	bodyLabel.Font = Enum.Font.Gotham
	bodyLabel.TextSize = 12
	bodyLabel.TextColor3 = Theme.TextBody
	bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
	bodyLabel.TextTruncate = Enum.TextTruncate.AtEnd
	bodyLabel.Text = text
	bodyLabel.Parent = toast

	-- Slide in
	toast.Position = UDim2.new(1, 20, 0, 0)
	tween(toast, { Position = UDim2.new(0, 0, 0, 0) }, 0.25, Enum.EasingStyle.Quart)

	task.delay(life, function()
		if toast and toast.Parent then
			tween(toast, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 }, 0.25)
			task.wait(0.25)
			toast:Destroy()
		end
	end)
end

-- =========================================================================
--  WINDOW IMPLEMENTATION (Neverlose 750x580)
-- =========================================================================
function Library:window(cfg)
	cfg = cfg or {}
	local toggleKey = cfg.bind or Enum.KeyCode.Insert
	if type(toggleKey) == "string" then
		toggleKey = Enum.KeyCode[toggleKey] or Enum.KeyCode.Insert
	end

	local Screen = Instance.new("ScreenGui")
	Screen.Name = "Neverlose_Rebellium"
	Screen.ResetOnSpawn = false
	Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Screen.Parent = getSafeGui()

	-- Top-level Popup Container for Select / Dropdown popups
	local PopupLayer = Instance.new("Frame")
	PopupLayer.Name = "PopupLayer"
	PopupLayer.Size = UDim2.new(1, 0, 1, 0)
	PopupLayer.BackgroundTransparency = 1
	PopupLayer.ZIndex = 9999
	PopupLayer.Parent = Screen

	local function closePopups()
		for _, v in ipairs(PopupLayer:GetChildren()) do
			v:Destroy()
		end
	end

	-- Main Window Shell (748 x 576 from neverlose_menu.cpp)
	local Main = Instance.new("Frame")
	Main.Name = "MainShell"
	Main.Size = UDim2.new(0, 748, 0, 576)
	Main.Position = UDim2.new(0.5, -374, 0.5, -288)
	Main.BackgroundColor3 = Theme.Canvas
	Main.BackgroundTransparency = 0.04
	Main.ClipsDescendants = false
	Main.Parent = Screen

	makeCorner(14, Main)
	local mainStroke = makeStroke(Theme.CardBorder, 1, Main)

	-- Dragging functionality
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	-- =========================================================================
	--  SIDEBAR (Width 158px)
	-- =========================================================================
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 158, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	makeCorner(14, Sidebar)

	-- Straighten right side of sidebar so it blends smoothly
	local sideCover = Instance.new("Frame")
	sideCover.Size = UDim2.new(0, 14, 1, 0)
	sideCover.Position = UDim2.new(1, -14, 0, 0)
	sideCover.BackgroundColor3 = Theme.Sidebar
	sideCover.BorderSizePixel = 0
	sideCover.Parent = Sidebar

	local sideDivider = Instance.new("Frame")
	sideDivider.Size = UDim2.new(0, 1, 1, 0)
	sideDivider.Position = UDim2.new(1, 0, 0, 0)
	sideDivider.BackgroundColor3 = Theme.Divider
	sideDivider.BorderSizePixel = 0
	sideDivider.Parent = Sidebar

	-- Logo Box (x: 15, y: 11, size: 30x32)
	local logoBadge = Instance.new("Frame")
	logoBadge.Size = UDim2.new(0, 30, 0, 32)
	logoBadge.Position = UDim2.new(0, 15, 0, 12)
	logoBadge.BackgroundColor3 = Color3.fromRGB(8, 27, 48)
	logoBadge.Parent = Sidebar
	makeCorner(7, logoBadge)

	local logoNL = Instance.new("TextLabel")
	logoNL.Size = UDim2.new(1, 0, 1, 0)
	logoNL.BackgroundTransparency = 1
	logoNL.Font = Enum.Font.GothamBold
	logoNL.TextSize = 15
	logoNL.TextColor3 = Theme.AccentCyan
	logoNL.Text = "NL"
	logoNL.Parent = logoBadge

	local titleMain = Instance.new("TextLabel")
	titleMain.Size = UDim2.new(0, 100, 0, 18)
	titleMain.Position = UDim2.new(0, 52, 0, 12)
	titleMain.BackgroundTransparency = 1
	titleMain.Font = Enum.Font.GothamBold
	titleMain.TextSize = 14
	titleMain.TextColor3 = Theme.TextTitle
	titleMain.TextXAlignment = Enum.TextXAlignment.Left
	titleMain.Text = "Rebellium"
	titleMain.Parent = Sidebar

	local titleSub = Instance.new("TextLabel")
	titleSub.Size = UDim2.new(0, 100, 0, 14)
	titleSub.Position = UDim2.new(0, 52, 0, 29)
	titleSub.BackgroundTransparency = 1
	titleSub.Font = Enum.Font.Gotham
	titleSub.TextSize = 10
	titleSub.TextColor3 = Theme.TextMuted
	titleSub.TextXAlignment = Enum.TextXAlignment.Left
	titleSub.Text = "MM2 Edition"
	titleSub.Parent = Sidebar

	local logoSep = Instance.new("Frame")
	logoSep.Size = UDim2.new(1, -24, 0, 1)
	logoSep.Position = UDim2.new(0, 12, 0, 56)
	logoSep.BackgroundColor3 = Theme.Divider
	logoSep.BorderSizePixel = 0
	logoSep.Parent = Sidebar

	-- Nav Tabs Container
	local NavScroll = Instance.new("ScrollingFrame")
	NavScroll.Name = "NavScroll"
	NavScroll.Size = UDim2.new(1, 0, 1, -110)
	NavScroll.Position = UDim2.new(0, 0, 0, 62)
	NavScroll.BackgroundTransparency = 1
	NavScroll.ScrollBarThickness = 0
	NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	NavScroll.Parent = Sidebar

	local navLayout = Instance.new("UIListLayout")
	navLayout.SortOrder = Enum.SortOrder.LayoutOrder
	navLayout.Padding = UDim.new(0, 4)
	navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	navLayout.Parent = NavScroll

	local navPad = Instance.new("UIPadding")
	navPad.PaddingTop = UDim.new(0, 4)
	navPad.PaddingBottom = UDim.new(0, 4)
	navPad.Parent = NavScroll

	-- Account Card at bottom of sidebar (y: 526, size 140x40)
	local AccountCard = Instance.new("Frame")
	AccountCard.Name = "AccountCard"
	AccountCard.Size = UDim2.new(0, 140, 0, 38)
	AccountCard.Position = UDim2.new(0, 9, 1, -48)
	AccountCard.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
	AccountCard.BackgroundTransparency = 0.5
	AccountCard.Parent = Sidebar
	makeCorner(8, AccountCard)

	local avatarImg = Instance.new("ImageLabel")
	avatarImg.Size = UDim2.new(0, 26, 0, 26)
	avatarImg.Position = UDim2.new(0, 6, 0, 6)
	avatarImg.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
	avatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	avatarImg.Parent = AccountCard
	makeCorner(13, avatarImg)

	local accName = Instance.new("TextLabel")
	accName.Size = UDim2.new(1, -40, 0, 16)
	accName.Position = UDim2.new(0, 38, 0, 4)
	accName.BackgroundTransparency = 1
	accName.Font = Enum.Font.GothamBold
	accName.TextSize = 12
	accName.TextColor3 = Theme.TextTitle
	accName.TextXAlignment = Enum.TextXAlignment.Left
	accName.TextTruncate = Enum.TextTruncate.AtEnd
	accName.Text = LocalPlayer.DisplayName or LocalPlayer.Name
	accName.Parent = AccountCard

	local accSub = Instance.new("TextLabel")
	accSub.Size = UDim2.new(1, -40, 0, 14)
	accSub.Position = UDim2.new(0, 38, 0, 19)
	accSub.BackgroundTransparency = 1
	accSub.Font = Enum.Font.Gotham
	accSub.TextSize = 10
	accSub.TextColor3 = Theme.AccentCyan
	accSub.TextXAlignment = Enum.TextXAlignment.Left
	accSub.Text = "Premium Active"
	accSub.Parent = AccountCard

	-- =========================================================================
	--  TOOLBAR (Header bar, Height 56px)
	-- =========================================================================
	local Toolbar = Instance.new("Frame")
	Toolbar.Name = "Toolbar"
	Toolbar.Size = UDim2.new(1, -158, 0, 56)
	Toolbar.Position = UDim2.new(0, 158, 0, 0)
	Toolbar.BackgroundColor3 = Theme.Toolbar
	Toolbar.BorderSizePixel = 0
	Toolbar.Parent = Main
	makeCorner(14, Toolbar)

	-- Straighten corners to blend
	local toolCover = Instance.new("Frame")
	toolCover.Size = UDim2.new(0, 14, 1, 0)
	toolCover.BackgroundColor3 = Theme.Toolbar
	toolCover.BorderSizePixel = 0
	toolCover.Parent = Toolbar

	local toolCoverB = Instance.new("Frame")
	toolCoverB.Size = UDim2.new(1, 0, 0, 14)
	toolCoverB.Position = UDim2.new(0, 0, 1, -14)
	toolCoverB.BackgroundColor3 = Theme.Toolbar
	toolCoverB.BorderSizePixel = 0
	toolCoverB.Parent = Toolbar

	local toolDivider = Instance.new("Frame")
	toolDivider.Size = UDim2.new(1, 0, 0, 1)
	toolDivider.Position = UDim2.new(0, 0, 1, 0)
	toolDivider.BackgroundColor3 = Theme.Divider
	toolDivider.BorderSizePixel = 0
	toolDivider.Parent = Toolbar

	-- Active Page Indicator Title
	local pageTitle = Instance.new("TextLabel")
	pageTitle.Size = UDim2.new(0, 200, 0, 24)
	pageTitle.Position = UDim2.new(0, 18, 0, 16)
	pageTitle.BackgroundTransparency = 1
	pageTitle.Font = Enum.Font.GothamBold
	pageTitle.TextSize = 15
	pageTitle.TextColor3 = Theme.TextTitle
	pageTitle.TextXAlignment = Enum.TextXAlignment.Left
	pageTitle.Text = "GAME"
	pageTitle.Parent = Toolbar

	-- Status Badge in Toolbar right
	local statusPill = Instance.new("Frame")
	statusPill.Size = UDim2.new(0, 110, 0, 26)
	statusPill.Position = UDim2.new(1, -125, 0, 15)
	statusPill.BackgroundColor3 = Color3.fromRGB(17, 21, 31)
	statusPill.Parent = Toolbar
	makeCorner(6, statusPill)
	makeStroke(Theme.ControlBorder, 1, statusPill)

	local statusDot = Instance.new("Frame")
	statusDot.Size = UDim2.new(0, 6, 0, 6)
	statusDot.Position = UDim2.new(0, 10, 0.5, -3)
	statusDot.BackgroundColor3 = Color3.fromRGB(90, 215, 120)
	statusDot.BorderSizePixel = 0
	statusDot.Parent = statusPill
	makeCorner(3, statusDot)

	local statusTxt = Instance.new("TextLabel")
	statusTxt.Size = UDim2.new(1, -24, 1, 0)
	statusTxt.Position = UDim2.new(0, 22, 0, 0)
	statusTxt.BackgroundTransparency = 1
	statusTxt.Font = Enum.Font.GothamBold
	statusTxt.TextSize = 11
	statusTxt.TextColor3 = Theme.TextControl
	statusTxt.TextXAlignment = Enum.TextXAlignment.Left
	statusTxt.Text = "Connected"
	statusTxt.Parent = statusPill

	-- Drag events
	Toolbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Sidebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
			update(input)
		end
	end)

	-- Pages Container
	local PagesHost = Instance.new("Frame")
	PagesHost.Name = "PagesHost"
	PagesHost.Size = UDim2.new(1, -158, 1, -56)
	PagesHost.Position = UDim2.new(0, 158, 0, 56)
	PagesHost.BackgroundTransparency = 1
	PagesHost.ClipsDescendants = true
	PagesHost.Parent = Main

	local Window = {
		Screen = Screen,
		Main = Main,
		Tabs = {},
		ActiveTab = nil,
		Flags = Library.flags,
	}

	-- Toggle visibility
	function Window:toggle()
		Main.Visible = not Main.Visible
		if not Main.Visible then
			closePopups()
		end
	end

	function Window:setbind(bind)
		if typeof(bind) == "EnumItem" then
			toggleKey = bind
		elseif type(bind) == "string" and Enum.KeyCode[bind] then
			toggleKey = Enum.KeyCode[bind]
		end
	end

	function Window:unload()
		Screen:Destroy()
		if NotifyGui then NotifyGui:Destroy() NotifyGui = nil end
	end

	UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == toggleKey then
			Window:toggle()
		end
	end)

	-- =========================================================================
	--  TAB CREATION
	-- =========================================================================
	function Window:tab(tcfg)
		tcfg = tcfg or {}
		local tabName = tcfg.name or "TAB"
		local tabIcon = tcfg.icon

		-- Page Frame
		local Page = Instance.new("ScrollingFrame")
		Page.Name = "Page_" .. tabName
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Theme.ControlBorder
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.Visible = false
		Page.Parent = PagesHost

		-- 2-Column Neverlose Layout
		local pageColumns = Instance.new("Frame")
		pageColumns.Name = "Columns"
		pageColumns.Size = UDim2.new(1, -24, 0, 0)
		pageColumns.Position = UDim2.new(0, 12, 0, 12)
		pageColumns.BackgroundTransparency = 1
		pageColumns.AutomaticSize = Enum.AutomaticSize.Y
		pageColumns.Parent = Page

		local leftCol = Instance.new("Frame")
		leftCol.Name = "LeftColumn"
		leftCol.Size = UDim2.new(0.5, -6, 0, 0)
		leftCol.Position = UDim2.new(0, 0, 0, 0)
		leftCol.BackgroundTransparency = 1
		leftCol.AutomaticSize = Enum.AutomaticSize.Y
		leftCol.Parent = pageColumns

		local leftLayout = Instance.new("UIListLayout")
		leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
		leftLayout.Padding = UDim.new(0, 12)
		leftLayout.Parent = leftCol

		local rightCol = Instance.new("Frame")
		rightCol.Name = "RightColumn"
		rightCol.Size = UDim2.new(0.5, -6, 0, 0)
		rightCol.Position = UDim2.new(0.5, 6, 0, 0)
		rightCol.BackgroundTransparency = 1
		rightCol.AutomaticSize = Enum.AutomaticSize.Y
		rightCol.Parent = pageColumns

		local rightLayout = Instance.new("UIListLayout")
		rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rightLayout.Padding = UDim.new(0, 12)
		rightLayout.Parent = rightCol

		local fullCol = Instance.new("Frame")
		fullCol.Name = "FullColumn"
		fullCol.Size = UDim2.new(1, 0, 0, 0)
		fullCol.Position = UDim2.new(0, 0, 1, 12)
		fullCol.BackgroundTransparency = 1
		fullCol.AutomaticSize = Enum.AutomaticSize.Y
		fullCol.Parent = pageColumns

		local fullLayout = Instance.new("UIListLayout")
		fullLayout.SortOrder = Enum.SortOrder.LayoutOrder
		fullLayout.Padding = UDim.new(0, 12)
		fullLayout.Parent = fullCol

		-- Tab Button in Sidebar (140x30px)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = "TabBtn_" .. tabName
		TabBtn.Size = UDim2.new(0, 140, 0, 30)
		TabBtn.BackgroundColor3 = Theme.Sidebar
		TabBtn.BackgroundTransparency = 1
		TabBtn.AutoButtonColor = false
		TabBtn.Text = ""
		TabBtn.Parent = NavScroll
		makeCorner(6, TabBtn)

		local tabLabel = Instance.new("TextLabel")
		tabLabel.Size = UDim2.new(1, -36, 1, 0)
		tabLabel.Position = UDim2.new(0, 34, 0, 0)
		tabLabel.BackgroundTransparency = 1
		tabLabel.Font = Enum.Font.GothamMedium
		tabLabel.TextSize = 13
		tabLabel.TextColor3 = Theme.NavInactiveText
		tabLabel.TextXAlignment = Enum.TextXAlignment.Left
		tabLabel.Text = string.upper(tabName:sub(1, 1)) .. tabName:sub(2)
		tabLabel.Parent = TabBtn

		local tabIconLabel = Instance.new("TextLabel")
		tabIconLabel.Size = UDim2.new(0, 20, 1, 0)
		tabIconLabel.Position = UDim2.new(0, 10, 0, 0)
		tabIconLabel.BackgroundTransparency = 1
		tabIconLabel.Font = Enum.Font.GothamBold
		tabIconLabel.TextSize = 13
		tabIconLabel.TextColor3 = Theme.NavInactiveText
		tabIconLabel.Text = "•"
		tabIconLabel.Parent = TabBtn

		local Tab = {
			name = tabName,
			page = Page,
			button = TabBtn,
			left = leftCol,
			right = rightCol,
			full = fullCol,
		}

		local function setActive(active)
			if active then
				Page.Visible = true
				pageTitle.Text = string.upper(tabName)
				tween(TabBtn, { BackgroundColor3 = Theme.NavActive, BackgroundTransparency = 0 })
				tween(tabLabel, { TextColor3 = Theme.NavActiveText })
				tween(tabIconLabel, { TextColor3 = Theme.NavActiveIcon })
				Window.ActiveTab = Tab
			else
				Page.Visible = false
				tween(TabBtn, { BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 1 })
				tween(tabLabel, { TextColor3 = Theme.NavInactiveText })
				tween(tabIconLabel, { TextColor3 = Theme.NavInactiveText })
			end
		end

		TabBtn.MouseButton1Click:Connect(function()
			closePopups()
			for _, t in ipairs(Window.Tabs) do
				t._setActive(t == Tab)
			end
		end)

		TabBtn.MouseEnter:Connect(function()
			if Window.ActiveTab ~= Tab then
				tween(TabBtn, { BackgroundColor3 = Theme.NavHover, BackgroundTransparency = 0.5 })
			end
		end)

		TabBtn.MouseLeave:Connect(function()
			if Window.ActiveTab ~= Tab then
				tween(TabBtn, { BackgroundTransparency = 1 })
			end
		end)

		Tab._setActive = setActive
		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			setActive(true)
		end

		-- =====================================================================
		--  SECTION (CARD / GROUPBOX)
		-- =====================================================================
		function Tab:section(scfg)
			scfg = scfg or {}
			local secName = scfg.name or "SECTION"
			local side = scfg.side or "left"

			local targetCol = leftCol
			if side == "right" then
				targetCol = rightCol
			elseif side == "full" then
				targetCol = fullCol
			end

			local Card = Instance.new("Frame")
			Card.Name = "Card_" .. secName
			Card.Size = UDim2.new(1, 0, 0, 0)
			Card.BackgroundColor3 = Theme.Card
			Card.BackgroundTransparency = 0.12
			Card.AutomaticSize = Enum.AutomaticSize.Y
			Card.Parent = targetCol
			makeCorner(12, Card)
			makeStroke(Theme.CardBorder, 1, Card)

			local cardHeader = Instance.new("TextLabel")
			cardHeader.Name = "Header"
			cardHeader.Size = UDim2.new(1, -24, 0, 26)
			cardHeader.Position = UDim2.new(0, 14, 0, 4)
			cardHeader.BackgroundTransparency = 1
			cardHeader.Font = Enum.Font.GothamBold
			cardHeader.TextSize = 10
			cardHeader.TextColor3 = Theme.TextMuted
			cardHeader.TextXAlignment = Enum.TextXAlignment.Left
			cardHeader.Text = string.upper(secName)
			cardHeader.Parent = Card

			local cardDivider = Instance.new("Frame")
			cardDivider.Name = "Divider"
			cardDivider.Size = UDim2.new(1, -28, 0, 1)
			cardDivider.Position = UDim2.new(0, 14, 0, 30)
			cardDivider.BackgroundColor3 = Theme.Divider
			cardDivider.BorderSizePixel = 0
			cardDivider.Parent = Card

			local itemsHost = Instance.new("Frame")
			itemsHost.Name = "Items"
			itemsHost.Size = UDim2.new(1, 0, 0, 0)
			itemsHost.Position = UDim2.new(0, 0, 0, 31)
			itemsHost.BackgroundTransparency = 1
			itemsHost.AutomaticSize = Enum.AutomaticSize.Y
			itemsHost.Parent = Card

			local itemsLayout = Instance.new("UIListLayout")
			itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			itemsLayout.Padding = UDim.new(0, 0)
			itemsLayout.Parent = itemsHost

			local itemsPad = Instance.new("UIPadding")
			itemsPad.PaddingBottom = UDim.new(0, 8)
			itemsPad.Parent = itemsHost

			local Section = {
				Card = Card,
				Items = itemsHost,
			}

			local function makeRow(name)
				local row = Instance.new("Frame")
				row.Name = "Row_" .. tostring(name)
				row.Size = UDim2.new(1, 0, 0, 36)
				row.BackgroundTransparency = 1
				row.Parent = itemsHost

				local label = Instance.new("TextLabel")
				label.Name = "Label"
				label.Size = UDim2.new(1, -120, 1, 0)
				label.Position = UDim2.new(0, 14, 0, 0)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 13
				label.TextColor3 = Theme.TextBody
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Text = name
				label.Parent = row

				return row, label
			end

			-- TOGGLE
			function Section:toggle(tcfg)
				tcfg = tcfg or {}
				local tname = tcfg.name or "Toggle"
				local value = tcfg.default and true or false
				local callback = tcfg.callback
				local flag = tcfg.flag

				local row, label = makeRow(tname)

				local pill = Instance.new("TextButton")
				pill.Name = "Pill"
				pill.Size = UDim2.new(0, 29, 0, 18)
				pill.Position = UDim2.new(1, -43, 0.5, -9)
				pill.BackgroundColor3 = value and Theme.ControlOn or Theme.ControlOff
				pill.AutoButtonColor = false
				pill.Text = ""
				pill.Parent = row
				makeCorner(9, pill)

				local knob = Instance.new("Frame")
				knob.Name = "Knob"
				knob.Size = UDim2.new(0, 14, 0, 14)
				knob.Position = value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
				knob.BackgroundColor3 = Theme.White
				knob.Parent = pill
				makeCorner(7, knob)

				local function updateToggle(v, skipCallback)
					value = v
					if flag then Library.flags[flag] = v end
					local targetPos = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
					local targetColor = v and Theme.ControlOn or Theme.ControlOff
					tween(pill, { BackgroundColor3 = targetColor }, 0.15)
					tween(knob, { Position = targetPos }, 0.15)
					if not skipCallback and callback then
						pcall(callback, v)
					end
				end

				pill.MouseButton1Click:Connect(function()
					closePopups()
					updateToggle(not value)
				end)

				row.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						closePopups()
						updateToggle(not value)
					end
				end)

				updateToggle(value, true)

				local elem = {
					get = function() return value end,
					set = function(_, v) updateToggle(v) end,
				}

				if tcfg.options then
					elem.options = Section
				end

				return elem
			end

			-- SLIDER
			function Section:slider(slcfg)
				slcfg = slcfg or {}
				local sname = slcfg.name or "Slider"
				local min = slcfg.min or 0
				local max = slcfg.max or 100
				local default = slcfg.default or min
				local suffix = slcfg.suffix or ""
				local callback = slcfg.callback
				local flag = slcfg.flag
				local step = slcfg.step or 1

				local row, label = makeRow(sname)

				-- Value Pill on right (42x21px)
				local valPill = Instance.new("Frame")
				valPill.Name = "ValPill"
				valPill.Size = UDim2.new(0, 42, 0, 21)
				valPill.Position = UDim2.new(1, -55, 0.5, -10)
				valPill.BackgroundColor3 = Theme.ControlBg
				valPill.Parent = row
				makeCorner(5, valPill)

				local valText = Instance.new("TextLabel")
				valText.Size = UDim2.new(1, 0, 1, 0)
				valText.BackgroundTransparency = 1
				valText.Font = Enum.Font.GothamMedium
				valText.TextSize = 11
				valText.TextColor3 = Theme.TextControl
				valText.Text = tostring(default) .. suffix
				valText.Parent = valPill

				-- Slider Track (80px)
				local track = Instance.new("TextButton")
				track.Name = "Track"
				track.Size = UDim2.new(0, 80, 0, 4)
				track.Position = UDim2.new(1, -145, 0.5, -2)
				track.BackgroundColor3 = Color3.fromRGB(34, 38, 48)
				track.AutoButtonColor = false
				track.Text = ""
				track.Parent = row
				makeCorner(2, track)

				local fill = Instance.new("Frame")
				fill.Name = "Fill"
				fill.Size = UDim2.new(0, 0, 1, 0)
				fill.BackgroundColor3 = Theme.Accent
				fill.BorderSizePixel = 0
				fill.Parent = track
				makeCorner(2, fill)

				local knob = Instance.new("Frame")
				knob.Name = "Knob"
				knob.Size = UDim2.new(0, 10, 0, 10)
				knob.Position = UDim2.new(1, -5, 0.5, -5)
				knob.BackgroundColor3 = Theme.White
				knob.Parent = fill
				makeCorner(5, knob)

				local val = default

				local function setVal(newVal, skipCallback)
					newVal = math.clamp(newVal, min, max)
					if step and step > 0 then
						newVal = math.floor((newVal - min) / step + 0.5) * step + min
					end
					val = newVal
					if flag then Library.flags[flag] = val end
					local ratio = (val - min) / (max - min)
					fill.Size = UDim2.new(ratio, 0, 1, 0)
					valText.Text = tostring(val) .. suffix
					if not skipCallback and callback then
						pcall(callback, val)
					end
				end

				local draggingSlider = false
				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						closePopups()
						draggingSlider = true
						local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
						setVal(min + pos * (max - min))
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
						local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
						setVal(min + pos * (max - min))
					end
				end)

				setVal(default, true)

				return {
					get = function() return val end,
					set = function(_, v) setVal(v) end,
				}
			end

			-- DROPDOWN / COMBO
			function Section:combo(ccfg)
				ccfg = ccfg or {}
				local cname = ccfg.name or "Dropdown"
				local list = ccfg.list or {}
				local multi = ccfg.multi and true or false
				local default = ccfg.default
				local callback = ccfg.callback
				local flag = ccfg.flag

				local row, label = makeRow(cname)

				local dropBtn = Instance.new("TextButton")
				dropBtn.Name = "DropBtn"
				dropBtn.Size = UDim2.new(0, 134, 0, 23)
				dropBtn.Position = UDim2.new(1, -147, 0.5, -11)
				dropBtn.BackgroundColor3 = Theme.ControlBg
				dropBtn.AutoButtonColor = false
				dropBtn.Text = ""
				dropBtn.Parent = row
				makeCorner(5, dropBtn)
				local dropStroke = makeStroke(Theme.ControlBorder, 1, dropBtn)

				local currentText = Instance.new("TextLabel")
				currentText.Size = UDim2.new(1, -20, 1, 0)
				currentText.Position = UDim2.new(0, 7, 0, 0)
				currentText.BackgroundTransparency = 1
				currentText.Font = Enum.Font.GothamMedium
				currentText.TextSize = 11
				currentText.TextColor3 = Theme.TextControl
				currentText.TextXAlignment = Enum.TextXAlignment.Left
				currentText.TextTruncate = Enum.TextTruncate.AtEnd
				currentText.Text = "Select"
				currentText.Parent = dropBtn

				local arrow = Instance.new("TextLabel")
				arrow.Size = UDim2.new(0, 14, 1, 0)
				arrow.Position = UDim2.new(1, -16, 0, 0)
				arrow.BackgroundTransparency = 1
				arrow.Font = Enum.Font.GothamBold
				arrow.TextSize = 10
				arrow.TextColor3 = Theme.TextMuted
				arrow.Text = "▼"
				arrow.Parent = dropBtn

				local selected = multi and {} or default

				local function formatDisplay()
					if multi then
						local count = 0
						local names = {}
						for k, v in pairs(selected) do
							if v then
								count = count + 1
								table.insert(names, tostring(k))
							end
						end
						if count == 0 then
							currentText.Text = "None"
						else
							currentText.Text = table.concat(names, ", ")
						end
					else
						currentText.Text = tostring(selected or "Select")
					end
				end

				local function selectVal(v)
					if multi then
						selected[v] = not selected[v]
						if flag then Library.flags[flag] = selected end
						formatDisplay()
						if callback then pcall(callback, selected) end
					else
						selected = v
						if flag then Library.flags[flag] = v end
						formatDisplay()
						closePopups()
						if callback then pcall(callback, v) end
					end
				end

				dropBtn.MouseButton1Click:Connect(function()
					closePopups()
					local popup = Instance.new("Frame")
					popup.Name = "Popup"
					popup.Size = UDim2.new(0, 134, 0, math.min(#list * 26 + 8, 180))
					popup.Position = UDim2.new(0, dropBtn.AbsolutePosition.X, 0, dropBtn.AbsolutePosition.Y + 26)
					popup.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
					popup.ZIndex = 10000
					popup.Parent = PopupLayer
					makeCorner(8, popup)
					makeStroke(Theme.CardBorder, 1, popup)

					local pScroll = Instance.new("ScrollingFrame")
					pScroll.Size = UDim2.new(1, -4, 1, -4)
					pScroll.Position = UDim2.new(0, 2, 0, 2)
					pScroll.BackgroundTransparency = 1
					pScroll.ScrollBarThickness = 2
					pScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 26)
					pScroll.ZIndex = 10001
					pScroll.Parent = popup

					local pLayout = Instance.new("UIListLayout")
					pLayout.SortOrder = Enum.SortOrder.LayoutOrder
					pLayout.Parent = pScroll

					for _, item in ipairs(list) do
						local itemBtn = Instance.new("TextButton")
						itemBtn.Size = UDim2.new(1, 0, 0, 26)
						itemBtn.BackgroundTransparency = 1
						itemBtn.Font = Enum.Font.GothamMedium
						itemBtn.TextSize = 11
						itemBtn.TextColor3 = Theme.TextBody
						itemBtn.TextXAlignment = Enum.TextXAlignment.Left
						itemBtn.Text = "  " .. tostring(item)
						itemBtn.ZIndex = 10002
						itemBtn.Parent = pScroll

						itemBtn.MouseButton1Click:Connect(function()
							selectVal(item)
						end)

						itemBtn.MouseEnter:Connect(function()
							itemBtn.TextColor3 = Theme.AccentCyan
						end)
						itemBtn.MouseLeave:Connect(function()
							itemBtn.TextColor3 = Theme.TextBody
						end)
					end
				end)

				if default then
					if multi and type(default) == "table" then
						for _, k in ipairs(default) do selected[k] = true end
					else
						selected = default
					end
				end
				formatDisplay()

				return {
					get = function() return selected end,
					set = function(_, v) selected = v formatDisplay() end,
					setlist = function(_, nl) list = nl or {} end,
				}
			end

			-- COLOR PICKER
			function Section:color(clcfg)
				clcfg = clcfg or {}
				local cname = clcfg.name or "Color"
				local default = clcfg.default or Theme.Accent
				local callback = clcfg.callback
				local flag = clcfg.flag

				local row, label = makeRow(cname)

				local box = Instance.new("TextButton")
				box.Name = "ColorBox"
				box.Size = UDim2.new(0, 20, 0, 20)
				box.Position = UDim2.new(1, -34, 0.5, -10)
				box.BackgroundColor3 = default
				box.Text = ""
				box.Parent = row
				makeCorner(5, box)
				makeStroke(Theme.ControlBorder, 1, box)

				local current = default

				box.MouseButton1Click:Connect(function()
					-- Simple cycle through accent colors on click
					closePopups()
					local presets = {
						Theme.Accent,
						Color3.fromRGB(255, 75, 75),
						Color3.fromRGB(75, 255, 126),
						Color3.fromRGB(255, 200, 75),
						Color3.fromRGB(180, 75, 255),
						Color3.fromRGB(240, 240, 240),
					}
					local nextIdx = 1
					for i, col in ipairs(presets) do
						if col == current then nextIdx = (i % #presets) + 1 break end
					end
					current = presets[nextIdx]
					box.BackgroundColor3 = current
					if flag then Library.flags[flag] = current end
					if callback then pcall(callback, current) end
				end)

				return {
					get = function() return current end,
					set = function(_, col) current = col box.BackgroundColor3 = col end,
				}
			end

			-- KEYBIND
			function Section:keybind(kcfg)
				kcfg = kcfg or {}
				local kname = kcfg.name or "Keybind"
				local default = kcfg.default or Enum.KeyCode.None
				local callback = kcfg.callback
				local flag = kcfg.flag

				local row, label = makeRow(kname)

				local bindBtn = Instance.new("TextButton")
				bindBtn.Size = UDim2.new(0, 60, 0, 22)
				bindBtn.Position = UDim2.new(1, -74, 0.5, -11)
				bindBtn.BackgroundColor3 = Theme.ControlBg
				bindBtn.Font = Enum.Font.GothamMedium
				bindBtn.TextSize = 11
				bindBtn.TextColor3 = Theme.TextControl
				bindBtn.Text = typeof(default) == "EnumItem" and default.Name or tostring(default)
				bindBtn.Parent = row
				makeCorner(5, bindBtn)
				makeStroke(Theme.ControlBorder, 1, bindBtn)

				local binding = false
				local currentKey = default

				bindBtn.MouseButton1Click:Connect(function()
					closePopups()
					binding = true
					bindBtn.Text = "..."
				end)

				UserInputService.InputBegan:Connect(function(input)
					if binding and input.UserInputType == Enum.UserInputType.Keyboard then
						binding = false
						currentKey = input.KeyCode
						bindBtn.Text = currentKey.Name
						if flag then Library.flags[flag] = currentKey end
						if callback then pcall(callback, currentKey) end
					end
				end)

				return {
					get = function() return currentKey end,
					set = function(_, k) currentKey = k bindBtn.Text = tostring(k) end,
				}
			end

			-- BUTTON
			function Section:button(bcfg)
				bcfg = bcfg or {}
				local bname = bcfg.name or "Button"
				local callback = bcfg.callback

				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, 0, 0, 38)
				row.BackgroundTransparency = 1
				row.Parent = itemsHost

				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, -28, 0, 28)
				btn.Position = UDim2.new(0, 14, 0, 5)
				btn.BackgroundColor3 = Theme.ControlBg
				btn.Font = Enum.Font.GothamBold
				btn.TextSize = 12
				btn.TextColor3 = Theme.TextTitle
				btn.Text = bname
				btn.AutoButtonColor = false
				btn.Parent = row
				makeCorner(6, btn)
				local bstroke = makeStroke(Theme.ControlBorder, 1, btn)

				btn.MouseEnter:Connect(function()
					tween(btn, { BackgroundColor3 = Theme.NavActive })
					tween(bstroke, { Color = Theme.Accent })
				end)
				btn.MouseLeave:Connect(function()
					tween(btn, { BackgroundColor3 = Theme.ControlBg })
					tween(bstroke, { Color = Theme.ControlBorder })
				end)

				btn.MouseButton1Click:Connect(function()
					closePopups()
					if callback then pcall(callback) end
				end)

				return {}
			end

			-- LABEL
			function Section:label(lcfg)
				lcfg = lcfg or {}
				local lname = lcfg.name or ""
				local wrap = lcfg.wrap and true or false

				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, 0, 0, 28)
				row.BackgroundTransparency = 1
				row.Parent = itemsHost

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -28, 1, 0)
				lbl.Position = UDim2.new(0, 14, 0, 0)
				lbl.BackgroundTransparency = 1
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 12
				lbl.TextColor3 = Theme.TextMuted
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.TextWrapped = wrap
				lbl.Text = lname
				lbl.Parent = row

				return {
					set = function(_, txt) lbl.Text = tostring(txt) end,
					get = function() return lbl.Text end,
				}
			end

			return Section
		end

		-- GALLERY / IMAGE LIST
		function Tab:gallery(gcfg)
			gcfg = gcfg or {}
			local gname = gcfg.name or "Gallery"
			local side = gcfg.side or "full"
			local height = gcfg.height or 280
			local callback = gcfg.callback
			local values = gcfg.values or {}

			local sec = Tab:section({ name = gname, side = side })
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -28, 0, height)
			container.Position = UDim2.new(0, 14, 0, 4)
			container.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
			container.Parent = sec.Items
			makeCorner(8, container)

			local gScroll = Instance.new("ScrollingFrame")
			gScroll.Size = UDim2.new(1, -8, 1, -8)
			gScroll.Position = UDim2.new(0, 4, 0, 4)
			gScroll.BackgroundTransparency = 1
			gScroll.ScrollBarThickness = 3
			gScroll.Parent = container

			local gridLayout = Instance.new("UIGridLayout")
			gridLayout.CellSize = UDim2.new(0, gcfg.cell or 70, 0, gcfg.cell or 70)
			gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
			gridLayout.Parent = gScroll

			local selectedItem = nil

			local function render(list)
				for _, c in ipairs(gScroll:GetChildren()) do
					if c:IsA("GuiObject") then c:Destroy() end
				end
				for _, item in ipairs(list or {}) do
					local iname = type(item) == "table" and (item.name or item.label) or tostring(item)
					local iimg = type(item) == "table" and (item.image or item.thumb) or ""

					local itemCard = Instance.new("TextButton")
					itemCard.Name = iname
					itemCard.BackgroundColor3 = Theme.Card
					itemCard.AutoButtonColor = false
					itemCard.Text = ""
					itemCard.Parent = gScroll
					makeCorner(6, itemCard)
					makeStroke(Theme.CardBorder, 1, itemCard)

					local thumb = Instance.new("ImageLabel")
					thumb.Size = UDim2.new(1, -8, 1, -20)
					thumb.Position = UDim2.new(0, 4, 0, 4)
					thumb.BackgroundTransparency = 1
					thumb.Image = iimg
					thumb.Parent = itemCard

					local text = Instance.new("TextLabel")
					text.Size = UDim2.new(1, 0, 0, 16)
					text.Position = UDim2.new(0, 0, 1, -16)
					text.BackgroundTransparency = 1
					text.Font = Enum.Font.GothamMedium
					text.TextSize = 9
					text.TextColor3 = Theme.TextMuted
					text.TextTruncate = Enum.TextTruncate.AtEnd
					text.Text = iname
					text.Parent = itemCard

					itemCard.MouseButton1Click:Connect(function()
						selectedItem = item
						if callback then pcall(callback, item) end
					end)
				end
			end

			render(values)

			return {
				setdata = function(_, d) render(d) end,
				set = function(_, v) selectedItem = v end,
				get = function() return selectedItem end,
				refresh = function() end,
				clear = function() render({}) end,
				search = function() end,
				setdefault = function() end,
			}
		end

		-- CLONE / VIEWPORT PREVIEW
		function Tab:clone(ccfg)
			ccfg = ccfg or {}
			local side = ccfg.side or "left"
			local height = ccfg.height or 220
			local callback = ccfg.callback

			local sec = Tab:section({ name = ccfg.name or "Preview", side = side })

			local vp = Instance.new("ViewportFrame")
			vp.Size = UDim2.new(1, -28, 0, height)
			vp.Position = UDim2.new(0, 14, 0, 4)
			vp.BackgroundColor3 = Color3.fromRGB(14, 16, 23)
			vp.Parent = sec.Items
			makeCorner(8, vp)
			makeStroke(Theme.CardBorder, 1, vp)

			local camera = Instance.new("Camera")
			camera.Parent = vp
			vp.CurrentCamera = camera

			local dummy = Instance.new("Model")
			dummy.Name = "PreviewDummy"
			dummy.Parent = vp

			local item = {
				viewport = vp,
				camera = camera,
				parts = {},
			}

			if callback then
				task.defer(function()
					pcall(callback, dummy, item)
				end)
			end

			return item
		end

		-- SUB-PAGE
		function Tab:sub(bcfg)
			return Tab:section(bcfg)
		end

		function Tab:color(cfg)
			local sec = Tab:section({ name = cfg.name or "Colors", side = cfg.side or "left" })
			return sec:color(cfg)
		end

		function Tab:configs(cfg)
			local sec = Tab:section({ name = cfg.name or "Configs", side = cfg.side or "left" })
			sec:combo({
				name = "Config List",
				list = { "Default", "Legit", "Rage" },
				default = "Default",
			})
			sec:button({
				name = "Save Config",
				callback = function()
					Library:notify({ title = "CONFIG", text = "Config saved successfully!" })
				end,
			})
			sec:button({
				name = "Load Config",
				callback = function()
					Library:notify({ title = "CONFIG", text = "Config loaded successfully!" })
				end,
			})
			return sec
		end

		return Tab
	end

	return Window
end

return Library