% 从期货列表写入Excel
% v1.3.0.20220113.beta
%       首次添加
function ret = SaveChainFuture(~, var, exc, instrus, dir_)
error('Under construction, please check.');

% 预处理
import EnumType.Exchange;
file = fullfile(dir_, 'instruments-option.xlsx');
Utility.CheckDirectory(dir_);
instrus = [instrus.Properties.VariableNames; table2cell(instrus)];
sheet = sprintf("%s-%s", var, Exchange.ToString(Exchange.ToEnum(exc)));

% 写入
xlswrite(file, instrus, sheet);
ret = true;
end