% 从csv读取行情
% v1.3.0.20220113.beta
%       首次添加
function md = LoadBar(~, asset, dir_)
% 预处理
% 检查输入目录 / 生成输出文件名
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) + ".csv");

% 检查文件 / 读取
if (~exist(filename, 'file'))
    warning('Please check csv file "%s", can''t find it.', filename);
    md = zeros(0, 8);
else
    md = readtable(filename);
    md = [datenum(table2array(md(:, 1))), table2array(md(:, 2 : end))];
end

if (asset.interval == EnumType.Interval.day)
    if (asset.product == EnumType.Product.ETF)
        md(:, [8, 9]) = md(:, [9, 8]);
    elseif (asset.product == EnumType.Product.Future)
        md(:, [6, 7]) = md(:, [7, 6]);
    elseif (asset.product == EnumType.Product.Index)
        md(:, [6, 7]) = md(:, [7, 6]);
    elseif (asset.product == EnumType.Product.Option)
        md(:, [6, 7]) = md(:, [7, 6]);
    end

else
    md(:, [6, 7]) = md(:, [7, 6]);
end

end