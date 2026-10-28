-- ============================================================
-- BINTANGX6LOCHUB — FULL MACHINE & UI (GENERATOR PROGRESS)
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local PathService = game:GetService("PathfindingService")
local VIM = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================================
-- 1. KONFIGURASI UTAMA (CFG & WARNA)
-- ============================================================
local CFG = {
    -- ESP
    KillerESP = true, SurvivorESP = true, GenESP = true,
    HookESP = false, PalletESP = false, VaultESP = false, GateESP = true,
    ESPRange = 999999, ESPFill = 0.6, ESPOutline = 0.1,
    -- Warna Default (Dari file lo)
    ColorKiller = Color3.fromRGB(255, 60, 60),
    ColorSurvivor = Color3.fromRGB(80, 255, 120),
    ColorSurvivorInjured = Color3.fromRGB(255, 120, 60),
    ColorSurvivorKnocked = Color3.fromRGB(255, 180, 60),
    ColorGenerator = Color3.fromRGB(0, 200, 255),
    ColorHook = Color3.fromRGB(255, 150, 0),
    ColorPallet = Color3.fromRGB(200, 160, 80),
    ColorVault = Color3.fromRGB(180, 180, 180),
    ColorGate = Color3.fromRGB(255, 220, 0),
    
    -- Skill
    AutoSkillCheck = true, InstantSkillCheck = false, SkillCheckMode = "Perfect", PerfectRate = 100,
    -- Combat
    AutoParry = false, ParryRange = 14,
    RevolverAimbot = false, RevolverAimbotRadius = 150,
    RevolverSilent = false, SpearSilent = false,
    -- Movement
    SpeedBoost = false, SpeedMult = 1.3,
    NoclipVaultsPallets = false, AlwaysFastVault = false,
    -- Visuals
    FullBright = false, NoFog = false, FOV = 70, FPSCap = 0,
    -- Farm
    AutoFarmSurvivor = false, AutoFarmKiller = false,
    AutoFlee = false, AutoUnhook = false, InstantEscape = false
}

local LOGO_URL = "https://files.catbox.moe/7jhr44.jpg" 
local LOGO_FALLBACK = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
local function loadLogo()
    local path = "BintangX6_DragonLogo.png"
    local getAsset = getcustomasset or getsynasset
    if writefile and isfile and getAsset then
        if not isfile(path) then
            local ok, body = pcall(function() return game:HttpGet(LOGO_URL) end)
            if ok and body then pcall(writefile, path, body) end
        end
        if isfile(path) then
            local ok, asset = pcall(getAsset, path)
            if ok and asset then return asset end
        end
    end
    return LOGO_FALLBACK
end
local LOGO_ASSET = loadLogo()

-- ============================================================
-- 2. ESP ENGINE & GENERATOR PROGRESS (Dari File Lo)
-- ============================================================
local ActiveESP = { Players = {}, Map = {} }
local highlightParent = workspace

local function isKiller(player)
    if player.Team and player.Team.Name == "Killer" then return true end
    if player:GetAttribute("Role") == "Killer" then return true end
    if player:GetAttribute("IsKiller") == true then return true end
    return false
end

-- FUNGSI PROGRESS GENERATOR (Ambil dari file lo)
local function getGeneratorProgress(resultValue)
    local repairProgress = resultValue:GetAttribute("RepairProgress")
    if repairProgress == nil then
        local repairProgress2 = resultValue:FindFirstChild("RepairProgress")
        if repairProgress2 and repairProgress2:IsA("ValueObject") then
            repairProgress = repairProgress2.Value
        end
    end
    if not repairProgress then return 0 end
    local numberValue = tonumber(repairProgress)
    if numberValue then
        if numberValue <= 1.01 and numberValue > 0 then
            return math.round(numberValue * 100)
        else
            return math.round(numberValue)
        end
    end
    return 0
end

local function createPlayerESP(player)
    if ActiveESP.Players[player] then return ActiveESP.Players[player] end
    local hl = Instance.new("Highlight")
    hl.FillTransparency = CFG.ESPFill
    hl.OutlineTransparency = CFG.ESPOutline
    hl.Enabled = false
    hl.Parent = highlightParent
    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.Size = UDim2.new(0, 180, 0, 42)
    bb.Enabled = false
    bb.Parent = highlightParent
    local name = Instance.new("TextLabel", bb)
    name.Size = UDim2.new(1,0,0.5,0)
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.fromRGB(255,255,255)
    name.TextStrokeTransparency = 0.4
    name.Font = Enum.Font.GothamBold
    name.TextSize = 12
    local info = Instance.new("TextLabel", bb)
    info.Size = UDim2.new(1,0,0.5,0)
    info.Position = UDim2.new(0,0,0.5,0)
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.fromRGB(220,220,220)
    info.TextStrokeTransparency = 0.5
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    ActiveESP.Players[player] = { hl = hl, bb = bb, name = name, info = info }
    return ActiveESP.Players[player]
