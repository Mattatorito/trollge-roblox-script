-- Trollge Universal Dupe Script для iOS устройств
-- Версия: 2.0 iOS Edition
-- Загрузка: loadstring(game:HttpGet("URL"))()

-- Проверка iOS устройства
local UserInputService = game:GetService("UserInputService")
local isIOS = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Защита от повторной загрузки
if _G.TrollgeIOSLoaded then
    warn("⚠️ Скрипт уже загружен! Перезапуск...")
    if _G.TrollgeIOSGUI then
        _G.TrollgeIOSGUI:Destroy()
    end
end

_G.TrollgeIOSLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer

-- Переменные для управления клонами
_G.CloneList = _G.CloneList or {}
_G.CloneSettings = _G.CloneSettings or {
    FollowPlayer = true,
    CloneDistance = 5,
    MaxClones = 6, -- Уменьшено для iOS
    CloneBehavior = "Follow"
}

-- Переменные для дюпа предметов
_G.ItemDupeSettings = _G.ItemDupeSettings or {
    DupeAmount = 3, -- Уменьшено для iOS
    AutoDupe = false,
    TargetItems = {"Troll", "Golden Troll", "Diamond Troll", "Rainbow Troll", "Void Troll"}
}

-- iOS настройки
local IOSConfig = {
    UseSimpleGUI = true,
    UseChatCommands = true,
    UseNotifications = false, -- Отключено для iOS
    SafeMode = true,
    ReducedAnimations = true
}

-- Функция безопасного выполнения для iOS
local function SafeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("⚠️ iOS Ошибка: " .. tostring(result))
        print("📱 Попробуйте перезапустить скрипт")
        return false
    end
    return result
end

-- iOS-совместимая функция уведомлений
local function IOSNotify(title, text, duration)
    -- Попытка использовать StarterGui (может не работать на iOS)
    local success = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 3;
        })
    end)
    
    -- Если не работает, используем print
    if not success then
        print("📱 " .. title .. ": " .. text)
    end
end

