
# Get argument settings
$sourceFile = $args[0]
$compilerJar = $args[1]
$tassFolder = $args[2]
$x16Emulator = $args[3]

# Compile script for Prog8 projects
# Add 64tass to PATH
$env:Path = "$tassFolder;$env:Path"


# If no file provided, try to use the active editor file
if (-not $sourceFile) {
    Write-Error "No source file specified. Usage: .\compile.ps1 <source-file>"
    exit 1
}

# Run the compilation
java -jar "$compilerJar" -target cx16 "$sourceFile"

if ($LASTEXITCODE -eq 0) {
    # Run the compilation
    & "$x16Emulator" -prg $([System.IO.Path]::GetFileNameWithoutExtension($sourceFile) + ".prg")
}