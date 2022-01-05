function BatchRenameExcel(root_, pth_in)

% ·������
dir_out = fullfile(pth_in, 'final');
Utility.CheckDirectory(dir_out);


% ��ȡ������֪��Լ��Ϣ
instrus = Utility.ReadSheet(root_, 'instrument');

% ��ȡȫ���ļ�
files = dir(pth_in);
for i = 1 : length(files)
    % ɸѡĿ���ļ�
    this = files(i);
    if (this.isdir)
        continue;
    elseif (~ismember(this.name(strfind(this.name, '.') +1 : end), {'xls', 'xlsx', 'csv'}))
        continue;
    end
    
    % ɾ��β����Ч��Ϣ
    filename_old = sprintf('%s\\%s', pth_in, this.name);
    [~, ~, dat] = xlsread(filename_old);
    for j = size(dat, 1) : -1 : 1
        if (~isnan(dat{j, end}))
            break;
        end
        dat(j, :) = [];
    end
    
    % ��ȡ��Ҫ��Ϣ
    symbol = dat{2, 1};
    symbol = symbol(1 : strfind(symbol, '.') - 1);
    
    % ������Ϣ
    dat(:, 1 : 2) = [];
    dat(1, :) = [];
    dat = [cellfun(@(x) datenum(x), dat(:, 1)), cell2mat(dat(:, 2 : end))];
    dat(:, 6) = 1000000 * dat(:, 6);
        
    % �������ļ�
    [~, ~, loc] = intersect(symbol, instrus(:, 1));
    info = instrus(loc, :);
    opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, dir_out);
    opt.MergeMarketData(dat);
    opt.OutputMarketData(dir_out);   
    fprintf('%s data transfered, %i/%i, please check...\r', symbol, i, length(files));
end
end