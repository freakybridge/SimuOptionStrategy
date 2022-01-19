% ��ȡ�������ԭʼ����
% v1.3.0.20220113.beta
%       1.�״����
function ret = FetchRawData(obj, db, tb)

% conn
conn = SelectConn(obj, db);

% ����
try
    sql = sprintf('SELECT * FROM [%s].[dbo].[%s]', db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    ret = fetch(conn, sql);
    ret = table2array(ret);
catch
    ret = zeros(0);
end
end