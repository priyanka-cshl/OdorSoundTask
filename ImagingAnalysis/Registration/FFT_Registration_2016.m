clear all
clc


%d(1).name= '/Volumes/PGUPTA_3KFC/02032017/1/a.roi/';
d(1).name= '/Volumes/Albeanu-Norepl/Photoncerber/Plane1/';

%'C:/...'; % Add the raw data directory here
                     % If more than one directory, make a struct in which
                     % each d(i).name is the name of the directory


for l = 1:size(d,2)
    data_dir = d(l).name;

    cd(data_dir);
    mkdir ('reg'); %makes a subfolder in the raw data path where the registered files will go into
    files_to_analyze=dir('*TC*Gr.tif'); %this line looks for the GREEN channel files. If registering red change to *TC*Rd.tif
    reg_image = '/MED.tif'; % the scrip looks for the MED.tif (median image file created in ImageJ) in the raw data folder
                            % THIS IS VERY IMPORTANT!!!!, if there is no
                            % Median image in there, it won't trun
                            
    for file_counter=1:length(files_to_analyze) % cycle through all the files in the folder
        
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
    
    pause(0.2)
    
    file_counter
    
        end
   end