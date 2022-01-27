% DataManager / LoadChain ��ȡ��Լ�б�
% v1.3.0.20220113.beta
%      1.�޸��߼�������Ч��
%      2.���������߼�
% v1.2.0.20220105.beta
%      1.�״μ���
function ins = LoadChain(obj, pdt, var, exc)

% ��ȡ���ݿ�
ins_local = obj.db.LoadChain(pdt, var, exc);
if (~NeedUpdate(ins_local))
    ins = ins_local;
    return;    
end

% ��ȡ����EXCEL
ins_local = obj.dr.LoadChain(pdt, var, exc, obj.dir_root);
if (~NeedUpdate(ins_local))
    ins = ins_local;
    obj.db.SaveChain(pdt, var, exc, ins);
    return;
end

% ������Դ��ȡ
ins = LoadViaDs(obj, pdt, var, exc, ins_local);
if (isequal(ins_local, ins))
    ins = ins_local;
    return;
end
obj.db.SaveChain(pdt, var, exc, ins);
obj.dr.SaveChain(pdt, var, exc, ins, obj.dir_root);

end


% �ж��Ƿ���Ҫ���º�Լ��
function ret = NeedUpdate(ins)
% ����ǰ�޺�Լ��Ϣ���������
if (isempty(ins))
    ret = true;
    return;
end

% �����ϴθ�������1�죬��������
last_ud_dt = max(datenum(ins.LAST_UPDATE_DATE));
if (now - last_ud_dt >= 1)
    ret = true;
else
    ret = false;
end
end

% �����ݽӿڻ�ȡ��Լ�б�
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