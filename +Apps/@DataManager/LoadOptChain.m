% DataManager / LoadOptChain 多种方式获取期权链
% v1.2.0.20220105.beta
%      1.首次加入
function instrus = LoadOptChain(obj, var, exc, dir_)

% 从数据库获取
instrus = obj.LoadOptChainViaDb(var, exc);

% 从excel获取
if (obj.IsInstruNeedUpdate(instrus))
    instrus = obj.LoadOptChainViaExcel(var, exc, dir_);
else
    return;
end

% 从数据源获取
if (obj.IsInstruNeedUpdate(instrus))
    instrus = obj.LoadOptChainViaDs(var, exc, instru);
    obj.SaveOptionChain2Db(var, exc, instrus);
    
    instrus = obj.LoadOptChainViaDb(var, exc);
    obj.SaveOptChain2Excel(var, exc, instrus, dir_);

else
    return;
end
end