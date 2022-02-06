% DataManager / Update
% v1.3.0.20220113.beta
%      1.First Commit
function Update(obj)

% UpdateCalendar(obj);
% UpdateIndex(obj);
% UpdateETF(obj);
% UpdateOption(obj);

InsertOptionMin(obj);
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


datefmt = 'yyyy-mm-dd HH:MM';
id = fopen('C:\Users\freakybridge\Desktop\err_record.txt', 'a+');
fprintf(id, '[Counter:%d]-[Interval:%s]-[Symbol:%s]\t\rListed:%s\tExpire:%s\rMdStart:%s\tMdEnd:%s\rUpdStart:%s\tUpdEnd:%s\r\r', ...
    counter, ...
    Utility.ToString(asset.interval), asset.symbol, ...
    datestr(asset.GetDateListed(), datefmt), ...
    datestr(asset.GetDateExpire(), datefmt), ...
    datestr(md_local(1, 1), datefmt), ...
    datestr(md_local(end, 1), datefmt), ...
    datestr(dt_s, datefmt), ...
    datestr(dt_e, datefmt));
fclose(id);

% % 读取本地 csv
% md_local = obj.dr.LoadMarketData(asset, obj.dir_root);
% [mark, dt_s, dt_e] = NeedUpdate(obj, asset, md_local);
% if (~mark)
%     obj.db.SaveMarketData(asset, md_local);
%     return;
% end

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
function FixLocalQuote()
dir_loc

% symb_mis_pre = {'10000041', '10000042', }
% 41~48
% 65~72
% 615~626
% 629~640
% 945~946
% 949~952
% 1021~1022
% 1051~1070


% symb_mis_post
% 933~944
% 955, 956, 963, 964, 979, 980

% symb_mis_both
% 947, 948, 

end