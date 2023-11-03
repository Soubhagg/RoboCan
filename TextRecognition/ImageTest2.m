%% Text Recognition

% This code reads text from an image and displays it on the image.

% Load the image
close all
canInfo = imread("861611_3.jpg");

try
    imageInfo = ocr(canInfo);
    recognizedText = imageInfo.Text;
catch
    recognizedText = 'Text not recognized';
end

% After getting recognized text from OCR
recognizedText = imageInfo.Text;

% Replace any misinterpreted characters
recognizedText = strrep(recognizedText, ')', 'J');

% Display the image and recognized text
figure
imshow(canInfo)
text(600, 150, recognizedText, 'BackgroundColor', [1 1 1]);


% Initialize variables to store nutritional information
servSize = '';
energy = '';
protein = '';
fat = '';
carbs = '';
sugars = '';
sodium = '';

% Define regular expressions to capture nutritional information
servSizePattern = 'SERVING SIZE:\s*([\d.]+\s*[a-zA-Z]+)';
energyPattern = 'ENERGY\s*([\d.]+)\s*(kJ)';
proteinPattern = 'PROTEIN\s*([\d.]+[a-zA-Z]*)';
fatPattern = 'FAT,\s*TOTAL\s*([\d.]+)\s*([a-zA-Z]*)';
carbsPattern = 'CARBOHYDRATE,\s*TOTAL\s*([\d.]+)\s*([a-zA-Z]*)';
sugarsPattern = 'SUGARS\s*([\d.]+[a-zA-Z]*)';
sodiumPattern = 'SODIUM\s*([\d.]+)\s*(mg)';

% Match the regular expressions and extract the data
servSizeMatch = regexp(recognizedText, servSizePattern, 'tokens');
energyMatch = regexp(recognizedText, energyPattern, 'tokens');
proteinMatch = regexp(recognizedText, proteinPattern, 'tokens');
fatMatch = regexp(recognizedText, fatPattern, 'tokens');
carbsMatch = regexp(recognizedText, carbsPattern, 'tokens');
sugarsMatch = regexp(recognizedText, sugarsPattern, 'tokens');
sodiumMatch = regexp(recognizedText, sodiumPattern, 'tokens');

% Extract the matched values
if ~isempty(servSizeMatch)
    servSize = servSizeMatch{1};
end

if ~isempty(energyMatch)
    energyValue = energyMatch{1};
    energy = energyValue;
else
    % If no energy information is found, set it to "Not available"
    energy = 'Not available';
end

if ~isempty(proteinMatch)
    protein = proteinMatch{1};
end

if ~isempty(fatMatch)
    fatValue = fatMatch{1}{1};
    fatUnit = fatMatch{1}{2};
    
    if isempty(fatUnit)
        fatUnit = 'g';
    end

    % Convert fat value to a decimal and display in grams
    fatValueInGrams = str2double(fatValue) / 100;
    fat = sprintf('%.1fg', fatValueInGrams);
else
    % If no fat information is found, set it to "Not available"
    fat = 'Not available';
end

if ~isempty(carbsMatch)
    carbsValue = carbsMatch{1}{1};
    carbsUnit = carbsMatch{1}{2};
    if isempty(carbsUnit)
        carbsUnit = 'g';  % If the unit is not available, set it to 'g'
    end
    % Concatenate the unit to the value
    carbs = [carbsValue ' ' carbsUnit];
else
    % If no carbohydrate information is found, set it to "Not available"
    carbs = 'Not available';
end

if ~isempty(sugarsMatch)
    sugars = sugarsMatch{1};
end

if ~isempty(sodiumMatch)
    sodium = sodiumMatch{1};
end

% Display the extracted information
disp(['Serving Size: ' servSize{1}]);
disp(['Energy: ' energy{1} ' ' energy{2}]);
disp(['Protein: ' protein{1}]);
disp(['Fat: ' fat]);
disp(['Carbohydrates: ' carbs]);
disp(['Sugars: ' sugars{1}]);
disp(['Sodium: ' sodium{1} ' ' sodium{2}]);

