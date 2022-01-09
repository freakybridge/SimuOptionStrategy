% ��csv��ȡ����
% v1.2.0.20220105.beta
%       �״����
function LoadMdViaCsv(~, ast, dir_csv)
% Ԥ����
% �������Ŀ¼ / ��������ļ���
dir_csv = fullfile(dir_csv, sprintf('%s-5m', ast.under));
filename = fullfile(dir_csv, [ast.GetFullSymbol(), '.csv']);

% ����ļ� / ��ȡ
if (~exist(filename, 'file'))
    warning('Please check csv file "%s", can''t find it.', filename);
else
    [~, ~, dat] = xlsread(filename);
    dat(1, :) = [];
    ast.MergeMarketData([datenum(dat(:, 1)), cell2mat(dat(:, 2 : end))]);
end

end