% DataManager / LoadOptChain ���ַ�ʽ��ȡ��Ȩ��
% v1.2.0.20220105.beta
%      1.�״μ���
function instrus = LoadOptChain(obj, var, exc, dir_)

% �����ݿ��ȡ
ins_local = obj.LoadOptChainViaDb(var, exc);

% ��excel��ȡ
if (isempty(ins_local))
    ins_local = obj.LoadOptChainViaExcel(var, exc, dir_);
end

% ������Դ��ȡ
if (obj.IsInstruNeedUpdate(ins_local))
    instrus = obj.LoadOptChainViaDs(var, exc, ins_local);
    if (isequal(ins_local, instrus))
        instrus = ins_local;
    else
        obj.SaveOptChain2Db(var, exc, instrus);
        obj.SaveOptChain2Excel(var, exc, instrus, dir_);
    end

else
    instrus = ins_local;
    obj.SaveOptChain2Db(var, exc, instrus);
end

end