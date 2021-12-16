function BatchRenameExcel(pth_tar, pth_work)

% ��ȡ������֪��Լ��Ϣ
instrus = Utility.ReadSheet(pth_work, 'instrument');

% ��ȡȫ���ļ�
files = dir(pth_tar);
for i = 1 : length(files)
    % ɸѡĿ���ļ�
    this = files(i);
    if (this.isdir)
        continue;
    elseif (~ismember(this.name(strfind(this.name, '.') +1 : end), {'xls', 'xlsx', 'csv'}))
        continue;
    end
    
    % ɾ��β����Ч��Ϣ
    filename_old = sprintf('%s\\%s', pth_tar, this.name);
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
    
    % �������ļ�
    [~, ~, loc] = intersect(symbol, instrus(:, 1));
    info = instrus(loc, :);
    this_opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, pth_work);
    filename_new = sprintf('%s\\%s.xlsx', pth_tar, this_opt.GetFullSymbol());
    xlswrite(filename_new, dat, 'file');
    
    % ɾ�����ļ�
    delete(filename_old);
end

end