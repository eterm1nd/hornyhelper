---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local

script_name("Horny Helper")
script_description('Script helper for Families')
script_author("eterm1nd")
script_version("2.2")
local ffi = require('ffi')
local sampev = require('samp.events')
local imgui = require 'imgui'
local enabled = false

-- Название окна
local window_title = "Horny Helper 2.2 by eterm1nd"

-- Цвета сообщений
local welcome_color = 0xFFff0000
local err_color = 0xFFff0000
local success_color = 0xFF00ff00

local commands = {
    {command = "hh", description = "Открыть окно помощника", hint = "Открывает окно помощника с подсказками", handler = "toggleWindow"},
    {command = "fi", description = "Пригласить игрока в семью", hint = "/fi [id] - пригласить игрока в семью", handler = "inviteToFamily"},
    {command = "fu", description = "Выгнать игрока из семьи", hint = "/fu [id] - выгнать по причине \"Нарушение правил семьи\"\n/fu [id] [причина] - выгнать по указанной причине", handler = "kickFromFamily"},
    {command = "fmt", description = "Заглушить игрока в рации семьи", hint = "/fmt [id] - выдать мут игроку на 10 мин по причине Н.П.Ч.\n/fmt [id] [причина] - выдать мут игроку на 10 мин по указанной причине\n/fmt [id] [время] - выдать мут игроку на кол-во мин. по причине Н.П.Ч.\n/fmt [id] [время] [причина] - выдать мут игроку на кол-во мин. по указанной причине", handler = "muteFamilyRadio"},
    {command = "fw", description = "Выдать предупреждение участнику семьи", hint = "/fw [id] - выдать предупреждение игроку по причине \"Нарушение правил семьи\"\n/fw [id] [причина] - выдать предупреждение игроку по указанной причине", handler = "warnFamilyMember"},
    {command = "frek", description = "Прорекламировать продажу рангов в семье", hint = "", handler = "advertiseRanks"},
    {command = "frc", description = "Заспавнить незанятые авто в автопарке семьи", hint = "", handler = "spawnFamilyCars"},
    {command = "fumt", description = "Снять глушилку рации участнику семьи", hint = "/fumt [id] - снять глушилку рации участнику семьи", handler = "unmuteFamilyRadio"},
    {command = "fuw", description = "Снять предупреждение участнику семьи", hint = "/fuw [id] - снять предупреждение участнику семьи по причине \"подарок\"\n/fuw [id] [причина] - снять предупреждение участнику семьи по указанной причине", handler = "removeFamilyWarning"}
}

function onetotwo(input)
    -- Убираем пробелы в начале и в конце строки
    input = input:match("^%s*(.-)%s*$")

    -- Разделяем строку на 2 части: id и reason
    local id, reason = input:match("^(%S+)%s*(.*)$")

    -- Преобразуем id в число
    local id_num = tonumber(id) or 0  -- Если не число, то 0

    -- Возвращаем id и reason
    return id_num, reason
end


function onetothree(input)
    -- Убираем пробелы в начале и в конце строки
    input = input:match("^%s*(.-)%s*$")

    -- Разделяем строку на 3 части: id, time, reason
    local id, time, reason = input:match("^(%S+)%s*(%S*)%s*(.*)$")

    -- Преобразуем id в число
    local id_num = tonumber(id) or 0  -- Если не число, то 0

    -- Преобразуем time в число. Если не получается, то time_num будет 0, а reason будет вторым значением
    local time_num = tonumber(time)

    if not time_num then
        -- Если time не число, то time_num = 0, а reason становится вторым значением
        time_num = 0
        reason = time
    end

    -- Возвращаем id, time и reason
    return id_num, time_num, reason
end

-- Функция для переключения состояния окна
function toggleWindow()
    enabled = not enabled
end

-- Функция для получения имени игрока по ID
function getname(id)
    return sampGetPlayerNickname(id)
end

-- Функция для отправки чата и выполнения действий
function playrp(messages)
    lua_thread.create(function()
        isActiveCommand = true
        -- Отправляем все сообщения с паузами
        for _, message in ipairs(messages) do
            sampSendChat(message)
            wait(1000)
        end
        -- Завершаем команду после отправки всех сообщений
        isActiveCommand = false
    end)
