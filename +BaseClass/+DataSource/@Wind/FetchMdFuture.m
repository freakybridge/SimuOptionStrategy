% Wind ��ȡ�ڻ���������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchMinMdFuture(obj, fut, ts_s, ts_e)
[is_err, md] = obj.FetchMinMd(fut, ts_s, ts_e, 'Fetching future [%s.%s] minitue market data');
end