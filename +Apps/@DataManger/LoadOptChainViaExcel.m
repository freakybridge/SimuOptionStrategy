% ��excel��ȡ��Ȩ�б�
% v1.2.0.20220105.beta
%       �״����
function instrus = LoadOptChainViaExcel(~, variety, exchange, dir_excel)

% Ԥ����
file = fullfile(dir_excel, 'instruments-option.xlsx');
if (~exist(file, 'file'))
    error("Can't find ""%s"", please check.", file);
end
try
    exchange = EnumType.Exchange.ToEnum(exchange);
    sheet = sprintf("%s-%s", variety, EnumType.Exchange.ToString(exchange));
    [~, ~, instrus] = xlsread(file, sheet);
catch
    error("Excel %s reading error, please check.", file);
end

% ����
instrus = cell2table(instrus(2 : end, :), 'VariableNames', instrus(1, :));

end