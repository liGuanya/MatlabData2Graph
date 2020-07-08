%Import *.ffe(monoRCS) from dir specified
%Extract key data and save as Origin data format (2D and 3D).
%Show and export the 2D and 3D graph.
%Function strcell() writeCellTo() setLinWidth()   plot3D()    filtLine()
%20200519
clear;clc;tic;
org2dFlag=1;org3dFlag=1;
grp2dFlag=1;grp3dFlag=1;
ffeDir='E:\ZM\0Work\3simuModel\20200416simlationModel\';
resultDir=[ffeDir,'ffe2Origin\'];
if  exist(resultDir,'dir')
    delete([resultDir,'\*'])
else
    mkdir(resultDir)
end
% Exract lines only exist numbers to txt file from ffe file
ffeListOb=dir([ffeDir,'*.ffe']);
ffeFoldnames={ffeListOb.folder};
ffeNames={ffeListOb.name};
ffeLongNames=fullfile(ffeFoldnames,ffeNames);
[ffeFiltFolder,ffeFiltLNames]=filtLine(ffeLongNames,'#','filtData');
%%%%%%%%%%%%%%%%%
% outPic=1;%输出图片
% outData=1;%输出数据
% modelName='';
% nTheta=3;%theta角的个数,即第一列相同的数值出现的次数
nTxt=length(ffeFiltLNames);count=0;
for longNameCell=ffeFiltLNames'
    longName=longNameCell{1};
    [~,simName,~]=fileparts(longName);
% for txtName=txtNames'
%     txtNameCh=char(txtName);
%     longName=[txtDir,txtNameCh];
%     simName=txtNameCh(1:end-4);
    f0=simName(strfind(simName,'Fre')+3:strfind(simName,'M')-1);
    obTxt=importdata(longName);
    data=obTxt.data(:,[1,2,end]);
    thetaVec=unique(data(:,1));phiVec=unique(data(:,2));
    nT=length(thetaVec);nP=length(phiVec);
    rcs=reshape(data(:,3),[nT,nP]);%Different theta for each same column, different phi for each same row.
    rcsDB=10.*log(rcs)./log(10);
    vThetaMat=zeros(nT,2*nP);
    vThetaMat(:,1:2:end-1)=rcs;vThetaMat(:,2:2:end)=rcsDB;%independent variate is theta
    vPhiMat=zeros(nP,2*nT);
    vPhiMat(:,1:2:end-1)=rcs';vPhiMat(:,2:2:end)=rcsDB';%independent variate is phi
    %%% Data header
    %   LongName	Theta           RCS     RCS         ...
    %   Units	    Deg             m^2     dBsm        ...
    %   Comments	Frquency=1GHz	Phi=0	Phi=0       ...
    elem2ThetaVec=repelem(thetaVec,2);elem2PhiVec=repelem(phiVec,2);
    theta2Str=cellstr(num2str(elem2ThetaVec,'%-.1f'));phi2Str=cellstr(num2str(elem2PhiVec,'%-.1f'));
    vThetaComments=cellfun(@strcat,cellstr(repmat('Phi=',size(phi2Str))),phi2Str, 'UniformOutput',false)';
    vPhiComments=cellfun(@strcat,cellstr(repmat('Theta=',size(theta2Str))),theta2Str, 'UniformOutput',false)';
    vThetaUnits=repmat({'m^2','dBsm'},1,nP);    vPhiUnits=repmat({'m^2','dBsm'},1,nT);
    vThetaDpName=repmat({'RCS'},1,nP*2);    vPhiDpName=repmat({'RCS'},1,nT*2);
    vThetaHeader={'Theta';'Deg';['Frequency=',f0,'MHz']};
    vPhiHeader={'Phi';'Deg';['Frequency=',f0,'MHz']};
    vThetaHeader(:,2:1+nP*2)=[vThetaDpName;vThetaUnits;vThetaComments];
    vPhiHeader(:,2:1+nT*2)=[vPhiDpName;vPhiUnits;vPhiComments];
    %%%Produce 2D 3D data for Origin
    vTheta2D=vThetaHeader;
    vTheta2D(4:3+nT,:)=num2cell([thetaVec,vThetaMat]);
    vPhi2D=vPhiHeader;
    vPhi2D(4:3+nP,:)=num2cell([phiVec,vPhiMat]);
    rcs3D=num2cell([0,phiVec';thetaVec,rcs]);
    rcs3D(1,1)={'Theta\Phi'};
    rcsDB3D=num2cell([0,phiVec';thetaVec,rcsDB]);
    rcsDB3D(1,1)={'Theta\Phi'};
    %%%Export 2D 3D data for Origin
    writeCellTo(resultDir,[simName,'(vTheta2D).txt'],vTheta2D);
    writeCellTo(resultDir,[simName,'(vPhi2D).txt'],vPhi2D);
    writeCellTo(resultDir,[simName,'(dB3D).txt'],rcsDB3D);
    writeCellTo(resultDir,[simName,'(3D).txt'],rcs3D);
    
    %%%Plot 2D and 3D graph
    clf;
    figHd=gcf;
    figHd.Name=simName;
    subplot(2,2,1);
    vThetaHd=plot(thetaVec,rcsDB);%Each column as a line
    setLineWidth(vThetaHd,1.5);
    fontName='Times New Roman';fontWeight='bold';
    title(['Frequency=',f0,'MHz'],'FontName',fontName,'fontWeight',fontWeight);
    xlabel('Theta(Deg)','FontName',fontName,'fontWeight',fontWeight);
    ylabel('RCS(dBsm)','FontName',fontName,'fontWeight',fontWeight);
    vThetaAx=gca;set(vThetaAx,'FontName',fontName,'fontWeight',fontWeight);
    legend(vThetaComments(1:2:end-1),'location','bestoutside');
%     vThetaAx.FontName='Times New Roman';vThetaAx.FontWeight='bold';
    subplot(2,2,2);
    vThetaHd=plot(phiVec,rcsDB');%Each column as a line
    setLineWidth(vThetaHd,1.5);
    fontName='Times New Roman';fontWeight='bold';
    title(['Frequency=',f0,'MHz'],'FontName',fontName,'fontWeight',fontWeight);
    xlabel('Phi(Deg)','FontName',fontName,'fontWeight',fontWeight);
    ylabel('RCS(dBsm)','FontName',fontName,'fontWeight',fontWeight);    
    vThetaAx=gca;set(vThetaAx,'FontName',fontName,'fontWeight',fontWeight);  
    legend(vPhiComments(1:2:end-1),'location','bestoutside');
%     vThetaAx.FontName='Times New Roman';vThetaAx.FontWeight='bold';
    subplot(2,2,3);
    [thetaGrid,phiGrid]=ndgrid(thetaVec,phiVec);
    [picHd,axHd,cbHd]=plot3D(thetaGrid,phiGrid,rcs,rcs);
    title(['Frequency=',f0,'MHz'],'fontName',fontName,'fontWeight',fontWeight);
    xlabel('Theta(deg)','fontName',fontName,'fontWeight',fontWeight);
    ylabel('Phi(deg)','fontName',fontName,'fontWeight',fontWeight);
    set(axHd,'fontName',fontName,'fontWeight',fontWeight);
    cbHd.Label.String='m^2';set(cbHd,'fontName',fontName,'fontWeight',fontWeight);
    
    subplot(2,2,4);
    [picHdDB,axHdDB,cbHdDB]=plot3D(thetaGrid,phiGrid,rcsDB,rcsDB);
    title(['Frequency=',f0,'MHz'],'fontName',fontName,'fontWeight',fontWeight);
    xlabel('Theta(deg)','fontName',fontName,'fontWeight',fontWeight);
    ylabel('Phi(deg)','fontName',fontName,'fontWeight',fontWeight);
    set(axHdDB,'fontName',fontName,'fontWeight',fontWeight);
    cbHdDB.Label.String='dBsm';set(cbHdDB,'fontName',fontName,'fontWeight',fontWeight);
    
%     gcf.OuterPosition=get(0,'screensize');
    set(gcf,'outerposition',get(0,'screensize'));
%     figHd=gcf;
    frame=getframe(figHd);
    imwrite(frame.cdata,[resultDir,simName,'(2D_3D).bmp']);     
    
    count=count+1;
    fprintf('\n## %d of %d Done.\n',count,nTxt);
end
disp('Program Done!');toc;
sound(sin(2*pi*25*(1:4000)/500));
