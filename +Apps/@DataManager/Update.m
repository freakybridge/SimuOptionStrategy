% DataManager / Update
% v1.3.0.20220113.beta
%      1.First Commit
function Update(obj)

% UpdateCalendar(obj);
% UpdateIndex(obj);
% UpdateETF(obj);
% UpdateOption(obj);

% InsertOptionMin(obj);
FixLocalQuote(obj);

end

% Calendar
function UpdateCalendar(obj)
obj.LoadCalendar();
end

% Index
function UpdateIndex(obj)
inv = EnumType.Interval.day;
upd_lst = struct;
upd_lst.product = EnumType.Product.Index;                      upd_lst.variety = '000001';             upd_lst.exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '000016';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '000300';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '000905';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '399001';     upd_lst(end).exchange = EnumType.Exchange.SZSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '399005';     upd_lst(end).exchange = EnumType.Exchange.SZSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '399006';     upd_lst(end).exchange = EnumType.Exchange.SZSE;
for i = 1 : length(upd_lst)
    this = upd_lst(i);
    fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));
    asset = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, inv);
    obj.LoadMd(asset);
end
end

% ETF
function UpdateETF(obj)
inv = EnumType.Interval.day;
upd_lst = struct;
upd_lst.product = EnumType.Product.ETF;                      upd_lst.variety = '159919';            upd_lst.exchange = EnumType.Exchange.SZSE;
upd_lst(end + 1).product = EnumType.Product.ETF;       upd_lst(end).variety = '510050';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.ETF;       upd_lst(end).variety = '510300';     upd_lst(end).exchange = EnumType.Exchange.SSE;
for i = 1 : length(upd_lst)
    this = upd_lst(i);
    fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));
    asset = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, inv);
    obj.LoadMd(asset);
end
end

