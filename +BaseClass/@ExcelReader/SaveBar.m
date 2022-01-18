% ��������д��csv
% v1.3.0.202201135.beta
%       �״����
function ret = SaveBar(~, asset, dir_, header, dat_fmt)
% Ԥ����
% �������Ŀ¼
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
Utility.CheckDirectory(dir_);

% ��������ļ���
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) +  ".csv");

% ���б�ͷ / ���ݸ�ʽ
header = [header, '\r'];
dat_fmt = [dat_fmt, '\r'];

% д���ͷ / д������
id = fopen(filename, 'w');
fprintf(id, header);
for i = 1 : size(asset.md, 1)
    this = asset.md(i, :);
    fprintf(id, dat_fmt, datestr(this(1), 'yyyy-mm-dd HH:MM'), this(4 : end));      
end
fclose(id);
ret = true;

end

