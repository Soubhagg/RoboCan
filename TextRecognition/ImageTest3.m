%% Text Recognition

% This code reads text from an image and displays it on the image.

% Load the image
close all
canInfo = imread("057198_2.jpg");

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
servSizePattern = 'Serving size:\s*([\d.]+\s*[a-zA-Z]+)';
energyPattern = 'Energy:\s*([\d.]+)\s*(kJ)';
proteinPattern = 'Protein[^0-9]*([\d.]+[a-zA-Z]*)';
fatPattern = 'Fat[^0-9]*([\d.]+[a-zA-Z]*)';
carbsPattern = 'Carbohydrate[^0-9]*([\d.]+)\s*([a-zA-Z]*)';
sugarsPattern = 'Sugars[^0-9]*([\d.]+[a-zA-Z]+)';
sodiumPattern = 'Sodium\s*([\d.]+)\s*(mg)';

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
    energyValue = energyMatch{1}{1};
    energyUnit = energyMatch{1}{2};
    energy = energyValue + " " + energyUnit;
else
    % If no energy information is found, set it to "Not available"
    energy = 'Not available';
end


if ~isempty(proteinMatch)
    protein = proteinMatch{1};
end

if ~isempty(fatMatch)
    fat = fatMatch{1};
end

if ~isempty(carbsMatch)
    carbsValue = carbsMatch{1}{1};
    carbsUnit = carbsMatch{1}{2};
    % If the unit is empty, set it to "g" (grams)
    if isempty(carbsUnit)
        carbsUnit = 'g';
    end
    % Append the unit to the value
    carbs = carbsValue + " " + carbsUnit;
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
disp(['Energy: ' energy]);
disp(['Protein: ' protein{1}]);
disp(['Fat: ' fat{1}]);
disp(['Carbohydrates: ' carbs{1}]);
disp(['Sugars: ' sugars{1}]);
disp(['Sodium: ' sodium{1}]);

