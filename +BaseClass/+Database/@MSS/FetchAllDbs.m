% 获取所有数据库
% v1.3.0.20220113.beta
%       1.首次添加
function ret = FetchAllDbs(obj)

% 库名
db = obj.db_default;
conn = SelectConn(obj, db);

% 确定前缀
prefix = cell(length(varargin), 1);
for i = 1 : length(varargin)
    prefix{i} = [varargin{i}, '%'];
end

% 生成语句
sql = repmat(' name LIKE ''%s'' OR', 1,  length(varargin));
sql(end - 1 : end) = [];
sql = sprintf('DECLARE dbs CURSOR FAST_FORWARD FOR SELECT name FROM sysdatabases WHERE %s;', sql);
sql = sprintf(sql, prefix{:});

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