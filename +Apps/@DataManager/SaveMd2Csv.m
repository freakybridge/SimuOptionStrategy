% ����д��csv
% v1.2.0.20220105.beta
%       �״�����
function ret = SaveMd2Csv(~, ast, dir_csv)
% Ԥ����
% �������Ŀ¼
dir_csv = fullfile(dir_csv, BaseClass.Database.Database.GetDbName(ast));
Utility.CheckDirectory(dir_csv);

% ��������ļ���
filename = fullfile(dir_csv, [BaseClass.Database.Database.GetTableName(ast), '.csv']);

% д���ͷ / д������
id = fopen(filename, 'w');
fprintf(id, 'datetime,open,high,low,last,turnover,volume,oi\r');
for i = 1 : size(ast.md, 1)
    this = ast.md(i, :);
    fprintf(id, '%s,%.4f,%.4f,%.4f,%.4f,%i,%i,%i\r',...
        datestr(this(1), 'yyyy-mm-dd HH:MM'), ...
        this(4), this(5), this(6), this(7), ...
        this(8), this(9), this(10));      
end
fclose(id);
ret = true;

end