end

local function updatePlayersESP()
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local killer = isKiller(plr)
                if (killer and CFG.KillerESP) or (not killer and CFG.SurvivorESP) then
                    local e = createPlayerESP(plr)
                    local d = (myHRP.Position - hrp.Position).Magnitude
                    if d <= CFG.ESPRange then
                        local roleColor = killer and CFG.ColorKiller or CFG.ColorSurvivor
                        if plr.Character:GetAttribute("Knocked") then
                            roleColor = CFG.ColorSurvivorKnocked
                        elseif hum.Health < hum.MaxHealth then
                            roleColor = CFG.ColorSurvivorInjured
                        end
                        e.hl.Adornee = plr.Character
                        e.hl.FillColor = roleColor
                        e.hl.OutlineColor = roleColor
                        e.hl.Enabled = true
                        e.bb.Adornee = hrp
                        e.bb.Enabled = true
                        e.name.Text = plr.DisplayName
                        e.name.TextColor3 = roleColor
                        local state = "Healthy"
                        if plr.Character:GetAttribute("Knocked") then state = "Knocked"
                        elseif plr.Character:GetAttribute("IsHooked") then state = "Hooked"
                        elseif hum.Health < hum.MaxHealth then state = "Injured" end
                        e.info.Text = string.format("[%dm] %s | %s", math.floor(d), killer and "KILLER" or "SURVIVOR", state)
                    else
                        e.hl.Enabled = false
                        e.bb.Enabled = false
                    end
                else
                    local e = ActiveESP.Players[plr]
                    if e then e.hl.Enabled = false; e.bb.Enabled = false end
                end
            end
        end
    end
end

local function clearMapESP()
    for i, e in pairs(ActiveESP.Map) do
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.bb:Destroy() end)
    end
    ActiveESP.Map = {}
end

