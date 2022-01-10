% ��csv��ȡ��Ȩ�б�
% v1.2.0.20220105.beta
%       �״����
function instrus = LoadOptChainViaExcel(obj, variety, exchange, dir_excel)

% Ԥ����
file = fullfile(dir_excel, 'instruments-option.xlsx');
if (~exist(file, 'file'))
    error("Can't find ""%s"", please check.", file);
end
exchange = EnumType.Exchange.ToEnum(exchange);
sheet = sprintf("%s-%s", variety, EnumType.Exchange.ToString(exchange));

% ��ȡ
[~, ~, dat1] = xlsread(file, sheet);
[~, ~, dat2] = xlsread(file, '510300-SSE');

end