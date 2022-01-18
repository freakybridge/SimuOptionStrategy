% DataManager / LoadChain 获取合约列表
% v1.3.0.20220113.beta
%      1.修改逻辑，提升效率
%      2.改名修正逻辑
% v1.2.0.20220105.beta
%      1.首次加入
function ins = LoadChain(obj, var, exc, dir_)

% 从数据库 / excel获取
ins_local = obj.LoadChainViaDb(var, exc);
if (isempty(ins_local))
    ins_local = obj.LoadChainViaExcel(var, exc, dir_);
    if (~obj.IsInstruNeedUpdate(ins_local))
        ins = ins_local;
        obj.SaveChain2Db(var, exc, ins);
        return;
    end
    
elseif (~obj.IsInstruNeedUpdate(ins_local))
    ins = ins_local;
    return;    
end

% 从数据源获取
ins = obj.LoadOptChainViaDs(var, exc, ins_local);
if (isequal(ins_local, ins))
    ins = ins_local;
    return;
end
obj.SaveOptChain2Db(var, exc, ins);
obj.SaveOptChain2Excel(var, exc, ins, dir_);

end
