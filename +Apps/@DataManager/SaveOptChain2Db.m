% 行情写入数据库
% v1.2.0.20220105.beta
%       首次添加
function ret = SaveOptChain2Db(obj, var, exc, instrus)
ret = obj.db.SaveChainOption(var, exc, instrus);
end