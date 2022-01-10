% DataManager / IsDataFinish �ж��Ƿ����ݳ���
% v1.2.0.20220105.beta
%       �״����
function ret = IsMdComplete(~, ast)

% ���������ݣ��ж�������
if (isempty(ast.md))
    ret = false;
    return;
end

% ��Ȩ����ǰ15�����޽��ף��ж�������
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