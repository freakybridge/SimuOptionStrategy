% DataManager / LoadMd ���ַ�ʽ��ȡ����
% v1.3.0.20220113.beta
%      1.�޸��߼�������Ч��
%      2.��������߼�
%      3.��������csv����
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMd(obj, asset, sw_csv)

% ��ȡ���ݿ�
md_local = obj.db.LoadMarketData(asset);
[mark, dt_s, dt_e] = NeedUpdate(obj, asset, md_local);
if (~mark)
    asset.MergeMarketData(md_local);
    return;
end

% ��ȡ���� csv
if (sw_csv)
    md_local = obj.dr.LoadMarketData(asset, obj.dir_root);
    [mark, dt_s, dt_e] = NeedUpdate(obj, asset, md_local);
    if (~mark)
        asset.MergeMarketData(md_local);
        obj.db.SaveMarketData(asset, md_local);
        return;
    end
end

% д�뱾������
if (~isempty(md_local))
    asset.MergeMarketData(md_local);
end

% ����
md = LoadViaDs(obj, asset, dt_s, dt_e);
if (~isempty(md))
    asset.MergeMarketData(md);
    obj.db.SaveMarketData(asset, md);
    obj.dr.SaveMarketData(asset, obj.dir_root);
end
end

% �ж��Ƿ���Ҫ����
function [mark, dt_s, dt_e] = NeedUpdate(obj, asset, md)
if (~isempty(md))
    [mark, dt_s, dt_e] = obj.NeedUpdate(asset, md(1, 1), md(end, 1));
else
    [mark, dt_s, dt_e] = obj.NeedUpdate(asset, nan, nan);
end
end

% �����ݽӿڻ�ȡ��������
function md = LoadViaDs(obj, asset, dt_s, dt_e)
while (true)
    [is_err, md] = obj.ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, dt_s, dt_e);
    if (is_err)
        obj.SetDsFailure();
        obj.ds.LogOut();
        obj.ds = obj.AutoSwitchDataSource();
        continue;
    end
    return;
end
end

