% ���������ݽӿڻ�ȡ��������
function BatchFetchOptionMd(pth_hm, pth_out, ds)

% ������Ŀ¼
Utility.CheckDirectory(pth_out);

% ��ȡ������֪��Լ��Ϣ
instrus = Utility.ReadSheet(pth_hm, 'instrument');

% ׼������Դ
switch lower(ds)
    case 'wind'
        api = BaseClass.DataSourceApi.Wind();
    case 'ifind'
        api = BaseClass.DataSourceApi.iFinD('00256770', '30377546');
    otherwise
        error('Sorry, unsupported datasource ''%s''. Please check !', ds);
end
 

% ��һ���ر���
fmt_dt = 'yyyy-mm-dd HH:MM:SS';
for i = 1 : size(instrus, 1)
    % Ԥ����
    info = instrus(i, :);
    opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, pth_out);
    fprintf('%s data fetching, progress %i/%i, please wait ...\n', opt.symbol, i, size(instrus, 1));
    
    
    % ������ʱ����apiʱ�����⣬������
    % ����excel�����Ϊ����ʱ��
    % �����������ڹ���ʱ���1�����ϣ����Ϊ����ʱ��
    % �����������ڵ���ʱ��15�������ڣ�������
    % �����������ڵ���ʱ��15�������ϣ������Ϊ�����������һ��
    if (datenum(opt.GetDateListed()) < now - api.FetchApiDateLimit())
        continue;
    end    
    
    if (exist(opt.GetExcelPath(), 'file') == 2)
        opt.LoadMarketData();
        if (opt.md(1, 1) - datenum(opt.GetDateListed()) >= 1)
            loc_start = opt.GetDateListed();
        elseif (opt.md(end, 1) - datenum(opt.GetDateExpire()) >= -15/60/24)
            continue;
        else
            loc_start = datestr(opt.md(end, 1), fmt_dt);
        end
    else
        loc_start = opt.GetDateListed();
    end
    loc_end = opt.GetDateExpire();
    
    % ��������
    md = api.FetchOptionMinData(opt.symbol, opt.exchange, loc_start, loc_end, 5);     
    
    % �ϲ����� / ����excel
    if (~isnan(md))
        opt.MergeMarketData(md);
        opt.OutputMarketData(pth_out);
    end
end

end