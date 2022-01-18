% ����Ȩ�б�д��Excel
% v1.3.0.20220113.beta
%       �״����
function ret = SaveChainOption(~, var, exc, instrus, dir_)

% Ԥ����
import EnumType.Exchange;
file = fullfile(dir_, 'instruments-option.xlsx');
Utility.CheckDirectory(dir_);
sheet = sprintf("%s-%s", var, Exchange.ToString(Exchange.ToEnum(exc)));

% �������
instrus = [instrus.Properties.VariableNames; table2cell(instrus)];
instrus(2 : end, 14) = cellfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, instrus(2 : end, 14));
instrus(2 : end, 15) = cellfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, instrus(2 : end, 15));
instrus(2 : end, 17) = cellfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, instrus(2 : end, 17));

% д��
xlswrite(file, instrus, sheet);
ret = true;
end