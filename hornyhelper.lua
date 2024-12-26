---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local

script_name("Horny Helper")
script_description('Script helper for Families')
script_author("eterm1nd")
script_version("2.2")
local ffi = require('ffi')
local sampev = require('samp.events')
local imgui = require 'imgui'
local enabled = false

-- �������� ����
local window_title = "Horny Helper 2.2 by eterm1nd"

-- ����� ���������
local welcome_color = 0xFFff0000
local err_color = 0xFFff0000
local success_color = 0xFF00ff00

local commands = {
    {command = "hh", description = "������� ���� ���������", hint = "��������� ���� ��������� � �����������", handler = "toggleWindow"},
    {command = "fi", description = "���������� ������ � �����", hint = "/fi [id] - ���������� ������ � �����", handler = "inviteToFamily"},
    {command = "fu", description = "������� ������ �� �����", hint = "/fu [id] - ������� �� ������� \"��������� ������ �����\"\n/fu [id] [�������] - ������� �� ��������� �������", handler = "kickFromFamily"},
    {command = "fmt", description = "��������� ������ � ����� �����", hint = "/fmt [id] - ������ ��� ������ �� 10 ��� �� ������� �.�.�.\n/fmt [id] [�������] - ������ ��� ������ �� 10 ��� �� ��������� �������\n/fmt [id] [�����] - ������ ��� ������ �� ���-�� ���. �� ������� �.�.�.\n/fmt [id] [�����] [�������] - ������ ��� ������ �� ���-�� ���. �� ��������� �������", handler = "muteFamilyRadio"},
    {command = "fw", description = "������ �������������� ��������� �����", hint = "/fw [id] - ������ �������������� ������ �� ������� \"��������� ������ �����\"\n/fw [id] [�������] - ������ �������������� ������ �� ��������� �������", handler = "warnFamilyMember"},
    {command = "frek", description = "���������������� ������� ������ � �����", hint = "", handler = "advertiseRanks"},
    {command = "frc", description = "���������� ��������� ���� � ��������� �����", hint = "", handler = "spawnFamilyCars"},
    {command = "fumt", description = "����� �������� ����� ��������� �����", hint = "/fumt [id] - ����� �������� ����� ��������� �����", handler = "unmuteFamilyRadio"},
    {command = "fuw", description = "����� �������������� ��������� �����", hint = "/fuw [id] - ����� �������������� ��������� ����� �� ������� \"�������\"\n/fuw [id] [�������] - ����� �������������� ��������� ����� �� ��������� �������", handler = "removeFamilyWarning"}
}

function onetotwo(input)
    -- ������� ������� � ������ � � ����� ������
    input = input:match("^%s*(.-)%s*$")

    -- ��������� ������ �� 2 �����: id � reason
    local id, reason = input:match("^(%S+)%s*(.*)$")

    -- ����������� id � �����
    local id_num = tonumber(id) or 0  -- ���� �� �����, �� 0

    -- ���������� id � reason
    return id_num, reason
end


function onetothree(input)
    -- ������� ������� � ������ � � ����� ������
    input = input:match("^%s*(.-)%s*$")

    -- ��������� ������ �� 3 �����: id, time, reason
    local id, time, reason = input:match("^(%S+)%s*(%S*)%s*(.*)$")

    -- ����������� id � �����
    local id_num = tonumber(id) or 0  -- ���� �� �����, �� 0

    -- ����������� time � �����. ���� �� ����������, �� time_num ����� 0, � reason ����� ������ ���������
    local time_num = tonumber(time)

    if not time_num then
        -- ���� time �� �����, �� time_num = 0, � reason ���������� ������ ���������
        time_num = 0
        reason = time
    end

    -- ���������� id, time � reason
    return id_num, time_num, reason
end

-- ������� ��� ������������ ��������� ����
function toggleWindow()
    enabled = not enabled
end

-- ������� ��� ��������� ����� ������ �� ID
function getname(id)
    return sampGetPlayerNickname(id)
end

-- ������� ��� �������� ���� � ���������� ��������
function playrp(messages)
    lua_thread.create(function()
        isActiveCommand = true
        -- ���������� ��� ��������� � �������
        for _, message in ipairs(messages) do
            sampSendChat(message)
            wait(1000)
        end
        -- ��������� ������� ����� �������� ���� ���������
        isActiveCommand = false
    end)
