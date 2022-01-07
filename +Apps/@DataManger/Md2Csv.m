% ����д��csv
function ret = Md2Csv(dir_out, opt, md)
% Ԥ����
% �������Ŀ¼
dir_out = fullfile(dir_out, sprintf('%s-5m', opt.under));
Utility.CheckDirectory(dir_out);

% ��������ļ���
filename = fullfile(dir_out, [opt.GetFullSymbol(), '.csv']);

% д���ͷ / д������
id = fopen(filename, 'w');
fprintf(id, 'datetime,open,high,low,last,turnover,volume,oi,strike,unit,spot\r');
for i = 1 : size(md, 1)
    this = md(i, :);
    fprintf(id, '%s,%.4f,%.4f,%.4f,%.4f,%i,%i,%i,%.3f,%i,%.3f\r',...
        datestr(this(1), 'yyyy-mm-dd HH:MM'), ...
        this(4), this(5), this(6), this(7), ...
        this(8), this(9), this(10), this(11), ...
        this(12), this(13));      
end
fclose(id);
ret = true;

end