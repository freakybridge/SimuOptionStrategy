function [pnl, price] = Simulation(port)

pnl = zeros(size(port(1).md, 1), 3 + 1 + length(port));
pnl(:, 1 : 3) = port(1).md(:, 1 : 3);

price = zeros(size(port(1).md, 1), 3 + length(port));
price(:, 1 : 3) = port(1).md(:, 1 : 3);

for i = 1 : length(port)
    this = port(i);
    dir = this.dir;
    vol = this.vol;
    entry = datenum(this.entry_timing);
    md = this.md;
    
    loc = find(md(:, 3) >= entry, 1, 'first');
    price_cost = md(loc, 4);
    for j = loc : size(md, 1)
        pnl(j, 3 + i) = (md(j, 7) - price_cost) * dir * vol * 10000;
    end
    price(:, 3 + i) = md(:, 7);
end

pnl(:, end) = sum(pnl(:, 4 : end - 1), 2);
end