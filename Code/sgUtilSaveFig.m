function sgUtilSaveFig(vFig,vTitle,vPos,vDpi)
    vFig.PaperUnits = 'inches';
    vFig.PaperPosition = vPos;
    outFname=sprintf("../Results/%s.png",vTitle);
    print(vFig,outFname,'-dpng',"-r"+vDpi);
    disp(sprintf("Saved figure: %s", outFname))
end
