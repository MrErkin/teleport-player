local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 340)
frame.Position = UDim2.new(0.5, -110, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Draggable = true
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Teleport to Player"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14

-- поле ввода ника
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1, -10, 0, 28)
input.Position = UDim2.new(0, 5, 0, 35)
input.PlaceholderText = "Enter name..."
input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Font = Enum.Font.SourceSans
input.TextSize = 12
input.ClearTextOnFocus = false

-- выпадающий список автозаполнения
local dropdown = Instance.new("ScrollingFrame", frame)
dropdown.Size = UDim2.new(1, -10, 0, 80)
dropdown.Position = UDim2.new(0, 5, 0, 65)
dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdown.BorderSizePixel = 0
dropdown.ScrollBarThickness = 4
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.Visible = false
dropdown.ZIndex = 10

local dropdownList = Instance.new("UIListLayout", dropdown)
dropdownList.Padding = UDim.new(0, 1)

-- тумблер зависания
local hoverToggle = Instance.new("TextButton", frame)
hoverToggle.Size = UDim2.new(1, -10, 0, 28)
hoverToggle.Position = UDim2.new(0, 5, 0, 150)
hoverToggle.Text = "Hover: OFF"
hoverToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hoverToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
hoverToggle.Font = Enum.Font.SourceSansBold
hoverToggle.TextSize = 12

local hoverEnabled = false
hoverToggle.MouseButton1Click:Connect(function()
    hoverEnabled = not hoverEnabled
    hoverToggle.Text = "Hover: " .. (hoverEnabled and "ON" or "OFF")
    hoverToggle.BackgroundColor3 = hoverEnabled and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(60, 60, 60)
end)

-- список всех игроков
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 0, 100)
scroll.Position = UDim2.new(0, 5, 0, 185)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 5
scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
scroll.BorderSizePixel = 0

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 2)
list.SortOrder = Enum.SortOrder.Name

local playersLabel = Instance.new("TextLabel", frame)
playersLabel.Size = UDim2.new(1, -10, 0, 16)
playersLabel.Position = UDim2.new(0, 5, 0, 168)
playersLabel.Text = "Players:"
playersLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
playersLabel.BackgroundTransparency = 1
playersLabel.Font = Enum.Font.SourceSans
playersLabel.TextSize = 11

-- кнопка закрытия
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(1, -10, 0, 25)
close.Position = UDim2.new(0, 5, 0, 295)
close.Text = "Close"
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.SourceSansBold
close.TextSize = 12
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- функция телепортации
local function teleportTo(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character.HumanoidRootPart
        local myRoot = player.Character.HumanoidRootPart
        local offset = targetRoot.CFrame.LookVector * 3
        if hoverEnabled then
            offset = offset + Vector3.new(0, 5, 0)
        end
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(offset)
        if hoverEnabled then
            myRoot.Anchored = true
            task.wait(0.5)
            myRoot.Anchored = false
        end
    end
end

-- обновление списка игроков
local function updatePlayerList()
    for _, v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    local y = 0
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.MouseButton1Click:Connect(function()
                teleportTo(p)
            end)
            y += 28
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- автозаполнение
input:GetPropertyChangedSignal("Text"):Connect(function()
    local text = input.Text:lower()
    for _, v in pairs(dropdown:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    if text == "" then
        dropdown.Visible = false
        return
    end
    local matches = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and (p.Name:lower():find(text, 1, true) or p.DisplayName:lower():find(text, 1, true)) then
            table.insert(matches, p.Name)
        end
    end
    if #matches > 0 then
        dropdown.Visible = true
        for _, name in ipairs(matches) do
            local btn = Instance.new("TextButton", dropdown)
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.Text = name
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 12
            btn.ZIndex = 11
            btn.MouseButton1Click:Connect(function()
                input.Text = name
                dropdown.Visible = false
                local target = game.Players:FindFirstChild(name)
                if target then teleportTo(target) end
            end)
        end
        dropdown.CanvasSize = UDim2.new(0, 0, 0, #matches * 25)
    else
        dropdown.Visible = false
    end
end)

input.FocusLost:Connect(function(enterPressed)
    task.wait(0.15)
    dropdown.Visible = false
    if enterPressed and input.Text ~= "" then
        local target = game.Players:FindFirstChild(input.Text)
        if target then teleportTo(target) end
    end
end)

updatePlayerList()
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(function()
    updatePlayerList()
    dropdown.Visible = false
end)