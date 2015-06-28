function [Sample_Names, Grain_Size, Data]=Read_Data_Files(path, files, file_data, type_data)
%
% Function that reads in the various data files
%

% file_data is data common to all file types
% type_data is data for specific file formats

File_Type_Flag = file_data{1};
nfiles = file_data{2};

switch File_Type_Flag
    
    case 'Excel' % Excel
        
        XL_layout = type_data{1};
        SheetName = type_data{6};
        
        Sample_Names=[];
        Grain_Size=[];
        Data=[];
        
        for ii=1:nfiles
            
            if nfiles > 1
                [~, ~, all_data]=xlsread(strcat(path, files{1,ii}), SheetName, '', 'basic');
            else
                [~, ~, all_data]=xlsread(strcat(path, files), SheetName, '', 'basic');
            end
            
            if XL_layout == 1
                % Rows are specimens, Columns are sizes
                % type_data{2} - the row with grain sizes (number)
                % type_data{3} - the first column with grain sizes (letter)
                % type_data{4} - the last column with grain sizes (letter, maybe empty)
                % type_data{5} - the column with specimen IDs (letter)
                
                tmp_names = all_data(type_data{2}+1:end, col2num(type_data{5}));
                
                if isempty(type_data{4})
                    tmp_GS = all_data(type_data{2}, col2num(type_data{3}):end);
                    tmp_Data = all_data(type_data{2}+1:end, col2num(type_data{3}):end);
                else
                    tmp_GS = all_data(type_data{2}, col2num(type_data{3}):col2num(type_data{4}));
                    tmp_Data = all_data(type_data{2}+1:end, col2num(type_data{3}):col2num(type_data{4}));
                end
                                                
                % Check for and remove bad data
                % Check for extra "specimens" at the end that are not real
                % checks for NaNs from blank cells  checks for spaces in the spreadsheet
                To_remove = ~min(cellfun(@(x) ~max(isnan(x)), tmp_names), cellfun(@(x) ~strcmp(x, ' '), tmp_names) );
                tmp_names(To_remove) = [];
                Nspec=length(tmp_names);
                tmp_Data(Nspec+1:end, :)=[];                
                                
                % Check for and remove NaNs at the end of tmp_Data
                To_remove=sum(cellfun(@isnan, tmp_Data));
                tmp_GS(To_remove > 0)=[];
                tmp_Data(:, To_remove > 0)=[];
                
                % Convert to matrices
                tmp_Data = cell2mat(tmp_Data');
                tmp_GS = cell2mat(tmp_GS');
                
                % Put together and sort by ascending grain szie
                tmpvar = sortrows([tmp_GS, tmp_Data], 1);
                
                % Reshape for output
                tmp_Data = tmpvar(:,2:end)';
                tmp_GS = repmat(tmpvar(:,1), 1, Nspec);                
                
            elseif XL_layout == 2
                % Colums are specimens, Rows are grain sizes
                % type_data{2} - the row with specimen IDs (number)
                % type_data{3} - the first column with specimen IDs (letter)
                % type_data{4} - the last column with specimen IDs (letter, maybe empty)
                % type_data{5} - the column with grain size (letter)
                
                tmp_GS = all_data(type_data{2}+1:end, col2num(type_data{5}));
                
                if isempty(type_data{4})
                    tmp_names = all_data(type_data{2}, col2num(type_data{3}):end );
                    tmp_Data = all_data(type_data{2}+1:end, col2num(type_data{3}):end);
                else
                    tmp_names = all_data(type_data{2}, col2num(type_data{3}):col2num(type_data{4}) );
                    tmp_Data = all_data(type_data{2}+1:end, col2num(type_data{3}):col2num(type_data{4}));
                end
                                
                % Check for and remove bad data
                % Check for extra "specimens" at the end that are not real
                % checks for NaNs from blank cells  checks for spaces in the spreadsheet
                To_remove = ~min(cellfun(@(x) ~max(isnan(x)), tmp_names), cellfun(@(x) ~strcmp(x, ' '), tmp_names) );
                tmp_names(To_remove) = [];
                Nspec=length(tmp_names);
                tmp_Data(:, Nspec+1:end)=[];
                
                % Check for and remove NaNs at the end of tmp_Data
                To_remove=sum(cellfun(@isnan, tmp_Data'));
                tmp_GS(To_remove > 0)=[];
                tmp_Data(To_remove > 0, :)=[];
                
                % Convert to matrices
                tmp_Data = cell2mat(tmp_Data);
                tmp_GS = cell2mat(tmp_GS);
                
                % Put together and sort by ascending grain szie
                tmpvar = sortrows([tmp_GS, tmp_Data], 1);
                
                % Reshape the outputs
                tmp_GS = repmat(tmpvar(:,1), 1, Nspec);
                tmp_Data = tmpvar(:,2:end)';
                tmp_names = tmp_names';
                
            else
                error('ReadFile:XLSLayout', 'Unsupported Excel layout. [Should not be here]');
            end
            
            % Normalize the data to sum to one
            tmp_Data = bsxfun(@rdivide, tmp_Data, sum(tmp_Data,2) );
            
            Sample_Names = [Sample_Names; tmp_names]; %#ok<AGROW>
            Grain_Size = [Grain_Size,  tmp_GS]; %#ok<AGROW>
            Data = [Data; tmp_Data]; %#ok<AGROW>
            
            Data = num2cell(Data,2);
            Grain_Size = num2cell(Grain_Size,1);
            
        end
                
    case 'Coulter' % Original $LS Data file
        
        Sample_Names=cell(nfiles,1);
        Grain_Size=cell(1,nfiles);
        Data=cell(nfiles,1);
        
        for ii=1:nfiles
            
            if nfiles > 1
                FID=fopen(strcat(path, files{1,ii}));
                split_name=regexp(files{1,ii}, '\.', 'split');
            else
                FID=fopen(strcat(path, files));
                split_name=regexp(files, '\.', 'split');
            end
            
            % Check the smples names and add in any extra dots that may be
            % missing
            if length(split_name(1:end-1)) >1
                Sample_Names(ii,1)={strjoin(split_name(1:end-1), '.')};
            else
                Sample_Names(ii,1)=split_name(1);
            end
            
            GS_start=0;
            Data_start=0;
            
            tline=fgetl(FID);
            y=1;
            while ischar(tline)
                tline=fgetl(FID);
                y=y+1;
                if strcmp(tline, '[#Bindiam]')
                    GS_start=y;
                end
                
                if strcmp(tline, '[#Binheight]')
                    Data_start=y;
                end
                
                if GS_start > 0 && Data_start > 0
                    % we have the data we need skip the rest
                    break
                end
                
            end
            
            % reset the read position back to the start of the file
            frewind(FID);
            
            if GS_start < Data_start
                
                tmp_input=textscan(FID, '%f', 'HeaderLines', GS_start);
                tmp_GS=tmp_input{1,1};
                
                HL=Data_start-(GS_start+length(tmp_GS)); % Get the nex header lines to skip
                
                tmp_input=textscan(FID, '%f', 'HeaderLines', HL);
                tmp_Data=tmp_input{1,1}./sum(tmp_input{1,1});
                
            else
                
                tmp_input=textscan(FID, '%f', 'HeaderLines', Data_start);
                tmp_Data=tmp_input{1,1}./sum(tmp_input{1,1});
                
                HL=GS_start-(Data_start+length(tmp_Data)); % Get the nex header lines to skip
                
                tmp_input=textscan(FID, '%f', 'HeaderLines', HL);
                tmp_GS=tmp_input{1,1};
                
            end
            
            fclose(FID);
                        
            % Sort by ascending grain size
            tmpvar = sortrows([tmp_GS, tmp_Data], 1);
            tmp_GS = tmpvar(:,1);
            tmp_Data  = tmpvar(:,2);
            
            Grain_Size(1,ii)={tmp_GS};
            Data(ii,1)={tmp_Data'};
            
        end
        
        fclose all;
        
    case 'SALD'
        
        Sample_Names=cell(nfiles,1);
        Grain_Size=cell(1,nfiles);
        Data=cell(nfiles,1);
        
        for ii=1:nfiles
            
            if nfiles > 1
                FID=fopen(strcat(path, files{1,ii}));
                split_name=regexp(files{1,ii}, '\.', 'split');
            else
                FID=fopen(strcat(path, files));
                split_name=regexp(files, '\.', 'split');
            end
            
            % Check the smples names and add in any extra dots that may be
            % missing
            if length(split_name(1:end-1)) >1
                Sample_Names(ii,1)={strjoin(split_name(1:end-1), '.')};
            else
                Sample_Names(ii,1)=split_name(1);
            end
            
            tline=fgetl(FID);
            while ischar(tline)
                tline=fgetl(FID);
                if strcmp(tline(1:4), 'PSD1')
                    break;
                end
            end
            
            tmp_input = textscan(FID, '%f %f %f', 'Delimiter', ':');
            
            tmp_GS=tmp_input{1};
            tmp_Data=tmp_input{3}./sum(tmp_input{3});
            
            fclose(FID);
            
            % Set to the output variables
            % sort by ascending grain size
            tmp_var = [tmp_GS, tmp_Data];
            tmp_var = sortrows(tmp_var, 1);
            
            Grain_Size(1,ii)={tmp_var(:,1)};
            Data(ii,1)={tmp_var(:,2)'};
                        
        end
        
        fclose all;
        
    case 'MicroTrac'
        
        % Set up empty cells to grow
        Sample_Names={};
        Grain_Size={};
        Data={};
        
        for ii=1:nfiles
            
            if nfiles > 1
                FID=fopen(strcat(path, files{1,ii}));
            else
                FID=fopen(strcat(path, files));
            end
            
            % Read the first line to get the header and data indices
            L1 = fgetl(FID);
            Header = textscan(L1, '%s', 'Delimiter', ',');
            nCols = length(Header{1});
            
            % The indices where the grain sizes and data are stored
            GS_Inds = cell2mat(cellfun(@(x) strcmpi(x(1:5), 'Size:'), Header{1}, 'UniformOutput', 0));
            Data_Inds = cell2mat(cellfun(@(x) strcmpi(x(1:5), 'PctCh'), Header{1}, 'UniformOutput', 0));
                        
            % Make the data format string
            fmt = '%d %s ';
            fmt = strcat(fmt, repmat('%f ', 1, nCols-3) );
            fmt = strcat(fmt, '%f');
            
            % Read the next line and process it
            tline=fgetl(FID);
            while ischar(tline)
                tmp_input = textscan(tline, fmt, 'Delimiter', ',');
                
                % Sort the data by ascending grain size
                tmp_var = [cell2mat(tmp_input(GS_Inds))', cell2mat(tmp_input(Data_Inds))'];
                tmp_var = sortrows(tmp_var, 1);
                
                % Sum-to-one
                tmp_var(:,2) = tmp_var(:,2) ./ sum(tmp_var(:,2));
                
                % Put into the output cells
                Grain_Size=[Grain_Size, {tmp_var(:,1)} ]; %#ok<AGROW>
                Data = [Data; {tmp_var(:,2)'} ]; %#ok<AGROW>
                Sample_Names= [ Sample_Names; tmp_input{1,2}]; %#ok<AGROW>
                
                % Read the next line
                tline=fgetl(FID);
                
            end
            
            fclose(FID);
                        
        end
        
        fclose all;
        
    case 'Cilas'
        
        Sample_Names=cell(nfiles,1);
        Grain_Size=cell(1,nfiles);
        Data=cell(nfiles,1);
        
        for ii=1:nfiles
            
            if nfiles > 1
                FID=fopen(strcat(path, files{1,ii}));
                split_name=regexp(files{1,ii}, '\.', 'split');
            else
                FID=fopen(strcat(path, files));
                split_name=regexp(files, '\.', 'split');
            end
            
            % Check the smples names and add in any extra dots that may be
            % missing
            if length(split_name(1:end-1)) >1
                Sample_Names(ii,1)={strjoin(split_name(1:end-1), '.')};
            else
                Sample_Names(ii,1)=split_name(1);
            end
            
            tmp_input = textscan(FID, '%f', 1, 'HeaderLines', 29);
            nVar = tmp_input{1};
            
            tmp_input = textscan(FID, '%f', 'HeaderLines', 3);
            tmp_input = tmp_input{1}; % get a vector
            
            tmp_GS = tmp_input(end-2*nVar:end-nVar);
            tmp_CDF = [0; tmp_input(end-nVar+1:end)]; % this is a CDF
            
            % Sort by ascending grain size
            tmpvar = sortrows([tmp_GS, tmp_CDF], 1);
            tmp_GS = tmpvar(:,1);
            tmp_Data = [0; gradient(tmpvar(2:end,2), log(tmp_GS(2:end)))]; % Get the PDF
            tmp_Data = tmp_Data./sum(tmp_Data); % Sum-to-one
            
            fclose(FID);
            
            Grain_Size(1,ii)={tmp_GS};
            Data(ii,1)={tmp_Data'};
        end
        
        fclose all;
        
    case 'Delimited'
        
        % Check the delimiters and multispecimen flag
        Delimiter = type_data{1};
        MS_flag = type_data{2};
        
        if MS_flag == 1
            
            switch Delimiter
                
                case 'Tab'
                    delim = '\t';
                case 'Space'
                    delim = '\s';
                case 'Comma'
                    delim = ',';
                otherwise
                    error('ReadFile:FileType', 'Unsupported delimiter. [Should not be here]');
            end
            
            % Set up empty cells to grow
            Sample_Names={};
            Grain_Size={};
            Data={};
            
            for ii=1:nfiles
                
                if nfiles > 1
                    FID=fopen(strcat(path, files{1,ii}));
                else
                    FID=fopen(strcat(path, files));
                end
                
                % Read the first line to get the header and number of lines
                L1 = fgetl(FID);
                Header = textscan(L1, '%s', 'Delimiter', delim);
                N = length(Header{1});
                
                % Make the data format string
                fmt = repmat(strcat('%f',delim), 1, N-1);
                fmt = strcat(fmt, '%f\n');
                
                input = textscan(FID, fmt);
                fclose(FID);
                
                T = cell2mat(input);
                T(:,sum(isnan(T))>0, :)=[]; % Remove NaN, which arise from over reading headers with extra spaces
                T = sortrows(T, 1); % sort by ascending grain size
                GS = T(:,1);
                D = T(:,2:end)';
                D = bsxfun(@rdivide, D, sum(D,2)); % sum-to-one
                [Nspec, nVar] = size(D); % number of specimens
                                
                Grain_Size = [Grain_Size, repmat({GS}, 1, Nspec)]; %#ok<AGROW>
                Data = [Data; mat2cell(D, ones(1,Nspec), nVar)]; %#ok<AGROW>
                
                % Remove the grain size lable
                Header{1}(1:N-Nspec)=[];
                
                Sample_Names = [Sample_Names; Header{1}]; %#ok<AGROW>
                
            end
            
            % make sure everything is closed
            fclose all;
            
        else % single specimen per file
            
            switch Delimiter
                
                case 'Tab'
                    scan_format = '%f\t%f';
                case 'Space'
                    scan_format = '%f\s%f';
                case 'Comma'
                    scan_format = '%f,%f';
                otherwise
                    error('ReadFile:FileType', 'Unsupported delimiter. [Should not be here]');
            end
            
            Sample_Names=cell(nfiles,1);
            Grain_Size=cell(1,nfiles);
            Data=cell(nfiles,1);
            
            for ii=1:nfiles
                
                if nfiles > 1
                    FID=fopen(strcat(path, files{1,ii}));
                    split_name=regexp(files{1,ii}, '\.', 'split');
                else
                    FID=fopen(strcat(path, files));
                    split_name=regexp(files, '\.', 'split');
                end
                
                % Check the smples names and add in any extra dots that may be
                % missing
                if length(split_name(1:end-1)) >1
                    Sample_Names(ii,1)={strjoin(split_name(1:end-1), '.')};
                else
                    Sample_Names(ii,1)=split_name(1);
                end
                
                input = textscan(FID, scan_format, 'HeaderLines', 1);
                
                % Normalize the data to sum-to-one
                tmp_var = cell2mat(input);
                
                % sort by ascending grain size
                tmp_var = sortrows(tmp_var, 1);
                                
                Grain_Size(1,ii) = {tmp_var(:,1)};
                Data(ii,1) = {tmp_var(:,2)'./sum(tmp_var(:,2))};
                
                fclose(FID);
            end
            
            fclose all;
            
        end % end MS_flag if
        
    otherwise
        error('ReadFile:FileType', 'Unsupported file type. [should be caught before here]');
end



function A = col2num(b)
%
% Function to convert an Excel letter column reference to an integer
%

if ~ischar(b)
    warning('col2num:Input', 'Non-character input is not supported.');
end

% convert to double and set to be between 1 and 26
b = double(upper(b)) - 64;
n = length(b);
A = b * 26.^((n-1):-1:0)';

