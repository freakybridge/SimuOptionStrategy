% ���ڻ��б�д��Excel
% v1.3.0.20220113.beta
%       �״����
function ret = SaveChainFuture(~, var, exc, instrus, dir_)
error('Under construction, please check.');

% Ԥ����
import EnumType.Exchange;
file = fullfile(dir_, 'instruments-option.xlsx');
Utility.CheckDirectory(dir_);
instrus = [instrus.Properties.VariableNames; table2cell(instrus)];
sheet = sprintf("%s-%s", var, Exchange.ToString(Exchange.ToEnum(exc)));

% д��
xlswrite(file, instrus, sheet);
ret = true;
end