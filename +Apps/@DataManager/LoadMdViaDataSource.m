% 从数据接口获取行情数据
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMdViaDataSource(obj, asset)

% 确定更新起点终点
[dt_s, dt_e] = FindUpdateSE(asset);

% 下载
while (true)
    [is_err, md] = obj.ds.FetchMarketData(asset.product, asset.symbol, asset.exchange, asset.interval, dt_s, dt_e);
    if (is_err)
        obj.SetDsFailure();
        obj.ds = obj.AutoSwitchDataSource();
        continue;
    else
        break;
    end
end

% 合并
if (~isempty(md))
    asset.MergeMarketData(md);
end
end


% 确定更新起点终点
function [dt_s, dt_e] = FindUpdateSE(asset)

md = asset.md;
switch asset.product
    case {EnumType.Product.Etf, EnumType.Product.Index}
        % 类似永续
        % 设定起点
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
        
        % 设定终点
        dt_e = now();
        
    case {EnumType.Product.Future, EnumType.Product.Option}
        % 续存期合约
        % 设定起点
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
        
        % 设定终点
        dt_e = dt_ep;

    otherwise
        error('Unexpected "product" for update start & end point determine, please check.');

end
end

