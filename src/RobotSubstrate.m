classdef RobotSubstrate < handle
    %ROBOTCOWS A class that creates a herd of robot cows
    %   The cows can be moved around randomly. It is then possible to query
    %   the current location (base) of the cows
    
    properties (Constant)
        %> Max height is for plotting of the workspace
        maxHeight = 10;
    end
    
    properties
        %> Number of bricks
        substrateCount = 16;
        
        %> A cell structure of \c cowCount cow models
        substrateModel;
        
        %> paddockSize in meters
        paddockSize = [2,2];
        
        %> Dimensions of the workspace in regard to the padoc size
        workspaceDimensions;
    end
    
    methods
        %% ...structors
        function self = RobotSubstrate(substrateCount)
            self.workspaceDimensions = [-self.paddockSize(1)/2, self.paddockSize(1)/2 ...
                ,-self.paddockSize(2)/2, self.paddockSize(2)/2 ...
                ,0,self.maxHeight];
            
            steps = substrateCount;
            for i = 1:steps
                self.substrateModel{i} = self.GetBrickModel(['Substrate',num2str(i)]);
                
                if i < 5
                    self.substrateModel{i}.base = SE3(transl(0.7-(i-1)*0.05, 0.25,0.06)*trotx(pi));
                end
                
                if 5 <= i
                    self.substrateModel{i}.base = SE3(transl(0.7-(i-5)*0.05, 0.2,0.06)*trotx(pi));
                end
                
                if 8 < i
                    self.substrateModel{i}.base = SE3(transl(0.7-(i-9)*0.05, 0.15,0.06)*trotx(pi)) ;
                end
                
                if 12 < i
                    self.substrateModel{i}.base = SE3(transl(0.7-(i-13)*0.05,0.1,0.06)*trotx(pi));
                    
                end
               
                
                % Plot 3D model
                plot3d(self.substrateModel{i},0,'workspace',self.workspaceDimensions,'view',[-30,30],'delay',0,'noarrow','nowrist','notiles');
                
                % Hold on after the first plot (if already on there's no difference)
                if i == 1
                    hold on;
                end
            end
            
            self.substrateCount = substrateCount;
            axis equal
            if isempty(findobj(get(gca,'Children'),'Type','Light'))
                camlight
            end
        end
        
        %% TestPlotManyStep
        % Go through and plot many random walk steps
        function TestPlotManyStep(self,numSteps,delay)
            if nargin < 3
                delay = 0;
                if nargin < 2
                    numSteps = 200;
                end
            end
            for i = 1:numSteps
                self.PlotSingleRandomStep();
                pause(delay);
            end
        end
    end
    
    methods (Static)
        %% GetBrickModel
        function model = GetBrickModel(name)
            if nargin < 1
                name = 'Netpot';
            end
            [faceData,vertexData] = plyread('30mm_Substrate.ply','tri');
            link1 = Link('alpha',0,'a',0,'d',0,'offset',0);
            model = SerialLink(link1,'name',name);
            
            % Changing order of cell array from {faceData, []} to
            % {[], faceData} so that data is attributed to Link 1
            % in plot3d rather than Link 0 (base).
            model.faces = {[], faceData};
            
            % Changing order of cell array from {vertexData, []} to
            % {[], vertexData} so that data is attributed to Link 1
            % in plot3d rather than Link 0 (base).
            model.points = {[], vertexData};
        end
    end
end