% DataManager/LoadOptiChainViaDb �����ݿ�������Ȩ��Լ
% v1.2.0.20220105.beta
%      1.�״μ���
function instrus = LoadOptChainViaDb(obj, var, exc)
instrus = obj.db.LoadChainOption(var, exc);
end
