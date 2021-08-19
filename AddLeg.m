function portfolio = AddLeg(file, dir, vol, entry_timing, portfolio_pre)

position = struct;
position.file = file;
position.dir = dir;
position.vol = vol;
position.entry_timing = entry_timing;
position.md = [];

portfolio = [portfolio_pre; position];

end