% ����д�����ݿ�
% v1.2.0.20220105.beta
%       �״����
function ret = SaveOptChain2Db(obj, var, exc, instrus)
ret = obj.db.SaveChainOption(var, exc, instrus);
end