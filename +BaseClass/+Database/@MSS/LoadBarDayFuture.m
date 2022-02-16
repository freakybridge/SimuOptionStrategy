% Microsoft Sql Server / LoadBarDayFuture
% v1.3.0.20220113.beta
%       首次加入
function md = LoadBarDayFuture(obj, asset)
% 库名 / 表名
db = obj.GetDbName(asset);
tb = obj.GetTableName(asset);
conn = SelectConn(obj, db);

% 载入
try
    sql = sprintf("SELECT [TIMESTAMP], [OPEN], [HIGH], [LOW], [LAST], [AMOUNT], [VOLUME], [OI], [PRE_SETTLE], [SETTLE], [ST_STOCK] FROM [%s].[dbo].[%s] ORDER BY [TIMESTAMP]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    md = fetch(conn, sql);
    md = [datenum(md.DATETIME), table2array(md(:, 2 : end))];
catch
    md = [];
end
end