% 从数据接口获取合约列表
% v1.3.0.20220113.beta
%      1.修改函数名
% v1.2.0.20220105.beta
%      1.首次加入
function ins = LoadChainViaDs(obj, pdt, var, exc, ins_local)

while (true)
    [is_err, ins] = obj.ds.FetchChain(pdt, var, exc, ins_local);    
    if (is_err)
        obj.SetDsFailure();
        obj.ds = obj.AutoSwitchDataSource();
        continue;    
    end
    return;
end
end