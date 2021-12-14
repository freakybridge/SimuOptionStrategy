function portfolio = AddLeg(port_pre, file, dir, vol, entry_timing, exit_timing)

position = struct;
position.file = file;
position.dir = dir;
position.vol = vol;
position.entry_timing = entry_timing;
position.exit_timing = exit_timing;
position.md = [];

portfolio = [port_pre; position];

end