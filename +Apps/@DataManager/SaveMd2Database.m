% 行情写入数据库
% v1.2.0.20220105.beta
%       首次添加
function ret = SaveMd2Database(obj, asset)
ret = obj.db.SaveMarketData(asset);
end