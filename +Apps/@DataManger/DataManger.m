classdef DataManger
    % FORMATTRANSFER �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    

    
    methods
        function obj = DataManger()
        end
        
    end
    
    methods (Static)
        ret = TransferTaobaoExcel(dir_hm, dir_tb, dir_sav);        
        
        function Database2Md(driver, ast)
            db = BaseClass.Database.Database.SelectDatabase(driver, 'sa', 'bridgeisbest');
            db.LoadMarketData(ast);
        end
        function ret = Md2Database(driver, ast)
            db = BaseClass.Database.Database.SelectDatabase(driver, 'sa', 'bridgeisbest');
            ret = db.SaveMarketData(ast);
        end
        
        DataSource2Md();
        Csv2Md(dir_in, ast);        
        ret = Md2Csv(dir_out, ast);
    end
end

