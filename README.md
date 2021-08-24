# sgstea
Smartgrid Simulator for Techno-Economic Analysis

The simulator is created in Matlab R2021a.
Simulator was written from scratch (does not usee any simulink, simscape, simscape electrical, ... )
Simulator has lot of demos that (partially based on demo data files) show thee functionality.
The simulator does the technical analysis and economical analysis
Actually supported core components:
  a) electrical network model
  b) battery models (basic models for PowerWall, Supercapacitors, Hybrid Batteries)
  c) consumer model (based on profile)
Basic concepts:
1) we run the whole microgrid or it part in the "simulation time" (e.g. one month, one year, ... in precise 15 minute steps)
2) afterwards, based on "simulation time" results, we can run the extended economical analysis is "economic time" and compute overall OPEX, CAPEX including deprecation models, Return Of Investments (RoI). Default setting is analysis in 15 years.  

THe structure of repository is as follows:
1) Code - matlab classes, all files have prefix "sg" (meaning SmartGrid), there is lot of demo classes with prefix "sgDemo"
2) Data - example of input data (needed fom some demos)
3) Results - results directory with some examples of generated images/results


