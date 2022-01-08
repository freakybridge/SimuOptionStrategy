% 转换淘宝excel
% v1.2.0.20220105.beta
%       首次添加
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
    opt = BaseClass.Asset.Option("5M", info{1},  info{2},  info{3},  info{7}, [[930, 1130]; [1300, 1500]], info{4}, info{5}, info{6}, info{8}, info{9});
    fprintf('Transfer %s market data, %i/%i,, please wait ...\r', info{1}, i, length(files));
    
    % 读取excel / 清除nan
    [dat, ~, raw] = xlsread(fullfile(this.folder, this.name));
    raw = raw(1 : 1 + size(dat, 1), :);
    dat = raw(2 : end, :);
    header = raw(1, :);
    
    % 整理行情
    md = [FetchField(dat, header, '交易时间'), ...
        FetchField(dat, header, '开盘价'), ...
        FetchField(dat, header, '最高价'), ...
        FetchField(dat, header, '最低价'), ...
        FetchField(dat, header, '收盘价'), ...
        FetchField(dat, header, '成交额'), ...
        FetchField(dat, header, '成交量'), ...
        FetchField(dat, header, '持仓量'), ...
        FetchField(dat, header, '行权价') / 1000, ...
        FetchField(dat, header, '合约单位'), ...
        FetchField(dat, header, '标的收盘价')];
    opt.MergeMarketData(md);
    
    % 保存CSV
    Apps.DataManger.Md2Csv(dir_sav, opt);
end
ret = true;

end


% 读取字段
function ret = FetchField(dat, header, field)
loc = ismember(header, field);
if (sum(loc))
    if (strcmpi(field, '交易时间'))
        ret = dat(:, loc);
        ret = datenum(ret);
    else
        ret = cell2mat(dat(:, loc));
    end
else
    ret = zeros(size(dat, 1), 1);
end
end