local function scanMapESP()
    clearMapESP()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    for _, inst in ipairs(map:GetDescendants()) do
        local n = inst.Name
        local role = nil
        if n == "Generator" and inst:IsA("Model") then role = "Gen"
        elseif n == "Hook" or n == "HookPoint" then role = "Hook"
        elseif n == "Pallet" and inst:IsA("Model") then role = "Pallet"
        elseif n == "Window" or n == "Vault" then role = "Vault"
        elseif n == "ExitLever" then role = "Gate" end
        if role then
            local show = (role == "Gen" and CFG.GenESP) or (role == "Hook" and CFG.HookESP)
                or (role == "Pallet" and CFG.PalletESP) or (role == "Vault" and CFG.VaultESP) or (role == "Gate" and CFG.GateESP)
            if show then
                local color = CFG["Color" .. role]
                local hl = Instance.new("Highlight")
                hl.FillTransparency = CFG.ESPFill
                hl.OutlineTransparency = CFG.ESPOutline
                hl.FillColor = color
                hl.OutlineColor = color
                hl.Enabled = true
                hl.Adornee = inst
                hl.Parent = highlightParent
                local bb = Instance.new("BillboardGui")
                bb.AlwaysOnTop = true
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.Size = UDim2.new(0, 120, 0, 30) -- Ukuran lebih tinggi buat progres
                bb.Enabled = true
                bb.Adornee = inst:IsA("Model") and (inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart")) or inst
                bb.Parent = highlightParent
                local lbl = Instance.new("TextLabel", bb)
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = color
                lbl.TextStrokeTransparency = 0.4
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 11
                lbl.Text = role
                ActiveESP.Map[inst] = { hl = hl, bb = bb, label = lbl, role = role }
            end
        end
    end
end

local function updateMapESPText()
    for inst, data in pairs(ActiveESP.Map) do
        if not inst.Parent then
            data.hl:Destroy()
            data.bb:Destroy()
            ActiveESP.Map[inst] = nil
        else
            if data.role == "Gen" then
                local prog = getGeneratorProgress(inst)
                local color = CFG.ColorGenerator
                if prog >= 100 then
                    color = Color3.fromRGB(80, 255, 120) -- Hijau kalau udah 100%
                else
                    color = CFG.ColorGenerator
                end
                data.label.Text = string.format("Generator [%d%%]", prog)
                data.label.TextColor3 = color
                data.hl.FillColor = color
                data.hl.OutlineColor = color
            end
        end
    end
end

-- ============================================================
-- 3. SKILL CHECK (Hypnosis Logic)
-- ============================================================
local randomValue = 104
local sum = 114
local check, line, trapPerfect = nil, nil, nil
local resultValue3, resultValue4, timestamp2, rotation, enabled2, timestamp3, enabled3, rotation2, resultValue5, numberValue, enabled4 = nil, nil, nil, nil, false, 0, false, nil, nil, 0, false

local function getSkillGui()
    local playerGui = LP:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
    local skillCheckPromptGui = playerGui:FindFirstChild("SkillCheckPromptGui")
    if skillCheckPromptGui and skillCheckPromptGui:IsA("ScreenGui") then
        local check2 = skillCheckPromptGui:FindFirstChild("Check")
        if check2 and check2.Visible then return skillCheckPromptGui end
    end
    local skillCheckPromptGuiCon = playerGui:FindFirstChild("SkillCheckPromptGui-con")
    if skillCheckPromptGuiCon and skillCheckPromptGuiCon:IsA("ScreenGui") then
        local check2 = skillCheckPromptGuiCon:FindFirstChild("Check")
        if check2 and check2.Visible then return skillCheckPromptGuiCon end
    end
    return skillCheckPromptGui or skillCheckPromptGuiCon
end

local function handleAction9()
    local resultValue6 = getSkillGui()
    if not resultValue6 then check, line, trapPerfect = nil, nil, nil; return false end
    resultValue4 = resultValue6
    check = resultValue6:FindFirstChild("Check")
    if not check then return false end
    line = check:FindFirstChild("Line")
    local trapPerfect2 = check:FindFirstChild("TrapPerfect")
    local trapGoal = check:FindFirstChild("TrapGoal")
    local goal = check:FindFirstChild("Goal")
    if trapPerfect2 and trapPerfect2.Visible then trapPerfect = trapPerfect2
    elseif trapGoal and trapGoal.Visible then trapPerfect = trapGoal
    elseif trapPerfect2 then trapPerfect = trapPerfect2
    elseif goal then trapPerfect = goal
    else trapPerfect = nil end
    if line and trapPerfect then timestamp3 = 0; return true end
    return false
end

local function handleAction8()
    task.spawn(function()
        local playerGui = LP:FindFirstChildOfClass("PlayerGui")
        local survivorMob = playerGui and (playerGui:FindFirstChild("Survivor-mob") or playerGui:FindFirstChild("Survivor") or playerGui:FindFirstChild("Survivor-con"))
        local matchesCondition2 = isMobile or UserInputService.TouchEnabled or survivorMob and survivorMob.Name == "Survivor-mob"
        if matchesCondition2 then
            pcall(function()
                if survivorMob then
                    local controls = survivorMob:FindFirstChild("Controls")
                    local action = controls and controls:FindFirstChild("action")
                    if action then
                        if firesignal then
                            pcall(firesignal, action.MouseButton1Down)
                            pcall(firesignal, action.MouseButton1Click)
                        end
                    end
                end
            end)
        else
            local resultValue = getSkillGui()
            local matchesCondition3 = resultValue and resultValue.Name == "SkillCheckPromptGui-con"
            pcall(function()
                if matchesCondition3 then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.ButtonL1, false, game)
                    task.wait(0.02)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.ButtonL1, false, game)
                else
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.02)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end
            end)
        end
    end)
end

local function handleAction4()
    local skillCheckMode = CFG.SkillCheckMode or "Perfect"
    if skillCheckMode == "Normal" then
        local randomValue2 = math.random(125, 155)
        randomValue = randomValue2
        sum = randomValue2 + 10
    else
        local premiumAvailable = math.clamp(CFG.PerfectRate or 100, 0, 100)
        if math.random(1, 100) <= premiumAvailable then
            randomValue = 104
            sum = 114
        else
            local randomValue2 = math.random(125, 155)
            randomValue = randomValue2
            sum = randomValue2 + 10
        end
    end
end

local function handleAction10()
    local resultValue6 = getSkillGui()
    if not resultValue6 or not resultValue6:IsA("ScreenGui") then return false end
    local check2 = resultValue6:FindFirstChild("Check")
    if not check2 or not check2.Visible then return false end
    if resultValue4 ~= resultValue6 then handleAction9() end
    return true
end

-- ============================================================
-- 4. AIMBOT & SILENT AIM
-- ============================================================
local function getClosestTarget(maxDist, priority)
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen and sp.Z > 0 then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d <= maxDist then
                        if priority == "Furthest" then
                            if d > bestDist then best, bestDist = plr, d end
                        else
                            if d < bestDist then best, bestDist = plr, d end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function updateAimbot()
    if not CFG.RevolverAimbot then return end
    if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget(CFG.RevolverAimbotRadius, "Nearest")
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position) end
        end
    end
end

