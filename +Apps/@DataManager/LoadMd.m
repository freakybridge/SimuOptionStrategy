% DataManager / LoadMd 多种方式获取行情
% v1.3.0.20220113.beta
%      1.修改逻辑，提升效率
%      2.加入更新逻辑
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMd(obj, asset, dir_csv, dir_tb)

% 读取数据库 / csv
obj.db.LoadMarketData(asset);
if (isempty(asset.md))
    obj.dr.LoadMarketData(asset, dir_csv);
    if (NeedUpdate(asset))
        obj.db.SaveMarketData(asset);
        return;
    end
elseif (NeedUpdate(asset))
    return;
end
    
% 读取淘宝excel
obj.LoadMdViaTaobaoExcel(asset, dir_tb);
if (NeedUpdate(asset))    
    obj.db.SaveMarketData(asset);
    obj.dr.SaveMarketData(asset, dir_csv);
end

% 更新
obj.LoadMdViaDataSource(asset);
if (~isempty(asset.md))
    obj.db.SaveMarketData(asset);
    obj.dr.SaveMarketData(asset, dir_csv);
end

end

% 判定是否数据充足
function ret = NeedUpdate(asset)

% 无行情数据，判定不充足
if (isempty(asset.md))
    ret = false;
    return;
end

% 期权收盘前15分钟无交易，判定不充足
switch asset.product
    case EnumType.Product.Option
        if (datenum(asset.GetDateExpire) - asset.md(end, 1) <= 15 / (24 * 60))
            ret = true;
        else
            ret = false;
        end        
        
    otherwise
        error("Unexpected ""product"" for market data accomplished judgement, please check");
end
end

