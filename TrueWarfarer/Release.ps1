New-Item -ItemType Directory -Path .\reframework\autorun -Force
Copy-Item -Path .\TrueWarfarer.lua -Destination .\reframework\autorun\TrueWarfarer.lua -Force
Compress-Archive -Path .\reframework -DestinationPath .\TrueWarfarer.zip -Force
Remove-Item -LiteralPath ".\reframework" -Force -Recurse