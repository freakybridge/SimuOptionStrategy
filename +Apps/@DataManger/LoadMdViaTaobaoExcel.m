% 从淘宝excel读取行情
% v1.2.0.20220105.beta
%       首次添加
function LoadMdViaTaobaoExcel(~, ast, dir_tb)

% 寻找目标文件
files = FetchFiles(dir_tb);
this = files(ismember({files.name}, [ast.symbol, '.xlsx']));
if (isempty(this))
    return;
end
  
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
    FetchField(dat, header, '持仓量')];

% 清除重复时间戳
md = ClearRepeatDatetime(md);

% 写入内存
ast.MergeMarketData(md);
end


% 读取文件目录
function ret = FetchFiles(dir_tb)
persistent files_buffer;
if (~isempty(files_buffer))
    ret = files_buffer;
    return;
end

% 检查路径
dir_tb = fullfile(dir_tb, 'dat');
if (~exist(dir_tb, 'dir'))
    error('can''t find taobao dat directory, please check .');
end

% 读取所有文件
files_buffer = [];
tmp = dir(dir_tb);
for i = 1 : length(tmp)
    this = tmp(i);
    if (~strcmpi(this.name, '.') && ~strcmpi(this.name, '..') && this.isdir)
        files_buffer = [files_buffer; dir(fullfile(this.folder, this.name))];
    end
end
files_buffer([files_buffer.bytes] == 0) = [];
ret = files_buffer;
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

% 清除重复时间戳
function md = ClearRepeatDatetime(md)
% 确定时间戳唯一性
loc = [-1; diff(md(:, 1))];
dt_repeat = unique(md(loc == 0, 1));
if (isempty(dt_repeat))
    return;
end

% 若均无成交量，则保留第一条行情
% 否则保留成交量最大的一条行情
for i = 1 : length(dt_repeat)
    this_dt = dt_repeat(i);
    head = md(md(:, 1) < this_dt, :);
    tail = md(md(:, 1) > this_dt, :);
    body = md(md(:, 1) == this_dt, :);
    
    if (all(body(:, 7) == 0))
        loc = 1;
    else
        [~, loc] = max(body(:, 7));
    end
    body = body(loc, :);
    
    md = [head; body; tail];
end
end