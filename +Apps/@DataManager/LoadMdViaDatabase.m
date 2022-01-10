% 从数据库读取行情
% v1.2.0.20220105.beta
%       首次添加
function LoadMdViaDatabase(obj, ast)
obj.db.LoadMarketData(ast);
end