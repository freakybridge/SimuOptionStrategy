% 从csv读取行情
% v1.3.0.20220113.beta
%       首次添加
function LoadBarMin(~, asset, dir_)
% 预处理
% 检查输入目录 / 生成输出文件名
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) + ".csv");

% 检查文件 / 读取
if (~exist(filename, 'file'))
    warning('Please check csv file "%s", can''t find it.', filename);
else
    [~, ~, dat] = xlsread(filename);
    dat(1, :) = [];
    asset.MergeMarketData([datenum(dat(:, 1)), cell2mat(dat(:, 2 : end))]);
end
end