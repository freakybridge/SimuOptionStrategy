% �����ݽӿڻ�ȡ��Ȩ�б�
% v1.2.0.20220105.beta
%      1.�״μ���
function instrus = LoadOptChainViaDs(obj, var, exc, instru_local)

% ȷ����������յ�
sample = BaseClass.Asset.Option.Option.Selector('sample', exc, var, 10000, '5m', 'sample', 'call', 888, now(), now());
if (isempty(instru_local))
    date_s = sample.GetDateInit();
else
    date_s = unique(instru_local.LAST_UPDATE_DATE);
    date_s = date_s{:};
end
date_s = datestr(date_s, 'yyyy-mm-dd');
date_e = datestr(now(), 'yyyy-mm-dd');

% ����
exc = EnumType.Exchange.ToEnum(exc);
instrus = obj.ds.FetchOptionChain(sample, instru_local, date_s, date_e);
end