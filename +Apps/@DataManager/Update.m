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
if (~isempty(md_local))
    return;
end

% 读取本地 csv
md_local = obj.dr.LoadMarketData(asset, obj.dir_root);
if (~isempty(md_local))
    obj.db.SaveMarketData(asset, md_local);
    return;
end
end
