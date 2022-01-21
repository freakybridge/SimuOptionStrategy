% 从期权列表写入Excel
% v1.3.0.20220113.beta
%       首次添加
function ret = SaveChainOption(~, var, exc, instrus, dir_)

% 预处理
dir_ = fullfile(dir_, 'INSTRUMENTS');
Utility.CheckDirectory(dir_);
file = fullfile(dir_, sprintf('%s.xlsx', BaseClass.Database.Database.GetTableName(EnumType.Product.Option, var, exc)));

% 整理变量
instrus = [instrus.Properties.VariableNames; table2cell(instrus)];
instrus(2 : end, 14) = cellfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, instrus(2 : end, 14));
instrus(2 : end, 15) = cellfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, instrus(2 : end, 15));
instrus(2 : end, 17) = cellfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, instrus(2 : end, 17));

% 写入
writecell(instrus, file);
ret = true;
end