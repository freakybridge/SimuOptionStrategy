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
    if (~NeedUpdate(ins_local))
        ins = ins_local;
        obj.db.SaveChain(pdt, var, exc, ins);
        return;
    end
    
elseif (~NeedUpdate(ins_local))
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


% �ж��Ƿ���Ҫ���º�Լ��
function ret = NeedUpdate(~, instrus)

% ����ǰ�޺�Լ��Ϣ���������
if (isempty(instrus))
    ret = true;
    return;
end

% �����ϴθ�������1�죬��������
last_ud_dt = max(datenum(instrus.LAST_UPDATE_DATE));
if (now - last_ud_dt >= 1)
    ret = true;
else
    ret = false;
end
end