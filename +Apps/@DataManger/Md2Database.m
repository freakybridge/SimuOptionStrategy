% ºÏÔ¼Èë¿â
function ret = Md2Database(ast, driver)
db = BaseClass.Database.Database.SelectDatabase(driver, 'sa', 'bridgeisbest');
ret = db.SaveMarketData(ast);
end


