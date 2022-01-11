% 从数据接口获取期权列表
% v1.2.0.20220105.beta
%      1.首次加入
function instrus = LoadOptChainViaDs(obj, var, exc, instru_local)

% 确定更新起点终点
sample = BaseClass.Asset.Option.Option.Selector('sample', exc, var, 10000, '5m', 'sample', 'call', 888, now(), now());
if (isempty(instru_local))
    date_s = sample.GetDateInit();
else
    date_s = unique(instru_local.LAST_UPDATE_DATE);
    date_s = date_s{:};
end
date_s = datestr(date_s, 'yyyy-mm-dd');
date_e = datestr(now(), 'yyyy-mm-dd');

% 下载
exc = EnumType.Exchange.ToEnum(exc);
instrus = obj.ds.FetchOptionChain(sample, instru_local, date_s, date_e);
end