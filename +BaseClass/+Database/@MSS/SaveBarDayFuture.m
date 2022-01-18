% Microsoft Sql Server / SaveBarDayFuture
% v1.3.0.20220113.beta
%       �״μ���
function ret = SaveBarDayFuture(obj, asset)
% ȷ������ / �˿� / ����
db = obj.GetDbName(asset);
conn = obj.SelectConn(db);
tb = obj.GetTableName(asset);
if (~CheckTable(obj, db, tb))
    CreateTable(obj, conn, db, tb);
end

% ���� sql
sql = string();
for i = 1 : size(asset.md, 1)
    this = asset.md(i, :);
    head = sprintf("IF EXISTS (SELECT * FROM [%s] WHERE [DATETIME] = '%s') UPDATE [%s] SET [OPEN] = %f, [HIGH] = %f, [LOW] = %f, [LAST] = %f, [TURNOVER] = %f, [VOLUME] = %f, [OI] = %f, [PRE_SETTLE] = %f, [SETTLE] = %f, [ST_STOCK] = %f WHERE [DATETIME] = '%s'", ...
        tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), tb, this(4), this(5), this(6), this(7), this(8), this(9), this(10), this(11), this(12), this(13), datestr(this(1), 'yyyy-mm-dd HH:MM'));
    tail = sprintf(" ELSE INSERT [%s]([DATETIME], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME], [OI], [PRE_SETTLE], [SETTLE], [ST_STOCK]) VALUES ('%s', %f, %f, %f, %f, %f, %f, %f, %f, %f, %f)", ...
        tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), this(4), this(5), this(6), this(7), this(8), this(9), this(10), this(11), this(12), this(13));
    sql = sql + head + tail;
end

% ���
exec(conn, sql);
ret = true;
end



% ���� FUTURE ��������
function ret = CreateTable(obj, conn, db, tb)
sql = sprintf("CREATE TABLE [%s](" ...
    + "[DATETIME] [datetime] NOT NULL PRIMARY KEY, " ...
    + "[OPEN] [numeric](18, 4) NULL, " ...
    + "[HIGH] [numeric](18, 4) NULL, " ...
    + "[LOW] [numeric](18, 4) NULL, " ...
    + "[LAST] [numeric](18, 4) NULL, " ...
    + "[TURNOVER] [numeric](18, 4) NULL, " ...
    + "[VOLUME] [numeric](18, 4) NULL, " ...
    + "[OI] [numeric](18, 4) NULL, " ...
    + "[PRE_SETTLE] [numeric](18, 4) NULL, " ...
    + "[SETTLE] [numeric](18, 4) NULL, " ...
    + "[ST_STOCK] [numeric](18, 4) NULL " ...
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