% 从期权列表写入Excel
% v1.2.0.20220105.beta
%       首次添加
function ret = SaveOptChain2Excel(~, var, exc, instrus, dir_)
import EnumType.Exchange;

% 预处理
file = fullfile(dir_, 'instruments-option.xlsx');
Utility.CheckDirectory(dir_);
instrus = [instrus.Properties.VariableNames; table2cell(instrus)];
sheet = sprintf("%s-%s", var, Exchange.ToString(Exchange.ToEnum(exc)));

% 写入
xlswrite(file, instrus, sheet);
ret = true;
end