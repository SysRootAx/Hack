-- ==================================================
-- 🏹 HUB DE LANÇAMENTO DE LANÇA
-- Botão LANÇAR: alcance de 24.649 studs
-- Toggle PREGOS: auto-lança em 80.873,98 studs
-- LocalScript em StarterPlayerScripts
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ===================== CONFIGURAÇÕES =====================

local DISTANCIA_BOTAO   = 24649          -- studs ao clicar em LANÇAR
local DISTANCIA_PREGOS  = 80873.98       -- studs no modo Pregos (auto)
local GRAVIDADE         = workspace.Gravity
local ANGULO_LANCAMENTO = math.rad(45)
local COOLDOWN          = 2              -- cooldown do botão LANÇAR (segundos)
local INTERVALO_PREGOS  = 0.3           -- intervalo entre lançamentos automáticos (segundos)

-- Velocidades calculadas via fórmula balística: v = sqrt(d * g / sin(2θ))
local velBotao  = math.sqrt(DISTANCIA_BOTAO  * GRAVIDADE / math.sin(2 * ANGULO_LANCAMENTO))
local velPrecos = math.sqrt(DISTANCIA_PREGOS * GRAVIDADE / math.sin(2 * ANGULO_LANCAMENTO))

-- ===================== CRIAÇÃO DO HUB (GUI) =====================

if player.PlayerGui:FindFirstChild("LancaHub") then
    player.PlayerGui:FindFirstChild("LancaHub"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LancaHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- Frame principal
local frame = Instance.new("Frame")
frame.Name = "HubFrame"
frame.Size = UDim2.new(0, 250, 0, 210)
frame.Position = UDim2.new(0.5, -125, 0.82, -105)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 110, 0)
frameStroke.Thickness = 2.5
frameStroke.Parent = frame

-- Sombra
local sombra = Instance.new("Frame")
sombra.Size = UDim2.new(1, 6, 1, 6)
sombra.Position = UDim2.new(0, -3, 0, 4)
sombra.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sombra.BackgroundTransparency = 0.6
sombra.BorderSizePixel = 0
sombra.ZIndex = frame.ZIndex - 1
sombra.Parent = frame

local sombraCorner = Instance.new("UICorner")
sombraCorner.CornerRadius = UDim.new(0, 14)
sombraCorner.Parent = sombra

-- Barra de título
local titulo = Instance.new("TextLabel")
titulo.Name = "Titulo"
titulo.Size = UDim2.new(1, 0, 0, 38)
titulo.Position = UDim2.new(0, 0, 0, 0)
titulo.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
titulo.BorderSizePixel = 0
titulo.Text = "🏹  Hub de Lança"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextScaled = true
titulo.Font = Enum.Font.GothamBold
titulo.ZIndex = 2
titulo.Parent = frame

local tituloCorner = Instance.new("UICorner")
tituloCorner.CornerRadius = UDim.new(0, 14)
tituloCorner.Parent = titulo

local tituloFix = Instance.new("Frame")
tituloFix.Size = UDim2.new(1, 0, 0, 14)
tituloFix.Position = UDim2.new(0, 0, 1, -14)
tituloFix.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
tituloFix.BorderSizePixel = 0
tituloFix.ZIndex = 2
tituloFix.Parent = titulo

-- Info: alcance do botão
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "InfoLabel"
infoLabel.Size = UDim2.new(1, -14, 0, 20)
infoLabel.Position = UDim2.new(0, 7, 0, 44)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "📏 Lançar: 24.649 studs  |  ⚙️ CD: " .. COOLDOWN .. "s"
infoLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.ZIndex = 2
infoLabel.Parent = frame

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -14, 0, 18)
statusLabel.Position = UDim2.new(0, 7, 0, 67)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "✅ Pronto para lançar!"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.ZIndex = 2
statusLabel.Parent = frame

-- Botão LANÇAR
local botao = Instance.new("TextButton")
botao.Name = "BotaoLancar"
botao.Size = UDim2.new(0, 210, 0, 40)
botao.Position = UDim2.new(0.5, -105, 0, 90)
botao.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
botao.BorderSizePixel = 0
botao.Text = "⚡  LANÇAR"
botao.TextColor3 = Color3.fromRGB(255, 255, 255)
botao.TextScaled = true
botao.Font = Enum.Font.GothamBold
botao.AutoButtonColor = false
botao.ZIndex = 2
botao.Parent = frame

local botaoCorner = Instance.new("UICorner")
botaoCorner.CornerRadius = UDim.new(0, 10)
botaoCorner.Parent = botao

