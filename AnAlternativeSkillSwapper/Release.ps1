$modName = "AnAlternativeSkillSwapper"
New-Item -ItemType Directory -Path .\reframework\autorun -Force
Copy-Item -Path .\$modName.lua -Destination .\reframework\autorun\$modName.lua -Force

New-Item -ItemType Directory -Path .\reframework\data -Force
Copy-Item -Path ..\localization\locstrings-truewarfarer.json -Destination .\reframework\data\locstrings-truewarfarer.json -Force

Compress-Archive -Path .\reframework -DestinationPath .\$modName.zip -Force
Remove-Item -LiteralPath ".\reframework" -Force -Recurse