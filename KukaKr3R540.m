classdef UR3 < RobotBaseClass
    %% KUKA KR3 R540 payload robot model
    %
    % WARNING: This model has been created by UTS students in the subject
    % 41013. No guarentee is made about the accuracy or correctness of the
    % of the DH parameters of the accompanying ply files. Do not assume
    % that this matches the real robot!

    properties(Access = public)   
        plyFileNameStem = 'KukaKr3R540';
    end
    
    methods
%% Constructor
        function self = KukaKr3(baseTr,useTool,toolFilename)
            if nargin < 3
                if nargin == 2
                    error('If you set useTool you must pass in the toolFilename as well');
                elseif nargin == 0 % Nothing passed
                    baseTr = transl(0,0,0);  
                end             
            else % All passed in 
                self.useTool = useTool;
                toolTrData = load([toolFilename,'.mat']);
                self.toolTr = toolTrData.tool;
                self.toolFilename = [toolFilename,'.ply'];
            end
          
            self.CreateModel();
			self.model.base = self.model.base.T * baseTr;
            self.model.tool = self.toolTr;
            self.PlotAndColourRobot();

            drawnow
        end

%% CreateModel
        function CreateModel(self)
            link(1) = Link('d',0.129, 'a', 0.002, 'alpha', -pi/2, 'offset', 0, 'qlim',[deg2rad(-170), deg2rad(170)]);
            link(2) = Link('d',0, 'a', 0.345-0.129, 'alpha', 0, 'offset', 0, 'qlim',[deg2rad(-170), deg2rad(50)]);
            link(3) = Link('d',0, 'a', 0.280, 'alpha', -pi/2, 'offset', 0, 'qlim',[deg2rad(-110), deg2rad(155)]);
            link(4) = Link('d',0.260-0.152, 'a',0, 'alpha', pi/2, 'offset', 0, 'qlim',[deg2rad(-175), deg2rad(175)]);
            link(5) = Link('d',0, 'a', 0.260-0.152, 'alpha',-pi/2 , 'offset', 0, 'qlim',[deg2rad(-120), deg2rad(120)]);
            link(6) = Link('d',0.075, 'a', 0, 'alpha',pi/2, 'offset', 0, 'qlim',[deg2rad(-350), deg2rad(350)]);
             
            self.model = SerialLink(link,'name',self.name);
        end      
    end
end
