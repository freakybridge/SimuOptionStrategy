% Microsoft Sql Server / LoadBarDayFuture
% v1.3.0.20220113.beta
%       �״μ���
function LoadBarDayFuture(obj, asset)
% ���� / ����
db = obj.GetDbName(asset);
tb = obj.GetTableName(asset);
conn = SelectConn(obj, db);

% ����
try
    sql = sprintf("SELECT [DATETIME], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME], [OI], [PRE_SETTLE], [SETTLE], [ST_STOCK] FROM [%s].[dbo].[%s] ORDER BY [DATETIME]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    md = fetch(conn, sql);
    md = [datenum(md.DATETIME), table2array(md(:, 2 : end))];
    asset.MergeMarketData(md);
catch
    asset.md = [];
end
end