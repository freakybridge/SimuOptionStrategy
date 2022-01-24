% Microsoft Sql Server / LoadCalendar
% v1.3.0.20220113.beta
%       首次加入
function cal = LoadCalendar(obj)
% 库名 / 表名
db = obj.db_calendar;
tb = obj.tb_calendar;
conn = SelectConn(obj, db);

% 载入
try
    sql = sprintf("SELECT [DATETIME], [TRADING], [WORKING], [WEEKDAY], [DATENUM], [LAST_UPDATE_DATE] FROM [%s].[dbo].[%s] ORDER BY [DATETIME]", db, tb);
    setdbprefs('DataReturnFormat', 'numeric');
    cal = table2array(fetch(conn, sql));
catch
    cal = zeros(0, 6);
end
end