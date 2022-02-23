% 获取固定前缀数据库
% v1.3.0.20220113.beta
%       1.首次添加
function ret = FetchDbsWithPrefix(obj, varargin)

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
sql = sprintf('SELECT name FROM sysdatabases WHERE %s;', sql);
sql = sprintf(sql, prefix{:});

% 载入
try
    ret = table2cell(fetch(conn, sql));
catch
    ret = cell(0);
end
end