---@diagnostic disable: undefined-global
local LP = game.Players.LocalPlayer
local RE = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")

local observeTag = require(RE.Packages.Observers.observeTag)
local ReplicatorClient = require(RE.Client.Modules.ReplicatorClient)
local ClientGlobals = require(RE.Client.Modules.ClientGlobals)
local EconomyMath = require(RE.Shared.utils.EconomyMath)
local BrainrotModule = require(RE.SharedModules.BrainrotModule)

repeat wait(0.1) until LP.Character
repeat wait(0.1) until LP.Character:FindFirstChild("Humanoid")

local data = {
    classes = {
        ["Common"] = 1,
        ["Uncommon"] = 2,
        ["Rare"] = 3,
        ["Epic"] = 4,
        ["Legendary"] = 5,
        ["Mythical"] = 6,
        ["Cosmic"] = 7,
        ["Secret"] = 8,
        ["Celestial"] = 9,
        ["Divine"] = 10,
        ["Infinity"] = 11
    },
    mutations = {
        "None",
        "Emerald",
        "Gold",
        "Blood",
        "Electric",
        "Radioactive",
        "UFO",
        "Money",
        "Candy",
        "Doom",
        "Fire",
        "Ice",
        "Gamer",
        "Diamond",
        "Admin",
        "Hacker",
        "Lucky"
    }
}

local modes = {
    highestPotential = 1,
    aboveRate = 2,
    specificTraits = 3,
    onlyLuckyBlocks = 4
}


local settings = {
    tweenSpeedX = 70,
    tweenSpeedY = 50,
    smartTweenY = -20,
    stopScriptKeybind = "F6",
    autoTweenSpeed = true,
    prioritizeEvents = true,
    mode = modes.highestPotential, -- 1 = collect highest potential brainrot, 2 = collect every brainrot above a certain rate, 3 = collect brainrots with specific traits/mutations/classes, 4 = collect only lucky blocks
    brainrotMinRate = 0,
    brainrotMinClass = "Celestial",
    brainrotTraits = {},
    brainrotMutations = {},
    luckyBlockMinClass = "Divine",
    luckyBlockMutations = {}
}

