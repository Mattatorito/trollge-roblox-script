-- Trollge Advanced Dupe Script для iOS устройств
-- Версия: 2.1 Advanced Dupe Edition
-- Загрузка: loadstring(game:HttpGet("URL"))()

-- Проверка iOS устройства
local UserInputService = game:GetService("UserInputService")
local isIOS = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Защита от повторной загрузки
if _G.TrollgeAdvancedLoaded then
    warn("⚠️ Скрипт уже загружен! Перезапуск...")
    if _G.TrollgeAdvancedGUI then
        _G.TrollgeAdvancedGUI:Destroy()
    end
end

_G.TrollgeAdvancedLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Переменные для управления клонами
_G.CloneList = _G.CloneList or {}
_G.CloneSettings = _G.CloneSettings or {
    FollowPlayer = true,
    CloneDistance = 5,
    MaxClones = 6,
    CloneBehavior = "Follow"
}

-- Переменные для продвинутого дюпа
_G.AdvancedDupeSettings = _G.AdvancedDupeSettings or {
    DupeAmount = 2,
    UseDropMethod = true,
    UseNetworkLag = true,
    UseMultipleAttempts = true,
    DelayBetweenAttempts = 0.5
}

-- Функция безопасного выполнения
local function SafeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("⚠️ Ошибка: " .. tostring(result))
        return false
    end
    return result
end

-- iOS-совместимая функция уведомлений
local function AdvancedNotify(title, text, duration)
    local success = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 3;
        })
    end)
    
    if not success then
        print("📱 " .. title .. ": " .. text)
    end
end

-- Продвинутый модуль дюпа предметов
local AdvancedDupeModule = {}

function AdvancedDupeModule.GetInventoryItems()
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

-- Метод 1: Дюп через дроп и быстрый подбор с лагом сети
function AdvancedDupeModule.DropDupeMethod(item)
    return SafeExecute(function()
        local duped = 0
        local originalParent = item.Parent
        
        for attempt = 1, _G.AdvancedDupeSettings.DupeAmount do
            -- Создаем искусственный лаг сети
            for lag = 1, 5 do
                spawn(function()
                    -- Быстро дропаем и подбираем
                    item.Parent = Workspace
                    wait(0.03)
                    item.Parent = LocalPlayer.Backpack
                end)
            end
            
            wait(_G.AdvancedDupeSettings.DelayBetweenAttempts)
            duped = duped + 1
        end
        
        -- Убеждаемся что оригинал в правильном месте
        item.Parent = originalParent
        return duped
    end) or 0
end

-- Метод 2: Дюп через клонирование с задержкой синхронизации
function AdvancedDupeModule.CloneSyncMethod(item)
    return SafeExecute(function()
        local duped = 0
        
        for attempt = 1, _G.AdvancedDupeSettings.DupeAmount do
            -- Создаем несколько клонов одновременно
            local clones = {}
            
            for i = 1, 3 do
                local clone = item:Clone()
                clone.Name = item.Name .. "_Dupe_" .. math.random(1000, 9999)
                table.insert(clones, clone)
            end
            
            -- Быстро добавляем их в рюкзак
            for _, clone in pairs(clones) do
                spawn(function()
                    clone.Parent = LocalPlayer.Backpack
                    duped = duped + 1
                end)
                wait(0.02)
            end
            
            wait(_G.AdvancedDupeSettings.DelayBetweenAttempts)
        end
        
        return duped
    end) or 0
end

