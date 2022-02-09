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
if (~isempty(md))
    [mark, dt_s, dt_e] = obj.NeedUpdate(asset, md(1, 1), md(end, 1));
else
    [mark, dt_s, dt_e] = obj.NeedUpdate(asset, nan, nan);
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

