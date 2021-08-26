%
% Detec��o de Rodovias - Limiariza��o dos MDIRs
% Autor: Gustavo Rota Collegio - 2021

close all; clear all; clc; pkg load image;

disp('  ');
disp(' Limiariza��o dos MDIRs ');
disp('  ');
disp('                                            UNESP/FCT');
disp('                              Engenharia Cartogr�fica');
disp('  ');

nome = '../MDIR_LIMIAR/_tin_05/121-II-1_GROUND_05.tif';
%nome = '../MDIR_LIMIAR/_grid_nodata_03/grid03_nodata.tif';
MDIR = imread(nome); MDIR = im2uint8(MDIR);
figure(1); imshow(MDIR); title(' MDIR com pontos de terreno na resolu��o 0,5 m ');
figure, imhist(MDIR); axis tight; title('Histograma de frequ�ncia do MDIR de resolu��o 0,5 m');

%% LIMIARIZA��O

%% Otsu (default) - Limiar autom�tico
[LimiarOtimo, SEP]=graythresh(MDIR); % LimiarOtimo; SEP � N�vel de separabilidade [0-1]
Limiar_Automatico = LimiarOtimo*255, Limiar_Automatico = LimiarOtimo                                 
Limiar = input(' Escolha o limiar a partir do histograma e informe: '); Limiar_manual=Limiar/255;
disp([ ' Limiar [0-255]: ' num2str(Limiar) ] );
disp([ ' Limiar   [0-1]: ' num2str(Limiar_manual) ] );
DATAbin = im2bw(MDIR,Limiar_manual);
figure, imshow(DATAbin), colormap(gray(256)), text=(['Limiar manual:',num2str(Limiar_manual)]);
xlabel(text);

%% MDIR - Building and vegetation
nome_2 = '../MDIR_LIMIAR/_tin_05/las_tin_c_05.tif';
%nome_2 = '../MDIR_LIMIAR/_tin_03/las2dem03.tif';
MDIR_2 = imread(nome_2); %MDIR_2 = im2uint8(MDIR_2);
figure; imshow(MDIR_2); title(' MDIR classe alta resolu��o 0,5 m ');

%% Visualiza��o do histograma de frequ�ncia
figure, imhist(MDIR_2); axis tight; title(' Histograma MDIR classe alta ');

%% Limiariza��o
Limiar2 = input(' Escolha o limiar a partir do segundo histograma e informe: ');
Limiar_manual2 = Limiar2/255;
disp([ ' Limiar [0-255]: ' num2str(Limiar2) ] );
disp([ ' Limiar   [0-1]: ' num2str(Limiar_manual2) ] );
DATAbin2 = im2bw(MDIR_2,Limiar_manual2); figure,imshow(DATAbin2),colormap(gray(256)),title(' MDIR classe alta limiarizado ')

## Caso haja incompatibilidade entre as resolu��es das imagens
%{
[i,j]=size(DATAbin), [x,y] = size(DATAbin2);
if i < x 
  DATAbin(i+1,j) = 0;
else 
 DATAbin(i-1,j) = 0;
endif
if j > y
    DATAbin(:,j) = [];
endif
%}

%% Soma das imagens - Classes ch�o e edifica��o
C = DATAbin + DATAbin2;
figure, imshow(C); title('Imagem somada');

[lin,col]=size(C);

% Clipando a imagem somada
for i=1:lin
  for j=1:col
    if C(i,j) >= 1
      C(i,j) = 1;
     else
      C(i,j) = 0;
    endif
  endfor
endfor
DATAbins_m = medfilt2(C, [3,3]);
C = im2bw(C);
figure, imshow(C); title('Imagem somada e clipada');

%% Operadores_Morfologicos

%% Elemento estruturante - 'strel' define uma forma para o EE
EE = strel("rectangle",[4 3])   %% Dimens�o do ret�ngulo
%EE = strel("disk",2,0)          %% Quadrado, especifca-se o comprimento das bordas

% Eros�o
IMGe = imerode(C,EE);
figure; imshow(IMGe); title(' Eros�o ');

% Dilata��o
IMGd = imdilate(C,EE);
figure; imshow(IMGd); title(' Dilata��o ');

%% Abertura
IMGabre = imopen(C,EE);
figure; imshow(IMGabre);colormap(gray(256)); title(' Imagem ap�s abertura ');

%% Fechamento
IMGclose = imclose(C,EE);
figure; imshow(IMGclose);colormap(gray(256)); title(' Imagem ap�s fechamento ');

%% Combina��o de abertura e fechamento
IMGaf = IMGabre + IMGclose;
figure; imshow(IMGaf);colormap(gray(256)); title(' Imagem combinada ');

%% Filtro da mediana
DATAbins_m = medfilt2(IMGaf, [3,3]);
figure; imshow(DATAbins_m); title( ' Filtro da mediana ');

% Armazenamento
imwrite(DATAbins_m, '../MDIR_LIMIAR/Armazenamento/tin_05/mdir_05_tin.tif')';

disp(' ');
disp(' Programa finalizado! ');
disp(' ');