end

-- Основная функция для отображения окна
imgui.OnRender(function()
    if enabled then
        imgui.SetNextWindowSize(imgui.ImVec2(500, 400), imgui.Cond.FirstUseEver)
        imgui.Begin(window_title, true, imgui.WindowFlags.AlwaysAutoResize)
        for _, cmd in ipairs(commands) do
            if imgui.Selectable(cmd.command .. " - " .. cmd.description) then
                -- Показать подсказку
            end
            if imgui.IsItemHovered() then
                imgui.SetTooltip(cmd.hint)
            end
        end
        imgui.End()
    end
end)

-- Основная функция для инициализации хелпера
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end
    welcome_message()
    commands()
end

-- Функция для приветственного сообщения
function welcome_message()
    if not sampIsLocalPlayerSpawned() then
        sampAddChatMessage('{ff0000}______________________{00ff00}[Horny Helper 2.2 by eterm1nd]{ff0000}______________________',welcome_color)
        sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}]: {00ff00}Инициализация хелпера прошла успешно!',welcome_color)
        sampAddChatMessage('{ffffff}[{ffff00}WARNING{ffffff}]: {ffff00}Для полной загрузки хелпера сначало заспавнитесь (войдите на сервер)',welcome_color)
        sampAddChatMessage('{ffffff}[{f7f7f7}INFO{ffffff}]: Доступны команды: {00ff00}/hh /fi /fu /fmt /fumt /fw /fuw /frc /frek',welcome_color)
        sampAddChatMessage('{ff0000}_______________________________________________________________________',welcome_color)
        repeat wait(0) until sampIsLocalPlayerSpawned()
    end
    sampAddChatMessage('{ff0000}______________________{00ff00}[Horny Helper 2.2 by eterm1nd]{ff0000}______________________',welcome_color)
    sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}]: {00ff00}Загрузка хелпера прошла успешно!',welcome_color)
    sampAddChatMessage('{ff0000}_______________________________________________________________________',welcome_color)
end

