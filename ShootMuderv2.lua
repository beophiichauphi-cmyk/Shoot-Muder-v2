-- [[ MM2 2026 V8 - ABSOLUTE VERDICT ENGINE (INSTANT DIE) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local localplayer = Players.LocalPlayer

local isDragLocked = false 
local currentGuiSize = 65 -- Kích thước mặc định

-- =======================================================
-- [[ ANTI-LAG SQUASH: TỐI ƯU HÓA SIÊU MƯỢT ]] --
-- =======================================================
local function cleanCoins()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and (v.Parent.Name == "Coin" or v.Parent.Name == "CoinContainer" or v.Parent:FindFirstChild("Coin")) then
            v.Parent:Destroy()
        elseif v.Name == "Coin" or v.Name == "CupidCoin" or v.Name == "Snowflake" then
            v:Destroy()
        end
    end
end
task.spawn(function()
    while task.wait(3) do pcall(cleanCoins) end
end)

-- =======================================================
-- [[ ABSOLUTE INSTANT TARGET LOCK (TRỊ TRUYỆT ĐỐI JUMP/LẠCH) ]] --
-- =======================================================
local function getAbsoluteVerdictTarget(roleNeeded)
    local closestTarget = nil
    local shortestDistance = math.huge
    local myChar = localplayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local hrp = p.Character.HumanoidRootPart
                local dist = (hrp.Position - myChar.HumanoidRootPart.Position).Magnitude
                
                -- Khóa cứng tâm vào vùng ngực (UpperTorso) - Nơi có Hitbox lớn nhất để không bao giờ trượt
                local targetBone = p.Character:FindFirstChild("UpperTorso") or hrp
                
                if roleNeeded == "Murderer" and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
                    return targetBone
                elseif roleNeeded == "Closest" and dist < shortestDistance then
                    shortestDistance = dist
                    closestTarget = targetBone
                end
            end
        end
    end
    return closestTarget
end

-- =======================================================
-- [[ SUPREME SHOOT / THROW SYSTEM - BẤM LÀ DIE TỨC THÌ ]] --
-- =======================================================
local function executeAbsoluteShoot()
    local char = localplayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- CHẾ ĐỘ SÚNG (SHERIFF / HERO)
    if char:FindFirstChild("Gun") or localplayer.Backpack:FindFirstChild("Gun") then
        local targetBone = getAbsoluteVerdictTarget("Murderer") or getAbsoluteVerdictTarget("Closest")
        if not targetBone then return end
        
        local gun = char:FindFirstChild("Gun")
        if not gun then 
            local bpGun = localplayer.Backpack:FindFirstChild("Gun")
            if bpGun then bpGun.Parent = char; gun = bpGun end
        end

        if gun and gun:FindFirstChild("Shoot") then
            -- Lấy vị trí chuẩn xác 100% tại mili-giây bấm nút, bất chấp góc lag desync hay lạng lách
            local finalDestination = targetBone.Position
            
            -- Gửi đồng thời 3 gói tin liên tục (Triệu tiêu hoàn toàn tỷ lệ lỗi script)
            gun.Shoot:FireServer(CFrame.new(finalDestination), CFrame.new(finalDestination))
            gun.Shoot:FireServer(CFrame.new(finalDestination), CFrame.new(finalDestination))
            gun.Shoot:FireServer(CFrame.new(finalDestination), CFrame.new(finalDestination))
        end

    -- CHẾ ĐỘ DAO (MURDERER THROW)
    elseif char:FindFirstChild("Knife") or localplayer.Backpack:FindFirstChild("Knife") then
        local targetBone = getAbsoluteVerdictTarget("Closest")
        if not targetBone then return end
        
        local knife = char:FindFirstChild("Knife")
        if not knife then
            local bpKnife = localplayer.Backpack:FindFirstChild("Knife")
            if bpKnife then bpKnife.Parent = char; knife = bpKnife end
        end

        if knife then
            local throwRemote = knife:FindFirstChild("Events") and knife.Events:FindFirstChild("KnifeThrown")
            if throwRemote then
                local finalDestination = targetBone.Position
                
                -- Khóa mục tiêu tuyệt đối, dao bẻ thẳng vào người không thể né
                throwRemote:FireServer(CFrame.new(finalDestination), CFrame.new(finalDestination))
                throwRemote:FireServer(CFrame.new(finalDestination), CFrame.new(finalDestination))
            end
        end
    end
end

-- =======================================================
-- [[ CYBERPUNK NEON CROSSHAIR - THIẾT KẾ ĐẸP & CHUẨN SIZE ]] --
-- =======================================================
if CoreGui:FindFirstChild("CompactAimUI") then CoreGui.CompactAimUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CompactAimUI"
ScreenGui.Parent = CoreGui

local MainButton = Instance.new("TextButton")
MainButton.Name = "MainButton"
MainButton.Parent = ScreenGui
MainButton.Size = UDim2.new(0, currentGuiSize, 0, currentGuiSize)
MainButton.Position = UDim2.new(0.5, -32, 0.4, 0)
MainButton.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainButton.BackgroundTransparency = 0.5
MainButton.Text = ""

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainButton

-- Viền ngoài mờ tinh tế
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.6
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainButton

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Name = "Crosshair"
CrosshairFrame.Size = UDim2.new(1, 0, 1, 0)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Parent = MainButton

-- HÀM THIẾT KẾ TÂM CYBERPUNK SIÊU ĐẸP (VIỀN NEON XANH + LÕI TRẮNG SẮC NÉT)
local function buildCyberCrosshair()
    CrosshairFrame:ClearAllChildren()
    
    local scale = currentGuiSize / 65
    local thickness = math.clamp(math.floor(2.5 * scale), 2, 5)
    local length = math.floor(14 * scale)
    local gap = math.floor(5 * scale)

    for i = 1, 4 do
        -- Lớp Neon Xanh Dạ Quang bọc ngoài làm hiệu ứng Glow
        local neonGlow = Instance.new("Frame")
        neonGlow.BackgroundColor3 = Color3.fromRGB(0, 240, 160) -- Màu xanh neon dạ quang cực sáng
        neonGlow.BackgroundTransparency = 0.3
        neonGlow.BorderSizePixel = 0
        neonGlow.Parent = CrosshairFrame

        -- Lớp lõi màu Trắng Ngọc Trai nằm chính giữa
        local whiteCore = Instance.new("Frame")
        whiteCore.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        whiteCore.BackgroundTransparency = 0.1
        whiteCore.BorderSizePixel = 0
        whiteCore.Size = UDim2.new(0, thickness, 0, length)
        whiteCore.Position = UDim2.new(0.5, -thickness/2, 0.5, -length/2)
        whiteCore.Parent = neonGlow

        -- Canh chỉnh 4 hướng đối xứng sắc nét
        if i == 1 then -- Trên
            neonGlow.Size = UDim2.new(0, thickness + 2, 0, length + 2)
            neonGlow.Position = UDim2.new(0.5, -(thickness + 2)/2, 0.5, -(length + gap + 1))
        elseif i == 2 then -- Dưới
            neonGlow.Size = UDim2.new(0, thickness + 2, 0, length + 2)
            neonGlow.Position = UDim2.new(0.5, -(thickness + 2)/2, 0.5, gap)
        elseif i == 3 then -- Trái
            neonGlow.Size = UDim2.new(0, length + 2, 0, thickness + 2)
            whiteCore.Size = UDim2.new(0, length, 0, thickness)
            whiteCore.Position = UDim2.new(0.5, -length/2, 0.5, -thickness/2)
            neonGlow.Position = UDim2.new(0.5, -(length + gap + 1), 0.5, -(thickness + 2)/2)
        elseif i == 4 then -- Phải
            neonGlow.Size = UDim2.new(0, length + 2, 0, thickness + 2)
            whiteCore.Size = UDim2.new(0, length, 0, thickness)
            whiteCore.Position = UDim2.new(0.5, -length/2, 0.5, -thickness/2)
            neonGlow.Position = UDim2.new(0.5, gap, 0.5, -(thickness + 2)/2)
        end
    end

    -- Chấm định tâm Mini màu đỏ rực ở chính giữa
    local CenterDot = Instance.new("Frame")
    CenterDot.Size = UDim2.new(0, 4, 0, 4)
    CenterDot.Position = UDim2.new(0.5, -2, 0.5, -2)
    CenterDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CenterDot.BorderSizePixel = 0
    CenterDot.Parent = CrosshairFrame
end
buildCyberCrosshair()

-- Ảnh đại diện Dao Găm (Khi làm Murderer)
local KnifeIcon = Instance.new("ImageLabel")
KnifeIcon.Name = "KnifeIcon"
KnifeIcon.Size = UDim2.new(0.65, 0, 0.65, 0)
KnifeIcon.Position = UDim2.new(0.175, 0, 0.175, 0)
KnifeIcon.BackgroundTransparency = 1
KnifeIcon.ImageTransparency = 0.4
KnifeIcon.Image = "rbxassetid://7137398850"
KnifeIcon.Visible = false
KnifeIcon.Parent = MainButton

-- Hiệu ứng xoay tâm súng mượt mà tinh tế
task.spawn(function()
    local rot = 0
    while task.wait(0.02) do
        if CrosshairFrame.Visible then rot = (rot + 2.5) % 360 CrosshairFrame.Rotation = rot end
    end
end)

-- Bánh răng Cài đặt
local SettingsButton = Instance.new("TextButton")
SettingsButton.Name = "SettingsButton"
SettingsButton.Parent = ScreenGui
SettingsButton.Size = UDim2.new(0, 25, 0, 25)
SettingsButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsButton.BackgroundTransparency = 0.5
SettingsButton.Text = "⚙"
SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsButton.TextSize = 14

local SettCorner = Instance.new("UICorner")
SettCorner.CornerRadius = UDim.new(0, 6)
SettCorner.Parent = SettingsButton

local SettStroke = Instance.new("UIStroke")
SettStroke.Thickness = 1.5
SettStroke.Color = Color3.fromRGB(255, 255, 255)
SettStroke.Transparency = 0.5
SettStroke.Parent = SettingsButton

-- Bảng Panel điều chỉnh
local SettPanel = Instance.new("Frame")
SettPanel.Name = "SettPanel"
SettPanel.Parent = ScreenGui
SettPanel.Size = UDim2.new(0, 150, 0, 100)
SettPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SettPanel.BackgroundTransparency = 0.5
SettPanel.Visible = false

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 8)
PanelCorner.Parent = SettPanel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Thickness = 1.5
PanelStroke.Color = Color3.fromRGB(255, 255, 255)
PanelStroke.Transparency = 0.5
PanelStroke.Parent = SettPanel

-- Nút Lock di chuyển vị trí nút bấm
local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0, 130, 0, 30)
LockBtn.Position = UDim2.new(0, 10, 0, 10)
LockBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
LockBtn.BackgroundTransparency = 0.5
LockBtn.Text = "Lock Drag: OFF"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.SourceSansBold
LockBtn.Parent = SettPanel
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 6)

