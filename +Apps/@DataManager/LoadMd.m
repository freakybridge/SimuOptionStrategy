% DataManager / LoadMd 多种方式获取行情
% v1.3.0.20220113.beta
%      1.修改逻辑，提升效率
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMd(obj, asset, dir_csv, dir_tb)

% 读取数据库 / csv
obj.db.LoadMarketData(asset);
if (isempty(asset.md))
    obj.er.LoadMarketData(asset, dir_csv);
    if (obj.IsMdComplete(asset))
        obj.db.SaveMarketData(asset);
        return;
    end
elseif (obj.IsMdComplete(asset))
    return;
end
    
% 读取淘宝excel
obj.LoadMdViaTaobaoExcel(asset, dir_tb);
if (obj.IsMdComplete(asset))    
    obj.db.SaveMarketData(asset);
    obj.er.SaveMarketData(asset, dir_csv);
end

% 更新
obj.LoadMdViaDataSource(asset);
if (~isempty(asset.md))
    obj.db.SaveMarketData(asset);
    obj.er.SaveMarketData(asset, dir_csv);
end

end

