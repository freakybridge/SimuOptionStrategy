% DataManager/LoadOptiChainViaDb 从数据库载入期权合约
% v1.2.0.20220105.beta
%      1.首次加入
function instrus = LoadOptChainViaDb(obj, var, exc)
instrus = obj.db.LoadChainOption(var, exc);
end
