% ��ȡ�������ݿ�
% v1.3.0.20220113.beta
%       1.�״����
function ret = FetchAllDbs(obj)

% ����
db = obj.db_default;
conn = SelectConn(obj, db);

% ����
try
    sql = 'SELECT NAME FROM MASTER.DBO.SYSDATABASES ORDER BY NAME';
    setdbprefs('DataReturnFormat', 'numeric');
    ret = fetch(conn, sql);
    ret = table2array(ret);
catch
    ret = cell(0);
end
end