LockBtn.MouseButton1Click:Connect(function()
    isDragLocked = not isDragLocked
    LockBtn.Text = isDragLocked and "Lock Drag: ON" or "Lock Drag: OFF"
    LockBtn.BackgroundColor3 = isDragLocked and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(180, 50, 50)
end)

-- Slider zoom to nhỏ GUI và phóng to Crosshair đồng bộ
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(0, 130, 0, 20)
SliderLabel.Position = UDim2.new(0, 10, 0, 45)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Size GUI"
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.TextTransparency = 0.5
SliderLabel.Font = Enum.Font.SourceSans

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(0, 130, 0, 8)
SliderBg.Position = UDim2.new(0, 10, 0, 75)
SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderBg.BackgroundTransparency = 0.5
SliderBg.Parent = SettPanel
SliderLabel.Parent = SettPanel

local SliderMain = Instance.new("TextButton")
SliderMain.Size = UDim2.new(0, 15, 0, 15)
SliderMain.Position = UDim2.new(0.3, 0, -0.4, 0)
SliderMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderMain.BackgroundTransparency = 0.5
SliderMain.Text = ""
SliderMain.Parent = SliderBg
Instance.new("UICorner", SliderMain).CornerRadius = UDim.new(1, 0)

local sliderDragging = false
SliderMain.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        SliderMain.Position = UDim2.new(relativeX, -7, -0.4, 0)
        
        -- Cho phép scale từ 45px đến tối đa 125px cho màn hình lớn/nhỏ tùy chọn
        currentGuiSize = math.floor(45 + (relativeX * 80))
        MainButton.Size = UDim2.new(0, currentGuiSize, 0, currentGuiSize)
        
        -- Kích hoạt vẽ lại tâm ngắm để tự phóng to theo tỉ lệ chuẩn
        buildCyberCrosshair()
    end
