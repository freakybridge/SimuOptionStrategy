% ���������ݽӿڻ�ȡ��������
function BatchFetchOptionMd(pth_instr, pth_sv, ds)

% ��ȡ������֪��Լ��Ϣ
instrus = Utility.ReadSheet(pth_instr, 'instrument');

% ׼������Դ
switch lower(ds)
    case 'wind'
        api = BaseClass.DataSourceApi.Wind();
    case 'ths'
        error('Sorry, unsupported datasource ''%s''. Please check !', ds);
    otherwise
        error('Sorry, unsupported datasource ''%s''. Please check !', ds);
end

% ��һ���ر���
for i = 1 : size(instrus, 1)
    % ����Ƿ���Ҫ����
    % ������excel����Ҫ����
    % excel�����У����һ�����ݾ��뵽��ʱ�����15mins����Ҫ����
    % �������������
    info = instrus(i, :);
    this_opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, pth_sv);
    if (exist(this_opt.GetExcelPath(), 'file') == 2)
        this_opt.LoadMarketData();
        if (this_opt.md(end, 1) - datenum(this_opt.GetDateExpire()) >= -15/60/24)
            continue;
        end
    end
    
    % ��������
    dat = api.FetchOptionMinData(this_opt.symbol, this_opt.exchange, this_opt.GetDateListed(), this_opt.GetDateExpire(), 5);     
        
        
    % ����excel
    
    
end

end