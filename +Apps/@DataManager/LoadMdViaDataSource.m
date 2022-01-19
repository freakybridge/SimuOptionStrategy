% �����ݽӿڻ�ȡ��������
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMdViaDataSource(obj, asset)

% ȷ����������յ�
[dt_s, dt_e] = FindUpdateSE(asset);

% ����
while (true)
    [is_err, md] = obj.ds.FetchMarketData(asset, dt_s, dt_s, 1);
    
    if (is_err)
        obj.SetDsFailure();
        obj.ds = obj.AutoSwitchDataSource();
        continue;
    else
        return;
    end
end



switch asset.product
    case EnumType.Product.Option
        md = LoadOption(obj, asset);            
        
    otherwise
        error("Unsupported ""product"" for DataSource loading. ");
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
    case {EnumType.Product.Etf, EnumType.Product.Index}
        % ��������
        % �趨���
        dt_ini = datenum(asset.GetDateInit());
        dt_md_s = md(1, 1);
        dt_md_e = md(end, 1);
        if (isempty(md) || dt_ini - dt_md_s > 1)
            dt_s = dt_ini;
        else
            dt_s = dt_md_e;
        end
        
        % �趨�յ�
        dt_e = now();
        
    case {EnumType.Product.Future, EnumType.Product.Option}
        % �����ں�Լ
        % �趨���
        dt_lt = datenum(asset.GetDateListed());
        dt_ep = datenum(asset.GetDateListed());
        dt_md_s = md(1, 1);
        dt_md_e = md(end, 1);
        if (isempty(md) || dt_lt - dt_md_s > 1)
            dt_s = dt_lt;
        else
            dt_s = dt_md_e;
        end
        
        % �趨�յ�
        dt_e = dt_ep;

    otherwise
        error('Unexpected "product" for update start & end point determine, please check.');

end
end


% ������Ȩ����
function md = LoadOption(obj, ast)

% �趨����յ�
% ����������Ϊ�գ������Ϊ����ʱ��
% �����������ڵ���ʱ��15�������ڣ�������
% �����������ڵ���ʱ��15�������ϣ������Ϊ�����������һ��
% �յ�ʼ��Ϊ����ʱ��
if (isempty(ast.md))
    loc_start = ast.GetDateListed();
elseif (ast.md(end, 1) - datenum(ast.GetDateExpire()) >= -15/60/24)
    md = [];
    return;
else
    loc_start = datestr(ast.md(end, 1));
end
loc_end = ast.GetDateExpire();
    

% ��ȡ����
import EnumType.Interval;
while (true)
    % ��ȡ����
    switch ast.interval
        case Interval.min1
            [is_err, md] = obj.ds.FetchOptionMinData(ast, loc_start, loc_end, 1);
            
        case Interval.min5
            [is_err, md] = obj.ds.FetchOptionMinData(ast, loc_start, loc_end, 5);
            
        otherwise
            error("Unsupported ""interval"" for DataSource loading. ");
    end
    
    if (is_err)
        obj.SetDsFailure();
        obj.ds = obj.AutoSwitchDataSource();
        continue;
    else
        return;
    end
end

end
