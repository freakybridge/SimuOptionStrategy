% Wind ��ȡָ����������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchMinMdIndex(obj, idx, ts_s, ts_e, inv)
[is_err, md] = obj.FetchMinMd(idx, ts_s, ts_e, inv, 'Fetching index %s.%s minitue market data');
end