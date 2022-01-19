% DataManager / LoadChain ��ȡ��Լ�б�
% v1.3.0.20220113.beta
%      1.�޸��߼�������Ч��
%      2.���������߼�
% v1.2.0.20220105.beta
%      1.�״μ���
function ins = LoadChain(obj, pdt, var, exc, dir_)

% �����ݿ� / excel��ȡ
ins_local = obj.db.LoadChain(pdt, var, exc);
if (isempty(ins_local))
    ins_local = obj.dr.LoadChain(pdt, var, exc, dir_);    
    if (~obj.IsInstruNeedUpdate(ins_local))
        ins = ins_local;
        obj.db.SaveChain(pdt, var, exc, ins);
        return;
    end
    
elseif (~obj.IsInstruNeedUpdate(ins_local))
    ins = ins_local;
    return;    
end

% ������Դ��ȡ
ins = obj.LoadChainViaDs(pdt, var, exc, ins_local);
if (isequal(ins_local, ins))
    ins = ins_local;
    return;
end
obj.db.SaveChain(pdt, var, exc, ins);
obj.dr.SaveChain(pdt, var, exc, ins, dir_);

end
