% Microsoft Sql Server / SaveBarDayFuture
% v1.3.0.20220113.beta
%       �״μ���
function ret = SaveBarDayFuture(obj, asset)
% 获取数据�? / 端口 / 表名 / �?�?
db = obj.GetDbName(asset);
conn = obj.SelectConn(db);
tb = obj.GetTableName(asset);
if (~CheckTable(obj, db, tb))
    CreateTable(obj, conn, db, tb, asset);
end

% 生成sql
sql = string();
for i = 1 : size(asset.md, 1)
    this = asset.md(i, :);
    head = sprintf("IF EXISTS (SELECT * FROM [%s] WHERE [DATETIME] = '%s') UPDATE [%s] SET [OPEN] = %f, [HIGH] = %f, [LOW] = %f, [LAST] = %f, [TURNOVER] = %f, [VOLUME] = %f, [OI] = %f WHERE [DATETIME] = '%s'", ...
        tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), tb, this(4), this(5), this(6), this(7), this(8), this(9), this(10), datestr(this(1), 'yyyy-mm-dd HH:MM'));
    tail = sprintf(" ELSE INSERT [%s]([DATETIME], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME], [OI]) VALUES ('%s', %f, %f, %f, %f, %f, %f, %f)", ...
        tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), this(4), this(5), this(6), this(7), this(8), this(9), this(10));
    sql = sql + head + tail;
end

% 入库
exec(conn, sql);
ret = true;
end