-- Метод 3: Дюп через манипуляцию Handle
function AdvancedDupeModule.HandleDupeMethod(item)
    return SafeExecute(function()
        local duped = 0
        local handle = item:FindFirstChild("Handle")
        
        if not handle then
            return 0
        end
        
        for attempt = 1, _G.AdvancedDupeSettings.DupeAmount do
            -- Создаем копию через Handle
            local newTool = Instance.new("Tool")
            newTool.Name = item.Name
            newTool.RequiresHandle = true
            
            local newHandle = handle:Clone()
            newHandle.Parent = newTool
            
            -- Копируем все скрипты и свойства
            for _, child in pairs(item:GetChildren()) do
                if child ~= handle then
                    local childClone = child:Clone()
                    childClone.Parent = newTool
                end
            end
            
            newTool.Parent = LocalPlayer.Backpack
            duped = duped + 1
            
            wait(_G.AdvancedDupeSettings.DelayBetweenAttempts)
        end
        
        return duped
    end) or 0
end

-- Метод 4: Дюп через RemoteEvents (если доступны)
function AdvancedDupeModule.RemoteEventDupe(item)
    return SafeExecute(function()
        local duped = 0
        
        -- Ищем RemoteEvents связанные с предметами
        local remotes = {}
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (
                obj.Name:lower():find("item") or 
                obj.Name:lower():find("tool") or 
                obj.Name:lower():find("give") or
                obj.Name:lower():find("add")
            ) then
                table.insert(remotes, obj)
            end
        end
        
        -- Пытаемся использовать найденные RemoteEvents
        for _, remote in pairs(remotes) do
            for attempt = 1, _G.AdvancedDupeSettings.DupeAmount do
                pcall(function()
                    remote:FireServer(item.Name)
                    remote:FireServer(item)
                    remote:FireServer("give", item.Name)
                    remote:FireServer("add", item.Name, 1)
                    duped = duped + 1
                end)
                wait(0.1)
            end
        end
        
        return duped
    end) or 0
end

