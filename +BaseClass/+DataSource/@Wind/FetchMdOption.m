% Wind ��ȡ��Ȩ��������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchMinMdOption(obj, opt, ts_s, ts_e)
[is_err, md] = obj.FetchMinMd(opt, ts_s, ts_e, 'Fetching option [%s.%s] minitue market data');
end