local function setupHooks()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if not checkcaller() and method == "FireServer" and typeof(self) == "Instance" then
            local n = self.Name:lower()
            if n == "vaultevent" and CFG.AlwaysFastVault then
                if args[2] == false then args[2] = true end
                return oldNamecall(self, unpack(args))
            end
            if n == "fire" and self.Parent and self.Parent.Name:lower():find("twist") then
                if CFG.RevolverSilent then
                    local target = getClosestTarget(200, "Nearest")
                    if target and target.Character then
                        local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                        if head and args[2] then args[2] = (head.Position - Camera.CFrame.Position).Unit end
                        return oldNamecall(self, unpack(args))
                    end
                end
            elseif n == "spearthrow" then
                if CFG.SpearSilent then
                    local target = getClosestTarget(240, "Nearest")
                    if target and target.Character then
                        local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                        if head and args[1] then
                            args[1] = { Origin = Camera.CFrame.Position, Direction = (head.Position - Camera.CFrame.Position).Unit }
                        end
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

-- ============================================================
-- 5. AUTO PARRY
-- ============================================================
local parryAnimIds = {
    ["71008020992570"]=true, ["72742711718023"]=true, ["72908958549833"]=true, ["73681849513551"]=true,
    ["73923929500477"]=true, ["74968262036854"]=true, ["75857500533792"]=true, ["76385865186777"]=true,
    ["76503974441748"]=true, ["76744850905644"]=true, ["77081789642514"]=true, ["78432063483146"]=true,
}
local function fireParry()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local s = pg and (pg:FindFirstChild("Survivor") or pg:FindFirstChild("Survivor-mob"))
    local c = s and s:FindFirstChild("Controls")
    local a = c and c:FindFirstChild("action")
    if a and firesignal then pcall(firesignal, a.MouseButton1Down); pcall(firesignal, a.MouseButton1Click) end
end
local function hookKiller(plr)
    if not plr or plr == LP or not plr.Character then return end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local an = hum and hum:FindFirstChildOfClass("Animator")
    if an and not an:GetAttribute("X6_Hooked") then
        an:SetAttribute("X6_Hooked", true)
        an.AnimationPlayed:Connect(function(t)
            if not CFG.AutoParry then return end
            local id = tostring(t.Animation and t.Animation.AnimationId or ""):match("%d+")
            if id and parryAnimIds[id] then
                local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local k = plr.Character:FindFirstChild("HumanoidRootPart")
                if my and k and (my.Position - k.Position).Magnitude <= CFG.ParryRange then fireParry() end
            end
        end)
    end
end

-- ============================================================
-- 6. RENDER & HEARTBEAT LOOPS
-- ============================================================
RunService.RenderStepped:Connect(function()
    pcall(updatePlayersESP)
    pcall(updateMapESPText)
    pcall(updateAimbot)
    
    if CFG.AutoSkillCheck then
        if not handleAction10() then
            check, line, trapPerfect = nil, nil, nil
            timestamp2, rotation, enabled2, enabled3, rotation2, resultValue5, numberValue, enabled4 = nil, nil, false, false, nil, nil, 0, false
        else
            local trapGoal = nil
            if check then
                local trapGoal2 = check:FindFirstChild("TrapGoal")
                local trapPerfect2 = check:FindFirstChild("TrapPerfect")
                if trapGoal2 and trapGoal2.Visible then trapGoal = trapGoal2
                elseif trapPerfect2 and trapPerfect2.Visible then trapGoal = trapPerfect2
                else trapGoal = check:FindFirstChild("Goal") end
            end
            if trapGoal and trapGoal ~= trapPerfect then
                trapPerfect = trapGoal
                rotation2 = nil
            end
            if check and line and trapPerfect then
                local rotation3 = trapPerfect.Rotation
                if rotation2 == nil or math.abs(rotation2 - rotation3) > 0.05 then
                    rotation2 = rotation3
                    enabled3, enabled4, timestamp2, rotation, enabled2 = false, false, tick(), nil, false
                    handleAction4()
                end
                if CFG.InstantSkillCheck then
                    if not enabled3 and not enabled4 then
                        enabled3, enabled4 = true, true
                        task.spawn(function()
                            task.wait(0.1)
                            if handleAction10() and check and line and trapPerfect then
                                local remainder = trapPerfect.Rotation % 360
                                if remainder < 0 then remainder = remainder + 360 end
                                local rotation4 = (remainder + (randomValue + sum) / 2) % 360
                                local sum2 = tick() + 0.25
                                task.spawn(function()
                                    while tick() < sum2 and handleAction10() and line do
                                        line.Rotation = rotation4
                                        RunService.RenderStepped:Wait()
                                    end
                                end)
                                handleAction8()
                            end
                        end)
                    end
                else
                    if not timestamp2 then timestamp2, enabled4 = tick(), false; handleAction4() end
                    if tick() - timestamp2 > 0.1 then
                        local rotation4 = line.Rotation
                        local remainder = rotation4 % 360
                        local remainder2 = trapPerfect.Rotation % 360
                        if remainder < 0 then remainder = remainder + 360 end
                        if remainder2 < 0 then remainder2 = remainder2 + 360 end
                        local remainder3 = (remainder2 + randomValue) % 360
                        local remainder4 = (remainder2 + sum) % 360
                        local matchesCondition3
                        if remainder3 > remainder4 then matchesCondition3 = remainder >= remainder3 or remainder <= remainder4
                        else matchesCondition3 = remainder >= remainder3 and remainder <= remainder4 end
                        local matchesCondition4 = matchesCondition3
                        if rotation then
                            local remainder5 = rotation % 360
                            if remainder5 < 0 then remainder5 = remainder5 + 360 end
                            local difference = rotation4 - rotation
                            if difference < -180 then difference = difference + 360
                            elseif difference > 180 then difference = difference - 360 end
                            if math.abs(difference) > 0.05 and math.abs(difference) < 100 then
                                enabled2 = true
                                local enabled = false
                                if difference > 0 then
                                    local remainder6 = (remainder3 - remainder5) % 360
                                    local remainder7 = (remainder3 - remainder) % 360
                                    if remainder6 < 180 and remainder7 > 180 then enabled = true end
                                else
                                    local remainder6 = (remainder5 - remainder4) % 360
                                    local remainder7 = (remainder - remainder4) % 360
                                    if remainder6 < 180 and remainder7 > 180 then enabled = true end
                                end
                                if enabled then matchesCondition4 = true end
                            end
                        end
                        rotation = rotation4
                        if enabled2 then
                            if enabled4 and tick() - (timestamp3 or 0) > 0.18 and not matchesCondition3 then enabled4 = false end
                            if matchesCondition4 and not enabled4 then
                                enabled4 = true
                                timestamp3 = tick()
                                handleAction8()
                            end
                        end
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if CFG.SpeedBoost then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 and hum.MoveDirection.Magnitude > 0.05 then
            local spd = char:GetAttribute("Speed") or 16
            local target = spd * CFG.SpeedMult
            local dir = Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z).Unit
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * target, hrp.AssemblyLinearVelocity.Y, dir.Z * target)
        end
    end
    if CFG.NoclipVaultsPallets then
        local char = LP.Character
        if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end
    if CFG.FullBright then
        Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255); Lighting.GlobalShadows = false
    end
    if CFG.NoFog then Lighting.FogStart = 1e6; Lighting.FogEnd = 1e6 end
    if Camera then Camera.FieldOfView = CFG.FOV end
