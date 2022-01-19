% 获取给定表的原始数据
% v1.3.0.20220113.beta
%       1.首次添加
function ret = FetchRawData(obj, db, tb)

% conn
conn = SelectConn(obj, db);

% 载入
try
    sql = sprintf('SELECT * FROM [%s].[dbo].[%s]', db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    ret = fetch(conn, sql);
    ret = table2array(ret);
catch
    ret = zeros(0);
end
end