local botaoStroke = Instance.new("UIStroke")
botaoStroke.Color = Color3.fromRGB(255, 180, 80)
botaoStroke.Thickness = 1.5
botaoStroke.Parent = botao

-- Separador
local sep = Instance.new("Frame")
sep.Size = UDim2.new(0, 210, 0, 1)
sep.Position = UDim2.new(0.5, -105, 0, 140)
sep.BackgroundColor3 = Color3.fromRGB(255, 110, 0)
sep.BackgroundTransparency = 0.5
sep.BorderSizePixel = 0
sep.ZIndex = 2
sep.Parent = frame

-- Label "PREGOS"
local pregosLabel = Instance.new("TextLabel")
pregosLabel.Name = "PregosLabel"
pregosLabel.Size = UDim2.new(0, 140, 0, 22)
pregosLabel.Position = UDim2.new(0, 10, 0, 148)
pregosLabel.BackgroundTransparency = 1
pregosLabel.Text = "📌 Pregos (80.873 studs)"
pregosLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
pregosLabel.TextScaled = true
pregosLabel.Font = Enum.Font.GothamBold
pregosLabel.TextXAlignment = Enum.TextXAlignment.Left
pregosLabel.ZIndex = 2
pregosLabel.Parent = frame

-- Toggle PREGOS (fundo)
local toggleBg = Instance.new("Frame")
toggleBg.Name = "ToggleBg"
toggleBg.Size = UDim2.new(0, 52, 0, 26)
toggleBg.Position = UDim2.new(1, -62, 0, 149)
toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBg.BorderSizePixel = 0
toggleBg.ZIndex = 2
toggleBg.Parent = frame

local toggleBgCorner = Instance.new("UICorner")
toggleBgCorner.CornerRadius = UDim.new(1, 0)
toggleBgCorner.Parent = toggleBg

-- Toggle PREGOS (bolinha)
local toggleCircle = Instance.new("Frame")
toggleCircle.Name = "ToggleCircle"
toggleCircle.Size = UDim2.new(0, 20, 0, 20)
toggleCircle.Position = UDim2.new(0, 3, 0.5, -10)
toggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
toggleCircle.BorderSizePixel = 0
toggleCircle.ZIndex = 3
toggleCircle.Parent = toggleBg

local toggleCircleCorner = Instance.new("UICorner")
toggleCircleCorner.CornerRadius = UDim.new(1, 0)
toggleCircleCorner.Parent = toggleCircle