local utils = {
    tween,
    noclipState = false,
    noclipConnection,
    floatConnection,
    breakVelocity = function(self)
        local velocity = Vector3.new(0, 0, 0)
        for i, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Velocity, v.RotVelocity = velocity, velocity
            end
        end
    end,
    nofall = function(self)
        local hrp = LP.Character:WaitForChild("HumanoidRootPart")

	    local att = hrp:FindFirstChild("NoFallAtt") or Instance.new("Attachment")
	    att.Name = "NoFallAtt"
	    att.Parent = hrp

	    local vf = hrp:FindFirstChild("NoFallVF") or Instance.new("VectorForce")
	    vf.Name = "NoFallVF"
	    vf.Attachment0 = att
	    vf.RelativeTo = Enum.ActuatorRelativeTo.World
	    vf.ApplyAtCenterOfMass = true
	    vf.Parent = hrp

	    -- cancel gravity
	    vf.Force = Vector3.new(0, hrp.AssemblyMass * workspace.Gravity, 0)
    end,
    fall = function(self)
        local hrp = LP.Character:WaitForChild("HumanoidRootPart")
	    if not hrp then return end
	    local vf = hrp:FindFirstChild("NoFallVF")
	    local att = hrp:FindFirstChild("NoFallAtt")
	    if vf then vf:Destroy() end
	    if att then att:Destroy() end
    end,
    noclip = function(self)
        self.noclipState = true
        wait(0.1)
        local function noclipLoop()
            if self.noclipState and LP.Character ~= nil then
                for i, v in pairs(LP.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide == true then
                        v.CanCollide = false
                    end
                end
            end
        end
        self.noclipConnection = game:GetService("RunService").Stepped:Connect(noclipLoop)
    end,
    clip = function(self)
        self.noclipState = false
        if self.noclipConnection then
            self.noclipConnection:Disconnect()
        end
    end,
    float = function(self)
        if self.floatConnection then
            if self.floatConnection.Connected then
                return
            end
        end
    	local floatPart = Instance.new('Part')
		floatPart.Name = "floatPart"
		floatPart.Parent = LP.Character
		floatPart.Transparency = 1
		floatPart.Size = Vector3.new(2,0.2,1.5)
		floatPart.Anchored = true
		local floatValue = -3.1
		floatPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0,floatValue,0)
        self.floatConnection = RS.Stepped:Connect(function()
            if floatPart and floatPart.Parent and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                floatPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0,floatValue,0)
            else
                self.floatConnection:Disconnect()
            end
        end)
    end,
    unfloat = function(self)
        if self.floatConnection then
            self.floatConnection:Disconnect()
        end
        if LP.Character:FindFirstChild("floatPart") then
            LP.Character.floatPart:Destroy()
        end
    end,
    tweenToPosition = function(self, position, speed)
        if not LP.Character or not LP.Character:FindFirstChild("Humanoid") then
            return false
        end

        local info = TweenInfo.new((LP.Character.HumanoidRootPart.Position - position).Magnitude / speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
        self.tween = TS:Create(LP.Character.HumanoidRootPart, info, {CFrame = CFrame.new(position.X, position.Y, position.Z)})
        self:noclip()
        self:breakVelocity()
        self.tween:Play()
        local died = false
        local diedConnection = LP.Character.Humanoid.Died:Connect(function()
            if self.tween then
                self.tween:Cancel()
                died = true
                print("Player died, tween cancelled.")
            end
        end)

        self.tween.Completed:Wait()
        diedConnection:Disconnect()
        self:breakVelocity()
        self:clip()
        if self.tween.PlaybackState ~= Enum.PlaybackState.Completed or died or LP.Character.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
            return false
        else
            return true
        end
    end,
    tweenSmart = function(self, position)
        
        local result = self:tweenToPosition(Vector3.new(LP.Character.HumanoidRootPart.Position.X, settings.smartTweenY, LP.Character.HumanoidRootPart.Position.Z), settings.tweenSpeedY)
            print(result)
            if not result then return false end
            
            result = self:tweenToPosition(Vector3.new(position.X, settings.smartTweenY, position.Z), settings.tweenSpeedX)
            print(result)
            if not result then return false end
            
            result = self:tweenToPosition(position, settings.tweenSpeedY)
            print(result)
            if not result then return false end
        return true
    end
}

local world = {
    brainrots = {},
    luckyBlocks = {},
    plot = {
        id = "",
        stands = {},
        brainrots = {}
    },
    currentEvents = {}
}


for i, v in pairs(game.workspace.Bases:GetChildren()) do
    if v:GetAttribute("Holder") == LP.UserId then
        world.plot.id = v.Name
    end
end


local stopScript = false
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode[settings.stopScriptKeybind] then
            if utils.tween then
                utils.tween:Cancel()
                utils:clip()
                utils:unfloat()
                utils:fall()
                stopScript = true
            end
        end
    end
end)

print("Script loaded. Press " .. settings.stopScriptKeybind .. " to stop the script.")

