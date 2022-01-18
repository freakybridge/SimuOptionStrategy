% DataManager / LoadMd ���ַ�ʽ��ȡ����
% v1.3.0.20220113.beta
%      1.�޸��߼�������Ч��
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMd(obj, asset, dir_csv, dir_tb)

% ��ȡ���ݿ� / csv
obj.db.LoadMarketData(asset);
if (isempty(asset.md))
    obj.er.LoadMarketData(asset, dir_csv);
    if (obj.IsMdComplete(asset))
        obj.db.SaveMarketData(asset);
        return;
    end
elseif (obj.IsMdComplete(asset))
    return;
end
    
% ��ȡ�Ա�excel
obj.LoadMdViaTaobaoExcel(asset, dir_tb);
if (obj.IsMdComplete(asset))    
    obj.db.SaveMarketData(asset);
    obj.er.SaveMarketData(asset, dir_csv);
end

% ����
obj.LoadMdViaDataSource(asset);
if (~isempty(asset.md))
    obj.db.SaveMarketData(asset);
    obj.er.SaveMarketData(asset, dir_csv);
end

end

