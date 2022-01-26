% Microsoft Sql Server / LoadBarDayEtf
% v1.3.0.20220113.beta
%       首次加入
function LoadBarDayEtf(obj, asset)
% 库名 / 表名
db = obj.GetDbName(asset);
tb = obj.GetTableName(asset);
conn = SelectConn(obj, db);

% 载入
try
    sql = sprintf("SELECT [DATETIME], [NAV], [NAV_ADJ], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME] FROM [%s].[dbo].[%s] ORDER BY [DATETIME]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    md = fetch(conn, sql);
    md = [datenum(md.DATETIME), table2array(md(:, 2 : end))];
    asset.MergeMarketData(md);
catch
    asset.md = [];
end
end