    
%get ANT network scores, accuracy, and mean    ; don't forget to change
%session number
%get table (B) of only accurate trials
    groups = fieldnames(metrics);
    for group = 3
        field_1 = char(groups(group))
    %build code for getting field name
    for x = 12
        %only running for non-empty cells
         if ~isempty(metrics.(field_1)(x).S2)
        A = [metrics.(field_1)(x).S2.acc;metrics.(field_1)(x).S2.CN;metrics.(field_1)(x).S2.congruent;metrics.(field_1)(x).S2.rtime];
        T = rows2vars(array2table(A));
        T.Properties.VariableNames(1:5) = {'line','accuracy','condition_number','congruent','rtime'};
        columns = T.accuracy==1;
        B=T(columns,:);
        meanRTcorrect = mean(B.rtime)
         
        % get table (C) of only trials with mean within 3 SDVs
        beforemean=mean(B.rtime)
        beforesdv=std(B.rtime)
        columns = abs(B.rtime-beforemean)<=3*beforesdv;
        C=B(columns,:);
        
        %then get mean RT of accurate trials
        meanRTcorrect_nooutliers=mean(C.rtime)
       
        %calculate condition means - none
        columns = (C.condition_number)<6;
        none = C(columns,:);
        mean_none = mean(none.rtime)
        
        %calculate condition means - center
        columns = (C.condition_number)>6 & (C.condition_number)<12;
        center = C(columns,:);
        mean_center = mean(center.rtime)
        
        %calculate conditions means - spatial
        columns = (C.condition_number)>12;
        spatial = C(columns,:);
        mean_spatial = mean(spatial.rtime)
        
        %calculate conditions means - conruent
        columns = (C.congruent)==1;
        congruent = C(columns,:);
        mean_congruent = mean(congruent.rtime)
        
        %calculate conditions means - inconruent
        columns = (C.congruent)==0;
        incongruent = C(columns,:);
        mean_incongruent = mean(incongruent.rtime)
        
        %calculate alerting network
        alerting = mean_none-mean_center
        
        %calculate orienting network
        orienting = mean_center-mean_spatial
        
        %calculate executive network
        executive = mean_incongruent-mean_congruent
        
        %add new data elements to subject
        metrics.(field_1)(x).S2.alerting = alerting
        metrics.(field_1)(x).S2.orienting = orienting
        metrics.(field_1)(x).S2.executive = executive
        metrics.(field_1)(x).S2.meanRT_correct = meanRTcorrect
        metrics.(field_1)(x).S2.meanRT_correct_no3SD = meanRTcorrect_nooutliers
        
        
        %get correct, change X to subject number, don't forget to change
        %session number
        
for X=12
metrics.TBIATTN(X).S2.correct = sum(metrics.TBIATTN(X).S2.acc==1)
end
         end 
    end
    end
    