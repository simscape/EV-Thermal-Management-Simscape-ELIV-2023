function plotSankey_Vertical(inputs, losses, unit, labels)
% This function has been adapted from the Sankey function available on File
% Exchange and created by: James SPELLING, KTH-EGI-EKV, spelling@kth.se
%-----------------
% This function plots the losses inputs and outputs as a Sankey diagram.
% Here is an exemplarly overview of an input set:
% inputs = [75 32];
% losses = [10 5 2.8]; 
% unit   = 'kWh';
% labels = {'Main Input','Aux Input','Losses I','Losses II','Losses III','Output'};
%-----------------
% Adapted by: Lorenzo Nicoletti, AE, The MathWorks
% Date: 31.08.2023
%-----------------

% Figure name
figString = ['h1_' mfilename];
% Only create a figure if no figure exists
figExist = 0;
fig_hExist = evalin('base',['exist(''' figString ''')']);
if (fig_hExist)
    figExist = evalin('base',['ishandle(' figString ') && strcmp(get(' figString ', ''type''), ''figure'')']);
end
if ~figExist
    fig_h = figure('Name',figString);
    assignin('base',figString,fig_h);
else
    fig_h = evalin('base',figString);
end
figure(fig_h)
clf(fig_h)

lineWidth = 1.5; % Set line width
fontsize  = 13;   % Font Size for input/outputs

if sum(losses) >= sum(inputs)
    %report unbalanced inputs and losses%
    error('drawSankey: losses exceed inputs, unable to draw diagram');
    
elseif any(losses < 0) || any(inputs < 0)    
    %report negative inputs and/or losses%
    error('drawSankey: negative inputs or losses encountered');
    
else    
    %if possible, maximize figure%
    if exist('maximize','file')
        maximize(gcf);
    end
    
    %create plotting axis then hide it
    axes('position',[0.1 0 0.8 0.85]); axis off;
    
    %calculate fractional losses and inputs%
    frLosses = losses/sum(inputs);
    frInputs = inputs/sum(inputs);
    
    inputLabel = sprintf('%s: %.1f %s', labels{1}, inputs(1), unit);
    
    %draw first input label to plotting window%
    text(frInputs(1)/2, 0.1, inputLabel, 'FontSize', fontsize,'HorizontalAlignment','center','Rotation',0);

    % First arrow values:
    fstArwLpoint = 0.4;
    fstArwHpoint = 0.7;

    %draw back edge of first input arrow%
    line([0 0 frInputs(1)/2 frInputs(1) frInputs(1)],-[fstArwLpoint 0 0.1 0 fstArwHpoint], 'Color', 'black', 'LineWidth', lineWidth);

    %set inital position for the top of the arrows%
    limTop = frInputs(1); posTop = fstArwHpoint;
    
    %set inital position for the bottom of the arrows%
    limBot = 0; posBot = fstArwLpoint;
    
    %draw arrows for additional inputs%
    for j = 2 : length(inputs)
        
        %don't draw negligable inputs%
        if frInputs(j) > eps
            
            %determine inner and outer arrow radii%
            rI = max(0.07, abs(frInputs(j)/2));
            rE = rI + abs(frInputs(j));
            
            %push separation point forwards%
            newPosB = posBot + rE*sin(pi/4) + 0.01;
            line([limBot limBot],-[posBot newPosB], 'Color', 'black', 'LineWidth', lineWidth);
            posBot = newPosB;
            
            %determine points on the external arc%
            arcEx = posBot - rE*sin(linspace(0,pi/3));
            arcEy = limBot - rE*(1 - cos(linspace(0,pi/3)));
            
            %determine points on the internal arc%
            arcIx = posBot - rI*sin(linspace(0,pi/3));
            arcIy = limBot - rE + rI*cos(linspace(0,pi/3));
            
            %draw internal and external arcs%
            line(arcIy,-arcIx, 'Color', 'black', 'LineWidth', lineWidth);
            line(arcEy,-arcEx, 'Color', 'black', 'LineWidth', lineWidth);
            
            %determine arrow point tip%
            phiTip = pi/3 - 2*min(0.05, 0.8*abs(frInputs(j)))/(rI + rE);
            xTip = posBot - (rE+rI)*sin(phiTip)/2;
            yTip = limBot - rE + (rE+rI)*cos(phiTip)/2;
            
            %draw back edge of additional input arrows%
            line([min(arcEy) yTip min(arcIy)],-[min(arcEx) xTip min(arcIx)], 'Color', 'black', 'LineWidth', lineWidth);
            
            %determine text edge location%
            phiText = pi/2 - 2*min(0.05, 0.8*abs(frInputs(j)))/(rI + rE);
            xText = posBot - (rE+rI)*sin(phiText)/2;
            yText = limBot - rE + (rE+rI)*cos(phiText)/2;
            
            fullLabel = sprintf('%s:\n%.1f %s', labels{j}, inputs(j), unit);

            %draw input label%
            text(yText,-xText, fullLabel, 'FontSize', fontsize,'HorizontalAlignment','center');
            
            %save new bottom end of arrow%
            limBot = limBot - frInputs(j);
            
        end
        
    end
    
    %draw arrows of losses%
    for i = 1 : length(losses)
        
        %don't draw negligable losses%
        if frLosses(i) > eps
            
            %determine inner and outer arrow radii%
            rI = max(0.07, abs(frLosses(i)/2));
            rE = rI + abs(frLosses(i));
            
            %determine points on the internal arc%
            arcIx = posTop + rI*sin(linspace(0,pi/2));
            arcIy = limTop + rI*(1 - cos(linspace(0,pi/2)));
            
            %determine points on the external arc%
            arcEx = posTop + rE*sin(linspace(0,pi/2));
            arcEy = (limTop + rI) - rE*cos(linspace(0,pi/2));
            
            %draw internal and external arcs%
            line(arcIy,-arcIx, 'Color', 'black', 'LineWidth', lineWidth);
            line(arcEy,-arcEx, 'Color', 'black', 'LineWidth', lineWidth);
            
            %determine arrow tip dimensions%
            arEdge = max(0.015, rI/3);
            arTop  = max(0.04, 0.8*frLosses(i));
            
            %determine points on arrow tip%
            arX = posTop + rI + [0 -arEdge frLosses(i)/2 frLosses(i)+ arEdge frLosses(i)];
            arY = limTop + rI + [0 0 arTop 0 0];
            
            %draw tip of losses arrow%
            line(arY,-arX, 'Color', 'black', 'LineWidth', lineWidth);
            
            %determine text edge location%
            txtX = posTop + rI + frLosses(i)/2;
            txtY = limTop + rI + arTop + 0.02;

            %minimum siye single line label%
            fullLabel = sprintf('%s: %.1f%%',labels{i+length(inputs)}, 100*frLosses(i));

            %draw losses label%
            text(txtY, - txtX, fullLabel,'FontSize', fontsize-2,'VerticalAlignment','middle');
            
            %save new position of arrow top%
            limTop = limTop - frLosses(i);
            
            %advance to new separation point%
            newPos = posTop + rE + 0.01;
            
            %draw top line to new separation point%
            line([limTop limTop],-[posTop newPos], 'Color', 'black', 'LineWidth', lineWidth);
            
            %save new advancement point%
            posTop = newPos;
            
        end        
    end
    
    %push the arrow forwards a little after all side-arrows drawn%
    newPos = max(posTop, posBot) + max(0.05*limTop, 0.05);
    
    %draw lines to this new position%
    line([limTop limTop],-[posTop, newPos], 'Color', 'black', 'LineWidth', lineWidth);
    line([limBot limBot],-[posBot, newPos], 'Color', 'black', 'LineWidth', lineWidth);
    
    %draw final arrowhead for the output%
    line([limBot, limBot - max(0.015, (limTop+limBot)/3), (limTop+limBot)/2, limTop + max(0.015, (limTop+limBot)/3), limTop],-[newPos newPos newPos+max(0.04, 0.8*(limTop-limBot)) newPos newPos], 'Color', 'black', 'LineWidth', lineWidth);
    
    %save final tip position%
    newPos = newPos + 0.8*(limTop - limBot);
    
    %determine overall ins and outs%
    outputFinal = sum(inputs) - sum(losses);
    
    %create the label for the overall output arrow%
    endText = sprintf('%s: %.1f %s',labels{length(losses)+length(inputs)+1}, outputFinal, unit);
    
    %draw text for the overall output arrow%
    text((limTop+limBot)/2,-(newPos + 0.05), endText, 'FontSize', fontsize,'HorizontalAlignment','center');
   
    
    % Find all text labels in the plot
    h = findall(gcf,'Type','text');
    Postext = reshape([h.Position],3,[]); % All positions of all text

    %set correct axis limits%
    set(gca,'YLim',[min(Postext(2,:))-0.1, max(Postext(2,:))+0.1]);
    set(gca,'XLim',[min(Postext(1,:))-0.3, max(Postext(1,:))+0.6]);
       
    %set correct aspect ratio%
    %axis equal;  

    % Try to maximize space usage by the axes
    ax = gca;
    ax.Position = [0.1,0,0.8,1];
end