% Option
function UpdateOption(obj)
upd_lst = struct;
upd_lst.product = EnumType.Product.Option;                upd_lst.variety = '510050';            upd_lst.exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Option;       upd_lst(end).variety = '510300';     upd_lst(end).exchange = EnumType.Exchange.SSE;
for i = 1 : length(upd_lst)
    % 读取所有合约
    this = upd_lst(i);
    fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));    
    ins = obj.LoadChain(this.product, this.variety, this.exchange);
    
    % 更新
    for j = 1 : height(ins)
        info = ins(j, :);        
        switch this.variety
            case {'159919', '510050', '510300'}
                asset = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, ...
                    info.SYMBOL{:}, ...
                    info.SEC_NAME{:}, ...
                    EnumType.Interval.day, ...
                    info.SIZE, ...
                    EnumType.CallOrPut.ToEnum(info.CALL_OR_PUT{:}), ...
                    info.STRIKE, ...
                    info.START_TRADE_DATE{:}, ...
                    info.END_TRADE_DATE{:}...
                    );
                    
            otherwise
                error('Unsupported variety for updating, please check !');
        end        
        fprintf('Updating [%s-%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), asset.symbol, j, height(ins));

        asset.interval = EnumType.Interval.day;
        obj.LoadMd(asset);      
        asset.md = [];
        
        asset.interval = EnumType.Interval.min5;
        obj.LoadMd(asset);        
    end
end
end

% Debug Function 
function InsertOptionMin(obj)
upd_lst = struct;
upd_lst.product = EnumType.Product.Option;                     upd_lst.variety = '510050';            upd_lst.exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Option;       upd_lst(end).variety = '510300';     upd_lst(end).exchange = EnumType.Exchange.SSE;
for i = 1 : length(upd_lst)
    % 读取所有合约
    this = upd_lst(i);
    fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));    
    ins = obj.LoadChain(this.product, this.variety, this.exchange);
    
    % 更新
    for j = 1 : height(ins)
        info = ins(j, :);        
        switch this.variety
            case {'159919', '510050', '510300'}
                asset = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, ...
                    info.SYMBOL{:}, ...
                    info.SEC_NAME{:}, ...
                    EnumType.Interval.day, ...
                    info.SIZE, ...
                    EnumType.CallOrPut.ToEnum(info.CALL_OR_PUT{:}), ...
                    info.STRIKE, ...
                    info.START_TRADE_DATE{:}, ...
                    info.END_TRADE_DATE{:}...
                    );
                    
            otherwise
                error('Unsupported variety for updating, please check !');
        end        
        fprintf('Updating [%s-%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), asset.symbol, j, height(ins));

        asset.interval = EnumType.Interval.day;
        LoadMd(obj, asset);      
        asset.md = [];
        
        asset.interval = EnumType.Interval.min5;
        LoadMd(obj, asset);      
    end
end
end

% Debug Function
function LoadMd(obj, asset)
% 读取数据库
md_local = obj.db.LoadMarketData(asset);
[mark, dt_s, dt_e] = NeedUpdate(obj, asset, md_local);
if (~mark)
    return;
end

if (isempty(md_local))
    return;
end

if (now() < datenum(asset.GetDateExpire()))
    return;
end

persistent counter;
if (~isempty(counter))
    counter = counter + 1;
else
    counter = 0;
end


% datefmt = 'yyyy-mm-dd HH:MM';
% id = fopen('C:\Users\freakybridge\Desktop\err_record.txt', 'a+');
% fprintf(id, '[Counter:%d]-[Interval:%s]-[Symbol:%s]\t\rListed:%s\tExpire:%s\rMdStart:%s\tMdEnd:%s\rUpdStart:%s\tUpdEnd:%s\r\r', ...
%     counter, ...
%     Utility.ToString(asset.interval), asset.symbol, ...
%     datestr(asset.GetDateListed(), datefmt), ...
%     datestr(asset.GetDateExpire(), datefmt), ...
%     datestr(md_local(1, 1), datefmt), ...
%     datestr(md_local(end, 1), datefmt), ...
%     datestr(dt_s, datefmt), ...
%     datestr(dt_e, datefmt));
% fclose(id);
asset.MergeMarketData(md_local);
end

% Debug Function
function [mark, dt_s, dt_e] = NeedUpdate(obj, asset, md)
% 读取交易日历 / 获取最后交易日
persistent cal;
if (isempty(cal))
    cal = obj.LoadCalendar();
end
if hour(now()) >= 15
    td = now();
else
    td = now() - 1;
end
last_trade_date = find(cal(:, 5) <= td, 1, 'last');
last_trade_date = cal(find(cal(1 : last_trade_date, 2) == 1, 1, 'last'), 5);


if (~isempty(md))
    % 有行情
    % 确定理论起点终点
    if (asset.product == EnumType.Product.ETF)
        dt_s_o = datenum(asset.GetDateInit()) + 40;
        dt_e_o = last_trade_date + 15 / 24;
    elseif (asset.product == EnumType.Product.Index)
        dt_s_o = datenum(asset.GetDateInit());
        dt_e_o = last_trade_date + 15 / 24;
    elseif (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
        dt_s_o =  datenum(asset.GetDateListed());
        dt_e_o = datenum(asset.GetDateExpire());
        if (dt_e_o > last_trade_date)
            dt_e_o = last_trade_date + 15 / 24;
        end
    else
        error('Unexpected "product" for update start point determine, please check.');
    end

    % 定位已有起点终点
    md_s = md(1, 1);
    md_e = md(end, 1);

    %  判定起点
    if (md_s - dt_s_o >= 1)
        dt_s = dt_s_o;
    else
        dt_s = md_e;
    end

    % 判定终点
    if (asset.interval == EnumType.Interval.min1 || asset.interval == EnumType.Interval.min5)
        if (dt_e_o - md_e < 15 / 60 / 24)
            dt_e = md_e;
        else
            dt_e = dt_e_o;
        end

    elseif (asset.interval == EnumType.Interval.day)
        dt_e_o = floor(dt_e_o);
        if (dt_e_o - md_e < 1)
            dt_e = md_e;
        else
            dt_e = dt_e_o;
        end
    else
        error("Unexpected 'interval' for market data accomplished judgement, please check.");
    end

    % 判定是否更新
    if (dt_s == dt_e && dt_e == md_e)
        mark = false;
    else
        mark = true;
    end

else
    % 无行情
    % 确定更新起点
    if (asset.product == EnumType.Product.ETF || asset.product == EnumType.Product.Index)
        dt_s = datenum(asset.GetDateInit());
    elseif (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
        dt_s =  datenum(asset.GetDateListed());
    else
        error('Unexpected "product" for update start point determine, please check.');
    end

    % 确定更新终点
    dt_e = last_trade_date + 15 / 24;
    mark = true;
end
end

% Fix Local Quetos
function FixLocalQuote(obj)
%% preprocess
dir_udt = 'D:\OneDrive\hisdata\update';
dir_out = 'D:\OneDrive\hisdata\update\fixed';

% symb_mis_pre
% 41~48             8
% 65~72             8
% 615~626       12
% 629~640       12
% 945~946       12
% 949~952        4
% 1021~1022    2
% 1051~1070    20
tmp = (10000041 : 10000048)';
tmp = [tmp; (10000065 : 10000072)'];
tmp = [tmp; (10000615 : 10000626)'];
tmp = [tmp; (10000629 : 10000640)'];
tmp = [tmp; (10000945 : 10000946)'];
tmp = [tmp; (10000949 : 10000952)'];
tmp = [tmp; (10001021 : 10001022)'];
tmp = [tmp; (10001051 : 10001070)'];
symb_mis_pre = arrayfun(@(x) {num2str(x)}, tmp);

% symb_mis_post
% 933~944       12
% 955, 956, 963, 964, 979, 980      6
tmp = (10000933 : 10000944)';
tmp = [tmp; [10000955, 10000956, 10000963, 10000964, 10000979, 10000980]'];
symb_mis_post = arrayfun(@(x) {num2str(x)}, tmp);

% symb_mis_both
% 947, 948,         2
tmp = (10000947 : 10000948)';
symb_mis_both = arrayfun(@(x) {num2str(x)}, tmp);

% load instrus & calendar
ins = obj.LoadChain(EnumType.Product.Option, '510050', EnumType.Exchange.SSE);
cal = LoadCalendar(obj);

%% fix pre
for i = 1 : length(symb_mis_pre)
    symb = symb_mis_pre(i);
    info = ins(ismember(ins.SYMBOL, symb), :);    
    asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Option, '510050', EnumType.Exchange.SSE, ...
        info.SYMBOL{:}, ...
        info.SEC_NAME{:}, ...
        EnumType.Interval.day, ...
        info.SIZE, ...
        EnumType.CallOrPut.ToEnum(info.CALL_OR_PUT{:}), ...
        info.STRIKE, ...
        info.START_TRADE_DATE{:}, ...
        info.END_TRADE_DATE{:}...
        );
    
    % fetch local queto
    asset.interval = EnumType.Interval.min5;
    LoadMd(obj, asset);
    
    % fetch update queto
    md_upd = LoadUpdateMd(dir_udt, symb{:});
        
    % confirm missing date / Generate TimeAxis
    dt_fix_s = str2double(datestr(asset.GetDateListed(), 'yyyymmdd'));
    dt_fix_e = asset.md(1, 2);
    dt_missing = cal(cal(:, 1) >= dt_fix_s & cal(:, 1) < dt_fix_e & cal(:, 2), 5);
    axis = [];
    for j = 1 : size(dt_missing, 1)
        axis = [axis; GenSseTimeAxis(dt_missing(j))];
    end
    
    % find missing queto
    md_missing = zeros(size(axis, 1), 8);
    for j = 1 : size(axis)
        loc = find(md_upd(:, 1) <= axis(j), 1, 'last');
    end
    
end


end

% debug function ： gen sse time axis
function axis = GenSseTimeAxis(dt_dm)
am = [935, 940, 945, 950, 955, 1000, 1005, 1010, 1015, 1020, 1025, 1030, 1035, 1040, 1045, 1050, 1055, 1100, 1105, 1110 , 1115 , 1120 , 1125, 1130];
pm = [1305, 1310, 1315, 1320, 1325, 1330, 1335, 1340, 1345, 1350, 1355, 1400, 1405, 1410, 1415, 1420, 1425, 1430, 1435, 1440, 1445, 1450, 1455, 1500];
axis = [am, pm]';

date = datevec(dt_dm);
date = repmat(date, length(axis), 1);
hour = floor(axis / 100);
date(:, 4) = hour;
date(:, 5) = axis - hour * 100;

axis = datenum(date);
end

% debug function ： load update maketdata
function md = LoadUpdateMd(dir_upd, symb)
md = readtable(fullfile(dir_upd, [symb, '.xlsx']), 'PreserveVariableNames', 1);
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
end