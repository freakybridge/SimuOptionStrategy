% 从数据接口获取行情数据
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMdViaDataSource(obj, asset)

% 确定更新起点终点
[dt_s, dt_e] = FindUpdateSE(asset);

% 下载
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
        dt_md_s = md(1, 1);
        dt_md_e = md(end, 1);
        if (isempty(md) || dt_ini - dt_md_s > 1)
            dt_s = dt_ini;
        else
            dt_s = dt_md_e;
        end
        
        % 设定终点
        dt_e = now();
        
    case {EnumType.Product.Future, EnumType.Product.Option}
        % 续存期合约
        % 设定起点
        dt_lt = datenum(asset.GetDateListed());
        dt_ep = datenum(asset.GetDateListed());
        dt_md_s = md(1, 1);
        dt_md_e = md(end, 1);
        if (isempty(md) || dt_lt - dt_md_s > 1)
            dt_s = dt_lt;
        else
            dt_s = dt_md_e;
        end
        
        % 设定终点
        dt_e = dt_ep;

    otherwise
        error('Unexpected "product" for update start & end point determine, please check.');

end
end


% 载入期权数据
function md = LoadOption(obj, ast)

% 设定起点终点
% 若本地数据为空，则起点为挂牌时间
% 若已有数据在到期时间15分钟以内，则不下载
% 若已有数据在到期时间15分钟以上，则起点为已有数据最后一条
% 终点始终为到期时点
if (isempty(ast.md))
    loc_start = ast.GetDateListed();
elseif (ast.md(end, 1) - datenum(ast.GetDateExpire()) >= -15/60/24)
    md = [];
    return;
else
    loc_start = datestr(ast.md(end, 1));
end
loc_end = ast.GetDateExpire();
    

% 获取数据
import EnumType.Interval;
while (true)
    % 读取数据
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
