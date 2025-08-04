-- Trollge Simple Working Script для iOS устройств
-- Версия: 2.2 Simple Working Edition
-- Простой скрипт который точно работает

-- Защита от повторной загрузки
if _G.TrollgeSimpleLoaded then
    warn("⚠️ Скрипт уже загружен! Перезапуск...")
end

_G.TrollgeSimpleLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Простые переменные
_G.SimpleClones = _G.SimpleClones or {}

-- Простая функция уведомлений
local function SimpleNotify(text)
    print("📱 " .. text)
    -- Попытка показать уведомление
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Trollge Simple";
            Text = text;
            Duration = 3;
        })
    end)
end

-- Простая функция создания клона
local function CreateSimpleClone()
    local character = LocalPlayer.Character
    if not character then
        SimpleNotify("Персонаж не найден!")
        return
    end
    
    local clone = character:Clone()
    clone.Name = "SimpleClone_" .. math.random(100, 999)
    
    -- Простая очистка
    for _, obj in pairs(clone:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            obj:Destroy()
        end
    end
    
    -- Позиционирование
    if clone:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart") then
        clone.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
    end
    
    clone.Parent = Workspace
    table.insert(_G.SimpleClones, clone)
    
    SimpleNotify("Клон создан! Всего: " .. #_G.SimpleClones)
end

-- Простая функция удаления клонов
local function ClearSimpleClones()
    local count = #_G.SimpleClones
    for _, clone in pairs(_G.SimpleClones) do
        if clone and clone.Parent then
            clone:Destroy()
        end
    end
    _G.SimpleClones = {}
    SimpleNotify("Удалено клонов: " .. count)
end

-- Простая функция получения предметов
local function GetSimpleItems()
    local items = {}
    
    -- Из рюкзака
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(items, item)
        end
    end
    
    -- Из персонажа
    if LocalPlayer.Character then
        for _, item in pairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(items, item)
            end
        end
    end
    
    return items
end

-- Простая функция дюпа (метод копирования)
local function SimpleDupe(filter)
    local items = GetSimpleItems()
    local duped = 0
    
    for _, item in pairs(items) do
        local itemName = item.Name:lower()
        
        -- Проверяем фильтр
        if not filter or itemName:find(filter:lower()) then
            -- Простое копирование
            for i = 1, 3 do
                local copy = item:Clone()
                copy.Name = item.Name .. "_Copy_" .. i
                copy.Parent = LocalPlayer.Backpack
                duped = duped + 1
                wait(0.1)
            end
        end
    end
    
    if duped > 0 then
        SimpleNotify("Скопировано предметов: " .. duped)
    else
        SimpleNotify("Предметы не найдены!")
    end
    
    return duped
end

-- Альтернативный метод дюпа (через Workspace)
local function WorkspaceDupe(filter)
    local items = GetSimpleItems()
    local duped = 0
    
    for _, item in pairs(items) do
        local itemName = item.Name:lower()
        
        if not filter or itemName:find(filter:lower()) then
            local originalParent = item.Parent
            
            -- Дропаем в Workspace
            item.Parent = Workspace
            wait(0.1)
            
            -- Создаем копии пока предмет в Workspace
            for i = 1, 2 do
                local copy = item:Clone()
                copy.Parent = LocalPlayer.Backpack
                duped = duped + 1
                wait(0.05)
            end
            
            -- Возвращаем оригинал
            item.Parent = originalParent
            wait(0.1)
        end
    end
    
    if duped > 0 then
        SimpleNotify("Workspace дюп: " .. duped)
    else
        SimpleNotify("Предметы не найдены!")
    end
    
    return duped
end

-- Функция показа всех предметов
local function ShowAllItems()
    local items = GetSimpleItems()
    
    if #items == 0 then
        SimpleNotify("Предметы не найдены в инвентаре!")
        return
    end
    
    print("📦 Найденные предметы:")
    for i, item in pairs(items) do
        print(i .. ". " .. item.Name .. " (" .. item.ClassName .. ")")
    end
    
    SimpleNotify("Найдено предметов: " .. #items .. " (смотрите консоль)")
end

-- Простые команды в чате
local function SetupSimpleCommands()
    LocalPlayer.Chatted:Connect(function(message)
        local msg = message:lower()
        
        -- Команды клонов
        if msg == "/clone" or msg == "/создать" then
            CreateSimpleClone()
        elseif msg == "/clear" or msg == "/очистить" then
            ClearSimpleClones()
            
        -- Команды дюпа
        elseif msg == "/dupe" or msg == "/дюп" then
            SimpleDupe("troll")
        elseif msg == "/dupeall" or msg == "/дюпвсе" then
            SimpleDupe(nil)
        elseif msg == "/workspace" or msg == "/воркспейс" then
            WorkspaceDupe("troll")
        elseif msg == "/workspaceall" or msg == "/воркспейсвсе" then
            WorkspaceDupe(nil)
            
        -- Команды информации
        elseif msg == "/items" or msg == "/предметы" then
            ShowAllItems()
        elseif msg == "/test" or msg == "/тест" then
            SimpleNotify("Скрипт работает! Предметов: " .. #GetSimpleItems())
            
        -- Команды дюпа конкретных предметов
        elseif msg:find("/dupe ") then
            local itemName = msg:gsub("/dupe ", "")
            SimpleDupe(itemName)
        elseif msg:find("/дюп ") then
            local itemName = msg:gsub("/дюп ", "")
            SimpleDupe(itemName)
            
        -- Справка
        elseif msg == "/help" or msg == "/помощь" then
            print("📱 Простые команды:")
            print("=== КЛОНЫ ===")
            print("/clone - Создать клон")
            print("/clear - Удалить клонов")
            print("")
            print("=== ДЮП ===")
            print("/dupe - Дюп троллей (простой)")
            print("/dupeall - Дюп всех предметов")
            print("/workspace - Дюп троллей (через Workspace)")
            print("/workspaceall - Дюп всех (через Workspace)")
            print("/dupe название - Дюп конкретного предмета")
            print("")
            print("=== ИНФОРМАЦИЯ ===")
            print("/items - Показать все предметы")
            print("/test - Проверить работу скрипта")
            print("/help - Эта справка")
            
            SimpleNotify("Команды выведены в консоль!")
        end
    end)
    
    SimpleNotify("Команды активированы! /help для справки")
end

-- Инициализация простого скрипта
print("📱 Trollge Simple Working Script v2.2 загружен!")
print("✅ Простой и надежный скрипт")
print("📋 Основные команды:")
print("   /clone - Создать клон")
print("   /dupe - Дюп троллей")
print("   /items - Показать предметы")
print("   /help - Все команды")
print("")
print("🔧 Два метода дюпа:")
print("   /dupe - Простое копирование")
print("   /workspace - Дюп через Workspace")

-- Активируем команды
SetupSimpleCommands()

-- Приветственное сообщение
SimpleNotify("Простой скрипт загружен! /help для команд")

-- Автоматическая проверка
wait(2)
local items = GetSimpleItems()
SimpleNotify("Готов к работе! Предметов в инвентаре: " .. #items)

-- Подсказка
if #items == 0 then
    SimpleNotify("Подберите предметы в игре, затем используйте /dupe")
else
    SimpleNotify("Используйте /dupe для дюпа или /items для просмотра")
end
