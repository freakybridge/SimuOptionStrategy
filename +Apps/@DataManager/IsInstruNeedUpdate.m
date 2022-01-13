% DataManager / IsInstruNeedUpdate 判定是否需要更新合约表
% v1.2.0.20220105.beta
%       首次添加
function ret = IsInstruNeedUpdate(~, instrus)

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