while (not stopScript) do
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or not LP.Character:FindFirstChild("Humanoid") then
        wait(3)
        continue
    elseif LP.Character.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
        repeat wait(0.1) until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead
    end

    if settings.autoTweenSpeed then  -- set tween speed based on player stats so that the server doesn't kill
        settings.tweenSpeedX = ClientGlobals.PlayerData.Data.CurrentSpeed
        settings.tweenSpeedY = ClientGlobals.PlayerData.Data.JumpUpgrade * 8
    end

    world.plot.stands = ClientGlobals.Plots:TryIndex({world.plot.id, "data", "Stands"}) or {}

    for i,v in pairs(ClientGlobals.Plots:TryIndex({world.plot.id, "data", "Stands"})) do -- get player's stands and brainrots
        if v.brainrot then
            world.plot.brainrots[i] = v.brainrot
            world.plot.brainrots[i]["rate"] = EconomyMath.GetBrainrotRate(v.brainrot)
        end
    end

    table.clear(world.brainrots)
    table.clear(world.luckyBlocks)
    for i, v in pairs(game.workspace.ActiveBrainrots:GetChildren()) do -- get collectable brainrots
        for z, x in pairs(v:GetChildren()) do
            if x:IsA("Model") and x:FindFirstChild("Root") and x.Root:FindFirstChild("TakePrompt") then
                world.brainrots[#world.brainrots+1] = {
                    ["name"] = x:GetAttribute("BrainrotName"),
                    ["class"] = v.Name,
                    ["mutation"] = x:GetAttribute("Mutation"),
                    ["level"] = x:GetAttribute("Level"),
                    ["traits"] = x:GetAttribute("Traits"),
                    ["position"] = x.WorldPivot.Position,
                    ["proximityPrompt"] = x.Root.TakePrompt,
                    ["time"] = x.Root.TimerGui.TimeLeft.TimeLeft.ContentText:gsub("%D+", "") or "0s"
                }
                world.brainrots[#world.brainrots].rate = EconomyMath.GetBrainrotRate(world.brainrots[#world.brainrots])
            end
        end
    end

    for i, v in pairs(game.workspace.ActiveLuckyBlocks:GetChildren()) do -- get collectable lucky blocks
        if v:IsA("Model") and v:FindFirstChild("RootPart") and v.RootPart:FindFirstChild("ProximityPrompt") then
            world.luckyBlocks[#world.luckyBlocks+1] = {
                ["class"] = v:GetAttribute("LuckyBlockType"),
                ["level"] = v:GetAttribute("Level"),
                ["mutation"] = v:GetAttribute("Mutation"),
                ["traits"] = v:GetAttribute("Traits"),
                ["position"] = v.WorldPivot.Position,
                ["proximityPrompt"] = v.RootPart.ProximityPrompt
            }
        end
    end
    world.currentEvents = ClientGlobals.ActiveEvents.Data
    local currentEvent = "None"
    for i, v in pairs(world.currentEvents) do
        print(i, v)
        if string.find(i, "Arcade") or string.find(i, "Valentine") or string.find(i, "Fire") then
            currentEvent = i
        end
    end
    if settings.mode ~= modes.onlyLuckyBlocks then
        table.sort(world.brainrots, function(a, b) -- sort brainrots based on settings.mode
            if settings.prioritizeEvents and string.find(currentEvent, "Fire") then
                local aScore, bScore = 0, 0
                if (ClientGlobals.PlayerData.Data.FireAndIceTeam == "Ice" and a.position.Z > 0) or (ClientGlobals.PlayerData.Data.FireAndIceTeam == "Fire" and a.position.Z < 0) then
                    aScore = aScore + 20
                end
                if (ClientGlobals.PlayerData.Data.FireAndIceTeam == "Ice" and b.position.Z > 0) or (ClientGlobals.PlayerData.Data.FireAndIceTeam == "Fire" and b.position.Z < 0) then
                    bScore = bScore + 20
                end
                
                if string.find(a.mutation, ClientGlobals.PlayerData.Data.FireAndIceTeam) then
                    aScore = aScore + 1
                end
                if string.find(b.mutation, ClientGlobals.PlayerData.Data.FireAndIceTeam) then
                    bScore = bScore + 1
                end

                aScore = aScore + (data.classes[a.class] - data.classes[b.class])

                return aScore > bScore
            elseif settings.mode == modes.highestPotential then
                local aScore, bScore = 0, 0
                local rate1, rate2 = 0, 0
                if a.level >= 250 then
                    rate1 = a.rate
                else
                    rate1 = EconomyMath.GetBrainrotRate({["name"] = a.name, ["mutation"] = a.mutation, ["level"] = 250, ["traits"] = a.traits})
                end

                if b.level >= 250 then
                    rate2 = b.rate
                else
                    rate2 = EconomyMath.GetBrainrotRate({["name"] = b.name, ["mutation"] = b.mutation, ["level"] = 250, ["traits"] = b.traits})
                end
                if rate1 < settings.brainrotMinRate and rate2 < settings.brainrotMinRate then
                    return a.rate > b.rate
                end

                if rate1 > rate2 then
                    aScore = aScore + 1
                elseif rate2 > rate1 then
                    bScore = bScore + 1
                end
                
                if data.classes[a.class] >= data.classes[settings.brainrotMinClass] then
                    aScore = aScore + 10 -- give a big score boost if the brainrot is above the minimum class
                end

                if data.classes[b.class] >= data.classes[settings.brainrotMinClass] then
                    bScore = bScore + 10
                end

                for i, v in pairs(settings.brainrotTraits) do
                    if table.find(a.traits, v) then
                        aScore = aScore + 1
                    end
                    if table.find(b.traits, v) then
                        bScore = bScore + 1
                    end
                end
                for i, v in pairs(settings.brainrotMutations) do
                    if a.mutation == v then
                        aScore = aScore + 1
                    end
                    if b.mutation == v then
                        bScore = bScore + 1
                    end
                end
                --print(a.class, b.class, rate1, rate2, aScore, bScore, temp1.level, temp2.level)
                if aScore == bScore then
                    return rate1 > rate2 -- if both have the same score, sort by rate
                else
                    return aScore > bScore -- otherwise sort by score
                end

            elseif settings.mode == modes.specificTraits then
                -- sort by number of desired traits/mutations/classes, then by rate
                local aScore, bScore = 0, 0
                for i, v in pairs(settings.brainrotTraits) do
                    if table.find(a.traits, v) then
                        aScore = aScore + 1
                    end
                    if table.find(b.traits, v) then
                        bScore = bScore + 1
                    end
                end
                for i, v in pairs(settings.brainrotMutations) do
                    if a.mutation == v then
                        aScore = aScore + 1
                    end
                    if b.mutation == v then
                        bScore = bScore + 1
                    end
                end

                if data.classes[a.class] >= data.classes[settings.brainrotMinClass] then
                    aScore = aScore + 10
                end

                if data.classes[b.class] >= data.classes[settings.brainrotMinClass] then
                    bScore = bScore + 10
                end

                if aScore == bScore then
                    return a.rate > b.rate -- if both have the same number of desired traits/mutations/classes, sort by rate
                else
                    return aScore > bScore -- otherwise sort by score
                end
            else
                return a.rate > b.rate -- if not sorting by specific traits, just sort by rate
            end
        end) 
    end

    table.sort(world.luckyBlocks, function(a, b)
        -- the lucky block must have at least the minimum class, and it must have all the mutations and traits specified in settings, then sort by level
        if not data.classes[a.class] then
            return false
        elseif not data.classes[b.class] then
            return true
        end

        local aScore, bScore = 0, 0
        for i, v in pairs(settings.luckyBlockMutations) do
            if a.mutation == v then
                aScore = aScore + 1
            end
            if b.mutation == v then
                bScore = bScore + 1
            end
        end

        if data.classes[a.class] >= data.classes[settings.luckyBlockMinClass] then
            aScore = aScore + 10 -- give a big score boost if the brainrot is above the minimum class
        end

        if data.classes[b.class] >= data.classes[settings.luckyBlockMinClass] then
            bScore = bScore + 10
        end

        if aScore == bScore then
            return data.classes[a.class] > data.classes[b.class] -- if both have the same number of desired mutations/classes, sort by class
        else
            return aScore > bScore -- otherwise sort by score
        end
    end)
    
    print("Current Events:", currentEvent)
    utils:nofall()
    if settings.prioritizeEvents and currentEvent ~= "None" then
        if string.find(currentEvent, "Arcade") then
            for i, v in pairs(workspace.ArcadeEventTickets:GetDescendants()) do
                if v.Name == "Ticket" and v:FindFirstChild("TouchInterest") then
                    local pos = v.WorldPivot.Position
                    if utils:tweenSmart(Vector3.new(pos.X, pos.Y - 5, pos.Z)) then
                        wait(0.2)
                        firetouchinterest(LP.Character.HumanoidRootPart, v, 0)
                        firetouchinterest(LP.Character.HumanoidRootPart, v, 1)
                        break
                    end
                end
            end
        elseif string.find(currentEvent, "Valentine") then
            if ClientGlobals.PlayerData.Data.SpecialCurrency.CandyCoin >= 100 then
                local pos = workspace.ValentinesMap.CandyGramStation.WorldPivot.Position
                if utils:tweenSmart(Vector3.new(pos.X, pos.Y - 5, pos.Z)) then
                    wait(0.2)
                    fireproximityprompt(workspace.ValentinesMap.CandyGramStation.Main.Prompts.ProximityPrompt)
                    continue
                end
            end
            if not workspace:FindFirstChild("CandyEventParts") then continue end
            local candies = {}
            for i, v in pairs(workspace.CandyEventParts:GetDescendants()) do
                if v.Name == "HeartCandy3" and v:FindFirstChild("TouchInterest") then
                    candies[#candies+1] = v
                end
            end
            table.sort(candies, function(a, b)
                return (LP.Character.HumanoidRootPart.Position - a.Position).Magnitude < (LP.Character.HumanoidRootPart.Position - b.Position).Magnitude
            end)

            if candies[1] then
                
                local pos = candies[1].Position
                if utils:tweenSmart(Vector3.new(pos.X, pos.Y - 10, pos.Z)) then
                    wait(0.2)
                    firetouchinterest(LP.Character.HumanoidRootPart, candies[1], 0)
                    firetouchinterest(LP.Character.HumanoidRootPart, candies[1], 1)
                end
            end
        elseif string.find(currentEvent, "Fire") then
            local carryCount = 0
            for i, v in pairs(LP.Character:GetChildren()) do
                if string.find(v.Name, "LuckyBlock") or string.find(v.Name, "RenderedBrainrot") then
                    carryCount = carryCount + 1
                end
            end
            local pos = world.brainrots[1].position
            if data.classes[world.brainrots[1].class] >= (data.classes[settings.brainrotMinClass] - 6) and
               tonumber(world.brainrots[1].time) > ((LP.Character.HumanoidRootPart.Position - pos).Magnitude / settings.tweenSpeedX) + 3 and
               carryCount < ClientGlobals.PlayerData.Data.MaxCarry then
                if utils:tweenSmart(Vector3.new(pos.X, pos.Y - 3, pos.Z)) then
                    wait(0.3)
                    fireproximityprompt(world.brainrots[1].proximityPrompt)
                    carryCount = carryCount + 1
                end
            end
            if carryCount >= ClientGlobals.PlayerData.Data.MaxCarry then
                pos = workspace.FireAndIceMap.FireAndIceSacraficeMachine.WorldPivot.Position
                if utils:tweenSmart(Vector3.new(pos.X, pos.Y - 40, pos.Z)) then
                    wait(0.2)
                    fireproximityprompt(workspace.FireAndIceMap.FireAndIceSacraficeMachine.Primary.Prompt.ProximityPrompt)
                    task.spawn(function()
                        wait(0.5)
                        firesignal(LP.PlayerGui.ChoiceGui.Choice.Choices.Yes.Activated)
                    end)
                end
            end
        end
    elseif settings.mode == modes.highestPotential or settings.mode == modes.aboveRate then
        local pos = world.brainrots[1].position
        local temp = {
            ["name"] = world.brainrots[1].name,
            ["mutation"] = world.brainrots[1].mutation,
            ["level"] = 250,
            ["traits"] = world.brainrots[1].traits
        }
        if world.brainrots[1].level >= 250 or settings.mode == modes.aboveRate then
            temp.level = world.brainrots[1].level
        end

        print(EconomyMath.GetBrainrotRate(temp))
        print(world.brainrots[1].class, data.classes[world.brainrots[1].class], data.classes[settings.brainrotMinClass])
        local con1, con2 = settings.mode == modes.highestPotential and EconomyMath.GetBrainrotRate(temp) >= settings.brainrotMinRate, settings.mode == modes.aboveRate and temp.rate >= settings.brainrotMinRate
        if (con1 or con2) and data.classes[world.brainrots[1].class] >= data.classes[settings.brainrotMinClass] and world.brainrots[1].rate >= settings.brainrotMinRate and tonumber(world.brainrots[1].time) > ((LP.Character.HumanoidRootPart.Position - pos).Magnitude / settings.tweenSpeedX) + 3 then
            if utils:tweenSmart(Vector3.new(pos.X, pos.Y - 3, pos.Z)) then
                wait(0.3)
                fireproximityprompt(world.brainrots[1].proximityPrompt)
                utils:tweenSmart(workspace.Bases[world.plot.id].WorldPivot.Position)
            end
        else
            if utils:tweenSmart(Vector3.new(pos.X, pos.Y + settings.smartTweenY, pos.Z)) then
                --utils:float()
            end
        end
    else
        if utils:tweenSmart(Vector3.new(world.brainrots[1].position.X, world.brainros[1].position.Y + settings.smartTweenY, world.brainrots[1].position.Z)) then
            --utils:float()
        end
    end
    wait(0.1)
end
