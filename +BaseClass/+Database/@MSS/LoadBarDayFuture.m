% Microsoft Sql Server / LoadBarDayFuture
% v1.3.0.20220113.beta
%       首次加入
function LoadBarDayFuture(obj, asset)
% 棰勫鐞?
db = obj.GetDbName(asset);
tb = obj.GetTableName(asset);
conn = SelectConn(obj, db);

% 璇诲彇
try
    sql = sprintf("SELECT [DATETIME], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME], [OI] FROM [%s].[dbo].[%s] ORDER BY [DATETIME]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    md = fetch(conn, sql);
    md = [datenum(md.DATETIME), table2array(md(:, 2 : end))];
    asset.MergeMarketData(md);
catch
    asset.md = [];
end
end