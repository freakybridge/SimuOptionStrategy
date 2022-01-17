% Microsoft Sql Server / LoadBarMin
% v1.3.0.20220113.beta
%       首次添加
function LoadBarMin(obj, asset)
% 预处理
db = BaseClass.Database.Database.GetDbName(asset);
tb = BaseClass.Database.Database.GetTableName(asset);
conn = SelectConn(obj, db);

% 读取
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