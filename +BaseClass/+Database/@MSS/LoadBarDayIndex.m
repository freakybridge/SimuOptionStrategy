% Microsoft Sql Server / LoadBarDayIndex
% v1.3.0.20220113.beta
%       �״μ���
function md = LoadBarDayIndex(obj, asset)
% ���� / ����
db = obj.GetDbName(asset);
tb = obj.GetTableName(asset);
conn = SelectConn(obj, db);

% ����
try
    sql = sprintf("SELECT [DATENUM], [OPEN], [HIGH], [LOW], [LAST], [VOLUME], [AMOUNT] FROM [%s].[dbo].[%s] ORDER BY [DATENUM]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    md = table2array(fetch(conn, sql));
catch
    md = [];
end
end