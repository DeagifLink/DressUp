DressUp.MysqlBase = {}

local mysql_hostname = '127.0.0.1'
local mysql_username = 'root'
local mysql_password = ''
local mysql_database = 'dressup_data'
local mysql_port = 3306

require('mysqloo')

DressUp.MysqlBase.db = mysqloo.connect(mysql_hostname, mysql_username, mysql_password, mysql_database, mysql_port)

function DressUp.MysqlBase.db:onConnected()
    MsgN("[DressUp] Database connected!")
end

function DressUp.MysqlBase.db:onConnectionFailed(err)
    MsgN("[DressUp] Database connection failed: " .. err)
end

DressUp.MysqlBase.db:connect()

function DressUp:InitPlayerData(ply)
    local newData = {
        Items = {},
        ModelItems = {},
    }

    local qs = [[
    INSERT INTO `dressup_data` (accountid, data)
    VALUES ('%s', '%s')
    ON DUPLICATE KEY UPDATE 
        data = VALUES(data)
    ]]

    qs = string.format(qs, ply:AccountID(), util.TableToJSON(newData))
    local q = DressUp.MysqlBase.db:query(qs)

    function q:onSuccess()
        ply.DressUp_Data = newData
        ply:DressUp_SendData()
    end

    function q:onError(err, sql)
        if DressUp.MysqlBase.db:status() ~= mysqloo.DATABASE_CONNECTED then
            DressUp.MysqlBase.db:connect()
            DressUp.MysqlBase.db:wait()
            if DressUp.MysqlBase.db:status() ~= mysqloo.DATABASE_CONNECTED then
                ErrorNoHalt("[DressUp] Database connection failed.")
                return
            end
        end
        MsgN('[DressUp] failed: ' .. err)
        q:start()
    end
    q:start()
end

function DressUp:CheckPlayerData(ply)
    local qs = [[
    SELECT *
    FROM `dressup_data`
    WHERE accountid = '%s'
    ]]
    qs = string.format(qs, ply:AccountID())
    local q = DressUp.MysqlBase.db:query(qs)

    function q:onSuccess(data)
        if #data <= 0 then
            DressUp:InitPlayerData(ply)
        else
            local row = data[1]
            ply.DressUp_Data = util.JSONToTable(row.data)
            ply:DressUp_SendData()
        end
    end

    function q:onError(err, sql)
        if DressUp.MysqlBase.db:status() ~= mysqloo.DATABASE_CONNECTED then
            DressUp.MysqlBase.db:connect()
            DressUp.MysqlBase.db:wait()
        if DressUp.MysqlBase.db:status() ~= mysqloo.DATABASE_CONNECTED then
            ErrorNoHalt("[DressUp] Failed to reconnect the database.")
            return
            end
        end
        MsgN('[DressUp] Failed: ' .. err)
        q:start()
    end
    q:start()
end

function DressUp:SavePlayerData(ply)
    if(!IsValid(ply) or !ply.AccountID)then return end
    local tmp = table.Copy(ply.DressUp_Data)

    local qs = [[
    INSERT INTO `dressup_data` (accountid, data)
    VALUES ('%s', '%s')
    ON DUPLICATE KEY UPDATE 
        data = VALUES(data)
    ]]

    qs = string.format(qs, ply:AccountID(), util.TableToJSON(tmp))
    local q = DressUp.MysqlBase.db:query(qs)

    function q:onError(err, sql)
        if DressUp.MysqlBase.db:status() ~= mysqloo.DATABASE_CONNECTED then
            DressUp.MysqlBase.db:connect()
            DressUp.MysqlBase.db:wait()
            if DressUp.MysqlBase.db:status() ~= mysqloo.DATABASE_CONNECTED then
                ErrorNoHalt("[DressUp] Failed to reconnect the database.")
                return
            end
        end
        MsgN('[DressUp] Failed: ' .. err)
        q:start()
    end
    q:start()
end