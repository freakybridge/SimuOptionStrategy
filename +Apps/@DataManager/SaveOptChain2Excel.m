% ����Ȩ�б�д��Excel
% v1.2.0.20220105.beta
%       �״����
function ret = SaveOptChain2Excel(~, var, exc, instrus, dir_)
import EnumType.Exchange;

% Ԥ����
file = fullfile(dir_, 'instruments-option.xlsx');
Utility.CheckDirectory(dir_);
instrus = [instrus.Properties.VariableNames; table2cell(instrus)];
sheet = sprintf("%s-%s", var, Exchange.ToString(Exchange.ToEnum(exc)));

% д��
xlswrite(file, instrus, sheet);
ret = true;
end