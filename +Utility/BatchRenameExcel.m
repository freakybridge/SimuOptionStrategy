function BatchRenameExcel(pth_tar, pth_work)

% 读取所有已知合约信息
instrus = Utility.ReadSheet(pth_work, 'instrument');

% 读取全部文件
files = dir(pth_tar);
for i = 1 : length(files)
    % 筛选目标文件
    this = files(i);
    if (this.isdir)
        continue;
    elseif (~ismember(this.name(strfind(this.name, '.') +1 : end), {'xls', 'xlsx', 'csv'}))
        continue;
    end
    
    % 删除尾部无效信息
    filename_old = sprintf('%s\\%s', pth_tar, this.name);
    [~, ~, dat] = xlsread(filename_old);
    for j = size(dat, 1) : -1 : 1
        if (~isnan(dat{j, end}))
            break;
        end
        dat(j, :) = [];
    end
    
    % 读取必要信息
    symbol = dat{2, 1};
    symbol = symbol(1 : strfind(symbol, '.') - 1);
    
    % 保存新文件
    [~, ~, loc] = intersect(symbol, instrus(:, 1));
    info = instrus(loc, :);
    this_opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, pth_work);
    filename_new = sprintf('%s\\%s.xlsx', pth_tar, this_opt.GetFullSymbol());
    xlswrite(filename_new, dat, 'file');
    
    % 删除旧文件
    delete(filename_old);
end

end