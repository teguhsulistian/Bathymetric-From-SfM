classdef SCRIPT_GUI_SFM < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SFM                            matlab.ui.Figure
        ImportMenu                     matlab.ui.container.Menu
        ImportPointCloudMenu           matlab.ui.container.Menu
        ExportMenu                     matlab.ui.container.Menu
        ExportCorrectedPointCloudMenu  matlab.ui.container.Menu
        QCMenu                         matlab.ui.container.Menu
        AboutMenu                      matlab.ui.container.Menu
        ProcessingPanel                matlab.ui.container.Panel
        UITableObservation             matlab.ui.control.Table
        PreviewTabelLabel              matlab.ui.control.Label
        WaterLevelEditFieldLabel       matlab.ui.control.Label
        WaterLevelEditField            matlab.ui.control.NumericEditField
        RefractionIndexEditFieldLabel  matlab.ui.control.Label
        RefractionIndexEditField       matlab.ui.control.NumericEditField
        OptionButton                   matlab.ui.control.Button
        ProcessButton                  matlab.ui.control.Button
        RefractionIndexPanel           matlab.ui.container.Panel
        SalinityEditFieldLabel         matlab.ui.control.Label
        SalinityEditField              matlab.ui.control.NumericEditField
        TemperatureCEditFieldLabel     matlab.ui.control.Label
        TemperatureCEditField          matlab.ui.control.NumericEditField
        WavelengthnmEditFieldLabel     matlab.ui.control.Label
        WavelengthnmEditField          matlab.ui.control.NumericEditField
        CalculateButton                matlab.ui.control.Button
        CorrectionMethodDropDownLabel  matlab.ui.control.Label
        CorrectionMethodDropDown       matlab.ui.control.DropDown
        ImportEOButton                 matlab.ui.control.Button
        Eoedit                         matlab.ui.control.EditField
        ImportIOButton                 matlab.ui.control.Button
        Ioedit                         matlab.ui.control.EditField
        ProcessButton_2                matlab.ui.control.Button
        TotalPointEditFieldLabel       matlab.ui.control.Label
        TotalPointEditField            matlab.ui.control.NumericEditField
        UIAxes                         matlab.ui.control.UIAxes
        DATAQCPanel                    matlab.ui.container.Panel
        ImportCorrectedPointCloudButton  matlab.ui.control.Button
        ImportCheckPointASCIIButton    matlab.ui.control.Button
        NoteSelectedpointmustbeinsamehorizontalandverticaldatumLabel  matlab.ui.control.Label
        Filename                       matlab.ui.control.EditField
        Checkname                      matlab.ui.control.EditField
        Process_Check                  matlab.ui.control.Button
        UIPlotCheck                    matlab.ui.control.UIAxes
        RESULTPanel                    matlab.ui.container.Panel
        UITable                        matlab.ui.control.Table
        TOTALPOINTEditFieldLabel       matlab.ui.control.Label
        TOTALPOINTEditField            matlab.ui.control.NumericEditField
        MEANEditFieldLabel             matlab.ui.control.Label
        MEANEditField                  matlab.ui.control.NumericEditField
        RMSEEditFieldLabel             matlab.ui.control.Label
        RMSEEditField                  matlab.ui.control.NumericEditField
        ExportButton                   matlab.ui.control.Button
    end

    
    properties (Access = public)
        INPUT_PC %SFM Point File Name
        XA %X SFM Point Cloud
        YA %Y SFM Point Cloud
        ZA %Z SFM Point Cloud
        WL %Water Level
        RI %Refractive Index
        XYZA % SFM XYZ Point Cloud
        ZD % Depth Temporary
        ZT % True Z
        XC %Corrected Point Cloud
        YC %Corrected Point Cloud
        ZC %Corrected Point Cloud
        XI %ICP Point Cloud
        YI %ICP Point Cloud
        ZI %ICP Point Cloud
        CROSS_CHECK %Result check
        RMSE %RMSE
        MEAN1 %MEAN ERROR
        EO %EO FILE
        IO %IO FILE
        
    end
    


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function BEGIN(app)
            app.ProcessingPanel.Visible ='off';
            app.RefractionIndexPanel.Visible ='off';
            app.UIAxes.Visible = 'off';
            app.DATAQCPanel.Visible = 'off';
            app.UIPlotCheck.Visible = 'off';
            app.RESULTPanel.Visible = 'off';
            app.CorrectionMethodDropDown.Visible = 'off';
            app.CorrectionMethodDropDownLabel.Visible = 'off';
            app.ImportEOButton.Visible = 'off';
            app.ImportIOButton.Visible ='off';
            app.Eoedit.Visible = 'off';
            app.Ioedit.Visible = 'off';
            app.ProcessButton.Visible = 'off';
            app.ProcessButton_2.Visible = 'off';
            app.TotalPointEditField.Visible = 'off';
            app.TotalPointEditFieldLabel.Visible = 'off';
            
        end

        % Menu selected function: ImportPointCloudMenu
        function ImportPointCloudMenuSelected(app, event)
            BEGIN(app);
            
            %%%%--------------------Import SFM Point Cloud, format Las
            [selected_files,directory] = uigetfile({'*.las',...
                'Point Cloud Data (*.las)';...
                '*.*','All file (*.*)'},'Input SFM Point Cloud', 'Multiselect','on');
            
            f = app.SFM
            
            if isequal(selected_files,0)
                uiwait(msgbox('Select Data Cancel'));
            else
                string_files = string(selected_files);
                string_files = string_files';
                size_files = size(string_files);
                list_files = size_files(1);
                
                app.XA=[];
                app.YA=[];
                app.ZA=[];
                
                for i=1:list_files
                    %Import las files
                    format LONGG
                    file_name = char(strcat(directory,string_files(i)));
                    data = lasdata(file_name);
                    X= data.x;
                    Y= data.y;
                    Z= data.z;
                    
                    d = uiprogressdlg(f,'Title','Please Wait',...
                    'Message','Loading Data');
                    pause(.45)
                    
                    %Combine Multiple file
                    app.XA =cat(1,app.XA,X);
                    app.YA =cat(1,app.YA,Y);
                    app.ZA =cat(1,app.ZA,Z);
                end
                d.Value = 1;
                d.Message = 'Finish';
                pause(1)
                uiwait(msgbox('Points Imported'));
            end
            
            total_data = length(app.XA);
            app.TotalPointEditField.Value = total_data;
            app.TotalPointEditField.Visible = 'on';
            app.TotalPointEditFieldLabel.Visible = 'on';
            app.INPUT_PC = file_name;
            app.ProcessingPanel.Visible ='on';
            app.XYZA = [app.XA app.YA app.ZA];
            app.UITableObservation.Data = app.XYZA(1:30,1:3);
            app.UITableObservation.ColumnFormat = {'longG','longG','longG'};
            app.CorrectionMethodDropDown.Visible = 'on';
            app.CorrectionMethodDropDownLabel.Visible = 'on';       
                                 
        end

        % Button pushed function: OptionButton
        function OptionButtonPushed(app, event)
           app.RefractionIndexPanel.Visible ='on';
        end

        % Button pushed function: CalculateButton
        function CalculateButtonPushed(app, event)
            s = app.SalinityEditField.Value;
            t = app.TemperatureCEditField.Value;
            l = app.WavelengthnmEditField.Value;
            app.RefractionIndexEditField.Value = 1.3247-(2.5*10^-6*t^2)+s*(2*(10^-4)-8*(10^-7)*t)+(3300/(l^2))-((3.2*10^7)/(l^4));
            
            app.RefractionIndexPanel.Visible='off'
        end

        % Button pushed function: ProcessButton
        function ProcessButtonPushed(app, event)
        app.UIAxes.Visible = 'off';
        
        %Calculate True Depth
        ref_index = app.RefractionIndexEditField.Value;
        app.RI = ref_index
        water_level = app.WaterLevelEditField.Value;
        app.WL = water_level;
        
        f = app.SFM
        d = uiprogressdlg(f,'Title','Please Wait',...
                    'Message','Loading Data');
                    pause(.20)
        
        ZA = app.ZA;
        ZD = ZA-water_level; %Depth Temporary
        ZT = ZA;
        idx = ZD<0;
        ZT(idx) = water_level+(ZD(idx)*ref_index);
        
        d.Value = .5;
        d.Message = 'Loading';
        pause(1)
        
        %Selected Sample
        d05 = find(ZD>-0.5 & ZD<0);
        d1 = find(ZD>-1 & ZD<-0.5);
        d2 = find(ZD>-2 & ZD<-1);
        d3 = find(ZD>-3 & ZD<-2);
        
        ZD05=[];
        ZD1 =[];
        ZD2 =[];
        ZD3 = [];
        ZT05=[];
        ZT1 =[];
        ZT2 =[];
        ZT3 = [];
        
        for i=10:50
            ZA05 = ZA(d05(i));
            ZD05= cat(1,ZD05,ZA05);
            zt05 = ZT(d05(i));
            ZT05= cat(1,ZT05,zt05);
        end
        
        for i=1:25
            ZA1 = ZA(d1(i));
            ZD1= cat(1,ZD1,ZA1);
            zt1 = ZT(d1(i));
            ZT1= cat(1,ZT1,zt1);
        end
        
        for i=75:124
            ZA2 = ZA(d2(i));
            ZD2= cat(1,ZD2,ZA2);
            zt2 = ZT(d2(i));
            ZT2= cat(1,ZT2,zt2);
        end
        
        for i=75:124
            ZA3 = ZA(d3(i));
            ZD3= cat(1,ZD3,ZA3);
            zt3 = ZT(d3(i));
            ZT3= cat(1,ZT3,zt3);
        end
        %True Depth To Public Properties
        app.ZT = ZT;
        
        
        %Gabung Z before
        Zgabung = [];
        Zgabung = cat(1,Zgabung,ZD05,ZD1,ZD2,ZD3); 
        
        %Gabung Z after
        Zafter = [];
        Zafter = cat(1,Zafter,ZT05,ZT1,ZT2,ZT3);
        
        %length Sample
        Xaxis = transpose([1:length(Zgabung)]);
        
        app.UIAxes.cla('reset');
        graph2 = app.UIAxes();
        plot(graph2,[Xaxis(1) Xaxis(end)],[app.WaterLevelEditField.Value app.WaterLevelEditField.Value], '--b','linewidth', 1.1);
        hold(graph2,"on");
        plot(graph2,Xaxis,Zgabung,'-k');
        plot(graph2,Xaxis,Zafter, '-g','linewidth', 1.1);
        ylabel(graph2, 'Elevation');
        xlabel(graph2, 'Number of Sample');
        graph2.XGrid = 'on';
        graph2.YGrid = 'on';
        legend(graph2,['1.Water Level : ' num2str(app.WaterLevelEditField.Value, '%2.2f')],'2. Apparent Depth','3. True Depth');
        title(graph2,'Preview Result');
        hold(graph2,"off");
        
        app.UIAxes.Visible = 'On';
        
        d.Value = 1;
        d.Message = 'Finish';
        pause(1)
        
        end

        % Menu selected function: ExportCorrectedPointCloudMenu
        function ExportCorrectedPointCloudMenuSelected(app, event)
        [file_txt, path_txt] = uiputfile({'*.las'},'Export Corrected Point Cloud');
        if isequal(file_txt,0)
            uiwait(msgbox('Export Cancel'));
        else
            guid1 = uint32(0);
            guid2 = uint16(0);
            guid3 = uint16(0);
            guid4 = blanks(8);
            
            s.header=struct('project_id_1',guid1,'project_id_2',guid2,'project_id_3',guid3,'project_id_4',guid4);
            s.record.x=app.XA;
            s.record.y=app.YA;
            s.record.z=app.ZT;
            
            file_output=strcat(path_txt,file_txt);
            
            s = LASwrite(s, ...
               file_output, ...
               'version', 14, ...
               'systemID', 'MODIFICATION', ...
               'guid', '270DBE859CF44302AB0C35E0F25A0942', ...
               'recordFormat', 6, ...
               'verbose', false);
           
           uiwait(msgbox('Export Done'));
        end
        end

        % Menu selected function: QCMenu
        function QCMenuSelected(app, event)
            app.DATAQCPanel.Visible = 'on';
        end

        % Button pushed function: ImportCorrectedPointCloudButton
        function ImportCorrectedPointCloudButtonPushed(app, event)
            [selected_files,directory] = uigetfile({'*.las',...
                'Point Cloud Data (*.las)';...
                '*.*','All file (*.*)'},'Input Corrected Point Cloud', 'Multiselect','on');
            
            if isequal(selected_files,0)
                uiwait(msgbox('Select Data Cancel'));
            else
                string_files = string(selected_files);
                string_files = string_files';
                size_files = size(string_files);
                list_files = size_files(1);
                
                app.XC=[];
                app.YC=[];
                app.ZC=[];
                
                for i=1:list_files
                    %Import las files
                    format LONGG
                    file_name = char(strcat(directory,string_files(i)));
                    data = lasdata(file_name);
                    X= data.x;
                    Y= data.y;
                    Z= data.z;
                    
                    %Combine Multiple file
                    app.XC =cat(1,app.XC,X);
                    app.YC =cat(1,app.YC,Y);
                    app.ZC =cat(1,app.ZC,Z);
                end
                uiwait(msgbox('Import Data Completed'));
            end
            
            app.Filename.Value = file_name;
            
        end

        % Button pushed function: ImportCheckPointASCIIButton
        function ImportCheckPointASCIIButtonPushed(app, event)
        [selected_files,directory] = uigetfile({'*.xyz;*.csv;*.txt;*.dat',...
                'ASCII (*.xyz,*.csv,*.txt,*.dat)';...
                '*.*','All file (*.*)'},'Input Check Point', 'Multiselect','on');
            
            if isequal(selected_files,0)
                uiwait(msgbox('Select Data Cancel'));
            else
                string_files = string(selected_files);
                string_files = string_files';
                size_files = size(string_files);
                list_files = size_files(1);
                
                app.XI=[];
                app.YI=[];
                app.ZI=[];
                
                for i=1:list_files
                    %Import las files
                    format LONGG
                    file_name = char(strcat(directory,string_files(i)));
                    data = table2array(readtable(file_name));
                    X= data(:,1);
                    Y= data(:,2);
                    Z= data(:,3);
                    
                    %Combine Multiple file
                    app.XI =cat(1,app.XI,X);
                    app.YI =cat(1,app.YI,Y);
                    app.ZI =cat(1,app.ZI,Z);
                end
                uiwait(msgbox('Import Data Completed'));
            end
            
            app.Checkname.Value = file_name;
        end

        % Button pushed function: Process_Check
        function Process_CheckButtonPushed(app, event)
            %QC DATA
            A = [app.XI app.YI];
            B = [app.XC app.YC];
            T = delaunayn(A); 
            [k,dist] = dsearchn(B,T,A);
            NEAR_DATA=[];
            
            for i=1:length(k)
                closest_main = [app.XI(i) app.YI(i) app.ZI(i) app.XC(k(i)) app.YC(k(i)) app.ZC(k(i)) dist(i)];
                NEAR_DATA = cat(1,NEAR_DATA,closest_main);
            end
            
            Zdiff = NEAR_DATA(:,3)-NEAR_DATA(:,6);
            kuadrat = Zdiff.^2;
            jumlah = sum(kuadrat);
            banyak = length(Zdiff);
            app.MEAN1 = mean(Zdiff);
            app.RMSE = sqrt(jumlah/banyak);
            
            app.CROSS_CHECK = [NEAR_DATA Zdiff];
            
            %Plot Result Data
            app.RESULTPanel.Visible ='on';
            plotcross = [app.CROSS_CHECK(1:50,1:3) app.CROSS_CHECK(1:50,6:8)]
            app.UITable.Data = plotcross;
            app.UITableObservation.ColumnFormat = {'longG','longG','longG','longG','longG','longG'};
            
            app.MEANEditField.Value = app.MEAN1;
            app.RMSEEditField.Value = app.RMSE;
            app.TOTALPOINTEditField.Value = banyak;
            
            %Plot Graphic
            A = sortrows([NEAR_DATA(:,3) NEAR_DATA(:,6)] ,'descend');
            Xaxis = transpose([1:length(A)]);
            
            app.UIPlotCheck.cla('reset');
            graph2 = app.UIPlotCheck();
            plot(graph2,Xaxis,A(:,1), '*b');
            hold(graph2,"on");
            plot(graph2,Xaxis,A(:,2), '*k');
            ylabel(graph2, 'Elevation');
            xlabel(graph2, 'Number of Sample');
            graph2.XGrid = 'on';
            graph2.YGrid = 'on';
            legend(graph2,'1. Sounding Point','2. SfM Point');
            title(graph2,'Preview Check Point');
            hold(graph2,"off");
            
            app.UIPlotCheck.Visible = 'On';
            
            
        end

        % Button pushed function: ExportButton
        function ExportButtonPushed(app, event)
        [file_txt, path_txt] = uiputfile({'*.txt'},'Export Point');
        if isequal(file_txt,0)
            uiwait(msgbox('Export Cancel'));
        else           
            file_output=strcat(path_txt,file_txt);
            
            dlmwrite(file_output,[])
            fr = fopen(file_output,'w');
            header = ["X_ICP" "Y_ICP" "Z_ICP" "X_DATA" "Y_DATA" "Z_DATA" "Distance_Point" "Different_Z"];
            fprintf(fr,'%s,%s,%s,%s,%s,%s,%s,%s\n',header(1),header(2),header(3),header(4),header(5),header(6),header(7),header(8));
            fprintf(fr,'\n');
            for i = 1 : length(app.CROSS_CHECK)
            fprintf(fr, '%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n',....
                app.CROSS_CHECK(i,1),app.CROSS_CHECK(i,2),app.CROSS_CHECK(i,3),app.CROSS_CHECK(i,4),app.CROSS_CHECK(i,5),app.CROSS_CHECK(i,6),app.CROSS_CHECK(i,7),app.CROSS_CHECK(i,8));
            end
            fclose(fr);
           
           uiwait(msgbox('Export Done'));
        end
        end

        % Value changed function: CorrectionMethodDropDown
        function CorrectionMethodDropDownValueChanged(app, event)
            value = app.CorrectionMethodDropDown.Value;
            str = 'Small Angle';

            if contains(value,str)
               app.ProcessButton.Visible = 'on';
               app.ImportEOButton.Visible = 'off';
               app.Eoedit.Visible ='off';
               app.ImportIOButton.Visible ='off';
               app.Ioedit.Visible ='off';
               app.ProcessButton_2.Visible ='off';
            else
               app.ImportEOButton.Visible = 'on';
               app.Eoedit.Visible ='on';
               app.ImportIOButton.Visible ='on';
               app.Ioedit.Visible ='on';
               app.ProcessButton_2.Visible ='on';
               app.ProcessButton.Visible = 'off';
            end
            
            if contains('-Please Select-',app.CorrectionMethodDropDown.Value)
               app.ProcessButton.Visible = 'off';
               app.ImportEOButton.Visible = 'off';
               app.Eoedit.Visible ='off';
               app.ImportIOButton.Visible ='off';
               app.Ioedit.Visible ='off';
               app.ProcessButton_2.Visible ='off';
            end
        end

        % Button pushed function: ImportEOButton
        function ImportEOButtonPushed(app, event)
            [selected_files,directory] = uigetfile({'*.txt',...
                'Text File (*.txt)';...
                '*.*','All file (*.*)'},'Input Exterior Oriention');
            
            if isequal(selected_files,0)
                uiwait(msgbox('Select Data Cancel'));
            else
                file_name = char(strcat(directory,selected_files));
                app.Eoedit.Value = file_name;
                uiwait(msgbox('EO Data Imported'));
            end
            
            app.EO = file_name;
        end

        % Button pushed function: ImportIOButton
        function ImportIOButtonPushed(app, event)
            [selected_files,directory] = uigetfile({'*.xml',...
                'Extensible Markup Language (*.xml)';...
                '*.*','All file (*.*)'},'Input Interior Oriention');
            
            if isequal(selected_files,0)
                uiwait(msgbox('Select Data Cancel'));
            else
                file_name = char(strcat(directory,selected_files));
                app.Ioedit.Value = file_name;
                uiwait(msgbox('IO Data Imported'));
            end
            
            app.IO = file_name;
        end

        % Button pushed function: ProcessButton_2
        function ProcessButton_2Pushed(app, event)
            f = app.SFM;
            d = uiprogressdlg(f,'Title','Please Wait',...
                    'Message','Loading Data');
                  
            d.Value = .35;
            d.Message = 'Loading';
            pause(1)
                   
            [Sfmcorr, correct_data] = sfmrefract(app.INPUT_PC,app.EO,app.IO,app.WaterLevelEditField.Value,'constsf',[],'ior',app.RefractionIndexEditField.Value);
            app.XC = correct_data.record.x;
            app.YC = correct_data.record.y;
            app.ZT = correct_data.record.z;
            
             d.Value = .85;
             d.Message = 'Loading';
             pause(1)
            
            water_level = app.WaterLevelEditField.Value;
            ZA = app.ZA;
            ZD = ZA-water_level; %Depth Temporary

            %Selected Sample
            d05 = find(ZD>-0.5 & ZD<0);
            d1 = find(ZD>-1 & ZD<-0.5);
            d2 = find(ZD>-2 & ZD<-1);
            d3 = find(ZD>-3 & ZD<-2);
            
            ZD05=[];
            ZD1 =[];
            ZD2 =[];
            ZD3 = [];
            ZT05=[];
            ZT1 =[];
            ZT2 =[];
            ZT3 = [];
            
            for i=10:50
                ZA05 = ZA(d05(i));
                ZD05= cat(1,ZD05,ZA05);
                zt05 = app.ZT(d05(i));
                ZT05= cat(1,ZT05,zt05);
            end
            
            for i=1:25
                ZA1 = ZA(d1(i));
                ZD1= cat(1,ZD1,ZA1);
                zt1 = app.ZT(d1(i));
                ZT1= cat(1,ZT1,zt1);
            end
            
            for i=75:124
                ZA2 = ZA(d2(i));
                ZD2= cat(1,ZD2,ZA2);
                zt2 = app.ZT(d2(i));
                ZT2= cat(1,ZT2,zt2);
            end
            
            for i=75:124
                ZA3 = ZA(d3(i));
                ZD3= cat(1,ZD3,ZA3);
                zt3 = app.ZT(d3(i));
                ZT3= cat(1,ZT3,zt3);
            end
            
            %Gabung Z before
            Zgabung = [];
            Zgabung = cat(1,Zgabung,ZD05,ZD1,ZD2,ZD3); 
            
            %Gabung Z after
            Zafter = [];
            Zafter = cat(1,Zafter,ZT05,ZT1,ZT2,ZT3);
            
            %length Sample
            Xaxis = transpose([1:length(Zgabung)]);
            
            app.UIAxes.cla('reset');
            graph2 = app.UIAxes();
            plot(graph2,[Xaxis(1) Xaxis(end)],[app.WaterLevelEditField.Value app.WaterLevelEditField.Value], '--b','linewidth', 1.1);
            hold(graph2,"on");
            plot(graph2,Xaxis,Zgabung,'-k');
            plot(graph2,Xaxis,Zafter, '-g','linewidth', 1.1);
            ylabel(graph2, 'Elevation');
            xlabel(graph2, 'Number of Sample');
            graph2.XGrid = 'on';
            graph2.YGrid = 'on';
            legend(graph2,['1.Water Level : ' num2str(app.WaterLevelEditField.Value, '%2.2f')],'2. Apparent Depth','3. True Depth');
            title(graph2,'Preview Result');
            hold(graph2,"off");
            
            app.UIAxes.Visible = 'On';
            
             d.Value = 1;
             d.Message = 'Finish';
             pause(1)
        end

        % Menu selected function: AboutMenu
        function AboutMenuSelected(app, event)
            about = sprintf(' Bathymetric From SfM Software \n 2022 \n Developed by Teguh Sulistian (Geospatial Information Agency Of Indonesia) \n Contact : teguh.sulistian@big.go.id')
            uiwait(msgbox(about));
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SFM and hide until all components are created
            app.SFM = uifigure('Visible', 'off');
            app.SFM.NumberTitle = 'on';
            app.SFM.Color = [0.302 0.6196 0.6588];
            app.SFM.Colormap = [0.2431 0.149 0.6588;0.2431 0.1529 0.6745;0.2471 0.1569 0.6863;0.2471 0.1608 0.698;0.251 0.1647 0.7059;0.251 0.1686 0.7176;0.2549 0.1725 0.7294;0.2549 0.1765 0.7412;0.2588 0.1804 0.749;0.2588 0.1843 0.7608;0.302 0.7451 0.9333;0.2627 0.1922 0.7843;0.2627 0.1961 0.7922;0.2667 0.2 0.8039;0.2667 0.2039 0.8157;0.2706 0.2078 0.8235;0.2706 0.2157 0.8353;0.2706 0.2196 0.8431;0.2745 0.2235 0.851;0.2745 0.2275 0.8627;0.2745 0.2314 0.8706;0.2745 0.2392 0.8784;0.2784 0.2431 0.8824;0.2784 0.2471 0.8902;0.2784 0.2549 0.898;0.2784 0.2588 0.902;0.2784 0.2667 0.9098;0.2784 0.2706 0.9137;0.2784 0.2745 0.9216;0.2824 0.2824 0.9255;0.2824 0.2863 0.9294;0.2824 0.2941 0.9333;0.2824 0.298 0.9412;0.2824 0.3059 0.9451;0.2824 0.3098 0.949;0.2824 0.3137 0.9529;0.2824 0.3216 0.9569;0.2824 0.3255 0.9608;0.2824 0.3294 0.9647;0.2784 0.3373 0.9686;0.2784 0.3412 0.9686;0.2784 0.349 0.9725;0.2784 0.3529 0.9765;0.2784 0.3569 0.9804;0.2784 0.3647 0.9804;0.2745 0.3686 0.9843;0.2745 0.3765 0.9843;0.2745 0.3804 0.9882;0.2706 0.3843 0.9882;0.2706 0.3922 0.9922;0.2667 0.3961 0.9922;0.2627 0.4039 0.9922;0.2627 0.4078 0.9961;0.2588 0.4157 0.9961;0.2549 0.4196 0.9961;0.251 0.4275 0.9961;0.2471 0.4314 1;0.2431 0.4392 1;0.2353 0.4431 1;0.2314 0.451 1;0.2235 0.4549 1;0.2196 0.4627 0.9961;0.2118 0.4667 0.9961;0.2078 0.4745 0.9922;0.2 0.4784 0.9922;0.1961 0.4863 0.9882;0.1922 0.4902 0.9882;0.1882 0.498 0.9843;0.1843 0.502 0.9804;0.1843 0.5098 0.9804;0.1804 0.5137 0.9765;0.1804 0.5176 0.9725;0.1804 0.5255 0.9725;0.1804 0.5294 0.9686;0.1765 0.5333 0.9647;0.1765 0.5412 0.9608;0.1765 0.5451 0.9569;0.1765 0.549 0.9529;0.1765 0.5569 0.949;0.1725 0.5608 0.9451;0.1725 0.5647 0.9412;0.1686 0.5686 0.9373;0.1647 0.5765 0.9333;0.1608 0.5804 0.9294;0.1569 0.5843 0.9255;0.1529 0.5922 0.9216;0.1529 0.5961 0.9176;0.149 0.6 0.9137;0.149 0.6039 0.9098;0.1451 0.6078 0.9098;0.1451 0.6118 0.9059;0.1412 0.6196 0.902;0.1412 0.6235 0.898;0.1373 0.6275 0.898;0.1373 0.6314 0.8941;0.1333 0.6353 0.8941;0.1294 0.6392 0.8902;0.1255 0.6471 0.8902;0.1216 0.651 0.8863;0.1176 0.6549 0.8824;0.1137 0.6588 0.8824;0.1137 0.6627 0.8784;0.1098 0.6667 0.8745;0.1059 0.6706 0.8706;0.102 0.6745 0.8667;0.098 0.6784 0.8627;0.0902 0.6824 0.8549;0.0863 0.6863 0.851;0.0784 0.6902 0.8471;0.0706 0.6941 0.8392;0.0627 0.698 0.8353;0.0549 0.702 0.8314;0.0431 0.702 0.8235;0.0314 0.7059 0.8196;0.0235 0.7098 0.8118;0.0157 0.7137 0.8078;0.0078 0.7176 0.8;0.0039 0.7176 0.7922;0 0.7216 0.7882;0 0.7255 0.7804;0 0.7294 0.7765;0.0039 0.7294 0.7686;0.0078 0.7333 0.7608;0.0157 0.7333 0.7569;0.0235 0.7373 0.749;0.0353 0.7412 0.7412;0.051 0.7412 0.7373;0.0627 0.7451 0.7294;0.0784 0.7451 0.7216;0.0902 0.749 0.7137;0.102 0.7529 0.7098;0.1137 0.7529 0.702;0.1255 0.7569 0.6941;0.1373 0.7569 0.6863;0.1451 0.7608 0.6824;0.1529 0.7608 0.6745;0.1608 0.7647 0.6667;0.1686 0.7647 0.6588;0.1725 0.7686 0.651;0.1804 0.7686 0.6471;0.1843 0.7725 0.6392;0.1922 0.7725 0.6314;0.1961 0.7765 0.6235;0.2 0.7804 0.6157;0.2078 0.7804 0.6078;0.2118 0.7843 0.6;0.2196 0.7843 0.5882;0.2235 0.7882 0.5804;0.2314 0.7882 0.5725;0.2392 0.7922 0.5647;0.251 0.7922 0.5529;0.2588 0.7922 0.5451;0.2706 0.7961 0.5373;0.2824 0.7961 0.5255;0.2941 0.7961 0.5176;0.3059 0.8 0.5059;0.3176 0.8 0.498;0.3294 0.8 0.4863;0.3412 0.8 0.4784;0.3529 0.8 0.4667;0.3686 0.8039 0.4549;0.3804 0.8039 0.4471;0.3922 0.8039 0.4353;0.4039 0.8039 0.4235;0.4196 0.8039 0.4118;0.4314 0.8039 0.4;0.4471 0.8039 0.3922;0.4627 0.8 0.3804;0.4745 0.8 0.3686;0.4902 0.8 0.3569;0.5059 0.8 0.349;0.5176 0.8 0.3373;0.5333 0.7961 0.3255;0.5451 0.7961 0.3176;0.5608 0.7961 0.3059;0.5765 0.7922 0.2941;0.5882 0.7922 0.2824;0.6039 0.7882 0.2745;0.6157 0.7882 0.2627;0.6314 0.7843 0.251;0.6431 0.7843 0.2431;0.6549 0.7804 0.2314;0.6706 0.7804 0.2235;0.6824 0.7765 0.2157;0.698 0.7765 0.2078;0.7098 0.7725 0.2;0.7216 0.7686 0.1922;0.7333 0.7686 0.1843;0.7451 0.7647 0.1765;0.7608 0.7647 0.1725;0.7725 0.7608 0.1647;0.7843 0.7569 0.1608;0.7961 0.7569 0.1569;0.8078 0.7529 0.1529;0.8157 0.749 0.1529;0.8275 0.749 0.1529;0.8392 0.7451 0.1529;0.851 0.7451 0.1569;0.8588 0.7412 0.1569;0.8706 0.7373 0.1608;0.8824 0.7373 0.1647;0.8902 0.7373 0.1686;0.902 0.7333 0.1765;0.9098 0.7333 0.1804;0.9176 0.7294 0.1882;0.9255 0.7294 0.1961;0.9373 0.7294 0.2078;0.9451 0.7294 0.2157;0.9529 0.7294 0.2235;0.9608 0.7294 0.2314;0.9686 0.7294 0.2392;0.9765 0.7294 0.2431;0.9843 0.7333 0.2431;0.9882 0.7373 0.2431;0.9961 0.7412 0.2392;0.9961 0.7451 0.2353;0.9961 0.7529 0.2314;0.9961 0.7569 0.2275;0.9961 0.7608 0.2235;0.9961 0.7686 0.2196;0.9961 0.7725 0.2157;0.9961 0.7804 0.2078;0.9961 0.7843 0.2039;0.9961 0.7922 0.2;0.9922 0.7961 0.1961;0.9922 0.8039 0.1922;0.9922 0.8078 0.1922;0.9882 0.8157 0.1882;0.9843 0.8235 0.1843;0.9843 0.8275 0.1804;0.9804 0.8353 0.1804;0.9765 0.8392 0.1765;0.9765 0.8471 0.1725;0.9725 0.851 0.1686;0.9686 0.8588 0.1647;0.9686 0.8667 0.1647;0.9647 0.8706 0.1608;0.9647 0.8784 0.1569;0.9608 0.8824 0.1569;0.9608 0.8902 0.1529;0.9608 0.898 0.149;0.9608 0.902 0.149;0.9608 0.9098 0.1451;0.9608 0.9137 0.1412;0.9608 0.9216 0.1373;0.9608 0.9255 0.1333;0.9608 0.9333 0.1294;0.9647 0.9373 0.1255;0.9647 0.9451 0.1216;0.9647 0.949 0.1176;0.9686 0.9569 0.1098;0.9686 0.9608 0.1059;0.9725 0.9686 0.102;0.9725 0.9725 0.0941;0.9765 0.9765 0.0863;0.9765 0.9843 0.0824];
            app.SFM.Position = [80 80 1223 751];
            app.SFM.Name = 'Bathymetric From SfM';

            % Create ImportMenu
            app.ImportMenu = uimenu(app.SFM);
            app.ImportMenu.Text = 'Import';

            % Create ImportPointCloudMenu
            app.ImportPointCloudMenu = uimenu(app.ImportMenu);
            app.ImportPointCloudMenu.MenuSelectedFcn = createCallbackFcn(app, @ImportPointCloudMenuSelected, true);
            app.ImportPointCloudMenu.Text = 'Import Point Cloud';

            % Create ExportMenu
            app.ExportMenu = uimenu(app.SFM);
            app.ExportMenu.Text = 'Export';

            % Create ExportCorrectedPointCloudMenu
            app.ExportCorrectedPointCloudMenu = uimenu(app.ExportMenu);
            app.ExportCorrectedPointCloudMenu.MenuSelectedFcn = createCallbackFcn(app, @ExportCorrectedPointCloudMenuSelected, true);
            app.ExportCorrectedPointCloudMenu.Text = 'Export Corrected Point Cloud';

            % Create QCMenu
            app.QCMenu = uimenu(app.SFM);
            app.QCMenu.MenuSelectedFcn = createCallbackFcn(app, @QCMenuSelected, true);
            app.QCMenu.Text = 'QC';

            % Create AboutMenu
            app.AboutMenu = uimenu(app.SFM);
            app.AboutMenu.MenuSelectedFcn = createCallbackFcn(app, @AboutMenuSelected, true);
            app.AboutMenu.Text = 'About';

            % Create ProcessingPanel
            app.ProcessingPanel = uipanel(app.SFM);
            app.ProcessingPanel.TitlePosition = 'centertop';
            app.ProcessingPanel.Title = 'Processing Panel';
            app.ProcessingPanel.Position = [1 288 302 464];

            % Create UITableObservation
            app.UITableObservation = uitable(app.ProcessingPanel);
            app.UITableObservation.ColumnName = {'XA'; 'YA'; 'ZA'};
            app.UITableObservation.RowName = {};
            app.UITableObservation.ColumnSortable = true;
            app.UITableObservation.Position = [6 294 288 131];

            % Create PreviewTabelLabel
            app.PreviewTabelLabel = uilabel(app.ProcessingPanel);
            app.PreviewTabelLabel.Position = [6 424 80 22];
            app.PreviewTabelLabel.Text = 'Preview Tabel';

            % Create WaterLevelEditFieldLabel
            app.WaterLevelEditFieldLabel = uilabel(app.ProcessingPanel);
            app.WaterLevelEditFieldLabel.HorizontalAlignment = 'right';
            app.WaterLevelEditFieldLabel.Position = [6 233 69 22];
            app.WaterLevelEditFieldLabel.Text = 'Water Level';

            % Create WaterLevelEditField
            app.WaterLevelEditField = uieditfield(app.ProcessingPanel, 'numeric');
            app.WaterLevelEditField.Position = [116 233 175 22];

            % Create RefractionIndexEditFieldLabel
            app.RefractionIndexEditFieldLabel = uilabel(app.ProcessingPanel);
            app.RefractionIndexEditFieldLabel.Position = [8 203 93 22];
            app.RefractionIndexEditFieldLabel.Text = 'Refraction Index';

            % Create RefractionIndexEditField
            app.RefractionIndexEditField = uieditfield(app.ProcessingPanel, 'numeric');
            app.RefractionIndexEditField.ValueDisplayFormat = '%.5f';
            app.RefractionIndexEditField.Position = [116 203 114 22];
            app.RefractionIndexEditField.Value = 1.337;

            % Create OptionButton
            app.OptionButton = uibutton(app.ProcessingPanel, 'push');
            app.OptionButton.ButtonPushedFcn = createCallbackFcn(app, @OptionButtonPushed, true);
            app.OptionButton.Position = [234 202 63 22];
            app.OptionButton.Text = 'Option';

            % Create ProcessButton
            app.ProcessButton = uibutton(app.ProcessingPanel, 'push');
            app.ProcessButton.ButtonPushedFcn = createCallbackFcn(app, @ProcessButtonPushed, true);
            app.ProcessButton.Position = [201 44 95 22];
            app.ProcessButton.Text = 'Process';

            % Create RefractionIndexPanel
            app.RefractionIndexPanel = uipanel(app.ProcessingPanel);
            app.RefractionIndexPanel.Title = 'Refraction Index';
            app.RefractionIndexPanel.Visible = 'off';
            app.RefractionIndexPanel.Position = [21 271 260 175];

            % Create SalinityEditFieldLabel
            app.SalinityEditFieldLabel = uilabel(app.RefractionIndexPanel);
            app.SalinityEditFieldLabel.Position = [5 124 63 22];
            app.SalinityEditFieldLabel.Text = 'Salinity(%)';

            % Create SalinityEditField
            app.SalinityEditField = uieditfield(app.RefractionIndexPanel, 'numeric');
            app.SalinityEditField.ValueDisplayFormat = '%.4f';
            app.SalinityEditField.Position = [175 124 74 22];
            app.SalinityEditField.Value = 34.998;

            % Create TemperatureCEditFieldLabel
            app.TemperatureCEditFieldLabel = uilabel(app.RefractionIndexPanel);
            app.TemperatureCEditFieldLabel.Position = [5 88 90 22];
            app.TemperatureCEditFieldLabel.Text = 'Temperature(C)';

            % Create TemperatureCEditField
            app.TemperatureCEditField = uieditfield(app.RefractionIndexPanel, 'numeric');
            app.TemperatureCEditField.ValueDisplayFormat = '%.2f';
            app.TemperatureCEditField.Position = [175 88 74 22];
            app.TemperatureCEditField.Value = 30;

            % Create WavelengthnmEditFieldLabel
            app.WavelengthnmEditFieldLabel = uilabel(app.RefractionIndexPanel);
            app.WavelengthnmEditFieldLabel.Position = [5 55 96 22];
            app.WavelengthnmEditFieldLabel.Text = 'Wavelength (nm)';

            % Create WavelengthnmEditField
            app.WavelengthnmEditField = uieditfield(app.RefractionIndexPanel, 'numeric');
            app.WavelengthnmEditField.ValueDisplayFormat = '%.2f';
            app.WavelengthnmEditField.Position = [175 55 74 22];
            app.WavelengthnmEditField.Value = 589.3;

            % Create CalculateButton
            app.CalculateButton = uibutton(app.RefractionIndexPanel, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.Position = [175 23 74 22];
            app.CalculateButton.Text = 'Calculate';

            % Create CorrectionMethodDropDownLabel
            app.CorrectionMethodDropDownLabel = uilabel(app.ProcessingPanel);
            app.CorrectionMethodDropDownLabel.HorizontalAlignment = 'right';
            app.CorrectionMethodDropDownLabel.Position = [1 169 104 22];
            app.CorrectionMethodDropDownLabel.Text = 'Correction Method';

            % Create CorrectionMethodDropDown
            app.CorrectionMethodDropDown = uidropdown(app.ProcessingPanel);
            app.CorrectionMethodDropDown.Items = {'-Please Select-', 'Small Angle ', 'Dietrich '};
            app.CorrectionMethodDropDown.ValueChangedFcn = createCallbackFcn(app, @CorrectionMethodDropDownValueChanged, true);
            app.CorrectionMethodDropDown.Position = [115 169 176 22];
            app.CorrectionMethodDropDown.Value = '-Please Select-';

            % Create ImportEOButton
            app.ImportEOButton = uibutton(app.ProcessingPanel, 'push');
            app.ImportEOButton.ButtonPushedFcn = createCallbackFcn(app, @ImportEOButtonPushed, true);
            app.ImportEOButton.Position = [6 135 98 22];
            app.ImportEOButton.Text = 'Import EO';

            % Create Eoedit
            app.Eoedit = uieditfield(app.ProcessingPanel, 'text');
            app.Eoedit.Position = [115 135 176 22];

            % Create ImportIOButton
            app.ImportIOButton = uibutton(app.ProcessingPanel, 'push');
            app.ImportIOButton.ButtonPushedFcn = createCallbackFcn(app, @ImportIOButtonPushed, true);
            app.ImportIOButton.Position = [6 93 98 22];
            app.ImportIOButton.Text = 'Import IO';

            % Create Ioedit
            app.Ioedit = uieditfield(app.ProcessingPanel, 'text');
            app.Ioedit.Position = [115 93 176 22];

            % Create ProcessButton_2
            app.ProcessButton_2 = uibutton(app.ProcessingPanel, 'push');
            app.ProcessButton_2.ButtonPushedFcn = createCallbackFcn(app, @ProcessButton_2Pushed, true);
            app.ProcessButton_2.Position = [201 11 95 22];
            app.ProcessButton_2.Text = 'Process';

            % Create TotalPointEditFieldLabel
            app.TotalPointEditFieldLabel = uilabel(app.ProcessingPanel);
            app.TotalPointEditFieldLabel.HorizontalAlignment = 'right';
            app.TotalPointEditFieldLabel.Position = [6 261 62 22];
            app.TotalPointEditFieldLabel.Text = 'Total Point';

            % Create TotalPointEditField
            app.TotalPointEditField = uieditfield(app.ProcessingPanel, 'numeric');
            app.TotalPointEditField.ValueDisplayFormat = '%.0f';
            app.TotalPointEditField.Position = [116 261 175 22];

            % Create UIAxes
            app.UIAxes = uiaxes(app.SFM);
            title(app.UIAxes, 'Preview Result')
            xlabel(app.UIAxes, 'Number Of Sample')
            ylabel(app.UIAxes, 'Elevation')
            app.UIAxes.Color = [0.302 0.7451 0.9333];
            app.UIAxes.Visible = 'off';
            app.UIAxes.BackgroundColor = [0.302 0.6196 0.6588];
            app.UIAxes.Position = [302 288 922 464];

            % Create DATAQCPanel
            app.DATAQCPanel = uipanel(app.SFM);
            app.DATAQCPanel.Title = 'DATA QC';
            app.DATAQCPanel.Position = [1 1 302 288];

            % Create ImportCorrectedPointCloudButton
            app.ImportCorrectedPointCloudButton = uibutton(app.DATAQCPanel, 'push');
            app.ImportCorrectedPointCloudButton.ButtonPushedFcn = createCallbackFcn(app, @ImportCorrectedPointCloudButtonPushed, true);
            app.ImportCorrectedPointCloudButton.Position = [6 177 165 34];
            app.ImportCorrectedPointCloudButton.Text = 'Import Corrected Point Cloud';

            % Create ImportCheckPointASCIIButton
            app.ImportCheckPointASCIIButton = uibutton(app.DATAQCPanel, 'push');
            app.ImportCheckPointASCIIButton.ButtonPushedFcn = createCallbackFcn(app, @ImportCheckPointASCIIButtonPushed, true);
            app.ImportCheckPointASCIIButton.Position = [6 83 165 34];
            app.ImportCheckPointASCIIButton.Text = 'Import Check Point (ASCII)';

            % Create NoteSelectedpointmustbeinsamehorizontalandverticaldatumLabel
            app.NoteSelectedpointmustbeinsamehorizontalandverticaldatumLabel = uilabel(app.DATAQCPanel);
            app.NoteSelectedpointmustbeinsamehorizontalandverticaldatumLabel.FontSize = 11;
            app.NoteSelectedpointmustbeinsamehorizontalandverticaldatumLabel.Position = [6 219 343 46];
            app.NoteSelectedpointmustbeinsamehorizontalandverticaldatumLabel.Text = 'Note : Selected point must be in same horizontal and vertical datum ';

            % Create Filename
            app.Filename = uieditfield(app.DATAQCPanel, 'text');
            app.Filename.Position = [8 142 286 22];

            % Create Checkname
            app.Checkname = uieditfield(app.DATAQCPanel, 'text');
            app.Checkname.Position = [5 50 286 22];

            % Create Process_Check
            app.Process_Check = uibutton(app.DATAQCPanel, 'push');
            app.Process_Check.ButtonPushedFcn = createCallbackFcn(app, @Process_CheckButtonPushed, true);
            app.Process_Check.Position = [167 11 124 22];
            app.Process_Check.Text = 'Process';

            % Create UIPlotCheck
            app.UIPlotCheck = uiaxes(app.SFM);
            title(app.UIPlotCheck, 'Title')
            xlabel(app.UIPlotCheck, 'X')
            ylabel(app.UIPlotCheck, 'Y')
            app.UIPlotCheck.Visible = 'off';
            app.UIPlotCheck.BackgroundColor = [0.302 0.6196 0.6588];
            app.UIPlotCheck.Position = [302 1 611 288];

            % Create RESULTPanel
            app.RESULTPanel = uipanel(app.SFM);
            app.RESULTPanel.Title = 'RESULT';
            app.RESULTPanel.Position = [912 1 312 288];

            % Create UITable
            app.UITable = uitable(app.RESULTPanel);
            app.UITable.ColumnName = {'X'; 'Y'; 'Z Data'; 'Z Check'; 'Distance'; 'Different'};
            app.UITable.RowName = {};
            app.UITable.Position = [1 153 303 112];

            % Create TOTALPOINTEditFieldLabel
            app.TOTALPOINTEditFieldLabel = uilabel(app.RESULTPanel);
            app.TOTALPOINTEditFieldLabel.HorizontalAlignment = 'right';
            app.TOTALPOINTEditFieldLabel.Position = [15 116 83 22];
            app.TOTALPOINTEditFieldLabel.Text = 'TOTAL POINT';

            % Create TOTALPOINTEditField
            app.TOTALPOINTEditField = uieditfield(app.RESULTPanel, 'numeric');
            app.TOTALPOINTEditField.Position = [194 116 104 22];

            % Create MEANEditFieldLabel
            app.MEANEditFieldLabel = uilabel(app.RESULTPanel);
            app.MEANEditFieldLabel.HorizontalAlignment = 'right';
            app.MEANEditFieldLabel.Position = [17 83 40 22];
            app.MEANEditFieldLabel.Text = 'MEAN';

            % Create MEANEditField
            app.MEANEditField = uieditfield(app.RESULTPanel, 'numeric');
            app.MEANEditField.Position = [194 83 104 22];

            % Create RMSEEditFieldLabel
            app.RMSEEditFieldLabel = uilabel(app.RESULTPanel);
            app.RMSEEditFieldLabel.HorizontalAlignment = 'right';
            app.RMSEEditFieldLabel.Position = [15 50 40 22];
            app.RMSEEditFieldLabel.Text = 'RMSE';

            % Create RMSEEditField
            app.RMSEEditField = uieditfield(app.RESULTPanel, 'numeric');
            app.RMSEEditField.Position = [192 50 104 22];

            % Create ExportButton
            app.ExportButton = uibutton(app.RESULTPanel, 'push');
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
            app.ExportButton.Position = [196 11 100 22];
            app.ExportButton.Text = 'Export';

            % Show the figure after all components are created
            app.SFM.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SCRIPT_GUI_SFM

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.SFM)

            % Execute the startup function
            runStartupFcn(app, @BEGIN)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.SFM)
        end
    end
end