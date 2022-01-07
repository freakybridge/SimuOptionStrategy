% ��ȡ����csv
function md = Csv2Md(dir_in, ast)
% Ԥ����
% �������Ŀ¼ / ��������ļ���
dir_in = fullfile(dir_in, sprintf('%s-5m', ast.under));
filename = fullfile(dir_in, [ast.GetFullSymbol(), '.csv']);

% ����ļ�
if (~exist(filename, 'file'))
    warning('Please check csv file "%s", can''t find it', filename);
    md = nan;
    return;
end

% ��ȡ����
[~, ~, dat] = xlsread(filename);
dat(1, :) = [];
ast.md = [datenum(dat(:, 1)), cell2mat(dat(:, 2 : end))];
end