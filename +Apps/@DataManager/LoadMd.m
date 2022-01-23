% DataManager / LoadMd 多种方式获取行情
% v1.3.0.20220113.beta
%      1.修改逻辑，提升效率
%      2.加入更新逻辑
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMd(obj, asset)

% 读取数据库 / csv
obj.db.LoadMarketData(asset);
if (isempty(asset.md))
    obj.dr.LoadMarketData(asset, obj.dir_root);
    if (~NeedUpdate(asset))
        obj.db.SaveMarketData(asset);
        return;
    end
elseif (~NeedUpdate(asset))
    return;
end
    
% 更新
LoadViaDs(obj, asset);
if (~isempty(asset.md))
    obj.db.SaveMarketData(asset);
    obj.dr.SaveMarketData(asset, obj.dir_root);
end
end

% 判定是否需要更新
function ret = NeedUpdate(asset)
% 无行情数据，需要更新
if (isempty(asset.md))
    ret = true;
    return;
end

% 期权收盘前15分钟无交易，需要更新
switch asset.product
    case EnumType.Product.Option
        if (datenum(asset.GetDateExpire) - asset.md(end, 1) <= 15 / (24 * 60))
            ret = false;
        else
            ret = true;
        end        
        
    otherwise
        error("Unexpected ""product"" for market data accomplished judgement, please check");
end
end

% 从数据接口获取行情数据
function LoadViaDs(obj, asset)

% 确定更新起点终点
[dt_s, dt_e] = FindUpdateSE(asset);

% 下载
while (true)
    [is_err, md] = obj.ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, dt_s, dt_e);
    if (is_err)
        obj.SetDsFailure();
        obj.ds.LogOut();
        obj.ds = obj.AutoSwitchDataSource();
        continue;
    else
        break;
    end
end

% 合并
if (~isempty(md))
    asset.MergeMarketData(md);
end
end

% 确定更新起点终点
function [dt_s, dt_e] = FindUpdateSE(asset)

md = asset.md;
switch asset.product
    case {EnumType.Product.ETF, EnumType.Product.Index}
        % 类似永续
        % 设定起点
        dt_ini = datenum(asset.GetDateInit());
        if (isempty(md))
            dt_s = dt_ini;
        else
            dt_md_s = md(1, 1);
            dt_md_e = md(end, 1);
            if (dt_ini - dt_md_s >= 1)
                dt_s = dt_ini;              
            else
                dt_s = dt_md_e;
            end
        end
        
        % 设定终点
        dt_e = now();
        
    case {EnumType.Product.Future, EnumType.Product.Option}
        % 续存期合约
        % 设定起点
        dt_lt = datenum(asset.GetDateListed());
        dt_ep = datenum(asset.GetDateExpire());
        if (isempty(md))
            dt_s = dt_lt;
        else
            dt_md_s = md(1, 1);
            dt_md_e = md(end, 1);
            if (dt_lt - dt_md_s > 1)
                dt_s = dt_lt;
            else
                dt_s = dt_md_e;
            end
        end
        
        % 设定终点
        dt_e = dt_ep;

    otherwise
        error('Unexpected "product" for update start & end point determine, please check.');

end
end
