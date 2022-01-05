% 转换淘宝excel
function ret = TransferTaobaoExcel(dir_hm, dir_tb, dir_sav)
% 读取已有合约信息
ret = false;
instrus = Utility.ReadSheet(dir_hm, 'instrument');

% 检查路径
dir_tb = fullfile(dir_tb, 'dat');
if (~exist(dir_tb, 'dir'))
    warning('can''t find taobao dat directory, please check .');
    return;
end
Utility.CheckDirectory(dir_sav);
    
% 读取所有文件
files = [];
tmp = dir(dir_tb);
for i = 1 : length(tmp)
    this = tmp(i);
    if (~strcmpi(this.name, '.') && ~strcmpi(this.name, '..') && this.isdir)
        files = [files; dir(fullfile(this.folder, this.name))];
    end
end
files([files.bytes] == 0) = [];


% 逐一读取
symbols = cellfun(@(x) str2double(x), instrus(:, 1));
for i = 1 : length(files)
    % 读取合约信息
    this = files(i);
    symb = sscanf(this.name, '%i.xlsx');
    info = instrus(symbols == symb, :);
    opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, dir_sav);
    fprintf('Transfer %s market data, %i/%i,, please wait ...\r', info{1}, i, length(files));
    
    % 读取excel / 清除nan
    [~, ~, dat] = xlsread(fullfile(this.folder, this.name));
    for j = size(dat, 1) : -1 : 1
        if (isnan(dat{j, end}))
            dat(j, :) = [];
        else
            break;
        end
    end
    
    % 整理行情
    header = dat(1, :);
    md = [FetchField(dat, header, '交易时间'), ...
        FetchField(dat, header, '开盘价'), ...
        FetchField(dat, header, '最高价'), ...
        FetchField(dat, header, '最低价'), ...
        FetchField(dat, header, '收盘价'), ...
        FetchField(dat, header, '成交额'), ...
        FetchField(dat, header, '成交量'), ...
        FetchField(dat, header, '持仓量'), ...
        FetchField(dat, header, '行权价'), ...
        FetchField(dat, header, '合约单位'), ...
        FetchField(dat, header, '标的收盘价')];
    opt.MergeMarketData(md);
    
    % 保存excel
    opt.OutputMarketData(dir_sav);    
end
ret = true;

end


% 读取字段
function ret = FetchField(dat, header, field)
loc = ismember(header, field);
if (sum(loc))
    if (strcmpi(field, '交易时间'))
        ret = dat(2 : end, loc);
        ret = datenum(ret);
    else
        ret = cell2mat(dat(2 : end, loc));
    end
else
    ret = zeros(size(dat, 1) - 1, 1);
end
end