function Data = Append_EM_Vars(Old, New)
%
% Appends the parametric end member fits to previous fits
%
% Input:
%       Old - the old fit data
%       New - the new fit data
%
% Output:
%       Data - the amalgamated data
%

%% Begin...

% Get some basic sizes and values
nData = size(Old.Spec_Angle, 1);
nParam = size(Old.Params{Old.EM_Max}, 2);
Global_Max = max(Old.EM_Max, New.EM_Max);


% Create a structure with empty arrays/cells of the correct size
Data.DataSet_R2 = NaN(Global_Max, 1);
Data.Spec_R2 = NaN(nData, Global_Max);
Data.DataSet_Angle = NaN(Global_Max, 1);
Data.Spec_Angle= NaN(nData, Global_Max);
Data.EM_R2 = NaN(Global_Max, 1);
Data.EM_Min = 1;
Data.EM_Max = Global_Max;
Data.Params = cell(Global_Max, 1);


% Add in the old data
Inds = Old.EM_Min:Old.EM_Max; % indices to access the old data

Data.DataSet_R2(Inds) = Old.DataSet_R2(Inds);
Data.Spec_R2(:, Inds) = Old.Spec_R2(:,Inds);
Data.Mean_Angle(Inds) = Old.DataSet_Angle(Inds);
Data.Spec_Angle(:, Inds)= Old.Spec_Angle(:,Inds);
Data.EM_R2(Inds) = Old.EM_R2(Inds);
Data.Params(Inds) = Old.Params(Inds);


% Add in the new data, which will overwite the old data
Inds = New.EM_Min:New.EM_Max; % indices to access the old data

Data.DataSet_R2(Inds) = New.DataSet_R2(Inds);
Data.Spec_R2(:, Inds) = New.Spec_R2(:,Inds);
Data.DataSet_Angle(Inds) = New.DataSet_Angle(Inds);
Data.Spec_Angle(:, Inds)= New.Spec_Angle(:,Inds);
Data.EM_R2(Inds) = New.EM_R2(Inds);
Data.Params(Inds) = New.Params(Inds);

