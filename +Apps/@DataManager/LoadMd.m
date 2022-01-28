% DataManager / LoadMd 多种方式获取行情
% v1.3.0.20220113.beta
%      1.修改逻辑，提升效率
%      2.加入更新逻辑
%      3.加入载入csv开关
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMd(obj, asset, sw_csv)

% 读取数据库
md_local = obj.db.LoadMarketData(asset);
[mark, dt_s, dt_e] = NeedUpdate(obj, asset, md_local);
if (~mark)
    asset.MergeMarketData(md_local);
    return;
end

% 读取本地 csv
if (sw_csv)
    md_local = obj.dr.LoadMarketData(asset, obj.dir_root);
    [mark, dt_s, dt_e] = NeedUpdate(obj, asset, md_local);
    if (~mark)
        asset.MergeMarketData(md_local);
        obj.db.SaveMarketData(asset, md_local);
        return;
    end
end

% 写入本地行情
if (~isempty(md_local))
    asset.MergeMarketData(md_local);
end

% 更新
md = LoadViaDs(obj, asset, dt_s, dt_e);
if (~isempty(md))
    asset.MergeMarketData(md);
    obj.db.SaveMarketData(asset, md);
    obj.dr.SaveMarketData(asset, obj.dir_root);
end
end

% 判定是否需要更新
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

% 从数据接口获取行情数据
function md = LoadViaDs(obj, asset, dt_s, dt_e)
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

