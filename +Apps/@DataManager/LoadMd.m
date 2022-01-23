% DataManager / LoadMd ���ַ�ʽ��ȡ����
% v1.3.0.20220113.beta
%      1.�޸��߼�������Ч��
%      2.��������߼�
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMd(obj, asset)

% ��ȡ���ݿ� / csv
obj.db.LoadMarketData(asset);
if (isempty(asset.md))
    obj.dr.LoadMarketData(asset, obj.dir_root);
    if (~NeedUpdate(asset))
        obj.db.SaveMarketData(asset);
        return;
    end
elseif (~NeedUpdate(asset))
    return;
end
    
% ����
LoadViaDs(obj, asset);
if (~isempty(asset.md))
    obj.db.SaveMarketData(asset);
    obj.dr.SaveMarketData(asset, obj.dir_root);
end
end

% �ж��Ƿ���Ҫ����
function ret = NeedUpdate(asset)
% ���������ݣ���Ҫ����
if (isempty(asset.md))
    ret = true;
    return;
end

% ��Ȩ����ǰ15�����޽��ף���Ҫ����
switch asset.product
    case EnumType.Product.Option
        if (datenum(asset.GetDateExpire) - asset.md(end, 1) <= 15 / (24 * 60))
            ret = false;
        else
            ret = true;
        end        
        
    otherwise
        error("Unexpected ""product"" for market data accomplished judgement, please check");
end
end

% �����ݽӿڻ�ȡ��������
function LoadViaDs(obj, asset)

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
    else
        break;
    end
end

% �ϲ�
if (~isempty(md))
    asset.MergeMarketData(md);
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
