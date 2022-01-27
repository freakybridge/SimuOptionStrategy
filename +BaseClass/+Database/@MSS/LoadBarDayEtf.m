% Microsoft Sql Server / LoadBarDayEtf
% v1.3.0.20220113.beta
%       �״μ���
function md = LoadBarDayEtf(obj, asset)
% ���� / ����
db = obj.GetDbName(asset);
tb = obj.GetTableName(asset);
conn = SelectConn(obj, db);

% ����
try
    sql = sprintf("SELECT [DATETIME], [NAV], [NAV_ADJ], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME] FROM [%s].[dbo].[%s] ORDER BY [DATETIME]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    md = fetch(conn, sql);
    md = [datenum(md.DATETIME), table2array(md(:, 2 : end))];
catch
    md = [];
end
end