% Microsoft Sql Server / LoadBarMin
% v1.3.0.20220113.beta
%       首次加入
function md = LoadBarMin(obj, asset)
% 库名 / 表名
db = obj.GetDbName(asset);
tb = obj.GetTableName(asset);
conn = SelectConn(obj, db);

% 载入
try
    sql = sprintf("SELECT [DATENUM], [OPEN], [HIGH], [LOW], [LAST], [VOLUME], [AMOUNT], [OI] FROM [%s].[dbo].[%s] ORDER BY [DATENUM]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    md = table2array(fetch(conn, sql));
catch
    md = [];
end
end