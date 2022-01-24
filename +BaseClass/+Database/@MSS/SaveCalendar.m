% Microsoft Sql Server / SaveCalendar
% v1.3.0.20220113.beta
%       首次加入
function ret = SaveCalendar(obj, cal)
% 确定库名 / 端口 / 表名
db = obj.db_calendar;
conn = obj.SelectConn(db);
tb = obj.tb_calendar;

% 删除已有表格 / 重新建表
try
    exec(conn, sprintf('DROP TABLE [%s]', tb));
catch
end
CreateTable(obj, conn, db, tb);

% 入库
fprintf('Saving [Calendar] to [%s], please wait ...\r', obj.name);
column = {'DATETIME', 'TRADING', 'WORKING', 'WEEKDAY', 'DATENUM', 'LAST_UPDATE_DATE'};
fastinsert(conn, tb, column, cal);
ret = true;
end

% 建表交易日历
function ret = CreateTable(obj, conn, db, tb)
sql = sprintf("CREATE TABLE [%s](" ...
    + "[DATETIME] [int] NOT NULL PRIMARY KEY, " ...
    + "[TRADING] [int] NULL, " ...
    + "[WORKING] [int] NULL, " ...
    + "[WEEKDAY] [int] NULL, " ...
    + "[DATENUM] [int] NULL, " ...
    + "[LAST_UPDATE_DATE] [numeric](18, 4) NULL " ...
    + ")ON [PRIMARY];" ...
    + "CREATE INDEX [%s] ON [%s] ([DATETIME] ASC);" ...
    , tb, obj.TableIndex(db, tb), tb);
res = exec(conn, sql);

if (~isempty(res.Cursor))
    ret = true;
else
    ret = false;
end
obj.CreateTbResDisp(ret, db, tb, res.Message);
end