end

-- �������� ������� ��� ����������� ����
imgui.OnRender(function()
    if enabled then
        imgui.SetNextWindowSize(imgui.ImVec2(500, 400), imgui.Cond.FirstUseEver)
        imgui.Begin(window_title, true, imgui.WindowFlags.AlwaysAutoResize)
        for _, cmd in ipairs(commands) do
            if imgui.Selectable(cmd.command .. " - " .. cmd.description) then
                -- �������� ���������
            end
            if imgui.IsItemHovered() then
                imgui.SetTooltip(cmd.hint)
            end
        end
        imgui.End()
    end
end)

-- �������� ������� ��� ������������� �������
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end
    welcome_message()
    commands()
end

-- ������� ��� ��������������� ���������
function welcome_message()
    if not sampIsLocalPlayerSpawned() then
        sampAddChatMessage('{ff0000}______________________{00ff00}[Horny Helper 2.2 by eterm1nd]{ff0000}______________________',welcome_color)
        sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}]: {00ff00}������������� ������� ������ �������!',welcome_color)
        sampAddChatMessage('{ffffff}[{ffff00}WARNING{ffffff}]: {ffff00}��� ������ �������� ������� ������� ������������ (������� �� ������)',welcome_color)
        sampAddChatMessage('{ffffff}[{f7f7f7}INFO{ffffff}]: �������� �������: {00ff00}/hh /fi /fu /fmt /fumt /fw /fuw /frc /frek',welcome_color)
        sampAddChatMessage('{ff0000}_______________________________________________________________________',welcome_color)
        repeat wait(0) until sampIsLocalPlayerSpawned()
    end
    sampAddChatMessage('{ff0000}______________________{00ff00}[Horny Helper 2.2 by eterm1nd]{ff0000}______________________',welcome_color)
    sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}]: {00ff00}�������� ������� ������ �������!',welcome_color)
    sampAddChatMessage('{ff0000}_______________________________________________________________________',welcome_color)
end