function commands()
    sampRegisterChatCommand('fi',function(arg)
        local id = arg
        if not isActiveCommand then
            if arg ~= nil then
                local invite_rp = {
                    '/do В пожилом чемодане, набитом баксами, лежат приглашения в семью.',
                    '/me растегнул чемодан с помощью молнии, всунул руку внутрь и достал бумажки',
                    '/do Бумажка оказалась приглашением в семью с довольно привлекательным внешним видом.',
                    '/me взявши за уголок приглашения, протянул его человеку напротив',
                    '/do В приглашении написано "Приглашение в семью Horny Squad"',
                    '/faminvite ' .. id,
                    '/b ' .. getname(id) .. " Прийми /offer, что бы втупить в семью"
                }
                    sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fi с аргументом ' .. id, success_color)
                    playrp(invite_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fi){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} Не указан аргумент команды', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} уже исполняеться какая-то команда', err_color)
        end
    end)

    sampRegisterChatCommand('fu',function(arg)
        local id, reason = onetotwo(arg)
        if not isActiveCommand then

            -- Указаны все аргументы
            if id ~= 0 and reason ~= "" then
                local uninvite_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "Исключить участника", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Исключить из семьи ' .. getname(id) .. ' ' .. 'за: ' .. reason,
                    '/me нажал кнопку подтверждения',
                    '/famuninvite ' .. id .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fu с аргументом ' .. id .. ' ' .. reason, success_color)
                playrp(uninvite_rp)

                -- Не указана причина применяеться стандартное значение
            elseif id ~= 0 and reason == "" then
                local uninvite_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "Исключить участника", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Исключить из семьи ' .. getname(id) .. ' ' .. 'за: нарушение правил семьи?',
                    '/me нажал кнопку подтверждения',
                    '/famuninvite ' .. id .. 'нарушение правил семьи'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fu с аргументом ' .. id .. ' ' .. reason, success_color)
                playrp(uninvite_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fu){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} Не указан аргумент команды', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} уже исполняеться какая-то команда', err_color)
        end
    end)

    sampRegisterChatCommand('fw',function(arg)
        if not isActiveCommand then
            local id, reason = onetotwo(arg)

            -- Указаны все аргументы
            if id ~= 0 and reason ~= "" then
                local warn_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "сделать выговор участнику", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Сделать выговор ' .. getname(id) .. ' ' .. 'за: ' .. reason,
                    '/me нажал кнопку подтверждения',
                    '/famwarn ' .. id .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fw с аргументом ' .. id .. ' ' .. reason, success_color)
                playrp(warn_rp)

                -- Не указана причина применяеться стандартное значение
            elseif id ~= 0 and reason == "" then
                local warn_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "сделать выговор участнику", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Сделать выговор ' .. getname(id) .. ' ' .. 'за: нарушение правил семьи?',
                    '/me нажал кнопку подтверждения',
                    '/famwarn ' .. id .. 'нарушение правил семьи'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fw с аргументом ' .. id .. ' ' .. reason, success_color)
                playrp(warn_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fw){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} Не указан аргумент команды', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} уже исполняеться какая-то команда', err_color)
        end
    end)

    sampRegisterChatCommand('fmt', function(arg)
        if not isActiveCommand then
            local id, time, reason = onetothree(arg)
            
            -- Указаны все аргументы
            if id ~= 0 and time ~= 0 and reason ~= "" then
                local mute_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "Заглушить волну рации участнику", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Заглушить волну FM для ' .. getname(id) .. ' за: ' .. reason .. ' на: ' .. time .. ' мин?"',
                    '/me нажал кнопку подтверждения',
                    '/fammute ' .. id .. ' ' .. time .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fmt с аргументом ' .. id .. ' ' .. time .. ' ' .. reason, success_color)
                playrp(mute_rp)
            
            -- Не указано время наказания, используется стандартные 10 минут
            elseif id ~= 0 and time == 0 and reason ~= "" then
                local mute_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "Заглушить волну рации участнику", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Заглушить волну FM для ' .. getname(id) .. ' за: ' .. reason .. ' на: 10 мин?"',
                    '/me нажал кнопку подтверждения',
                    '/fammute ' .. id .. ' ' .. 10 .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fmt с аргументом ' .. id .. ' ' .. 10 .. ' ' .. reason, success_color)
                playrp(mute_rp)
            
            -- Не указана причина наказания, используется стандартная "Н.П.Ч"
            elseif id ~= 0 and time ~= 0 and reason == "" then
                local mute_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "Заглушить волну рации участнику", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Заглушить волну FM для ' .. getname(id) .. ' за: Н.П.Ч. на: ' .. time .. ' мин?"',
                    '/me нажал кнопку подтверждения',
                    '/fammute ' .. id .. ' ' .. time .. ' Н.П.Ч.'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fmt с аргументом ' .. id .. ' ' .. time .. ' Н.П.Ч.', success_color)
                playrp(mute_rp)
            
            -- Не указаны время и причина, используется стандартная "Н.П.Ч" и 10 минут
            elseif id ~= 0 and time == 0 and reason == "" then
                local mute_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "Заглушить волну рации участнику", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Заглушить волну FM для ' .. getname(id) .. ' за: Н.П.Ч. на: 10 мин?"',
                    '/me нажал кнопку подтверждения',
                    '/fammute ' .. id .. ' ' .. 10 .. ' Н.П.Ч.'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fmt с аргументом ' .. id .. ' 10 Н.П.Ч.', success_color)
                playrp(mute_rp)
            
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fmt){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} Не указан аргумент команды', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} Уже исполняется какая-то команда', err_color)
        end
    end)
    sampRegisterChatCommand("frek", function()
        if not isActiveCommand then
            local marketing_messages = {
                "/fam Привет, в нашей семье есть возможность покупки рангов",
                "/fam [2]Огузок - 1.OOO.OOO$",
                "/fam [3]Скромник - 1.5OO.OOO$",
                "/fam [4]Пупсик - 2.OOO.OOO$",
                "/fam [5]Водитель велосипеда - 3.5OO.OOO$",
                "/fam [6]Кайфуша - 4.OOO.OOO$",
                "/fam [7]Спортик - 5.5OO.OOO$",
                "/fam [8]Оператор качалки - 6.0OO.OOO$",
                "/fam [9]Блатной - Установка Фамилии Horny",
                "/fam Опплатить ранг можно в разделе /fammenu -> Семейная квартира",
                "/fam [5] Положить деньги на склад семьи",
                "/fam Не забудь сделать скриншот с time (/time + F8)",
                "/fam отправлять в ТГ: @BizH0",
                "/fam Замки не выдаём!!!",
                "/fam Неактив - 30 дней (автокик)",
                "/fam ранги после неактива/ухода из семьи не восстанавливаем",
                "/fam Наш дискорд: https://discord.gg/cTRWq99XQ9"
            }
            playrp(marketing_messages)
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} Уже исполняется какая-то команда', err_color)
        end
    end)

    sampRegisterChatCommand('fumt',function(arg)
        id = arg
        if not isActiveCommand then
            if id ~= 0 then
                local unmute_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "Разглушить волну рации участнику", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Разглушить волну FM для ' .. getname(id) .. '?".',
                    '/me нажал кнопку подтверждения',
                    '/famunmute ' .. id
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fumt с аргументом ' .. id, success_color)
                playrp(unmute_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fumt){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} Не указан аргумент команды', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} Уже исполняется какая-то команда', err_color)
        end
    end)

    sampRegisterChatCommand('fuw',function(arg)
        if not isActiveCommand then
            local id, reason = onetotwo(arg)

            -- Указаны все аргументы
            if id ~= 0 and reason ~= "" then
                local unwarn_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "Убрать выговор участнику", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Убрать выговор ' .. getname(id) .. ' ' .. 'за: ' .. reason,
                    '/me нажал кнопку подтверждения',
                    '/unfamwarn ' .. id .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fuw с аргументом ' .. id .. ' ' .. reason, success_color)
                playrp(unwarn_rp)

                -- Не указана причина применяеться стандартное значение
            elseif id ~= 0 and reason == "" then
                local warn_rp = {
                    '/do В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                    '/me залез рукой в карман, затем, нащупав телефон, достал его',
                    '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                    '/do На экране приложение в виде плиток управления семьей.',
                    '/me выбрал на телефоне пункт "Убрать выговор участнику", выбрал ' .. getname(id),
                    '/do На телефоне появилось окно с надписью и кнопками Да и Нет.',
                    '/do Надпись: "Снять выговор ' .. getname(id) .. ' ' .. 'причина: подарок?',
                    '/me нажал кнопку подтверждения',
                    '/unfamwarn ' .. id .. 'подарок'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} Успешно применили команду /fuw с аргументом ' .. id .. ' ' .. reason, success_color)
                playrp(unwarn_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fuw){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} Не указан аргумент команды', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} уже исполняеться какая-то команда', err_color)
        end
    end)

    sampRegisterChatCommand('frc',function()
        if not isActiveCommand then
            local car_rp = {
                '/fam [WARNING]: Через 15 секунд произойдёт спавн всех незанятых автомобилей',
                '/fam Займите автомобиль.',
                'В кармане тёмно коричневого халата лежит IPhone 16 Pro Max 1TB.',
                '/me залез рукой в карман, затем, нащупав телефон, достал его',
                '/me разблокировал телефон отпечатком пальца, затем перешел в приложение управление семьей',
                '/do На экране приложение в виде плиток управления семьей.',
                '/me выбрал на телефоне пункт "Заказать транспорт"'
            }
            lua_thread.create(function()
                isActiveCommand = true
                -- Отправляем все сообщения с паузами
                for _, message in ipairs(car_rp) do
                    sampSendChat(message)
                    wait(1000)
                end
                    wait(10000)
                    sampSendChat('/famspawn')
                -- Завершаем команду после отправки всех сообщений
                isActiveCommand = false
            end)
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} уже исполняеться какая-то команда', err_color)
        end
    end)

    -- Регистрация команды /hh
    sampRegisterChatCommand("hh", function()
        toggleWindow()
        if enabled then
            sampAddChatMessage('{ffffff}[{00ff00}INFO{ffffff}][{00ff00}Horny Helper{ffffff}]: {00ff00}Окно хелпера включено', success_color)
        else
            sampAddChatMessage('{ffffff}[{00ff00}INFO{ffffff}][{00ff00}Horny Helper{ffffff}]: {ff0000}Окно хелпера выключено', err_color)
        end
    end)
end