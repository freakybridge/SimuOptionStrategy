% DataManager / LoadChain 获取合约列表
% v1.3.0.20220113.beta
%      1.修改逻辑，提升效率
%      2.改名修正逻辑
% v1.2.0.20220105.beta
%      1.首次加入
function ins = LoadChain(obj, pdt, var, exc)

% 读取数据库
ins_local = obj.db.LoadChain(pdt, var, exc);
if (~NeedUpdate(ins_local))
    ins = ins_local;
    return;    
end

% 读取本地EXCEL
ins_local = obj.dr.LoadChain(pdt, var, exc, obj.dir_root);
if (~NeedUpdate(ins_local))
    ins = ins_local;
    obj.db.SaveChain(pdt, var, exc, ins);
    return;
end

% 从数据源获取
ins = LoadViaDs(obj, pdt, var, exc, ins_local);
if (isequal(ins_local, ins))
    ins = ins_local;
    return;
end
obj.db.SaveChain(pdt, var, exc, ins);
obj.dr.SaveChain(pdt, var, exc, ins, obj.dir_root);

end


% 判定是否需要更新合约表
function ret = NeedUpdate(ins)
% 若当前无合约信息，必须更新
if (isempty(ins))
    ret = true;
    return;
end

% 若据上次更新已有1天，则必须更新
last_ud_dt = max(datenum(ins.LAST_UPDATE_DATE));
if (now - last_ud_dt >= 1)
    ret = true;
else
    ret = false;
end
end

% 从数据接口获取合约列表
function ins = LoadViaDs(obj, pdt, var, exc, ins_local)
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