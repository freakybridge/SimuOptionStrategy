% �����ݽӿڻ�ȡ��������
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMdViaDataSource(obj, ast)

% ����
switch ast.product
    case EnumType.Product.Option
        md = LoadOption(obj, ast);            
        
    otherwise
        error("Unsupported ""product"" for DataSource loading. ");
end

% �ϲ�
if (~isempty(md))
    ast.MergeMarketData(md);
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
