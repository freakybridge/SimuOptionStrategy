% 从csv读取行情
% v1.2.0.20220105.beta
%       首次添加
function LoadMdViaCsv(~, dir_in, ast)
% 预处理
% 检查输入目录 / 生成输出文件名
dir_in = fullfile(dir_in, sprintf('%s-5m', ast.under));
filename = fullfile(dir_in, [ast.GetFullSymbol(), '.csv']);

% 检查文件 / 读取
if (~exist(filename, 'file'))
    warning('Please check csv file "%s", can''t find it', filename);
    ast.md = nan;
else
    [~, ~, dat] = xlsread(filename);
    dat(1, :) = [];
    ast.md = [datenum(dat(:, 1)), cell2mat(dat(:, 2 : end))];   
end

end