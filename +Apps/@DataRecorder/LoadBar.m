% ��csv��ȡ����
% v1.3.0.20220113.beta
%       �״����
function md = LoadBar(~, asset, dir_)
% Ԥ����
% �������Ŀ¼ / ��������ļ���
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) + ".csv");

% ����ļ� / ��ȡ
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