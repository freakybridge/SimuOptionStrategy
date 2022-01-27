% DataManager / Update
% v1.3.0.20220113.beta
%      1.First Commit
function Update(obj)

% Calendar
obj.LoadCalendar();

% INDEX
inv = EnumType.Interval.day;
upd_lst = struct;
upd_lst.product = EnumType.Product.Index;                      upd_lst.variety = '000001';             upd_lst.exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '000016';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '000300';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '000905';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '399001';     upd_lst(end).exchange = EnumType.Exchange.SZSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '399005';     upd_lst(end).exchange = EnumType.Exchange.SZSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '399006';     upd_lst(end).exchange = EnumType.Exchange.SZSE;
for i = 1 : length(upd_lst)
    this = upd_lst(i);
    fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));
    asset = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, inv);
    obj.LoadMd(asset);
end

% ETF
inv = EnumType.Interval.day;
upd_lst = struct;
upd_lst.product = EnumType.Product.ETF;                      upd_lst.variety = '159919';            upd_lst.exchange = EnumType.Exchange.SZSE;
upd_lst(end + 1).product = EnumType.Product.ETF;       upd_lst(end).variety = '510050';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.ETF;       upd_lst(end).variety = '510300';     upd_lst(end).exchange = EnumType.Exchange.SSE;
for i = 1 : length(upd_lst)
    this = upd_lst(i);
    fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));
    asset = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, inv);
    obj.LoadMd(asset);
end
disp(12345);

% 更新期权




end