-- Toggle PREGOS (botão invisível sobre o fundo)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.Position = UDim2.new(0, 0, 0, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""
toggleBtn.ZIndex = 4
toggleBtn.Parent = toggleBg

-- Status do modo Pregos
local pregosStatus = Instance.new("TextLabel")
pregosStatus.Name = "PregosStatus"
pregosStatus.Size = UDim2.new(1, -14, 0, 18)
pregosStatus.Position = UDim2.new(0, 7, 0, 182)
pregosStatus.BackgroundTransparency = 1
pregosStatus.Text = "🔴 Pregos: DESATIVADO"
pregosStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
pregosStatus.TextScaled = true
pregosStatus.Font = Enum.Font.GothamMedium
pregosStatus.ZIndex = 2
pregosStatus.Parent = frame

-- ===================== EFEITOS VISUAIS DO BOTÃO LANÇAR =====================

botao.MouseEnter:Connect(function()
    botao.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
end)

botao.MouseLeave:Connect(function()
    if botao.Text == "⚡  LANÇAR" then
        botao.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    end
end)

-- ===================== FUNÇÃO: CRIAR LANÇA =====================

local function criarLanca()
    character = player.Character or player.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local lanca = Instance.new("Part")
    lanca.Name = "LancaProjetil"
    lanca.Size = Vector3.new(0.35, 0.35, 3.2)
    lanca.Shape = Enum.PartType.Cylinder
    lanca.BrickColor = BrickColor.new("Bright orange")
    lanca.Material = Enum.Material.Metal
    lanca.Reflectance = 0.3
    lanca.CastShadow = true
    lanca.Anchored = false
    lanca.CanCollide = true
    lanca.CollisionGroup = "Default"

    lanca.CFrame = humanoidRootPart.CFrame
        * CFrame.new(0, 1.2, -2.5)
        * CFrame.Angles(0, math.pi / 2, math.pi / 2)

    lanca.Parent = workspace

    local ponta = Instance.new("SpecialMesh")
    ponta.MeshType = Enum.MeshType.FileMesh
    ponta.MeshId = "rbxasset://fonts/rightarm.mesh"
    ponta.Parent = lanca

    return lanca
end

-- ===================== FUNÇÃO: LANÇAR (genérica) =====================

local function dispararLanca(velocidade)
    character = player.Character or player.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local lanca = criarLanca()

    local lookDir  = humanoidRootPart.CFrame.LookVector
    local velHoriz = velocidade * math.cos(ANGULO_LANCAMENTO)
    local velVert  = velocidade * math.sin(ANGULO_LANCAMENTO)

    local velocidadeVetor = Vector3.new(
        lookDir.X * velHoriz,
        velVert,
        lookDir.Z * velHoriz
    )

    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVel.Velocity = velocidadeVetor
    bodyVel.Parent = lanca

    task.delay(0.08, function()
        if bodyVel and bodyVel.Parent then bodyVel:Destroy() end
    end)

    local hb = nil
    hb = RunService.Heartbeat:Connect(function()
        if lanca and lanca.Parent then
            local vel = lanca.AssemblyLinearVelocity
            if vel.Magnitude > 0.5 then
                local ok = pcall(function()
                    lanca.CFrame = CFrame.lookAt(lanca.Position, lanca.Position + vel)
                        * CFrame.Angles(0, math.pi / 2, math.pi / 2)
                end)
                if not ok and hb then hb:Disconnect() end
            end
        else
            if hb then hb:Disconnect() end
        end
    end)

    task.delay(8, function()
        if hb then hb:Disconnect() end
        if lanca and lanca.Parent then lanca:Destroy() end
    end)
end

-- ===================== BOTÃO LANÇAR (24.649 studs, com cooldown) =====================

local podelancar = true

local function lancarBotao()
    if not podelancar then return end
    podelancar = false

    botao.Text = "⏳  Aguarde..."
    botao.BackgroundColor3 = Color3.fromRGB(90, 45, 0)
    statusLabel.Text = "🕐 Cooldown ativo..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 180, 50)

    dispararLanca(velBotao)

    local tempoRestante = COOLDOWN
    task.spawn(function()
        while tempoRestante > 0 do
            statusLabel.Text = "🕐 Cooldown: " .. tempoRestante .. "s"
            task.wait(1)
            tempoRestante -= 1
        end
    end)

    task.delay(COOLDOWN, function()
        podelancar = true
        botao.Text = "⚡  LANÇAR"
        botao.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
        statusLabel.Text = "✅ Pronto para lançar!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
end

botao.MouseButton1Click:Connect(lancarBotao)

-- ===================== TOGGLE PREGOS (auto-lança 80.873,98 studs) =====================

local pregosAtivo = false
local pregosLoop  = nil

local function setPrecos(ativo)
    pregosAtivo = ativo

    if ativo then
        -- Visual: toggle ON (verde, bolinha direita)
        toggleBg.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        toggleCircle.Position = UDim2.new(1, -23, 0.5, -10)
        toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        pregosStatus.Text = "🟢 Pregos: ATIVADO"
        pregosStatus.TextColor3 = Color3.fromRGB(100, 255, 100)

        -- Loop automático
        pregosLoop = task.spawn(function()
            while pregosAtivo do
                dispararLanca(velPrecos)
                task.wait(INTERVALO_PREGOS)
            end
        end)
    else
        -- Visual: toggle OFF (cinza, bolinha esquerda)
        toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        toggleCircle.Position = UDim2.new(0, 3, 0.5, -10)
        toggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        pregosStatus.Text = "🔴 Pregos: DESATIVADO"
        pregosStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
        pregosLoop = nil
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setPrecos(not pregosAtivo)
end)

-- ===================== RESPAWN =====================

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    -- Para o modo Pregos ao respawnar (segurança)
    pregosAtivo = false
    if pregosLoop then task.cancel(pregosLoop) pregosLoop = nil end
    setPrecos(false)
    -- Reseta botão
    podelancar = true
    botao.Text = "⚡  LANÇAR"
    botao.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    statusLabel.Text = "✅ Pronto para lançar!"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end)

-- ===================== LOG =====================

print(string.format(
    "[LancaHub] ✅ Carregado! | Botão: %.0f studs (v=%.2f) | Pregos: %.2f studs (v=%.2f) | CD: %ds | IntervaloPrecos: %.1fs",
    DISTANCIA_BOTAO, velBotao, DISTANCIA_PREGOS, velPrecos, COOLDOWN, INTERVALO_PREGOS
))
