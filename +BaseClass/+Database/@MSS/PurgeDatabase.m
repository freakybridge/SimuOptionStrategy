% Microsoft Sql Server / PurgeDatabase
% v1.3.0.20220113.beta
%       �״μ���
function ret = PurgeDatabase(obj, varargin)

% ȷ���˿�
conn = obj.SelectConn(obj.db_default);

% ȷ����Ҫ��������ݿ�
dbs = obj.FetchDbsWithPrefix(varargin{:});

% ��һ����
mark = false(length(dbs), 1);
for i = 1 : length(dbs)
    fprintf('Purging database [%s], %i/%i, please wait ...\r', dbs{i}, i, length(dbs));
    cr = exec(conn, sprintf('DROP DATABASE [%s];', dbs{i}));
    if (isempty(cr.Message))
        mark(i) = true;
    end    
end

% ����
ret = all(mark);

end