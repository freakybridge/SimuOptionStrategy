% 读取行情csv
function md = Csv2MarketData(dir_in, opt)
% 预处理
% 检查输入目录 / 生成输出文件名
dir_in = fullfile(dir_in, sprintf('%s-5m', opt.under));
filename = fullfile(dir_in, [opt.GetFullSymbol(), '.csv']);

% 检查文件
if (~exist(filename, 'file'))
    warning('Please check csv file "%s", can''t find it', filename);
    md = nan;
    return;
end

% 读取数据
[~, ~, dat] = xlsread(filename);
dat(1, :) = [];
md = [datenum(dat(:, 1)), cell2mat(dat(:, 2 : end))];

end