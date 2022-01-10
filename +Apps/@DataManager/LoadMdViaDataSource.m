% 从数据接口获取行情数据
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMdViaDataSource(obj, ast)

% 下载
switch ast.product
    case EnumType.Product.Option
        md = LoadOption(obj.ds, ast);            
        
    otherwise
        error("Unsupported ""product"" for DataSource loading. ");
end

% 合并
if (~isempty(md))
    ast.MergeMarketData(md);
end
end


% 载入期权数据
function md = LoadOption(ds, ast)

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
    

% 根据周期下载
switch ast.interval
    case EnumType.Interval.min1
        md = ds.FetchOptionMinData(ast, loc_start, loc_end, 1);
        
    case EnumType.Interval.min5
        md = ds.FetchOptionMinData(ast, loc_start, loc_end, 5);
        
    otherwise
        error("Unsupported ""interval"" for DataSource loading. ");
end

end
