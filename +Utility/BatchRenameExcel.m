function BatchRenameExcel(pth_tar, pth_work)

% 读取所有已知合约信息
instrus = Utility.ReadSheet(pth_work, 'instrument');

% 读取全部文件
hm_pth = cd;
cd(pth_tar);
files = dir;

for i = 1 : length(files)
    % 筛选目标文件
    this = files(i);
    if (this.isdir)
        continue;
    elseif (~ismember(this.name(strfind(this.name, '.') +1 : end), {'xls', 'xlsx', 'csv'}))
        continue;
    end
    
    % 删除尾部无效信息
    [~, ~, dat] = xlsread(this.name);
    for j = size(dat, 1) : -1 : 1
        if (~isnan(dat{j, end}))
            break;
        end
        dat(j, :) = [];
    end
    
    % 读取必要信息
    symbol = dat{2, 1};
    symbol = symbol(1 : strfind(symbol, '.') - 1);
    
    % 重命名
    [~, ~, loc] = intersect(symbol, instrus(:, 1));
    info = instrus(loc, :);
    this_opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, pth_work);

end


cd(hm_pth);
end