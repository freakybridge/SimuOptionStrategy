% ����Ȩ�б�д��Excel
% v1.2.0.20220105.beta
%       �״����
function SaveOptChain2Excel(~, var, exc, instrus, dir_)

% Ԥ����
file = fullfile(dir_, 'instruments-option.xlsx');
Utility.CheckDirectory(dir_);
instrus = [instrus.Properties.VariableNames; table2cell(instrus)];
sheet = sprintf("%s-%s", var, EnumType.Exchange.ToString(exc));

% д��
xlswrite(file, instrus, sheet);
end