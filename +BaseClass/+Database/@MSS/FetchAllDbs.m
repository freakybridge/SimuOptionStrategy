% 获取所有数据库
% v1.3.0.20220113.beta
%       1.首次添加
function ret = FetchAllDbs(obj)

% 库名
db = obj.db_default;
conn = SelectConn(obj, db);

% 载入
try
    sql = 'SELECT NAME FROM MASTER.DBO.SYSDATABASES ORDER BY NAME';
    setdbprefs('DataReturnFormat', 'numeric');
    ret = fetch(conn, sql);
    ret = table2array(ret);
catch
    ret = cell(0);
end
end