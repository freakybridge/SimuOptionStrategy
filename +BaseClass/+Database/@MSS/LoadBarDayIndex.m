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
    sql = sprintf("SELECT [TIMESTAMP], [OPEN], [HIGH], [LOW], [LAST], [AMOUNT], [VOLUME] FROM [%s].[dbo].[%s] ORDER BY [TIMESTAMP]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    md = fetch(conn, sql);
    md = [datenum(md.DATETIME), table2array(md(:, 2 : end))];
catch
    md = [];
end
end