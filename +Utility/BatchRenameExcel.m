function BatchRenameExcel(root_, pth_in)

% 路径设置
dir_out = fullfile(pth_in, 'final');
Utility.CheckDirectory(dir_out);


% 读取所有已知合约信息
instrus = Utility.ReadSheet(root_, 'instrument');

% 读取全部文件
files = dir(pth_in);
for i = 1 : length(files)
    % 筛选目标文件
    this = files(i);
    if (this.isdir)
        continue;
    elseif (~ismember(this.name(strfind(this.name, '.') +1 : end), {'xls', 'xlsx', 'csv'}))
        continue;
    end
    
    % 删除尾部无效信息
    filename_old = sprintf('%s\\%s', pth_in, this.name);
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
    
    % 整理信息
    dat(:, 1 : 2) = [];
    dat(1, :) = [];
    dat = [cellfun(@(x) datenum(x), dat(:, 1)), cell2mat(dat(:, 2 : end))];
    dat(:, 6) = 1000000 * dat(:, 6);
        
    % 保存新文件
    [~, ~, loc] = intersect(symbol, instrus(:, 1));
    info = instrus(loc, :);
    opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, dir_out);
    opt.MergeMarketData(dat);
    opt.OutputMarketData(dir_out);   
    fprintf('%s data transfered, %i/%i, please check...\r', symbol, i, length(files));
end
end