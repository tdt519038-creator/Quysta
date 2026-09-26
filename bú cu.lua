local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("SimpleSpy") then 
    CoreGui.SimpleSpy:Destroy() 
end

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "SimpleSpy"
sg.ZIndex = 999

local fr = Instance.new("Frame", sg)
fr.Size = UDim2.new(0, 500, 0, 400)
fr.Position = UDim2.new(0.5, -250, 0.5, -200)
fr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fr.BorderColor3 = Color3.fromRGB(100, 100, 100)
fr.BorderSizePixel = 2
fr.Active = true
fr.Draggable = true

local toggleBtn = Instance.new("TextButton", fr)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "LOGGING: OFF"
toggleBtn.Font = Enum.Font.Code
toggleBtn.TextSize = 13

local clearBtn = Instance.new("TextButton", fr)
clearBtn.Size = UDim2.new(0, 80, 0, 30)
clearBtn.Position = UDim2.new(0, 130, 0, 5)
clearBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 200)
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Text = "CLEAR"
clearBtn.Font = Enum.Font.Code
clearBtn.TextSize = 13

local sf = Instance.new("ScrollingFrame", fr)
sf.Size = UDim2.new(1, -10, 1, -45)
sf.Position = UDim2.new(0, 5, 0, 40)
sf.BackgroundTransparency = 1
sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
sf.CanvasSize = UDim2.new(0, 0, 0, 0)
sf.ScrollBarThickness = 4

local ll = Instance.new("UIListLayout", sf)
ll.Padding = UDim.new(0, 2)

local isLogging = false
local hooked = {}

toggleBtn.MouseButton1Click:Connect(function()
    isLogging = not isLogging
    if isLogging then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        toggleBtn.Text = "LOGGING: ON"
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        toggleBtn.Text = "LOGGING: OFF"
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(sf:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end)

local function logRemote(remoteName, method, args)
    local txt = Instance.new("TextLabel", sf)
    txt.Size = UDim2.new(1, 0, 0, 30)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(0, 255, 150)
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextSize = 11
    txt.Font = Enum.Font.Code
    txt.TextWrapped = true
    
    local str = string.format("[%s::%s] ", remoteName, method)
    for i, v in ipairs(args) do 
        if typeof(v) == "Instance" then
            str = str .. "<" .. v.ClassName .. "> | "
        else
            str = str .. tostring(v) .. " | "
        end
    end
    txt.Text = str
    print(str)
end

local function hookRemote(remote)
    if hooked[remote] then return end
    hooked[remote] = true
    
    if remote:IsA("RemoteEvent") then
        local oldFire = remote.FireServer
        remote.FireServer = function(self, ...)
            if isLogging then
                logRemote(remote.Name, "FireServer", {...})
            end
            return oldFire(self, ...)
        end
    elseif remote:IsA("RemoteFunction") then
        local oldInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            if isLogging then
                logRemote(remote.Name, "InvokeServer", {...})
            end
            return oldInvoke(self, ...)
        end
    end
end

local function scanForRemotes()
    local function scan(parent)
        for _, desc in pairs(parent:GetDescendants()) do
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                hookRemote(desc)
            end
        end
    end
    
    scan(game:GetService("ReplicatedStorage"))
    scan(game:GetService("ServerScriptService"))
end

-- Initial scan
scanForRemotes()

-- Monitor for new remotes
local services = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService")
}

for _, service in pairs(services) do
    service.DescendantAdded:Connect(function(desc)
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
            task.wait(0.1)
            hookRemote(desc)
        end
    end)
end

print("[SimpleSpy] Loaded. Toggle LOGGING and perform actions in-game.")