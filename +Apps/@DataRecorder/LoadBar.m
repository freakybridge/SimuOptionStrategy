% ��csv��ȡ����
% v1.3.0.20220113.beta
%       �״����
function LoadBar(~, asset, dir_)
% Ԥ����
% �������Ŀ¼ / ��������ļ���
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) + ".csv");

% ����ļ� / ��ȡ
if (~exist(filename, 'file'))
    warning('Please check csv file "%s", can''t find it.', filename);
else
    dat = readtable(filename);
    asset.MergeMarketData([datenum(table2array(dat(:, 1))), table2array(dat(:, 2 : end))]);
end
end