function commands()
    sampRegisterChatCommand('fi',function(arg)
        local id = arg
        if not isActiveCommand then
            if arg ~= nil then
                local invite_rp = {
                    '/do � ������� ��������, ������� �������, ����� ����������� � �����.',
                    '/me ��������� ������� � ������� ������, ������ ���� ������ � ������ �������',
                    '/do ������� ��������� ������������ � ����� � �������� ��������������� ������� �����.',
                    '/me ������ �� ������ �����������, �������� ��� �������� ��������',
                    '/do � ����������� �������� "����������� � ����� Horny Squad"',
                    '/faminvite ' .. id,
                    '/b ' .. getname(id) .. " ������ /offer, ��� �� ������� � �����"
                }
                    sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fi � ���������� ' .. id, success_color)
                    playrp(invite_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fi){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} �� ������ �������� �������', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} ��� ������������ �����-�� �������', err_color)
        end
    end)

    sampRegisterChatCommand('fu',function(arg)
        local id, reason = onetotwo(arg)
        if not isActiveCommand then

            -- ������� ��� ���������
            if id ~= 0 and reason ~= "" then
                local uninvite_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "��������� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "��������� �� ����� ' .. getname(id) .. ' ' .. '��: ' .. reason,
                    '/me ����� ������ �������������',
                    '/famuninvite ' .. id .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fu � ���������� ' .. id .. ' ' .. reason, success_color)
                playrp(uninvite_rp)

                -- �� ������� ������� ������������ ����������� ��������
            elseif id ~= 0 and reason == "" then
                local uninvite_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "��������� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "��������� �� ����� ' .. getname(id) .. ' ' .. '��: ��������� ������ �����?',
                    '/me ����� ������ �������������',
                    '/famuninvite ' .. id .. '��������� ������ �����'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fu � ���������� ' .. id .. ' ' .. reason, success_color)
                playrp(uninvite_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fu){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} �� ������ �������� �������', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} ��� ������������ �����-�� �������', err_color)
        end
    end)

    sampRegisterChatCommand('fw',function(arg)
        if not isActiveCommand then
            local id, reason = onetotwo(arg)

            -- ������� ��� ���������
            if id ~= 0 and reason ~= "" then
                local warn_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "������� ������� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "������� ������� ' .. getname(id) .. ' ' .. '��: ' .. reason,
                    '/me ����� ������ �������������',
                    '/famwarn ' .. id .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fw � ���������� ' .. id .. ' ' .. reason, success_color)
                playrp(warn_rp)

                -- �� ������� ������� ������������ ����������� ��������
            elseif id ~= 0 and reason == "" then
                local warn_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "������� ������� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "������� ������� ' .. getname(id) .. ' ' .. '��: ��������� ������ �����?',
                    '/me ����� ������ �������������',
                    '/famwarn ' .. id .. '��������� ������ �����'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fw � ���������� ' .. id .. ' ' .. reason, success_color)
                playrp(warn_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fw){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} �� ������ �������� �������', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} ��� ������������ �����-�� �������', err_color)
        end
    end)

    sampRegisterChatCommand('fmt', function(arg)
        if not isActiveCommand then
            local id, time, reason = onetothree(arg)
            
            -- ������� ��� ���������
            if id ~= 0 and time ~= 0 and reason ~= "" then
                local mute_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "��������� ����� ����� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "��������� ����� FM ��� ' .. getname(id) .. ' ��: ' .. reason .. ' ��: ' .. time .. ' ���?"',
                    '/me ����� ������ �������������',
                    '/fammute ' .. id .. ' ' .. time .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fmt � ���������� ' .. id .. ' ' .. time .. ' ' .. reason, success_color)
                playrp(mute_rp)
            
            -- �� ������� ����� ���������, ������������ ����������� 10 �����
            elseif id ~= 0 and time == 0 and reason ~= "" then
                local mute_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "��������� ����� ����� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "��������� ����� FM ��� ' .. getname(id) .. ' ��: ' .. reason .. ' ��: 10 ���?"',
                    '/me ����� ������ �������������',
                    '/fammute ' .. id .. ' ' .. 10 .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fmt � ���������� ' .. id .. ' ' .. 10 .. ' ' .. reason, success_color)
                playrp(mute_rp)
            
            -- �� ������� ������� ���������, ������������ ����������� "�.�.�"
            elseif id ~= 0 and time ~= 0 and reason == "" then
                local mute_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "��������� ����� ����� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "��������� ����� FM ��� ' .. getname(id) .. ' ��: �.�.�. ��: ' .. time .. ' ���?"',
                    '/me ����� ������ �������������',
                    '/fammute ' .. id .. ' ' .. time .. ' �.�.�.'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fmt � ���������� ' .. id .. ' ' .. time .. ' �.�.�.', success_color)
                playrp(mute_rp)
            
            -- �� ������� ����� � �������, ������������ ����������� "�.�.�" � 10 �����
            elseif id ~= 0 and time == 0 and reason == "" then
                local mute_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "��������� ����� ����� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "��������� ����� FM ��� ' .. getname(id) .. ' ��: �.�.�. ��: 10 ���?"',
                    '/me ����� ������ �������������',
                    '/fammute ' .. id .. ' ' .. 10 .. ' �.�.�.'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fmt � ���������� ' .. id .. ' 10 �.�.�.', success_color)
                playrp(mute_rp)
            
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fmt){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} �� ������ �������� �������', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} ��� ����������� �����-�� �������', err_color)
        end
    end)
    sampRegisterChatCommand("frek", function()
        if not isActiveCommand then
            local marketing_messages = {
                "/fam ������, � ����� ����� ���� ����������� ������� ������",
                "/fam [2]������ - 1.OOO.OOO$",
                "/fam [3]�������� - 1.5OO.OOO$",
                "/fam [4]������ - 2.OOO.OOO$",
                "/fam [5]�������� ���������� - 3.5OO.OOO$",
                "/fam [6]������� - 4.OOO.OOO$",
                "/fam [7]������� - 5.5OO.OOO$",
                "/fam [8]�������� ������� - 6.0OO.OOO$",
                "/fam [9]������� - ��������� ������� Horny",
                "/fam ��������� ���� ����� � ������� /fammenu -> �������� ��������",
                "/fam [5] �������� ������ �� ����� �����",
                "/fam �� ������ ������� �������� � time (/time + F8)",
                "/fam ���������� � ��: @BizH0",
                "/fam ����� �� �����!!!",
                "/fam ������� - 30 ���� (�������)",
                "/fam ����� ����� ��������/����� �� ����� �� ���������������",
                "/fam ��� �������: https://discord.gg/cTRWq99XQ9"
            }
            playrp(marketing_messages)
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} ��� ����������� �����-�� �������', err_color)
        end
    end)

    sampRegisterChatCommand('fumt',function(arg)
        id = arg
        if not isActiveCommand then
            if id ~= 0 then
                local unmute_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "���������� ����� ����� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "���������� ����� FM ��� ' .. getname(id) .. '?".',
                    '/me ����� ������ �������������',
                    '/famunmute ' .. id
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fumt � ���������� ' .. id, success_color)
                playrp(unmute_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fumt){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} �� ������ �������� �������', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} ��� ����������� �����-�� �������', err_color)
        end
    end)

    sampRegisterChatCommand('fuw',function(arg)
        if not isActiveCommand then
            local id, reason = onetotwo(arg)

            -- ������� ��� ���������
            if id ~= 0 and reason ~= "" then
                local unwarn_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "������ ������� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "������ ������� ' .. getname(id) .. ' ' .. '��: ' .. reason,
                    '/me ����� ������ �������������',
                    '/unfamwarn ' .. id .. ' ' .. reason
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fuw � ���������� ' .. id .. ' ' .. reason, success_color)
                playrp(unwarn_rp)

                -- �� ������� ������� ������������ ����������� ��������
            elseif id ~= 0 and reason == "" then
                local warn_rp = {
                    '/do � ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                    '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                    '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                    '/do �� ������ ���������� � ���� ������ ���������� ������.',
                    '/me ������ �� �������� ����� "������ ������� ���������", ������ ' .. getname(id),
                    '/do �� �������� ��������� ���� � �������� � �������� �� � ���.',
                    '/do �������: "����� ������� ' .. getname(id) .. ' ' .. '�������: �������?',
                    '/me ����� ������ �������������',
                    '/unfamwarn ' .. id .. '�������'
                }
                sampAddChatMessage('{ffffff}[{00ff00}SUCCESS{ffffff}][{00ff00}Horny Helper{ffffff}]:{00ff00} ������� ��������� ������� /fuw � ���������� ' .. id .. ' ' .. reason, success_color)
                playrp(unwarn_rp)
            else
                sampAddChatMessage('{ffffff}[{ff0000}ERR (/fuw){ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} �� ������ �������� �������', err_color)
            end
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} ��� ������������ �����-�� �������', err_color)
        end
    end)

    sampRegisterChatCommand('frc',function()
        if not isActiveCommand then
            local car_rp = {
                '/fam [WARNING]: ����� 15 ������ ��������� ����� ���� ��������� �����������',
                '/fam ������� ����������.',
                '� ������� ���� ����������� ������ ����� IPhone 16 Pro Max 1TB.',
                '/me ����� ����� � ������, �����, ������� �������, ������ ���',
                '/me ������������� ������� ���������� ������, ����� ������� � ���������� ���������� ������',
                '/do �� ������ ���������� � ���� ������ ���������� ������.',
                '/me ������ �� �������� ����� "�������� ���������"'
            }
            lua_thread.create(function()
                isActiveCommand = true
                -- ���������� ��� ��������� � �������
                for _, message in ipairs(car_rp) do
                    sampSendChat(message)
                    wait(1000)
                end
                    wait(10000)
                    sampSendChat('/famspawn')
                -- ��������� ������� ����� �������� ���� ���������
                isActiveCommand = false
            end)
        else
            sampAddChatMessage('{ffffff}[{ff0000}ERR{ffffff}][{00ff00}Horny Helper{ffffff}]:{ff0000} ��� ������������ �����-�� �������', err_color)
        end
    end)

    -- ����������� ������� /hh
    sampRegisterChatCommand("hh", function()
        toggleWindow()
        if enabled then
            sampAddChatMessage('{ffffff}[{00ff00}INFO{ffffff}][{00ff00}Horny Helper{ffffff}]: {00ff00}���� ������� ��������', success_color)
        else
            sampAddChatMessage('{ffffff}[{00ff00}INFO{ffffff}][{00ff00}Horny Helper{ffffff}]: {ff0000}���� ������� ���������', err_color)
        end
    end)
end