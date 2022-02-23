% Microsoft Sql Server / PurgeDatabase
% v1.3.0.20220113.beta
%       首次加入
function ret = PurgeDatabase(obj, varargin)

% 确定端口
conn = obj.SelectConn(obj.db_default);

% 确定需要清理的数据库
dbs = obj.FetchDbsWithPrefix(varargin{:});

% 逐一清理
mark = false(length(dbs), 1);
for i = 1 : length(dbs)
    fprintf('Purging database [%s], %i/%i, please wait ...\r', dbs{i}, i, length(dbs));
    cr = exec(conn, sprintf('DROP DATABASE [%s];', dbs{i}));
    if (isempty(cr.Message))
        mark(i) = true;
    end    
end

% 返回
ret = all(mark);

end