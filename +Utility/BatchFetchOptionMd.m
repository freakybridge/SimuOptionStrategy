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
fmt_dt = 'yyyy-mm-dd HH:MM:SS';
for i = 1 : size(instrus, 1)
    % 确定下载起点终点
    % 若无excel，起点为挂牌时间
    % 若已有数据在挂牌时间后1天以上，起点为挂牌时间
    % 若已有数据在到期时间15分钟以内，则不下载
    % 若已有数据在到期时间15分钟以上，则起点为已有数据最后一条
    info = instrus(i, :);
    opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, pth_sv);
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
    
    % 下载数据 / 合并
    md = api.FetchOptionMinData(opt.symbol, opt.exchange, loc_start, loc_end, 5);     
    opt.MergeMarketData(md);
        
    % 保存excel
    
    
end

end