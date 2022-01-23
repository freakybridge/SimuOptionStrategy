% DataManager / LoadChain 获取合约列表
% v1.3.0.20220113.beta
%      1.修改逻辑，提升效率
%      2.改名修正逻辑
% v1.2.0.20220105.beta
%      1.首次加入
function ins = LoadChain(obj, pdt, var, exc, dir_)

% 从数据库 / excel获取
ins_local = obj.db.LoadChain(pdt, var, exc);
if (isempty(ins_local))
    ins_local = obj.dr.LoadChain(pdt, var, exc, dir_);    
    if (~NeedUpdate(ins_local))
        ins = ins_local;
        obj.db.SaveChain(pdt, var, exc, ins);
        return;
    end
    
elseif (~NeedUpdate(ins_local))
    ins = ins_local;
    return;    
end

% 从数据源获取
ins = obj.LoadChainViaDs(pdt, var, exc, ins_local);
if (isequal(ins_local, ins))
    ins = ins_local;
    return;
end
obj.db.SaveChain(pdt, var, exc, ins);
obj.dr.SaveChain(pdt, var, exc, ins, dir_);

end


% 判定是否需要更新合约表
function ret = NeedUpdate(~, instrus)

% 若当前无合约信息，必须更新
if (isempty(instrus))
    ret = true;
    return;
end

% 若据上次更新已有1天，则必须更新
last_ud_dt = max(datenum(instrus.LAST_UPDATE_DATE));
if (now - last_ud_dt >= 1)
    ret = true;
else
    ret = false;
end
end