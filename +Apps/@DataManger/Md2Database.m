% ºÏÔ¼Èë¿â
function ret = Md2Database(driver, ast)
ret = BaseClass.Database.Database.SelectDatabase(driver, 'sa', 'bridgeisbest').SaveMarketData(ast);
end


