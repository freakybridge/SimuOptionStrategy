% DataManager / LoadChain ��ȡ��Լ�б�
% v1.3.0.20220113.beta
%      1.�޸��߼�������Ч��
%      2.���������߼�
% v1.2.0.20220105.beta
%      1.�״μ���
function ins = LoadChain(obj, var, exc, dir_)

% �����ݿ� / excel��ȡ
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

% ������Դ��ȡ
ins = obj.LoadOptChainViaDs(var, exc, ins_local);
if (isequal(ins_local, ins))
    ins = ins_local;
    return;
end
obj.SaveOptChain2Db(var, exc, ins);
obj.SaveOptChain2Excel(var, exc, ins, dir_);

end
