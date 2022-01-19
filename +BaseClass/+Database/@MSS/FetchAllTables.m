% 获取给定数据库所有表名
% v1.3.0.20220113.beta
%       1.首次添加
function ret = FetchAllTables(obj, db)

% conn
conn = SelectConn(obj, db);

% 载入
try
    sql = 'SELECT NAME FROM SYSOBJECTS WHERE XTYPE=''U'' ORDER BY NAME';
    setdbprefs('DataReturnFormat', 'numeric');
    ret = fetch(conn, sql);
    ret = table2array(ret);
catch
    ret = cell(0);
end
end