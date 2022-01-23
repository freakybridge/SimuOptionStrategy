% DataManager / LoadMd ���ַ�ʽ��ȡ����
% v1.3.0.20220113.beta
%      1.�޸��߼�������Ч��
%      2.��������߼�
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMd(obj, asset, dir_csv, dir_tb)

% ��ȡ���ݿ� / csv
obj.db.LoadMarketData(asset);
if (isempty(asset.md))
    obj.dr.LoadMarketData(asset, dir_csv);
    if (NeedUpdate(asset))
        obj.db.SaveMarketData(asset);
        return;
    end
elseif (NeedUpdate(asset))
    return;
end
    
% ��ȡ�Ա�excel
obj.LoadMdViaTaobaoExcel(asset, dir_tb);
if (NeedUpdate(asset))    
    obj.db.SaveMarketData(asset);
    obj.dr.SaveMarketData(asset, dir_csv);
end

% ����
obj.LoadMdViaDataSource(asset);
if (~isempty(asset.md))
    obj.db.SaveMarketData(asset);
    obj.dr.SaveMarketData(asset, dir_csv);
end

end

% �ж��Ƿ����ݳ���
function ret = NeedUpdate(asset)

% ���������ݣ��ж�������
if (isempty(asset.md))
    ret = false;
    return;
end

% ��Ȩ����ǰ15�����޽��ף��ж�������
switch asset.product
    case EnumType.Product.Option
        if (datenum(asset.GetDateExpire) - asset.md(end, 1) <= 15 / (24 * 60))
            ret = true;
        else
            ret = false;
        end        
        
    otherwise
        error("Unexpected ""product"" for market data accomplished judgement, please check");
end
end

