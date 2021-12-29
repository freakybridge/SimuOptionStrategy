% 批量从数据接口获取行情数据
function BatchFetchOptionMd(pth_hm, pth_out, ds)

% 检查输出目录
Utility.CheckDirectory(pth_out);

% 读取所有已知合约信息
instrus = Utility.ReadSheet(pth_hm, 'instrument');

% 准备数据源
switch lower(ds)
    case 'wind'
        api = BaseClass.DataSourceApi.Wind();
    case 'ifind'
        api = BaseClass.DataSourceApi.iFinD('00256770', '30377546');
    otherwise
        error('Sorry, unsupported datasource ''%s''. Please check !', ds);
end
 

% 逐一下载保存
fmt_dt = 'yyyy-mm-dd HH:MM:SS';
for i = 1 : size(instrus, 1)
    % 预处理
    info = instrus(i, :);
    opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, pth_out);
    fprintf('%s data fetching, progress %i/%i, please wait ...\n', opt.symbol, i, size(instrus, 1));
    
    
    % 若挂牌时间在api时限以外，则不下载
    % 若无excel，起点为挂牌时间
    % 若已有数据在挂牌时间后1天以上，起点为挂牌时间
    % 若已有数据在到期时间15分钟以内，则不下载
    % 若已有数据在到期时间15分钟以上，则起点为已有数据最后一条
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
    
    % 下载数据
    md = api.FetchOptionMinData(opt.symbol, opt.exchange, loc_start, loc_end, 5);     
    
    % 合并保存 / 保存excel
    if (~isnan(md))
        opt.MergeMarketData(md);
        opt.OutputMarketData(pth_out);
    end
end

end