end)

SettingsButton.MouseButton1Click:Connect(function() SettPanel.Visible = not SettPanel.Visible end)
MainButton.MouseButton1Click:Connect(executeAbsoluteShoot)

-- Vòng lặp cập nhật trạng thái cầm vũ khí và đồng bộ bảng menu
task.spawn(function()
    while task.wait(0.1) do
        local char = localplayer.Character
        if char then
            if char:FindFirstChild("Knife") or localplayer.Backpack:FindFirstChild("Knife") then
                CrosshairFrame.Visible = false KnifeIcon.Visible = true
            else
                CrosshairFrame.Visible = true KnifeIcon.Visible = false
            end
        end
        SettingsButton.Position = UDim2.new(MainButton.Position.X.Scale, MainButton.Position.X.Offset + MainButton.AbsoluteSize.X + 5, MainButton.Position.Y.Scale, MainButton.Position.Y.Offset)
        SettPanel.Position = UDim2.new(SettingsButton.Position.X.Scale, SettingsButton.Position.X.Offset, SettingsButton.Position.Y.Scale, SettingsButton.Position.Y.Offset + 30)
    end
end)

-- Xử lý kéo thả nút tròn chính mượt mà trên Delta Mobile Executor
local dragging, dragInput, dragStart, startPos
MainButton.InputBegan:Connect(function(input)
    if not isDragLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true; dragStart = input.Position; startPos = MainButton.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainButton.InputChanged:Connect(function(input) if not isDragLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if not isDragLocked and input == dragInput and dragging then
    local delta = input.Position - dragStart
    MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end end)