-- Основная функция продвинутого дюпа
function AdvancedDupeModule.AdvancedDupe(itemFilter)
    return SafeExecute(function()
        local totalDuped = 0
        local items = AdvancedDupeModule.GetInventoryItems()
        local targetItems = {}
        
        -- Фильтруем предметы
        for _, itemData in pairs(items) do
            local itemName = itemData.name:lower()
            if not itemFilter or itemName:find(itemFilter:lower()) then
                table.insert(targetItems, itemData)
            end
        end
        
        if #targetItems == 0 then
            AdvancedNotify("Ошибка", "Предметы не найдены: " .. (itemFilter or "все"), 3)
            return 0
        end
        
        AdvancedNotify("Начало дюпа", "Найдено предметов: " .. #targetItems, 2)
        
        -- Применяем все методы дюпа
        for _, itemData in pairs(targetItems) do
            local item = itemData.item
            local itemDuped = 0
            
            print("🔄 Дюп предмета: " .. item.Name)
            
            -- Метод 1: Дроп дюп
            if _G.AdvancedDupeSettings.UseDropMethod then
                local dropDuped = AdvancedDupeModule.DropDupeMethod(item)
                itemDuped = itemDuped + dropDuped
                print("   📦 Дроп метод: +" .. dropDuped)
            end
            
            -- Метод 2: Клон синхронизация
            local cloneDuped = AdvancedDupeModule.CloneSyncMethod(item)
            itemDuped = itemDuped + cloneDuped
            print("   🔄 Клон метод: +" .. cloneDuped)
            
            -- Метод 3: Handle дюп
            local handleDuped = AdvancedDupeModule.HandleDupeMethod(item)
            itemDuped = itemDuped + handleDuped
            print("   🔧 Handle метод: +" .. handleDuped)
            
            -- Метод 4: RemoteEvent дюп
            local remoteDuped = AdvancedDupeModule.RemoteEventDupe(item)
            itemDuped = itemDuped + remoteDuped
            print("   📡 Remote метод: +" .. remoteDuped)
            
            totalDuped = totalDuped + itemDuped
            print("   ✅ Итого для " .. item.Name .. ": " .. itemDuped)
            
            wait(1) -- Пауза между предметами
        end
        
        AdvancedNotify("Дюп завершен", "Всего попыток: " .. totalDuped, 5)
        return totalDuped
    end) or 0
end

-- Специализированные функции дюпа
function AdvancedDupeModule.DupeTrolls()
    return AdvancedDupeModule.AdvancedDupe("troll")
end

function AdvancedDupeModule.DupeValuable()
    local valuable = {"golden", "diamond", "rainbow", "void", "legendary", "epic", "rare"}
    local totalDuped = 0
    
    for _, keyword in pairs(valuable) do
        totalDuped = totalDuped + AdvancedDupeModule.AdvancedDupe(keyword)
        wait(0.5)
    end
    
    return totalDuped
end

function AdvancedDupeModule.DupeMoney()
    local money = {"coin", "money", "cash", "dollar", "gold"}
    local totalDuped = 0
    
    for _, keyword in pairs(money) do
        totalDuped = totalDuped + AdvancedDupeModule.AdvancedDupe(keyword)
        wait(0.5)
    end
    
    return totalDuped
end

function AdvancedDupeModule.DupeAll()
    return AdvancedDupeModule.AdvancedDupe(nil)
end

-- Система команд в чате
local function SetupAdvancedCommands()
    return SafeExecute(function()
        local function onPlayerChatted(message)
            local msg = message:lower()
            
            if msg == "/advdupe" or msg == "/продвинутыйдюп" then
                AdvancedDupeModule.DupeTrolls()
            elseif msg == "/advall" or msg == "/продвинутыевсе" then
                AdvancedDupeModule.DupeAll()
            elseif msg == "/advvaluable" or msg == "/продвинутыеценные" then
                AdvancedDupeModule.DupeValuable()
            elseif msg == "/advmoney" or msg == "/продвинутыеденьги" then
                AdvancedDupeModule.DupeMoney()
            elseif msg:find("/advitem ") or msg:find("/продвинутыйпредмет ") then
                local itemName = msg:gsub("/advitem ", ""):gsub("/продвинутыйпредмет ", "")
                if itemName and itemName ~= "" then
                    AdvancedDupeModule.AdvancedDupe(itemName)
                end
            elseif msg == "/advhelp" or msg == "/продвинутаяпомощь" then
                print("🚀 Продвинутые команды дюпа:")
                print("/advdupe - Продвинутый дюп троллей")
                print("/advall - Продвинутый дюп всех предметов")
                print("/advvaluable - Продвинутый дюп ценных")
                print("/advmoney - Продвинутый дюп денег")
                print("/advitem название - Продвинутый дюп предмета")
                print("")
                print("🔧 Настройки:")
                print("Количество: " .. _G.AdvancedDupeSettings.DupeAmount)
                print("Дроп метод: " .. (_G.AdvancedDupeSettings.UseDropMethod and "ВКЛ" or "ВЫКЛ"))
                print("Задержка: " .. _G.AdvancedDupeSettings.DelayBetweenAttempts .. "с")
            end
        end
        
        LocalPlayer.Chatted:Connect(onPlayerChatted)
        print("🚀 Продвинутые команды дюпа активированы!")
        print("Напишите /advhelp для справки")
    end)
end

-- Инициализация продвинутой версии
print("🚀 Trollge Advanced Dupe Script v2.1 загружен!")
print("💎 Продвинутые методы дюпа:")
print("   • Дроп и быстрый подбор")
print("   • Клонирование с синхронизацией")
print("   • Манипуляция Handle")
print("   • RemoteEvent эксплойты")
print("   • Искусственный лаг сети")
print("")
print("📋 Команды:")
print("   /advdupe - Продвинутый дюп троллей")
print("   /advall - Дюп всех предметов")
print("   /advhelp - Полная справка")

-- Активируем команды
SetupAdvancedCommands()

-- Приветственное сообщение
AdvancedNotify("🚀 Advanced Dupe", "Продвинутый дюп загружен! /advhelp для справки", 5)
