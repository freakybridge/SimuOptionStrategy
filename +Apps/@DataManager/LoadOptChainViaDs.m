% 从数据接口获取期权列表
% v1.2.0.20220105.beta
%      1.首次加入
function instrus = LoadOptChainViaDs(obj, var, exc, instru_local)

opt_sample = BaseClass.Asset.Option.Option.Selector('sample', exc, var, 10000, '5m', 'sample', 'call', 888, now(), now());
instrus = obj.ds.FetchOptionChain(opt_sample, instru_local);
end