end)

-- ============================================================
-- 7. UI MODERN & COLOR PICKER
-- ============================================================
local function getSVG(svgString)
    return "data:image/svg+xml;utf8," .. svgString
end

local Icons = {
    Combat = getSVG('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#f0f2fa" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 17.5 3 6V3h3l11.5 11.5"/><path d="M13 19l6-6"/><path d="M16 16l4 4"/><path d="M19 21l2-2"/></svg>'),
    ESP = getSVG('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#f0f2fa" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/><circle cx="12" cy="12" r="3"/></svg>'),
    Farm = getSVG('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#f0f2fa" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z"/><path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12"/></svg>'),
    Mods = getSVG('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#f0f2fa" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>'),
    Visuals = getSVG('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#f0f2fa" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="13.5" cy="6.5" r=".5" fill="#f0f2fa"/><circle cx="17.5" cy="10.5" r=".5" fill="#f0f2fa"/><circle cx="8.5" cy="7.5" r=".5" fill="#f0f2fa"/><circle cx="6.5" cy="12.5" r=".5" fill="#f0f2fa"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.92 0 1.5-.7 1.5-1.5 0-.4-.2-.8-.4-1.1-.3-.3-.4-.7-.4-1.1 0-.8.7-1.5 1.5-1.5H16c3.3 0 6-2.7 6-6 0-5.5-4.5-10-10-10z"/></svg>'),
}

local Colors = {
    Bg = Color3.fromRGB(10, 11, 14),
    Sidebar = Color3.fromRGB(14, 15, 20),
    Card = Color3.fromRGB(22, 24, 30),
    Hover = Color3.fromRGB(30, 33, 42),
    Stroke = Color3.fromRGB(40, 42, 55),
    Accent = Color3.fromRGB(100, 150, 255),
    Text = Color3.fromRGB(240, 242, 250),
    TextDim = Color3.fromRGB(130, 135, 150),
}

