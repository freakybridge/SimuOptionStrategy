% DataManager / LoadMd ���ַ�ʽ��ȡ����
% v1.3.0.20220113.beta
%      1.�޸��߼�������Ч��
%      2.��������߼�
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMd(obj, asset)

% ��ȡ���ݿ�
md_local = obj.db.LoadMarketData(asset);
if (~NeedUpdate(obj, asset, md_local))
    asset.MergeMarketData(md_local);
    return;
end

% ��ȡ���� csv
md_local = obj.dr.LoadMarketData(asset, obj.dir_root);
if (~NeedUpdate(obj, asset))
    asset.MergeMarketData(md_local);
    obj.db.SaveMarketData(asset, md_local);
    return;
end
asset.MergeMarketData(md_local);

% ����
md = LoadViaDs(obj, asset);
if (~isempty(md))
    asset.MergeMarketData(md);
    obj.db.SaveMarketData(asset, md);
    obj.dr.SaveMarketData(asset, obj.dir_root);
end
end

% �ж��Ƿ���Ҫ����
function ret = NeedUpdate(obj, asset, md)
% ���������ݣ���Ҫ����
if (isempty(md))
    ret = true;
    return;
end

% ��ȡ��������
persistent cal;
if (isempty(cal))
    cal = obj.LoadCalendar();
end
if hour(now()) >= 15
    td = now();
else
    td = now() - 1;
end

% ȷ����������
last_td_dt = find(cal(:, 5) <= td, 1, 'last');
last_td_dt = cal(find(cal(1 : last_td_dt, 2) == 1, 1, 'last'), 5);
last_md_dt = md(end, 1);
if (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
    if (last_td_dt > datenum(asset.GetDateExpire()))
        last_td_dt = floor(datenum(asset.GetDateExpire()));
    end
end

% ���ڷ���bar������ǰ15�����ڱ���������
% ����day bar��������Ҫ����һ��
if (asset.interval == EnumType.Interval.min1 || asset.interval == EnumType.Interval.min5)
    last_td_dt = last_td_dt + 15 / 24;
    if (last_td_dt - last_md_dt >= 15 / 24/ 60)
        ret = true;
    else
        ret = false;
    end
    return;

elseif (asset.interval == EnumType.Interval.day)
    if (last_td_dt - last_md_dt >= 1)
        ret = true;
    else
        ret = false;
    end
    return;
else
    error("Unexpected 'interval' for market data accomplished judgement, please check.");
end
end

% �����ݽӿڻ�ȡ��������
function md = LoadViaDs(obj, asset)

% ȷ����������յ�
[dt_s, dt_e] = FindUpdateSE(asset);

% ����
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

% ȷ����������յ�
function [dt_s, dt_e] = FindUpdateSE(asset)

md = asset.md;
switch asset.product
    case {EnumType.Product.ETF, EnumType.Product.Index}
        % ��������
        % �趨���
        dt_ini = datenum(asset.GetDateInit());
        if (isempty(md))
            dt_s = dt_ini;
        else
            dt_md_s = md(1, 1);
            dt_md_e = md(end, 1);
            if (dt_ini - dt_md_s >= 1)
                dt_s = dt_ini;
            else
                dt_s = dt_md_e;
            end
        end

        % �趨�յ�
        dt_e = now();

    case {EnumType.Product.Future, EnumType.Product.Option}
        % �����ں�Լ
        % �趨���
        dt_lt = datenum(asset.GetDateListed());
        dt_ep = datenum(asset.GetDateExpire());
        if (isempty(md))
            dt_s = dt_lt;
        else
            dt_md_s = md(1, 1);
            dt_md_e = md(end, 1);
            if (dt_lt - dt_md_s > 1)
                dt_s = dt_lt;
            else
                dt_s = dt_md_e;
            end
        end

        % �趨�յ�
        dt_e = dt_ep;

    otherwise
        error('Unexpected "product" for update start & end point determine, please check.');

end
end
