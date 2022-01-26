% Microsoft Sql Server / SaveBarMin
% v1.3.0.20220113.beta
%       首次加入
function ret = SaveBarMin(obj, asset)
% 确定库名 / 端口 / 表名
db = obj.GetDbName(asset);
conn = obj.SelectConn(db);
tb = obj.GetTableName(asset);
if (~CheckTable(obj, db, tb))
    CreateTable(obj, conn, db, tb);
end

% 行情预处理
md = asset.md;
md = [arrayfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM:SS')}, md(:, 1)), num2cell(md(:, 4 : end))];
tbs = repmat({tb}, size(md, 1), 1);
md = [tbs, md(:, 1), tbs, md(:, 2 : end), md(:, 1), tbs, md]';

% 准备sql
sql = " IF EXISTS (SELECT * FROM [%s] WHERE [DATETIME] = '%s') UPDATE [%s] SET [OPEN] = %f, [HIGH] = %f, [LOW] = %f, [LAST] = %f, [TURNOVER] = %f, [VOLUME] = %f, [OI] = %f WHERE [DATETIME] = '%s' ELSE INSERT [%s]([DATETIME], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME], [OI]) VALUES ('%s', %f, %f, %f, %f, %f, %f, %f)";
sql = repmat(sql, 1, size(md, 2));
sql = [sql{:}];
sql = sprintf(sql, md{:});

% 入库
exec(conn, sql);
ret = true;

end

% 建表分钟K线数据
function ret = CreateTable(obj, conn, db, tb)
sql = sprintf("CREATE TABLE [%s](" ...
    + "[DATETIME] [datetime] NOT NULL PRIMARY KEY, " ...
    + "[OPEN] [numeric](18, 4) NULL, " ...
    + "[HIGH] [numeric](18, 4) NULL, " ...
    + "[LOW] [numeric](18, 4) NULL, " ...
    + "[LAST] [numeric](18, 4) NULL, " ...
    + "[TURNOVER] [numeric](18, 4) NULL, " ...
    + "[VOLUME] [numeric](18, 4) NULL, " ...
    + "[OI] [numeric](18, 4) NULL " ...
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