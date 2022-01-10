% DataManager / IsDataFinish 判定是否数据充足
% v1.2.0.20220105.beta
%       首次添加
function ret = IsMdComplete(~, ast)

% 无行情数据，判定不充足
if (isempty(ast.md))
    ret = false;
    return;
end

% 期权收盘前15分钟无交易，判定不充足
switch ast.product
    case EnumType.Product.Option
        if (datenum(ast.GetDateExpire) - ast.md(end, 1) <= 15 / (24 * 60))
            ret = true;
        else
            ret = false;
        end        
        
    otherwise
        error("Unexpected ""product"" for market data accomplished judgement, please check");
end
end