-- Функция создания клона персонажа (iOS версия)
local function CreateCharacterClone()
    return SafeExecute(function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            IOSNotify("Ошибка", "Персонаж не найден!", 3)
            return false
        end
        
        if #_G.CloneList >= _G.CloneSettings.MaxClones then
            IOSNotify("Лимит", "Максимум клонов: " .. _G.CloneSettings.MaxClones, 3)
            return false
        end
        
        local clone = character:Clone()
        clone.Name = LocalPlayer.Name .. "_Clone_" .. math.random(100, 999)
        
        -- Упрощенная очистка для iOS
        for _, obj in pairs(clone:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                obj:Destroy()
            end
        end
        
        local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local playerPos = character.HumanoidRootPart.Position
            local randomOffset = Vector3.new(
                math.random(-_G.CloneSettings.CloneDistance, _G.CloneSettings.CloneDistance),
                0,
                math.random(-_G.CloneSettings.CloneDistance, _G.CloneSettings.CloneDistance)
            )
            humanoidRootPart.CFrame = CFrame.new(playerPos + randomOffset)
        end
        
        clone.Parent = Workspace
        
        table.insert(_G.CloneList, {
            clone = clone,
            behavior = _G.CloneSettings.CloneBehavior,
            created = tick()
        })
        
        IOSNotify("Успех", "Клон создан! Всего: " .. #_G.CloneList, 2)
        return true
    end)
end

-- Функция управления поведением клонов (упрощенная для iOS)
local function UpdateCloneBehavior()
    return SafeExecute(function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        for i = #_G.CloneList, 1, -1 do
            local cloneData = _G.CloneList[i]
            local clone = cloneData.clone
            
            if not clone or not clone.Parent or not clone:FindFirstChild("Humanoid") then
                table.remove(_G.CloneList, i)
                continue
            end
            
            local humanoid = clone.Humanoid
            local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
            
            if not humanoidRootPart then continue end
            
            if cloneData.behavior == "Follow" and _G.CloneSettings.FollowPlayer then
                local playerPos = character.HumanoidRootPart.Position
                local clonePos = humanoidRootPart.Position
                local distance = (playerPos - clonePos).Magnitude
                
                if distance > _G.CloneSettings.CloneDistance + 2 then
                    local targetPos = playerPos + Vector3.new(
                        math.random(-_G.CloneSettings.CloneDistance, _G.CloneSettings.CloneDistance),
                        0,
                        math.random(-_G.CloneSettings.CloneDistance, _G.CloneSettings.CloneDistance)
                    )
                    humanoid:MoveTo(targetPos)
                end
            end
        end
    end)
end

-- Функция удаления всех клонов
local function DestroyAllClones()
    return SafeExecute(function()
        local count = #_G.CloneList
        for _, cloneData in pairs(_G.CloneList) do
            if cloneData.clone and cloneData.clone.Parent then
                cloneData.clone:Destroy()
            end
        end
        _G.CloneList = {}
        
        IOSNotify("Очистка", "Удалено клонов: " .. count, 2)
    end)
end

-- Функция изменения поведения клонов
local function SetCloneBehavior(behavior)
    return SafeExecute(function()
        _G.CloneSettings.CloneBehavior = behavior
        for _, cloneData in pairs(_G.CloneList) do
            cloneData.behavior = behavior
        end
        
        IOSNotify("Поведение", "Режим: " .. behavior, 2)
    end)
end

-- Модуль дюпа предметов (iOS версия)
local ItemDupeModule = {}

function ItemDupeModule.GetInventoryItems()
    return SafeExecute(function()
        local items = {}
        local backpack = LocalPlayer.Backpack
        local character = LocalPlayer.Character
        
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(items, {name = item.Name, location = "Backpack", item = item})
            end
        end
        
        if character then
            for _, item in pairs(character:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(items, {name = item.Name, location = "Character", item = item})
                end
            end
        end
        
        return items
    end) or {}
end

function ItemDupeModule.DupeAllTrolls()
    return SafeExecute(function()
        local totalDuped = 0
        local items = ItemDupeModule.GetInventoryItems()
        
        for _, itemData in pairs(items) do
            local itemName = itemData.name:lower()
            
            if itemName:find("troll") then
                local originalItem = itemData.item
                
                for i = 1, _G.ItemDupeSettings.DupeAmount do
                    local clone = originalItem:Clone()
                    clone.Parent = LocalPlayer.Backpack
                    totalDuped = totalDuped + 1
                    wait(0.2) -- Увеличенная задержка для iOS
                end
            end
        end
        
        if totalDuped > 0 then
            IOSNotify("Дюп троллей", "Дублировано: " .. totalDuped, 3)
        else
            IOSNotify("Ошибка", "Тролли не найдены!", 3)
        end
        
        return totalDuped
    end)
end

function ItemDupeModule.DupeValuableItems()
    return SafeExecute(function()
        local valuableKeywords = {"golden", "diamond", "rainbow", "void", "legendary", "epic", "rare"}
        local totalDuped = 0
        local items = ItemDupeModule.GetInventoryItems()
        
        for _, itemData in pairs(items) do
            local itemName = itemData.name:lower()
            local isValuable = false
            
            for _, keyword in pairs(valuableKeywords) do
                if itemName:find(keyword) then
                    isValuable = true
                    break
                end
            end
            
            if isValuable then
                local originalItem = itemData.item
                
                for i = 1, _G.ItemDupeSettings.DupeAmount do
                    local clone = originalItem:Clone()
                    clone.Parent = LocalPlayer.Backpack
                    totalDuped = totalDuped + 1
                    wait(0.2)
                end
            end
        end
        
        if totalDuped > 0 then
            IOSNotify("Дюп ценных", "Дублировано: " .. totalDuped, 3)
        else
            IOSNotify("Ошибка", "Ценные предметы не найдены!", 3)
        end
        
        return totalDuped
    end)
end

function ItemDupeModule.DupeAllItems()
    return SafeExecute(function()
        local totalDuped = 0
        local items = ItemDupeModule.GetInventoryItems()
        
        for _, itemData in pairs(items) do
            local originalItem = itemData.item
            
            for i = 1, _G.ItemDupeSettings.DupeAmount do
                local clone = originalItem:Clone()
                clone.Parent = LocalPlayer.Backpack
                totalDuped = totalDuped + 1
                wait(0.2)
            end
        end
        
        if totalDuped > 0 then
            IOSNotify("Дюп всех предметов", "Дублировано: " .. totalDuped, 3)
        else
            IOSNotify("Ошибка", "Предметы не найдены!", 3)
        end
        
        return totalDuped
    end)
end

function ItemDupeModule.DupeMoney()
    return SafeExecute(function()
        local totalDuped = 0
        local moneyKeywords = {"coin", "money", "cash", "dollar", "gold", "монета", "деньги"}
        local items = ItemDupeModule.GetInventoryItems()
        
        for _, itemData in pairs(items) do
            local itemName = itemData.name:lower()
            local isMoney = false
            
            for _, keyword in pairs(moneyKeywords) do
                if itemName:find(keyword) then
                    isMoney = true
                    break
                end
            end
            
            if isMoney then
                local originalItem = itemData.item
                
                for i = 1, _G.ItemDupeSettings.DupeAmount * 2 do -- Больше денег
                    local clone = originalItem:Clone()
                    clone.Parent = LocalPlayer.Backpack
                    totalDuped = totalDuped + 1
                    wait(0.15)
                end
            end
        end
        
        -- Попытка найти leaderstats для дюпа денег
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in pairs(leaderstats:GetChildren()) do
                local statName = stat.Name:lower()
                if statName:find("money") or statName:find("cash") or statName:find("coin") or 
                   statName:find("деньги") or statName:find("монеты") then
                    -- Попытка увеличить статистику (может не работать на всех серверах)
                    pcall(function()
                        local currentValue = stat.Value
                        stat.Value = currentValue * 2
                        IOSNotify("Дюп денег", "Статистика удвоена!", 3)
                    end)
                end
            end
        end
        
        if totalDuped > 0 then
            IOSNotify("Дюп денег", "Дублировано предметов: " .. totalDuped, 3)
        else
            IOSNotify("Ошибка", "Денежные предметы не найдены!", 3)
        end
        
        return totalDuped
    end)
end

function ItemDupeModule.DupeSpecificItem(itemName)
    return SafeExecute(function()
        local totalDuped = 0
        local items = ItemDupeModule.GetInventoryItems()
        local targetName = itemName:lower()
        
        for _, itemData in pairs(items) do
            local currentName = itemData.name:lower()
            
            if currentName:find(targetName) then
                local originalItem = itemData.item
                
                for i = 1, _G.ItemDupeSettings.DupeAmount do
                    local clone = originalItem:Clone()
                    clone.Parent = LocalPlayer.Backpack
                    totalDuped = totalDuped + 1
                    wait(0.2)
                end
            end
        end
        
        if totalDuped > 0 then
            IOSNotify("Дюп предмета", "Дублировано " .. itemName .. ": " .. totalDuped, 3)
        else
            IOSNotify("Ошибка", "Предмет " .. itemName .. " не найден!", 3)
        end
        
        return totalDuped
    end)
end

-- iOS-совместимый простой GUI
local function CreateIOSSimpleGUI()
    return SafeExecute(function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        
        -- Удаляем старый GUI если есть
        if PlayerGui:FindFirstChild("TrollgeIOSGUI") then
            PlayerGui.TrollgeIOSGUI:Destroy()
        end
        
        -- Создаем простой ScreenGui
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "TrollgeIOSGUI"
        ScreenGui.ResetOnSpawn = false
        
        -- Попытка добавить в PlayerGui
        local success = pcall(function()
            ScreenGui.Parent = PlayerGui
        end)
        
        if not success then
            print("❌ iOS не поддерживает ScreenGui. Используйте команды в чате.")
            return false
        end
        
        _G.TrollgeIOSGUI = ScreenGui
        
        -- Простая панель без сложных элементов
        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 250, 0, 300)
        MainFrame.Position = UDim2.new(0, 10, 0, 10)
        MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        MainFrame.BorderSizePixel = 1
        MainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui
        
        -- Простой заголовок
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Title.BorderSizePixel = 0
        Title.Text = "📱 Trollge iOS v2.0"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextScaled = true
        Title.Font = Enum.Font.SourceSans
        Title.Parent = MainFrame
        
        -- Функция создания простой кнопки
        local function CreateSimpleButton(text, position, callback, color)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 100, 0, 30)
            Button.Position = position
            Button.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
            Button.BorderSizePixel = 1
            Button.BorderColor3 = Color3.fromRGB(100, 100, 100)
            Button.Text = text
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextScaled = true
            Button.Font = Enum.Font.SourceSans
            Button.Parent = MainFrame
            
            Button.MouseButton1Click:Connect(callback)
            
            return Button
        end
        
        -- Простые кнопки
        CreateSimpleButton("Создать клон", UDim2.new(0, 10, 0, 50), CreateCharacterClone, Color3.fromRGB(0, 120, 0))
        CreateSimpleButton("Удалить всех", UDim2.new(0, 130, 0, 50), DestroyAllClones, Color3.fromRGB(120, 0, 0))
        
        CreateSimpleButton("Следовать", UDim2.new(0, 10, 0, 90), function() SetCloneBehavior("Follow") end)
        CreateSimpleButton("Стоять", UDim2.new(0, 130, 0, 90), function() SetCloneBehavior("Stay") end)
        
        CreateSimpleButton("Дюп троллей", UDim2.new(0, 10, 0, 130), function() ItemDupeModule.DupeAllTrolls() end, Color3.fromRGB(200, 100, 0))
        CreateSimpleButton("Дюп ценных", UDim2.new(0, 130, 0, 130), function() ItemDupeModule.DupeValuableItems() end, Color3.fromRGB(200, 150, 0))
        
        -- Простая информационная панель
        local InfoLabel = Instance.new("TextLabel")
        InfoLabel.Size = UDim2.new(1, -20, 0, 100)
        InfoLabel.Position = UDim2.new(0, 10, 0, 170)
        InfoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        InfoLabel.BorderSizePixel = 1
        InfoLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
        InfoLabel.Text = "📱 iOS Mode\nКлонов: 0\nДюп: 3"
        InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        InfoLabel.TextScaled = true
        InfoLabel.Font = Enum.Font.SourceSans
        InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
        InfoLabel.Parent = MainFrame
        
        -- Простое обновление информации
        spawn(function()
            while ScreenGui.Parent do
                local inventoryCount = #ItemDupeModule.GetInventoryItems()
                InfoLabel.Text = string.format(
                    "📱 iOS Mode\nКлонов: %d/%d\nПредметов: %d\nДюп: %d",
                    #_G.CloneList,
                    _G.CloneSettings.MaxClones,
                    inventoryCount,
                    _G.ItemDupeSettings.DupeAmount
                )
                wait(3)
            end
        end)
        
        -- Кнопка закрытия
        local CloseButton = Instance.new("TextButton")
        CloseButton.Size = UDim2.new(0, 30, 0, 30)
        CloseButton.Position = UDim2.new(1, -35, 0, 5)
        CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        CloseButton.BorderSizePixel = 0
        CloseButton.Text = "X"
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.TextScaled = true
        CloseButton.Font = Enum.Font.SourceSans
        CloseButton.Parent = MainFrame
        
        CloseButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
        
        print("📱 iOS простой GUI создан!")
        IOSNotify("Trollge iOS", "Простое меню загружено!", 3)
        return true
    end)
end

-- Система команд в чате для iOS
local function SetupChatCommands()
    return SafeExecute(function()
        -- Подключение к чату
        local function onPlayerChatted(message)
            local msg = message:lower()
            
            -- Команды клонов
            if msg == "/clone" or msg == "/создать" then
                CreateCharacterClone()
            elseif msg == "/clear" or msg == "/очистить" then
                DestroyAllClones()
            elseif msg == "/follow" or msg == "/следовать" then
                SetCloneBehavior("Follow")
            elseif msg == "/stay" or msg == "/стоять" then
                SetCloneBehavior("Stay")
                
            -- Команды дюпа предметов
            elseif msg == "/dupe" or msg == "/дюп" then
                ItemDupeModule.DupeAllTrolls()
            elseif msg == "/valuable" or msg == "/ценные" then
                ItemDupeModule.DupeValuableItems()
            elseif msg == "/all" or msg == "/все" then
                ItemDupeModule.DupeAllItems()
            elseif msg == "/money" or msg == "/деньги" then
                ItemDupeModule.DupeMoney()
                
            -- Команды дюпа конкретных предметов
            elseif msg:find("/item ") or msg:find("/предмет ") then
                local itemName = msg:gsub("/item ", ""):gsub("/предмет ", "")
                if itemName and itemName ~= "" then
                    ItemDupeModule.DupeSpecificItem(itemName)
                else
                    print("📱 Использование: /item название_предмета")
                end
                
            -- Справка
            elseif msg == "/help" or msg == "/помощь" then
                print("📱 iOS Команды:")
                print("=== КЛОНЫ ===")
                print("/clone - Создать клон")
                print("/clear - Удалить всех клонов")
                print("/follow - Режим следования")
                print("/stay - Режим стояния")
                print("")
                print("=== ДЮП ПРЕДМЕТОВ ===")
                print("/dupe - Дюп троллей")
                print("/valuable - Дюп ценных предметов")
                print("/all - Дюп всех предметов")
                print("/money - Дюп денег")
                print("/item название - Дюп конкретного предмета")
                print("")
                print("=== ПРИМЕРЫ ===")
                print("/item troll - Дюп всех троллей")
                print("/item golden - Дюп золотых предметов")
                print("/item coin - Дюп монет")
            end
        end
        
        LocalPlayer.Chatted:Connect(onPlayerChatted)
        
        print("📱 Команды чата активированы!")
        print("Напишите /help для списка команд")
    end)
end

-- Основной цикл обновления (упрощенный для iOS)
local connection = RunService.Heartbeat:Connect(UpdateCloneBehavior)

-- Очистка при выходе
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        DestroyAllClones()
        if connection then
            connection:Disconnect()
        end
    end
end)

-- Инициализация iOS версии
print("📱 Trollge Universal Dupe Script v2.0 iOS Edition загружен!")
print("🎯 Специально оптимизировано для iOS устройств")
print("📋 iOS особенности:")
print("   • Упрощенный GUI")
print("   • Команды в чате")
print("   • Уменьшенные лимиты")
print("   • Повышенная стабильность")

-- Попытка создать GUI, если не получится - используем команды
local guiCreated = CreateIOSSimpleGUI()

if not guiCreated then
    print("⚠️ GUI недоступен на вашем iOS эксплойте")
    print("📱 Используйте команды в чате:")
    print("   /clone - Создать клон")
    print("   /clear - Удалить клонов")
    print("   /dupe - Дюп троллей")
    print("   /help - Все команды")
end

-- Всегда активируем команды чата
SetupChatCommands()

-- Приветственное сообщение
IOSNotify("🎭 Trollge iOS", "Скрипт загружен! Используйте GUI или команды в чате.", 5)
