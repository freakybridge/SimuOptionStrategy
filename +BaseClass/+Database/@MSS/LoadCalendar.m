% Microsoft Sql Server / LoadCalendar
% v1.3.0.20220113.beta
%       �״μ���
function cal = LoadCalendar(obj)
% ���� / ����
db = obj.db_calendar;
tb = obj.tb_calendar;
conn = SelectConn(obj, db);

% ����
try
    sql = sprintf("SELECT [DATETIME], [TRADING], [WORKING], [WEEKDAY], [DATENUM], [LAST_UPDATE_DATE] FROM [%s].[dbo].[%s] ORDER BY [DATETIME]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    cal = table2array(fetch(conn, sql));
catch
    cal = zeros(0, 6);
end
end