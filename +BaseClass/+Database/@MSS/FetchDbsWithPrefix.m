% ��ȡ�̶�ǰ׺���ݿ�
% v1.3.0.20220113.beta
%       1.�״����
function ret = FetchDbsWithPrefix(obj, varargin)

% ����
db = obj.db_default;
conn = SelectConn(obj, db);

% ȷ��ǰ׺
prefix = cell(length(varargin), 1);
for i = 1 : length(varargin)
    prefix{i} = [varargin{i}, '%'];
end

% �������
sql = repmat(' name LIKE ''%s'' OR', 1,  length(varargin));
sql(end - 1 : end) = [];
sql = sprintf('SELECT name FROM sysdatabases WHERE %s;', sql);
sql = sprintf(sql, prefix{:});

% ����
try
    ret = table2cell(fetch(conn, sql));
catch
    ret = cell(0);
end
end