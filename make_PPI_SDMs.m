clear;
maindir = pwd;

subnums = [3 5 6 8 9 10 11 14 18 22 23 24 25 26 29 30 31 32 37 38 40 41 42 43 44];
runnums = 1:8;
roinums = [1 2 3 4 5 6];

for roi = 1:length(roinums)
    roinum = roinums(roi);
    outdir = fullfile(maindir,'output',['SDMs_roi' num2str(roinum)]);
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
    
    for s = 1:length(subnums)
        subnum = subnums(s);
        for r = 1:length(runnums)
            runnum = runnums(r);
            
            % missing runs
            % 41 - missing run 1
            % 42 - missing run 2 & 3
            % 40 - missing run 1 & 2 & 8
            
            if subnum == 29 && (runnum == 6)
                continue
            elseif subnum == 40 && (runnum == 1 || runnum == 2 || runnum == 8)
                continue
            elseif subnum == 41 && (runnum == 1)
                continue
            elseif subnum == 42 && (runnum == 2 || runnum == 3)
                continue
            elseif subnum == 8 && (runnum == 2 || runnum == 1)
                continue
            elseif subnum == 29 && (runnum == 1)
                continue   
            end
            
            
            
            
            % path to files
            if runnum == 6
                %weird naming quirk
                sdmfile = fullfile(maindir,'data','SDM_Task',['Subject' num2str(subnum) '_Run' num2str(runnum) '-S1R6_SCCTBL_3DMCTS_LTR_THPGLMF2c.sdm']);
            else
                sdmfile = fullfile(maindir,'data','SDM_Task',['Subject' num2str(subnum) '_Run' num2str(runnum) '-S1R1_SCCTBL_3DMCTS_LTR_THPGLMF2c.sdm']);
            end
            tsfile = fullfile(maindir,'data','VTC_Time_Course_Conjunction',['Subject' num2str(subnum) '_Run' num2str(runnum) '_TimeCourse.txt']);
            
            % load ts data and design. cols 1-7 in the sdm are the task
            fid = fopen(sdmfile,'r');
            C = textscan(fid,'%.6f%.6f%.6f%.6f%.6f%.6f%.6f%.6f%.6f%.6f%.6f%.6f%.6f%.6f','Headerlines', 9);
            D = [C{1} C{2} C{3} C{4} C{5} C{6} C{7} C{8} C{9} C{10} C{11} C{12} C{13} C{14}];
            fclose(fid);
            tsdata = load(tsfile); % this has 8 columns. that's a lot overlap. does the degree of overlap/similarity relate to individual differences in behavior?
            
            % make PPI
            tsdata = zscore(tsdata);
            phys = tsdata(:,roinum) - mean(tsdata(:,roinum)); % demean ts
            ppi_mat = zeros(length(phys),7); % we have 7 task regressors
            %ppi_mat = [];
            for i = 1:7
                ppi_mat(:,i) = phys .* D(:,i);
                % figure,plot(ppi_mat(:,i)) % always look at your data!
            end
            Dppi = [phys ppi_mat D];
            
            % write output SDM
            dummyfile = fullfile(maindir,'DummyHeader.sdm');
            outfile = fullfile(outdir,['Subject' num2str(subnum) '_Run' num2str(runnum) '_PPI_roi' num2str(roinum) '.sdm']);
            disp(dummyfile)
            disp(outfile)
            copyfile(dummyfile,outfile);
            dlmwrite(outfile,Dppi,'delimiter','\t','precision','%.6f','-append')
            
            
        end
    end
end

