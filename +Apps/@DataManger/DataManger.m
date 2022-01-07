classdef DataManger
    % FORMATTRANSFER 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        Property1
    end
    
    methods
        function obj = DataManger()
        end
        
    end
    
    methods (Static)
        ret = TransferTaobaoExcel(dir_hm, dir_tb, dir_sav);        
        
        function Database2Md(driver, ast)
            BaseClass.Database.Database.SelectDatabase(driver, 'sa', 'bridgeisbest').LoadMarketData(ast);
        end
        function Md2Database(ast, db
        DataSource2Md();
        Csv2Md(dir_in, ast);
        
        ret = Md2Csv(dir_out, ast);
        ret = Md2Database(ast, db_);
    end
end

