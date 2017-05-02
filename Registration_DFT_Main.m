function varargout = Registration_DFT_Main(varargin)
% REGISTRATION_DFT_MAIN MATLAB code for Registration_DFT_Main.fig
%      REGISTRATION_DFT_MAIN, by itself, creates a new REGISTRATION_DFT_MAIN or raises the existing
%      singleton*.
%
%      H = REGISTRATION_DFT_MAIN returns the handle to a new REGISTRATION_DFT_MAIN or the handle to
%      the existing singleton*.
%
%      REGISTRATION_DFT_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTRATION_DFT_MAIN.M with the given input arguments.
%
%      REGISTRATION_DFT_MAIN('Property','Value',...) creates a new REGISTRATION_DFT_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Registration_DFT_Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Registration_DFT_Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Registration_DFT_Main

% Last Modified by GUIDE v2.5 30-Apr-2017 17:43:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Registration_DFT_Main_OpeningFcn, ...
    'gui_OutputFcn',  @Registration_DFT_Main_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Registration_DFT_Main is made visible.
function Registration_DFT_Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Registration_DFT_Main (see VARARGIN)

% Choose default command line output for Registration_DFT_Main
handles.output = hObject;
handles.filelist = [];
% reposition GUI
movegui(hObject,'northwest');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Registration_DFT_Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Registration_DFT_Main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SetUpSession_CLEAR.
function SetUpSession_CLEAR_Callback(hObject, eventdata, handles)
% hObject    handle to SetUpSession_CLEAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.SetUpSession_TotalSessions.Data(1) > 0
    handles.SetUpSession_TotalSessions.Data = [0 0 0 0]';
    handles.session_list.Value = 1;
    %handles.filelist = [];
    handles.session_list.String = {' '};
    guidata(hObject, handles);
end

% --- Executes on button press in ClearLast.
function ClearLast_Callback(hObject, eventdata, handles)
% hObject    handle to ClearLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.SetUpSession_TotalSessions.Data(1) > 0
    handles.session_list.Value = 1;
    y = handles.SetUpSession_TotalSessions.Data(1);
    handles.SetUpSession_TotalSessions.Data(1) = handles.SetUpSession_TotalSessions.Data(1) - 1;
    %handles.filelist(y) = [];
    handles.session_list.String(y) = [];
    guidata(hObject, handles);
end

% --- Executes on button press in SetUpSession_AddNew.
function SetUpSession_AddNew_Callback(hObject, eventdata, handles)
% hObject    handle to SetUpSession_AddNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
X = uigetfile_n_dir('F:\ImageData','Select experimental session folder');
if ~isempty (X)
    handles.SetUpSession_TotalSessions.Data(1) = handles.SetUpSession_TotalSessions.Data(1) + 1;
    y = handles.SetUpSession_TotalSessions.Data(1);
    %handles.filelist(y) = X;
    handles.session_list.String(y:y+size(X,2)-1) = X;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in RegisterNow.
function RegisterNow_Callback(hObject, eventdata, handles)

set(hObject,'BackgroundColor','cyan','String','running ...');
pause(0.5);
guidata(hObject, handles);
display('starting registration...');

