% DataManager / LoadMd 多种方式获取行情
% v1.3.0.20220113.beta
%      1.修改逻辑，提升效率
%      2.加入更新逻辑
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMd(obj, asset)

% 读取数据库
md_local = obj.db.LoadMarketData(asset);
if (~NeedUpdate(obj, asset, md_local))
    asset.MergeMarketData(md_local);
    return;
end

% 读取本地 csv
md_local = obj.dr.LoadMarketData(asset, obj.dir_root);
if (~NeedUpdate(obj, asset))
    asset.MergeMarketData(md_local);
    obj.db.SaveMarketData(asset, md_local);
    return;
end
asset.MergeMarketData(md_local);

% 更新
md = LoadViaDs(obj, asset);
if (~isempty(md))
    asset.MergeMarketData(md);
    obj.db.SaveMarketData(asset, md);
    obj.dr.SaveMarketData(asset, obj.dir_root);
end
end

% 判定是否需要更新
function ret = NeedUpdate(obj, asset, md)
% 无行情数据，需要更新
if (isempty(md))
    ret = true;
    return;
end

% 读取交易日历
persistent cal;
if (isempty(cal))
    cal = obj.LoadCalendar();
end
if hour(now()) >= 15
    td = now();
else
    td = now() - 1;
end

% 确定最后更新日
last_td_dt = find(cal(:, 5) <= td, 1, 'last');
last_td_dt = cal(find(cal(1 : last_td_dt, 2) == 1, 1, 'last'), 5);
last_md_dt = md(end, 1);
if (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
    if (last_td_dt > datenum(asset.GetDateExpire()))
        last_td_dt = floor(datenum(asset.GetDateExpire()));
    end
end

% 对于分钟bar，收盘前15分钟内必须有数据
% 对于day bar，至少需要更新一天
if (asset.interval == EnumType.Interval.min1 || asset.interval == EnumType.Interval.min5)
    last_td_dt = last_td_dt + 15 / 24;
    if (last_td_dt - last_md_dt >= 15 / 24/ 60)
        ret = true;
    else
        ret = false;
    end
    return;

elseif (asset.interval == EnumType.Interval.day)
    if (last_td_dt - last_md_dt >= 1)
        ret = true;
    else
        ret = false;
    end
    return;
else
    error("Unexpected 'interval' for market data accomplished judgement, please check.");
end
end

% 从数据接口获取行情数据
function md = LoadViaDs(obj, asset)

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
    end
    return;
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
