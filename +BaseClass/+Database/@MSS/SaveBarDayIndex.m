% Microsoft Sql Server / SaveBarDayIndex
% v1.3.0.20220113.beta
%       首次加入
function ret = SaveBarDayIndex(obj, asset, md)
% 确定库名 / 端口 / 表名
db = obj.GetDbName(asset);
conn = obj.SelectConn(db);
tb = obj.GetTableName(asset);
if (~CheckTable(obj, db, tb))
    CreateTable(obj, conn, db, tb);
end

% 删除行情
sql = sprintf("DELETE FROM [%s] WHERE [TIMESTAMP] >= '%s';", tb, datestr(md(1, 1), 'yyyy-mm-dd HH:MM:SS'));
exec(conn, sql);

% 行情预处理
[str, dm, dt, tm] = Utility.ConvertTimeStamp(md(:, 1));
md = [str, num2cell([dm, dt, tm, md(:, 2 : end)])]';
steps = 1 : obj.lmt_insert : size(md, 2);

% 生成sql
sql = [];
for i = 1 : length(steps)
    % 提取行情
    loc_s = steps(i);
    if (i ~= length(steps))
        loc_e = steps(i) + obj.lmt_insert - 1;
    else
        loc_e = size(md, 2);
    end
    md_in = md(:, loc_s : loc_e);

    % 入库
    tmp = '(''%s'', %f, %i, %i, %f, %f, %f, %f, %f, %f),';
    tmp = repmat(tmp, 1, size(md_in, 2));
    tmp(end) = ';';
    tmp = ['INSERT INTO [%s] ([TIMESTAMP], [DATENUM], [DATE], [TIME], [OPEN], [HIGH], [LOW], [LAST], [AMOUNT], [VOLUME]) VALUES', tmp];
    sql = [sql, sprintf(tmp, tb, md_in{:})];
end
exec(conn, sql);
ret = true;

end

% 建表 Index 日线数据
function ret = CreateTable(obj, conn, db, tb)
sql = sprintf("CREATE TABLE [%s](" ...
    + "[TIMESTAMP] [datetime] NOT NULL PRIMARY KEY, " ...
    + "[DATENUM] [float] NULL, " ...
    + "[DATE] [int] NULL, " ...
    + "[TIME] [int] NULL, " ...
    + "[OPEN] [numeric](18, 4) NULL, " ...
    + "[HIGH] [numeric](18, 4) NULL, " ...
    + "[LOW] [numeric](18, 4) NULL, " ...
    + "[LAST] [numeric](18, 4) NULL, " ...
    + "[AMOUNT] [numeric](18, 4) NULL, " ...
    + "[VOLUME] [numeric](18, 4) NULL, " ...
    + ")ON [PRIMARY];" ...
    + "CREATE INDEX [%s] ON [%s] ([TIMESTAMP] ASC);" ...
    , tb, obj.TableIndex(db, tb), tb);
res = exec(conn, sql);

if (~isempty(res.Cursor))
    ret = true;
else
    ret = false;
end
obj.CreateTbResDisp(ret, db, tb, res.Message);
obj.CreateTriggerOverviews(db, tb);
end