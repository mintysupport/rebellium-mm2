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

-- Скачиваем и запускаем главный файл
loadstring(game:HttpGet(base .. "main.lua", true))()
