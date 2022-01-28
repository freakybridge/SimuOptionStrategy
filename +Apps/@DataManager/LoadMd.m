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
% ��ȡ�������� / ��ȡ�������
persistent cal;
if (isempty(cal))
    cal = obj.LoadCalendar();
end
if hour(now()) >= 15
    td = now();
else
    td = now() - 1;
end
last_trade_date = find(cal(:, 5) <= td, 1, 'last');
last_trade_date = cal(find(cal(1 : last_trade_date, 2) == 1, 1, 'last'), 5);


if (~isempty(md))
    % ������
    % ȷ����������յ�
    if (asset.product == EnumType.Product.ETF)
        dt_s_o = datenum(asset.GetDateInit()) + 40;
        dt_e_o = last_trade_date + 15 / 24;
    elseif (asset.product == EnumType.Product.Index)
        dt_s_o = datenum(asset.GetDateInit());
        dt_e_o = last_trade_date + 15 / 24;
    elseif (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
        dt_s_o =  datenum(asset.GetDateListed());
        dt_e_o = datenum(asset.GetDateExpire());
        if (dt_e_o > last_trade_date)
            dt_e_o = last_trade_date + 15 / 24;
        end
    else
        error('Unexpected "product" for update start point determine, please check.');
    end

    % ��λ��������յ�
    md_s = md(1, 1);
    md_e = md(end, 1);

    %  �ж����
    if (md_s - dt_s_o >= 1)
        dt_s = dt_s_o;
    else
        dt_s = md_e;
    end

    % �ж��յ�
    if (asset.interval == EnumType.Interval.min1 || asset.interval == EnumType.Interval.min5)
        if (dt_e_o - md_e < 15 / 60 / 24)
            dt_e = md_e;
        else
            dt_e = dt_e_o;
        end

    elseif (asset.interval == EnumType.Interval.day)
        dt_e_o = floor(dt_e_o);
        if (dt_e_o - md_e < 1)
            dt_e = md_e;
        else
            dt_e = dt_e_o;
        end
    else
        error("Unexpected 'interval' for market data accomplished judgement, please check.");
    end

    % �ж��Ƿ����
    if (dt_s == dt_e && dt_e == md_e)
        mark = false;
    else
        mark = true;
    end

else
    % ������
    % ȷ���������
    if (asset.product == EnumType.Product.ETF || asset.product == EnumType.Product.Index)
        dt_s = datenum(asset.GetDateInit());
    elseif (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
        dt_s =  datenum(asset.GetDateListed());
    else
        error('Unexpected "product" for update start point determine, please check.');
    end

    % ȷ�������յ�
    dt_e = last_trade_date + 15 / 24;
    mark = true;
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

