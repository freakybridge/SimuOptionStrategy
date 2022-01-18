% ��csv��ȡ����
% v1.3.0.20220113.beta
%       �״����
function LoadBarMin(~, asset, dir_)
% Ԥ����
% �������Ŀ¼ / ��������ļ���
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) + ".csv");

% ����ļ� / ��ȡ
if (~exist(filename, 'file'))
    warning('Please check csv file "%s", can''t find it.', filename);
else
    [~, ~, dat] = xlsread(filename);
    dat(1, :) = [];
    asset.MergeMarketData([datenum(dat(:, 1)), cell2mat(dat(:, 2 : end))]);
end
end