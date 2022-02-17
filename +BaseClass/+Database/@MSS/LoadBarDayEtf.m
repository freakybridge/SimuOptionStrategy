% Microsoft Sql Server / LoadBarDayEtf
% v1.3.0.20220113.beta
%       首次加入
function md = LoadBarDayEtf(obj, asset)
% 库名 / 表名
db = obj.GetDbName(asset);
tb = obj.GetTableName(asset);
conn = SelectConn(obj, db);

% 载入
try
    sql = sprintf("SELECT [DATENUM], [NAV], [NAV_ADJ], [OPEN], [HIGH], [LOW], [LAST], [VOLUME], [AMOUNT] FROM [%s].[dbo].[%s] ORDER BY [DATENUM]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    md = table2array(fetch(conn, sql));
catch
    md = [];
end
end