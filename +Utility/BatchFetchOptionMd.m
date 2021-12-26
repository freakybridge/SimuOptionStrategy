% 批量从数据接口获取行情数据
function BatchFetchOptionMd(pth_instr, pth_sv, ds)

% 读取所有已知合约信息
instrus = Utility.ReadSheet(pth_instr, 'instrument');

% 准备数据源
switch lower(ds)
    case 'wind'
        api = BaseClass.DataSourceApi.Wind();
    case 'ths'
        error('Sorry, unsupported datasource ''%s''. Please check !', ds);
    otherwise
        error('Sorry, unsupported datasource ''%s''. Please check !', ds);
end

% 逐一下载保存
for i = 1 : size(instrus, 1)
    % 检查是否需要下载
    % 不存在excel，需要下载
    % excel数据中，最后一条数据距离到期时间大于15mins，需要下载
    % 其余情况不下载
    info = instrus(i, :);
    this_opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, pth_sv);
    if (exist(this_opt.GetExcelPath(), 'file') == 2)
        this_opt.LoadMarketData();
        if (this_opt.md(end, 1) - datenum(this_opt.GetDateExpire()) >= -15/60/24)
            continue;
        end
    end
    
    % 下载数据
    dat = api.FetchOptionMinData(this_opt.symbol, this_opt.exchange, this_opt.GetDateListed(), this_opt.GetDateExpire(), 5);     
        
        
    % 保存excel
    
    
end

end