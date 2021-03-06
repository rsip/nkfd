% DEMNKFD2 Demonstration of noise model with Gaussian distributions. 
%
% COPYRIGHT : Neil D. Lawrence, 2000-2001

% NKFD


rand('seed', 4e5);
randn('seed', 4e5);
%close all
%clear all

ndata = 200;
flipProb = 0.3;
dataMix = gmm(2, 4, 'full');
dataMix.centres = [1 -3; -1 -1; 1 1; -1 3];
dataMix.covars = dataMix.covars;
C1 = [4 0; 2 4];
C2 = [2 0; 4 2];
dataMix.covars(:, :, 1) = [4 0; 0 4];
dataMix.covars(:, :, 2) = [4 0; 0 4];
dataMix.covars(:, :, 3) = [4 0; 0 4];
dataMix.covars(:, :, 4) = [4 0; 0 4];
[x, trueT] = gmmsamp(dataMix, ndata);
[x2, trueT2] = gmmsamp(dataMix, ndata);
trueT = ~rem(trueT, 2);
trueT2 = ~rem(trueT2, 2);

modelMix = gmm(2, 2, 'full');


noiseT = trueT;
noise = rand(size(trueT));
index = find(noise<flipProb);
noiseT(index) = ~trueT(index);

figure
plot(x(find(noiseT==0), 1), x(find(noiseT==0), 2), 'y.')
hold on
plot(x(find(noiseT==1), 1), x(find(noiseT==1), 2), 'wx')
plot(x(find(noiseT==0 & trueT==1), 1), x(find(noiseT==0 & trueT == 1), 2), 'ro')
hold on
plot(x(find(noiseT==1 & trueT==0), 1), x(find(noiseT==1 & trueT == 0), 2), 'ro')
xLim = get(gca, 'XLim');
yLim = get(gca, 'YLim');
zeroAxes(gca)
if exist('printPlot', 'var') & printPlot
  print -depsc ../tex/diagrams/demNkfd2_1.eps
  pos = get(gcf, 'paperposition');
  set(gcf, 'paperposition', [pos(1) pos(2) pos(3)/2 pos(4)/2]);
  print -dpng ../tex/diagrams/demNkfd2_1.png
  set(gcf, 'paperposition', [pos(1) pos(2) pos(3) pos(4)]);
end

counter = 0;
for alpha = [0.0 0.1];
  counter = counter + 1;
  modelMix.covars(:, :, 1) = cov(x(find(noiseT==0), :));
  modelMix.covars(:, :, 2) = cov(x(find(noiseT==1), :));
  modelMix.centres(1, :) = mean(x(find(noiseT==0), :));
  modelMix.centres(2, :) = mean(x(find(noiseT==1), :));
  modelMix.priors(1) = 1-alpha;
  modelMix.priors(2) = 1-alpha;
  options = foptions; 
  options(14) = 1000;
  options(1) = 1;
  modelMix = nlem(modelMix, x, noiseT, options);
  modelMix.priors
  figure
  hold on
  if counter == 1
    title('(a)')
    fileName = 'demNkfd2_2';
  else
    title('(b)')
    fileName = 'demNkfd2_3';
  end
  for i = 1:modelMix.ncentres
    [v,d] = eig(modelMix.covars(:,:,i));
    for j = 1:2
      % Ensure that eigenvector has unit length
      v(:,j) = v(:,j)/norm(v(:,j));
      start=modelMix.centres(i,:)-sqrt(d(j,j))*(v(:,j)');
      endpt=modelMix.centres(i,:)+sqrt(d(j,j))*(v(:,j)');
      linex = [start(1) endpt(1)];
      liney = [start(2) endpt(2)];
      line(linex, liney, 'Color', 'r', 'LineWidth', 1)
    end
    % Plot ellipses of one standard deviation
    theta = 0:0.02:2*pi;
    newx = sqrt(d(1,1))*cos(theta);
    newy = sqrt(d(2,2))*sin(theta);
    % Rotate ellipse axes
    ellipse = (v*([newx; newy]))';
    % Adjust centre
    ellipse = ellipse + ones(length(theta), 1)*modelMix.centres(i,:);
    ellipse1 = plot(ellipse(:,1), ellipse(:,2), 'r-');
    set(ellipse1, 'LineWidth', 2)
  end
 
  for i = 1:dataMix.ncentres
    [v,d] = eig(dataMix.covars(:,:,i));
    for j = 1:2
      % Ensure that eigenvector has unit length
      v(:,j) = v(:,j)/norm(v(:,j));
      start=dataMix.centres(i,:)-sqrt(d(j,j))*(v(:,j)');
      endpt=dataMix.centres(i,:)+sqrt(d(j,j))*(v(:,j)');
      linex = [start(1) endpt(1)];
      liney = [start(2) endpt(2)];
      line(linex, liney, 'Color', 'r', 'LineWidth', 2, 'Linestyle', ':')
    end
    % Plot ellipses of one standard deviation
    theta = 0:0.02:2*pi;
    newx = sqrt(d(1,1))*cos(theta);
    newy = sqrt(d(2,2))*sin(theta);
    % Rotate ellipse axes
    ellipse = (v*([newx; newy]))';
    % Adjust centre
    ellipse = ellipse + ones(length(theta), 1)*dataMix.centres(i,:);
    ellipse2 = plot(ellipse(:,1), ellipse(:,2), 'r:');
    set(ellipse2, 'LineWidth', 2)
  end
  set(gca, 'XLim', xLim)
  set(gca, 'YLim', yLim)
  zeroAxes(gca)
  if exist('printPlot', 'var') & printPlot
    print('-depsc', ['../tex/diagrams/' fileName '.eps'])
    pos = get(gcf, 'paperposition');
    set(gcf, 'paperposition', [pos(1) pos(2) pos(3)/2 pos(4)/2]);
    print('-dpng', ['../tex/diagrams/' fileName '.png'])
    set(gcf, 'paperposition', [pos(1) pos(2) pos(3) pos(4)]);
  end
  hold off
  %/~
  %post = nlpost(modelMix, x, noiseT);
  
  %sum((post(:, 1) < .5) == trueT)
  
  %modelMix.priors(1) = .8;
  %modelMix.priors(2) = .2;
  
  %post = nlpost(modelMix, x2, rand(size(trueT2))>.5);  
  %sum((post(:, 1) < .5) == trueT2)
  %~/
end