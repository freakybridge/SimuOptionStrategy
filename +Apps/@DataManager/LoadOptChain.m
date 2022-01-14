% DataManager / LoadOptChain 多种方式获取期权链
% v1.2.0.20220105.beta
%      1.首次加入
function instrus = LoadOptChain(obj, var, exc, dir_)

% 从数据库获取
ins_local = obj.LoadOptChainViaDb(var, exc);

% 从excel获取
if (isempty(ins_local))
    ins_local = obj.LoadOptChainViaExcel(var, exc, dir_);
end

% 从数据源获取
if (obj.IsInstruNeedUpdate(ins_local))
    instrus = obj.LoadOptChainViaDs(var, exc, ins_local);
    if (isequal(ins_local, instrus))
        instrus = ins_local;
    else
        obj.SaveOptChain2Db(var, exc, instrus);
        obj.SaveOptChain2Excel(var, exc, instrus, dir_);
    end

else
    instrus = ins_local;
    obj.SaveOptChain2Db(var, exc, instrus);
end

end