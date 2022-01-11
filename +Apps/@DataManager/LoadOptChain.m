% DataManager / LoadOptChain ���ַ�ʽ��ȡ��Ȩ��
% v1.2.0.20220105.beta
%      1.�״μ���
function instrus = LoadOptChain(obj, var, exc, dir_)

% �����ݿ��ȡ
instrus = obj.LoadOptChainViaDb(var, exc);

% ��excel��ȡ
if (obj.IsInstruNeedUpdate(instrus))
    instrus = obj.LoadOptChainViaExcel(var, exc, dir_);
else
    return;
end

% ������Դ��ȡ
if (obj.IsInstruNeedUpdate(instrus))
    instrus = obj.LoadOptChainViaDs(var, exc, instrus);
    if (obj.IsInstruNeedUpdate(instrus))
        obj.SaveOptionChain2Db(var, exc, instrus);
        obj.SaveOptChain2Excel(var, exc, instrus, dir_);
    end

else
    return;
end
end