function [pnl, price] = Simulation(port, axis)

pnl = zeros(length(axis), 3 + 1 + length(port));
pnl(:, 3) = axis;
pnl(:,1) = arrayfun(@(x) str2double(datestr(x, 'yyyymmdd')), axis);
pnl(:,2) = arrayfun(@(x) str2double(datestr(x, 'HHMM')), axis);


price = zeros(size(pnl, 1), 3 + length(port));
price(:, 1 : 3) = pnl(:, 1 : 3);

for i = 1 : length(port)
    this = port(i);
    dir = this.dir;
    vol = this.vol;
    
    md = this.md;
    start_point = find(md(:, 3) >= datenum(this.entry_timing), 1, 'first');
    end_point = find(md(:, 3) <= datenum(this.exit_timing), 1, 'last');
    price_entry = md(start_point, 4);
    
    loc = find(pnl(:, 3) >= datenum(this.entry_timing), 1, 'first');
    for j = start_point : end_point
        pnl(loc, 3 + i) = (md(j, 7) - price_entry) * dir * vol * 10000;
        loc = loc + 1;
    end
    
    [~, loc1, loc2] = intersect(price(:, 3), md(:, 3));
    price(loc1, 3 + i) = md(loc2, 7);
end

pnl(:, end) = sum(pnl(:, 4 : end - 1), 2);
end