%% RUN THE PIPELINE HERE (code from Pedro)
for l = 1:handles.SetUpSession_TotalSessions.Data(1) % all directories
    data_dir = char(handles.session_list.String(l,:));
    cd(data_dir);
    
    % check if median file exists
    if exist('MED.tif','file')
        handles.session_list.Value = l;
        handles.SetUpSession_TotalSessions.Data(2) = l;
        if ~exist('reg','dir')
            mkdir ('reg'); %makes a subfolder in the raw data path where the registered files will go into
        end
        
        if handles.GreenChannel.Value
            files_to_analyze=dir('*TC*Gr.tif'); %this line looks for the GREEN channel files. If registering red change to *TC*Rd.tif
        else
            files_to_analyze=dir('*TC*Rd.tif');
        end
        reg_image = '/MED.tif'; % the scrip looks for the MED.tif (median image file created in ImageJ) in the raw data folder
        % THIS IS VERY IMPORTANT!!!!, if there is no
        % Median image in there, it won't trun
        handles.SetUpSession_TotalSessions.Data(3) = length(files_to_analyze);
        
        for file_counter=1:length(files_to_analyze) % cycle through all the files in the folder
            handles.SetUpSession_TotalSessions.Data(4) = file_counter;
            filetoRead = files_to_analyze(file_counter).name; % index all the files to analyze
            cd(data_dir);
            
            a_index=strfind(filetoRead,'A'); % legacy, not important
            o_index=strfind(filetoRead,'_O'); % legacy, not important
            s_index=strfind(filetoRead,'_S'); % legacy, not important
            repeat_index=strfind(filetoRead,'trial_'); % legacy, not important
            odor_index=strfind(filetoRead,'type_'); % legacy, not important
            
            nair_frames=str2double(filetoRead((a_index+1):(a_index+2)));% legacy, not important
            nodor_frames=str2double(filetoRead((o_index+2):(o_index+3)));% legacy, not important
            nrepeat=str2double(filetoRead((repeat_index+6):(repeat_index+8)));% legacy, not important
            nodor=str2double(filetoRead((odor_index+5)));% legacy, not important
            nsair_frames=str2double(filetoRead((s_index+2):(s_index+3)));% legacy, not important
            targetimage=strcat(data_dir,reg_image);% legacy, not important
            f=imread(targetimage); %reads the image
            
            maskedfilename=['RT_ROI_0_trial_' num2str(nrepeat,'%03d') '_type_' num2str(nodor) '_A' num2str(nair_frames)...
                '_O' num2str(nodor_frames) '_S' num2str(nsair_frames) '_Gr.tif']; % naming files
            
            xyfilename=['xy_ROI_0_trial_' num2str(nrepeat,'%03d') '_type_' num2str(nodor) '_A' num2str(nair_frames) ...
                '_O' num2str(nodor_frames) '_S' num2str(nsair_frames) '.mat']; % naming files
            
            movement_filename=['mv_ROI_0_trial_' num2str(nrepeat,'%03d') '_type_' num2str(nodor) '_A' num2str(nair_frames)...
                '_O' num2str(nodor_frames) '_S' num2str(nsair_frames) '.mat']; % naming files
            
            xy_coordinate=zeros(nair_frames+nodor_frames+nsair_frames,4); % housekeeping
            tiftag = imfinfo(filetoRead); % housekeeping
            maskedimage=zeros(tiftag(1).Height,tiftag(1).Width,length(tiftag)); % housekeeping
            newimage=zeros(tiftag(1).Height,tiftag(1).Width,length(tiftag)); % housekeeping
            
            air_mean=double(zeros(tiftag(1).Height,tiftag(1).Width)); % housekeeping
            odor_mean=double(zeros(tiftag(1).Height,tiftag(1).Width)); % housekeeping
            sair_mean=double(zeros(tiftag(1).Height,tiftag(1).Width)); % housekeeping
            
            rawimage=zeros(tiftag(1).Height,tiftag(1).Width,nair_frames+nodor_frames+nsair_frames);
            
            for i=1:nair_frames+nodor_frames+nsair_frames;
                g=imread(filetoRead,i);
                rawimage(:,:,i)=g;
                [output Greg]=dftregistration(fft2(f),fft2(g),100); %this is the actual registration step
                newimage(:,:,i)=abs(ifft2(Greg));
                xy_coordinate(i,:)=output;
                mask=ones(size(g,1),size(g,2));
                xshift=abs(floor(output(3)));
                yshift=abs(floor(output(4)));
                
                
                if  xshift > 0 && output(3) >0
                    mask(1:xshift,:)=0;
                elseif xshift >0 && output(3) <0
                    mask(size(g,1)-xshift+1: size(g,1),:)=0;
                end
                
                if  yshift > 0 && output(4) >0
                    mask(:,1:yshift)=0;
                elseif yshift >0 && output(4) <0
                    mask(:,size(g,2)-yshift+1: size(g,2))=0;
                end
                
                maskedimage(:,:,i)=mask.*newimage(:,:,i);
                
                if i<=nair_frames
                    air_mean=air_mean+maskedimage(:,:,i);
                end
                
                if i>nair_frames && i<=nair_frames+nodor_frames
                    odor_mean=odor_mean+maskedimage(:,:,i);
                end
                
                if i>nair_frames+nodor_frames
                    sair_mean=sair_mean+maskedimage(:,:,i);
                end
                
            end
            
            air_od_ratio=ones(tiftag(1).Height,tiftag(1).Width)*65356-(odor_mean/nodor_frames)./(air_mean/nair_frames)*32678;
            od_sair_ratio=ones(tiftag(1).Height,tiftag(1).Width)*65356-(sair_mean/nsair_frames)./(odor_mean/nodor_frames)*32678;
            
            cd('reg');
            pause(0.1);
            
            for K=1:nair_frames+nodor_frames+nsair_frames
                imwrite(uint16(maskedimage(:, :, K)), maskedfilename, 'WriteMode', 'append','Compression','none');
            end
            
            pause(0.1);
            
        end
    else
        display('MED.tif not found, skipping to next directory');
    end
end
display('done!');
set(hObject,'BackgroundColor',[0.9400 0.9400 0.9400],'String','GO');
pause(0.5);
guidata(hObject, handles);

function WhichChannel_Callback(hObject, eventdata, handles)
switch hObject.String
    case 'Green Channel'
        handles.RedChannel.Value = ~handles.GreenChannel.Value;
    case 'Red Channel'
        handles.GreenChannel.Value = ~handles.RedChannel.Value;
end
