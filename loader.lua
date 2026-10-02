-- =========================================================================
--  SHITARO MM2 - UNIVERSAL GITHUB LOADER
-- =========================================================================

-- Укажи свою ссылку на GitHub (Raw), где лежат файлы скрипта.
-- Обязательно со слешем на конце '/'!
-- Ссылка на твой репозиторий на GitHub (Raw)
local GITHUB_BASE_URL = "https://raw.githubusercontent.com/mintysupport/rebellium-mm2/refs/heads/main/"

if not getgenv().SHITARO_BASE_URL then
	getgenv().SHITARO_BASE_URL = GITHUB_BASE_URL
end

local base = getgenv().SHITARO_BASE_URL
if not string.match(base, "/$") then
	base = base .. "/"
	getgenv().SHITARO_BASE_URL = base
end

-- Очищаем старый кэш obfuscated библиотеки из воркспейса
pcall(function()
	if type(delfile) == "function" and type(isfile) == "function" then
		if isfile("shitaroebet.lua") then
			local ok, c = pcall(readfile, "shitaroebet.lua")
			if ok and type(c) == "string" and (#c > 200000 or string.find(c, "LPH_") or string.find(c, "furynew")) then
				pcall(delfile, "shitaroebet.lua")
			end
		end
	end
end)

-- Скачиваем и запускаем главный файл со сбросом кэша
local cacheBuster = "?t=" .. tostring(os.time())
loadstring(game:HttpGet(base .. "main.lua" .. cacheBuster, false))()
