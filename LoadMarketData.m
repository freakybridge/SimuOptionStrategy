function LoadMarketData(po)

keys = po.keys;
for i = 1 : length(keys)
    this = po.at(keys{i});
    if (~isempty(this.move))
        this.LoadMarketData();
    else
        po.remove(keys{i});
    end
end
end