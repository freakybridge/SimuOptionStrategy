% ��ȡ�������ݿ����б���
% v1.3.0.20220113.beta
%       1.�״����
function ret = FetchAllTables(obj, db)

% conn
conn = SelectConn(obj, db);

% ����
try
    sql = 'SELECT NAME FROM SYSOBJECTS WHERE XTYPE=''U'' ORDER BY NAME';
    setdbprefs('DataReturnFormat', 'numeric');
    ret = fetch(conn, sql);
    ret = table2array(ret);
catch
    ret = cell(0);
end
end