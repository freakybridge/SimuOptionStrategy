% 从淘宝excel读取行情
% LoadMdViaTaobaoExcel(~, asset, dir_tb)
% v1.2.0.20220105.beta
%       首次添加
function LoadMdViaTaobaoExcel(obj, asset, dir_tb, dir_alt)
% 寻找目标文件
files = FetchFiles(dir_tb);
this = files(ismember({files.name}, [asset.symbol, '.xlsx']));
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
    FetchField(dat, header, '成交量'), ...
    FetchField(dat, header, '成交额'), ...
    FetchField(dat, header, '持仓量')];

% 清除重复时间戳
md = ClearRepeatDatetime(md);

% 写入内存
asset.MergeMarketData(md);

% 判定是否需要修复
FixMarketData(obj, asset, dir_alt);

end


% 读取文件目录
function ret = FetchFiles(dir_tb)
persistent files_buffer;
if (~isempty(files_buffer))
    ret = files_buffer;
    return;
end

% 检查路径
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
md = sortrows(md, 1);
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

% 修复行情
function FixMarketData(obj, asset, dir_alt)
% 修复列表
persistent fixlst;
if (isempty(fixlst))
    % symb_mis_front
    % 41~48             8
    % 65~72             8
    % 615~626       12
    % 629~640       12
    % 945~946       12
    % 949~952        4
    % 1021~1022    2
    % 1151~1170    20
    tmp = (10000041 : 10000048)';
    tmp = [tmp; (10000065 : 10000072)'];
    tmp = [tmp; (10000615 : 10000626)'];
    tmp = [tmp; (10000629 : 10000640)'];
    tmp = [tmp; (10000945 : 10000946)'];
    tmp = [tmp; (10000949 : 10000952)'];
    tmp = [tmp; (10001021 : 10001022)'];
    tmp = [tmp; (10001151 : 10001170)'];
    fixlst.mis_front = cellstr(num2str(tmp));
    
    % symb_mis_rear
    % 933~944       12
    % 955, 956, 963, 964, 979, 980      6
    tmp = (10000933 : 10000944)';
    tmp = [tmp; [10000955, 10000956, 10000963, 10000964, 10000979, 10000980]'];
    fixlst.mis_rear = cellstr(num2str(tmp));
    
    % symb_mis_both
    % 947, 948,         2
    tmp = (10000947 : 10000948)';
    fixlst.mis_both = cellstr(num2str(tmp));
end

% 交易日历
persistent cal;
if (isempty(cal))
    cal = LoadCalendar(obj);
end

% 判断
if (ismember(asset.symbol, fixlst.mis_front))
    mark = 1;
elseif (ismember(asset.symbol, fixlst.mis_rear))
    mark = 2;
elseif (ismember(asset.symbol, fixlst.mis_both))
    mark = 3;
else
    return;
end

% 修复
switch mark
    case 1        
        % missing front
        dt_fix_s = str2double(datestr(asset.GetDateListed(), 'yyyymmdd'));
        dt_fix_e = str2double(datestr(asset.md(1, 1), 'yyyymmdd'));
        dt_missing = cal(cal(:, 1) >= dt_fix_s & cal(:, 1) < dt_fix_e & cal(:, 2), 5);
        fprintf(2, '[%s] missing [front], %i day(s),, please wait ...\r', asset.symbol, length(dt_missing));
        disp(datestr(dt_missing));
        fprintf('\r');

    case 2
        % missing rear
        dt_fix_s = str2double(datestr(asset.md(end, 1), 'yyyymmdd'));
        dt_fix_e = str2double(datestr(asset.GetDateExpire(), 'yyyymmdd'));
        dt_missing = cal(cal(:, 1) > dt_fix_s & cal(:, 1) <= dt_fix_e & cal(:, 2), 5);
        fprintf(2, '[%s] missing [rear], %i day(s), please wait ...\r', asset.symbol, length(dt_missing));
        disp(datestr(dt_missing));
        fprintf('\r');
    case 3
        % missing both
        dt_fix_s = str2double(datestr(asset.GetDateListed(), 'yyyymmdd'));
        dt_fix_e = str2double(datestr(asset.md(1, 1), 'yyyymmdd'));
        mis_1 = cal(cal(:, 1) >= dt_fix_s & cal(:, 1) < dt_fix_e & cal(:, 2), 5);

        dt_fix_s = str2double(datestr(asset.md(end, 1), 'yyyymmdd'));
        dt_fix_e = str2double(datestr(asset.GetDateExpire(), 'yyyymmdd'));
        mis_2 = cal(cal(:, 1) > dt_fix_s & cal(:, 1) <= dt_fix_e & cal(:, 2), 5);
        dt_missing = union(mis_1, mis_2)';
        fprintf(2, '[%s] missing [both], %i day(s), please wait ...\r', asset.symbol, length(dt_missing));
        disp(datestr(dt_missing));
        fprintf('\r');
end

% fix
md_alter = LoadAlterMd(dir_alt, asset.symbol);
for j = 1 : size(dt_missing, 1)
    md_fix = Fix(dt_missing(j), md_alter);
    asset.MergeMarketData(md_fix);
end

end

% 载入候补行情
function md = LoadAlterMd(dir_alt, symb)
md = readtable(fullfile(dir_alt, [symb, '.xlsx']), 'PreserveVariableNames', 1);
if (~isequal(md{1, 1}{:}(1 : 8), symb))
    error('symbol error %s', symb);
end
md = table2cell(md);
md(:, 1 : 2) = [];
md(:, 1) = cellfun(@(x) {datenum(x)}, md(:, 1));
md = cell2mat(md);
md(isnan(md(:, 1)), :) = [];
md(:, 6) = md(:, 6) * 1000000;
md(:, 8) = 0;
md(:, 6 : 7) = md(:, [7, 6]);
end

% 标准时间轴
function axis = GenSseTimeAxis(dt_dm)
am = [930, 935, 940, 945, 950, 955, 1000, 1005, 1010, 1015, 1020, 1025, 1030, 1035, 1040, 1045, 1050, 1055, 1100, 1105, 1110 , 1115 , 1120 , 1125, 1130];
pm = [1305, 1310, 1315, 1320, 1325, 1330, 1335, 1340, 1345, 1350, 1355, 1400, 1405, 1410, 1415, 1420, 1425, 1430, 1435, 1440, 1445, 1450, 1455, 1500];
axis = [am, pm]';

date = datevec(dt_dm);
date = repmat(date, length(axis), 1);
hour = floor(axis / 100);
date(:, 4) = hour;
date(:, 5) = axis - hour * 100;

axis = datenum(date);
end

% debug function:  fix market data
function md_fix = Fix(date_mis, md_upd)
axis = GenSseTimeAxis(date_mis);
md_fix = [];
for k = 2 : size(axis, 1)
    s = axis(k - 1);
    e = axis(k);
    if (k ~= 2)
        tmp_md = md_upd(md_upd(:, 1) > s & md_upd(:, 1) <= e, :);
    else
        tmp_md = md_upd(md_upd(:, 1) >= s & md_upd(:, 1) <= e, :);
    end
    dt = e;
    if (~isempty(tmp_md))
        open = tmp_md(1, 2);
        high = max(max(tmp_md(:, 2 : 5)));
        low = min(min(tmp_md(:, 2 : 5)));
        close = tmp_md(end, 5);
        volume = sum(tmp_md(:, 6));
        amt = sum(tmp_md(:, 7));
        oi = 0;
        md_fix = [md_fix; [dt, open, high, low, close, volume, amt, oi]];
    else
        md_fix = [md_fix; [dt, zeros(1, 7)]];
    end
end
end