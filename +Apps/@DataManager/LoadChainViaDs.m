% �����ݽӿڻ�ȡ��Լ�б�
% v1.3.0.20220113.beta
%      1.�޸ĺ�����
% v1.2.0.20220105.beta
%      1.�״μ���
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