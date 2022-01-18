% 从数据库读取行情
% v1.3.0.20220113.beta
%       修改变量名
% v1.2.0.20220105.beta
%       首次添加
function LoadMdViaDatabase(obj, asset)
obj.db.LoadMarketData(asset);
end