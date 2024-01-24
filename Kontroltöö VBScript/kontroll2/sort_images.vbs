Option Explicit

Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
Dim sourceFolder, destinationFolder
sourceFolder = WScript.Arguments(0) & "\"
destinationFolder = WScript.Arguments(1) & "\"
Dim jpegExt, jpgExt
jpegExt = "jpeg"
jpgExt = "jpg"
Dim fileCount, folderCount
fileCount = 0
folderCount = 0

If Not fso.FolderExists(sourceFolder) Or Not fso.FolderExists(destinationFolder) Then
    WScript.Echo "Source or destination folder does not exist."
    WScript.Quit
End If

Function PadDigits(number, totalDigits)
    PadDigits = Right(String(totalDigits, "0") & number, totalDigits)
End Function

Function ProcessFolder(folderPath)
    Dim folder, subFolder, file
    Set folder = fso.GetFolder(folderPath)

    For Each file In folder.Files
        ProcessFile file
    Next

    For Each subFolder In folder.SubFolders
        ProcessFolder subFolder.Path
    Next
End Function

Function ProcessFile(file)
    If LCase(fso.GetExtensionName(file.Path)) = jpegExt Or LCase(fso.GetExtensionName(file.Path)) = jpgExt Then
        Dim fileYear, formattedDate, yearPath, datePath
        fileYear = Year(file.DateLastModified)
        formattedDate = fileYear & "-" & PadDigits(Month(file.DateLastModified), 2) & "-" & PadDigits(Day(file.DateLastModified), 2)
        yearPath = destinationFolder & fileYear & "\"
        datePath = yearPath & formattedDate & "\"

        If Not fso.FolderExists(yearPath) Then
            fso.CreateFolder yearPath
            folderCount = folderCount + 1
        End If

        If Not fso.FolderExists(datePath) Then
            fso.CreateFolder datePath
            folderCount = folderCount + 1
        End If

        file.Copy datePath
        fileCount = fileCount + 1
    End If
End Function

Function OutputLog(destinationFolderPath)
    Dim folder, subFolder, file
    Dim fileList, fileCount
    Set folder = fso.GetFolder(destinationFolderPath)

    For Each subFolder In folder.SubFolders
        Set fileList = CreateObject("System.Collections.ArrayList")
        fileCount = 0

        For Each file In subFolder.Files
            fileList.Add(file.Name)
            fileCount = fileCount + 1
        Next

        If fileCount > 0 Then
            WScript.Echo "--------"
            If fileCount = 1 Then
                WScript.Echo fileCount & " file"
            Else
                WScript.Echo fileCount & " files"
            End If
            WScript.Echo Join(fileList.ToArray(), ", ")
            WScript.Echo "were moved to folder"
            WScript.Echo subFolder.Path
        End If

        OutputLog subFolder.Path
    Next
End Function

ProcessFolder sourceFolder
OutputLog(destinationFolder)

If fileCount = 1 And folderCount = 1 Then
    WScript.Echo fileCount & " picture was sorted into " & folderCount & " folder."
ElseIf fileCount = 1 Then
    WScript.Echo fileCount & " picture was sorted into " & folderCount & " folders."
ElseIf folderCount = 1 Then
    WScript.Echo fileCount & " pictures were sorted into " & folderCount & " folder."
Else 
    WScript.Echo fileCount & " pictures were sorted into " & folderCount & " folders."
End If
