%% Text Recognition

% This code reads text from an image and displays it on the image.

% Load the image
close all
canInfo = imread("131559_2.jpg");

try
    imageInfo = ocr(canInfo);
    recognizedText = imageInfo.Text;
catch
    recognizedText = 'Text not recognized';
end

% Display the image and recognized text
figure
imshow(canInfo)
text(1500, 150, recognizedText, 'BackgroundColor', [1 1 1]);


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
energyPattern = 'Energy\s*([\d.]+[a-zA-Z]+)\s*\((\d+\s*Cal)\)';
proteinPattern = 'Protein\s*([\d.]+[a-zA-Z]+)';
fatPattern = 'Fat[^0-9]*([\d.]+[a-zA-Z]+)';
carbsPattern = 'Carbohydrate[^0-9]*([\d.]+)\s*([a-zA-Z]*)';
sugarsPattern = 'Sugars[^0-9]*([\d.]+[a-zA-Z]+)';
sodiumPattern = 'Sodium[^0-9]*(\d+)\s*mg';

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
    energy = energyMatch{1};
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
disp(['Serving Size: ' servSize]);
disp(['Energy: ' energy]);
disp(['Protein: ' protein]);
disp(['Fat: ' fat]);
disp(['Carbohydrates: ' carbs]);
disp(['Sugars: ' sugars]);
disp(['Sodium: ' sodium]);


%% Converting nutrional information to basic macros

