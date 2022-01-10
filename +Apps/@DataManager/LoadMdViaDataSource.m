% �����ݽӿڻ�ȡ��������
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMdViaDataSource(obj, ast)

% ����
switch ast.product
    case EnumType.Product.Option
        md = LoadOption(obj.ds, ast);            
        
    otherwise
        error("Unsupported ""product"" for DataSource loading. ");
end

% �ϲ�
if (~isempty(md))
    ast.MergeMarketData(md);
end
end


% ������Ȩ����
function md = LoadOption(ds, ast)

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
    

% ������������
switch ast.interval
    case EnumType.Interval.min1
        md = ds.FetchOptionMinData(ast, loc_start, loc_end, 1);
        
    case EnumType.Interval.min5
        md = ds.FetchOptionMinData(ast, loc_start, loc_end, 5);
        
    otherwise
        error("Unsupported ""interval"" for DataSource loading. ");
end

end
