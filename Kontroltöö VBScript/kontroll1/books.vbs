inputFile = WScript.Arguments(0)
wordCountLimit = WScript.Arguments(1)

Set textFile = CreateObject("Scripting.FileSystemObject").OpenTextFile(inputFile, 1)
Set wordFrequency = CreateObject("Scripting.Dictionary")
Set uniqueWords = CreateObject("Scripting.Dictionary")

Function GetUniqueID(word)
    If uniqueWords.Exists(word) Then
        GetUniqueID = uniqueWords(word)
    Else
        uniqueID = uniqueWords.Count + 1
        uniqueWords.Add word, uniqueID
        GetUniqueID = uniqueID
    End If
End Function

Do Until textFile.AtEndOfStream
    currentLine = LCase(textFile.ReadLine())
    wordsArray = Split(currentLine, " ")
    For Each item In wordsArray
        item = Replace(item, ",", "")
        item = Replace(item, ";", "")
        item = Replace(item, ":", "")
        item = Replace(item, ")", "")
        item = Replace(item, "(", "")
        item = Replace(item, "!", "")
        item = Replace(item, "?", "")
        item = Replace(item, ".", "")
        item = Replace(item, """", "")
        item = Replace(item, "--", "")
        item = Replace(item, "&", "")
        item = Replace(item, "$", "")
        item = Replace(item, "  ", "")
        item = Replace(item, "_", "")

        Select Case item
            Case "don't", "doesn't"
                item = "do not"
            Case "can't"
                item = "cannot"
            Case "an"
                item = "a"
            Case "me", "mine", "my", "myself", "i'm", "'i"
                item = "i"
            Case "him", "his", "himself"
                item = "he"
            Case "her", "hers", "herself"
                item = "she"
            Case "its", "itself"
                item = "it"
            Case "whom", "whose"
                item = "who"
            Case "one's", "oneself"
                item = "one"
            Case "us", "our", "ours", "ourselves"
                item = "we"
            Case "yours", "your", "yourself", "yourselves"
                item = "you"
            Case "them", "their", "theirs", "themselves"
                item = "they"
            Case "am", "is", "are", "was", "were", "being", "been"
                item = "be"
            Case "has", "had", "having"
                item = "have"
            Case "an'"
                item = "and"
        End Select

        uniqueID = GetUniqueID(item)

        If wordFrequency.Exists(uniqueID) Then
            wordFrequency(uniqueID) = wordFrequency(uniqueID) + 1
        Else
            wordFrequency.Add uniqueID, 1
        End If
    Next
Loop

WScript.Echo "CHECKING THE ZIPF's LAW"
WScript.Echo
WScript.Echo "The first column is the number of corresponding words in the text and the second column is the number of words which should occur in the text according to the Zipf's law."
WScript.Echo
WScript.Echo "The most popular words in " & inputFile & " are:"
WScript.Echo

For index = 0 To wordCountLimit
    maxWord = "" : maxCount = 0
    For Each term In wordFrequency
        If wordFrequency(term) > maxCount Then
            maxWord = term
            maxCount = wordFrequency(term)
        End If
    Next

    If maxCount <> 0 Then
        wordFrequency.Remove maxWord
        If Not (maxWord = vbLf Or maxWord = vbCr Or maxWord = "" Or maxWord = " ") Then
            zipfLawCount = maxCount
            WScript.Echo maxWord, vbTab, maxCount, vbTab, Round(zipfLawCount / index)
        End If
    End If
Next

WScript.Echo
WScript.Echo "The most popular still remaining short forms in " & inputFile & " are:"
WScript.Echo

For index = 0 To wordCountLimit
    maxWord = "" : maxCount = 0
    For Each term In wordFrequency
        If wordFrequency(term) > maxCount And InStr(term, "'") Then
            maxWord = term
            maxCount = wordFrequency(term)
        End If
    Next

    If maxCount <> 0 Then
        wordFrequency.Remove maxWord
        If Not (maxWord = vbLf Or maxWord = vbCr Or maxWord = "" Or maxWord = " ") Then
            WScript.Echo maxWord, vbTab, maxCount
        End If
    End If
Next
