% ETF ������д��csv
% v1.3.0.202201135.beta
%       �״����
function ret = SaveBarDayEtf(~, asset, dir_)
% Ԥ����
% �������Ŀ¼
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
Utility.CheckDirectory(dir_);

% ��������ļ���
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) +  ".csv");

% д���ͷ / д������
id = fopen(filename, 'w');
fprintf(id, 'datetime,nav, nav_adj, open,high,low,last,turnover,volume\r');
for i = 1 : size(asset.md, 1)
    this = asset.md(i, :);
    fprintf(id, '%s,%.5f,%.5f,%.4f,%.4f,%.4f,%.4f,%i,%i\r',...
        datestr(this(1), 'yyyy-mm-dd HH:MM'), ...
        this(4), this(5), ...
        this(6), this(7), this(8), this(9), ...
        this(10), this(11));
end
fclose(id);
ret = true;

end