local function buildUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "BintangX6LocHUB"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = LP:WaitForChild("PlayerGui")

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 660, 0, 460)
    main.Position = UDim2.new(0.5, -330, 0.5, -230)
    main.BackgroundColor3 = Colors.Bg
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.Active = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Colors.Stroke
    stroke.Thickness = 1.5

    local bgWatermark = Instance.new("ImageLabel", main)
    bgWatermark.Size = UDim2.new(1, 0, 1, 0)
    bgWatermark.BackgroundTransparency = 1
    bgWatermark.Image = LOGO_ASSET
    bgWatermark.ScaleType = Enum.ScaleType.Crop
    bgWatermark.ImageTransparency = 0.75 
    bgWatermark.ZIndex = 0
    Instance.new("UICorner", bgWatermark).CornerRadius = UDim.new(0, 12)
    
    local bgOverlay = Instance.new("Frame", main)
    bgOverlay.Size = UDim2.new(1, 0, 1, 0)
    bgOverlay.BackgroundColor3 = Colors.Bg
    bgOverlay.BackgroundTransparency = 0.4
    bgOverlay.BorderSizePixel = 0
    bgOverlay.ZIndex = 0
    Instance.new("UICorner", bgOverlay).CornerRadius = UDim.new(0, 12)

    local side = Instance.new("Frame", main)
    side.Size = UDim2.new(0, 170, 1, 0)
    side.BackgroundColor3 = Colors.Sidebar
    side.BackgroundTransparency = 0.2
    side.BorderSizePixel = 0
    side.ZIndex = 1
    Instance.new("UICorner", side).CornerRadius = UDim.new(0, 12)
    local sideStroke = Instance.new("UIStroke", side)
    sideStroke.Color = Colors.Stroke
    sideStroke.Thickness = 1
    sideStroke.Transparency = 0.5    local header = Instance.new("Frame", side)
    header.Size = UDim2.new(1, -20, 0, 60)
    header.Position = UDim2.new(0, 10, 0, 10)
    header.BackgroundTransparency = 1

    local miniLogo = Instance.new("ImageLabel", header)
    miniLogo.Size = UDim2.new(0, 32, 0, 32)
    miniLogo.Position = UDim2.new(0, 0, 0.5, -16)
    miniLogo.BackgroundColor3 = Colors.Card
    miniLogo.Image = LOGO_ASSET
    miniLogo.ScaleType = Enum.ScaleType.Crop
    miniLogo.ZIndex = 2
    Instance.new("UICorner", miniLogo).CornerRadius = UDim.new(0, 6)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -42, 0, 20)
    title.Position = UDim2.new(0, 42, 0.5, -12)
    title.BackgroundTransparency = 1
    title.Text = "BintangX6"
    title.TextColor3 = Colors.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 2

    local subtitle = Instance.new("TextLabel", header)
    subtitle.Size = UDim2.new(1, -42, 0, 14)
    subtitle.Position = UDim2.new(0, 42, 0.5, 6)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "LocHUB"
    subtitle.TextColor3 = Colors.Accent
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 2

    local tabScroll = Instance.new("ScrollingFrame", side)
    tabScroll.Size = UDim2.new(1, -12, 1, -90)
    tabScroll.Position = UDim2.new(0, 6, 0, 70)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 0
    tabScroll.ZIndex = 1
    local tabList = Instance.new("UIListLayout", tabScroll)
    tabList.Padding = UDim.new(0, 4)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -185, 1, -20)
    content.Position = UDim2.new(0, 175, 0, 10)
    content.BackgroundTransparency = 1
    content.ZIndex = 1

    local pages = {}
    local tabButtons = {}

    local function makeTab(id, iconSvg, name, order)
        local btn = Instance.new("TextButton", tabScroll)
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Colors.Card
        btn.BackgroundTransparency = 0.8
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        local ic = Instance.new("ImageLabel", btn)
        ic.Size = UDim2.new(0, 16, 0, 16)
        ic.Position = UDim2.new(0, 12, 0.5, -8)
        ic.BackgroundTransparency = 1
        ic.Image = iconSvg
        ic.ImageColor3 = Colors.TextDim
        ic.ZIndex = 2
        
        local tx = Instance.new("TextLabel", btn)
        tx.Size = UDim2.new(1, -44, 1, 0)
        tx.Position = UDim2.new(0, 38, 0, 0)
        tx.BackgroundTransparency = 1
        tx.Text = name
        tx.TextColor3 = Colors.TextDim
        tx.Font = Enum.Font.GothamBold
        tx.TextSize = 12
        tx.TextXAlignment = Enum.TextXAlignment.Left
        tx.ZIndex = 2
        
        tabButtons[id] = { btn = btn, txt = tx, ic = ic }
        
        btn.MouseButton1Click:Connect(function()
            for _, tb in pairs(tabButtons) do
                TweenService:Create(tb.btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, BackgroundColor3 = Colors.Card}):Play()
                TweenService:Create(tb.txt, TweenInfo.new(0.2), {TextColor3 = Colors.TextDim}):Play()
                TweenService:Create(tb.ic, TweenInfo.new(0.2), {ImageColor3 = Colors.TextDim}):Play()
            end
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, BackgroundColor3 = Colors.Hover}):Play()
            TweenService:Create(tx, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
            TweenService:Create(ic, TweenInfo.new(0.2), {ImageColor3 = Colors.Accent}):Play()
            for pid, pg in pairs(pages) do pg.Visible = (pid == id) end
        end)
        return btn
    end

    local function makePage(id)
        local f = Instance.new("ScrollingFrame", content)
        f.Size = UDim2.new(1, 0, 1, 0)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.ScrollBarThickness = 2
        f.ScrollBarImageColor3 = Colors.Accent
        f.CanvasSize = UDim2.new(0, 0, 0, 0)
        f.AutomaticCanvasSize = Enum.AutomaticSize.Y
        f.Visible = false
        local ll = Instance.new("UIListLayout", f)
        ll.Padding = UDim.new(0, 6)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        pages[id] = f
        return f
    end

    local function addSection(parent, text)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, 0, 0, 24)
        l.BackgroundTransparency = 1
        l.Text = text:upper()
        l.TextColor3 = Colors.Accent
        l.Font = Enum.Font.GothamBold
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function addToggle(parent, label, key, order)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 36)
        b.BackgroundColor3 = Colors.Card
        b.BackgroundTransparency = 0.2
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.LayoutOrder = order
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

        local kn = Instance.new("Frame", b)
        kn.Size = UDim2.new(0, 28, 0, 16)
        kn.Position = UDim2.new(1, -38, 0.5, -8)
        kn.BackgroundColor3 = CFG[key] and Colors.Accent or Colors.Stroke
        kn.BorderSizePixel = 0
        Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
        
        local dot = Instance.new("Frame", kn)
        dot.Size = UDim2.new(0, 12, 0, 12)
        dot.Position = CFG[key] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1, -50, 1, 0)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = label
        l.TextColor3 = Colors.Text
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left

        b.MouseButton1Click:Connect(function()
            CFG[key] = not CFG[key]
            TweenService:Create(kn, TweenInfo.new(0.2), {BackgroundColor3 = CFG[key] and Colors.Accent or Colors.Stroke}):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = CFG[key] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
            if key:find("ESP") then task.spawn(scanMapESP) end
        end)
    end

    local function addColorPicker(parent, label, key, order)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 36)
        f.BackgroundColor3 = Colors.Card
        f.BackgroundTransparency = 0.2
        f.BorderSizePixel = 0
        f.LayoutOrder = order
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -60, 1, 0)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = label
        l.TextColor3 = Colors.Text
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        
        local colorBox = Instance.new("Frame", f)
        colorBox.Size = UDim2.new(0, 24, 0, 24)
        colorBox.Position = UDim2.new(1, -36, 0.5, -12)
        colorBox.BackgroundColor3 = CFG[key]
        colorBox.BorderSizePixel = 0
        Instance.new("UICorner", colorBox).CornerRadius = UDim.new(0, 4)
        local cStroke = Instance.new("UIStroke", colorBox)
        cStroke.Color = Colors.Stroke
        
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        
        btn.MouseButton1Click:Connect(function()
            local colors = {
                Color3.fromRGB(255,60,60), Color3.fromRGB(80,255,120), Color3.fromRGB(0,200,255),
                Color3.fromRGB(255,180,60), Color3.fromRGB(255,150,0), Color3.fromRGB(200,160,80),
                Color3.fromRGB(180,180,180), Color3.fromRGB(255,220,0), Color3.fromRGB(150,0,255)
            }
            local currentIdx = 1
            for i, c in ipairs(colors) do
                if c == CFG[key] then currentIdx = i; break end
            end
            currentIdx = currentIdx + 1
            if currentIdx > #colors then currentIdx = 1 end
            CFG[key] = colors[currentIdx]
            colorBox.BackgroundColor3 = CFG[key]
            task.spawn(scanMapESP)
        end)
    end

    local function addSlider(parent, label, key, min, max, order)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 50)
        f.BackgroundColor3 = Colors.Card
        f.BackgroundTransparency = 0.2
        f.BorderSizePixel = 0
        f.LayoutOrder = order
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -20, 0, 18)
        l.Position = UDim2.new(0, 12, 0, 4)
        l.BackgroundTransparency = 1
        l.Text = label .. ": " .. tostring(CFG[key])
        l.TextColor3 = Colors.Text
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        local bar = Instance.new("Frame", f)
        bar.Size = UDim2.new(1, -24, 0, 6)
        bar.Position = UDim2.new(0, 12, 0, 32)
        bar.BackgroundColor3 = Colors.Stroke
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((CFG[key]-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Colors.Accent
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local dragging = false
        bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
        bar.InputEnded:Connect(function() dragging = false end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local v = min + rel * (max - min)
                CFG[key] = v
                fill.Size = UDim2.new(rel, 0, 1, 0)
                l.Text = label .. ": " .. string.format("%.1f", v)
            end
        end)
    end

    -- ============================================================
    -- TAB CONTENT WIRING
    -- ============================================================
    makeTab("Combat", Icons.Combat, "Combat", 1)
    makeTab("ESP", Icons.ESP, "ESP", 2)
    makeTab("Farm", Icons.Farm, "Farm", 3)
    makeTab("Mods", Icons.Mods, "Modifiers", 4)
    makeTab("Visuals", Icons.Visuals, "Visuals", 5)

    local cb = makePage("Combat")
    addSection(cb, "Skill Check")
    addToggle(cb, "Auto Skill Check", "AutoSkillCheck", 1)
    addToggle(cb, "Instant Skill Check", "InstantSkillCheck", 2)
    addSection(cb, "Combat")
    addToggle(cb, "Auto Parry (Killer)", "AutoParry", 3)
    addToggle(cb, "Revolver Silent Aim", "RevolverSilent", 4)
    addToggle(cb, "Spear Silent Aim", "SpearSilent", 5)
    addToggle(cb, "Revolver Aimbot", "RevolverAimbot", 6)

    local ep = makePage("ESP")
    addSection(ep, "Player ESP")
    addToggle(ep, "Killer ESP", "KillerESP", 1)
    addToggle(ep, "Survivor ESP", "SurvivorESP", 2)
    addSection(ep, "Warna Player")
    addColorPicker(ep, "Warna Killer", "ColorKiller", 3)
    addColorPicker(ep, "Warna Survivor", "ColorSurvivor", 4)
    addColorPicker(ep, "Warna Injured", "ColorSurvivorInjured", 5)
    addColorPicker(ep, "Warna Knocked", "ColorSurvivorKnocked", 6)
    addSection(ep, "Map ESP")
    addToggle(ep, "Generator", "GenESP", 7)
    addToggle(ep, "Gate", "GateESP", 8)
    addToggle(ep, "Hook", "HookESP", 9)
    addToggle(ep, "Pallet", "PalletESP", 10)
    addToggle(ep, "Vault", "VaultESP", 11)
    addSection(ep, "Warna Map")
    addColorPicker(ep, "Warna Generator", "ColorGenerator", 12)
    addColorPicker(ep, "Warna Gate", "ColorGate", 13)
    addColorPicker(ep, "Warna Hook", "ColorHook", 14)
    addColorPicker(ep, "Warna Pallet", "ColorPallet", 15)
    addColorPicker(ep, "Warna Vault", "ColorVault", 16)

    local fm = makePage("Farm")
    addSection(fm, "Auto Farm")
    addToggle(fm, "Auto Farm Survivor", "AutoFarmSurvivor", 1)
    addToggle(fm, "Auto Farm Killer", "AutoFarmKiller", 2)
    addToggle(fm, "Auto Flee Killer", "AutoFlee", 3)

    local md = makePage("Mods")
    addSection(md, "Movement")
    addToggle(md, "Speed Boost", "SpeedBoost", 1)
    addSlider(md, "Speed Multiplier", "SpeedMult", 1, 3, 2)
    addSection(md, "Vault/Pallet")
    addToggle(md, "Always Fast Vault", "AlwaysFastVault", 3)
    addToggle(md, "Noclip Vaults/Pallets", "NoclipVaultsPallets", 4)

    local vs = makePage("Visuals")
    addSection(vs, "Lighting")
    addToggle(vs, "Full Bright", "FullBright", 1)
    addToggle(vs, "No Fog", "NoFog", 2)
    addSlider(vs, "Field of View", "FOV", 70, 160, 3)

    -- BH BUTTON & DRAG
    local bh = Instance.new("TextButton", sg)
    bh.Size = UDim2.new(0, 44, 0, 44)
    bh.Position = UDim2.new(0, 20, 0, 200)
    bh.BackgroundColor3 = Colors.Bg
    bh.BorderSizePixel = 0
    bh.Text = "BH"
    bh.TextColor3 = Colors.Accent
    bh.Font = Enum.Font.GothamBold
    bh.TextSize = 14
    bh.AutoButtonColor = false
    bh.ZIndex = 5
    Instance.new("UICorner", bh).CornerRadius = UDim.new(1, 0)
    local bhStroke = Instance.new("UIStroke", bh)
    bhStroke.Color = Colors.Accent
    bhStroke.Thickness = 1.5
    bh.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
        end
    end)
    header.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    header.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    tabButtons["ESP"].btn.MouseButton1Click:Fire()
end

task.spawn(function()
    while not LP do task.wait(0.5); LP = Players.LocalPlayer end
    pcall(setupHooks)
    task.spawn(function() while true do task.wait(3); pcall(scanMapESP); for _, plr in ipairs(Players:GetPlayers()) do if isKiller(plr) then hookKiller(plr) end end end end)
    buildUI()
end)