% ��Excel��ȡ��Ȩ�б�
% v1.2.0.20220105.beta
%       �״����
function instrus = LoadOptChainViaExcel(~, var, exc, dir_)

% Ԥ����
file = fullfile(dir_, 'instruments-option.xlsx');
if (~exist(file, 'file'))
    error("Can't find ""%s"", please check.", file);
end
try
    exc = EnumType.Exchange.ToEnum(exc);
    sheet = sprintf("%s-%s", var, EnumType.Exchange.ToString(exc));
    [~, ~, instrus] = xlsread(file, sheet);
catch
    error("Excel %s reading error, please check.", file);
end

% ����
instrus = cell2table(instrus(2 : end, :), 'VariableNames', instrus(1, :));

end