New-Item -ItemType Directory -Path .\reframework\autorun -Force
Copy-Item -Path .\TrueWarfarer.lua -Destination .\reframework\autorun\TrueWarfarer.lua -Force

New-Item -ItemType Directory -Path .\reframework\data -Force
Copy-Item -Path ..\localization\locstrings-truewarfarer.json -Destination .\reframework\data\locstrings-truewarfarer.json -Force

Compress-Archive -Path .\reframework -DestinationPath .\TrueWarfarer.zip -Force
Remove-Item -LiteralPath ".\reframework" -Force -Recurse