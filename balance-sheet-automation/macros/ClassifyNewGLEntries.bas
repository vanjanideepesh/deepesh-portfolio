Attribute VB_Name = "ClassifyNewGLEntries"
'==============================================================
' ClassifyNewGLEntries
'
' Recreates the second macro from the Balance Sheet & P&L
' automation project: scans newly posted General Ledger entries,
' groups them by Cost Center and Profit Center, and compares
' each against the existing master lists.
'
' Only entries that don't already exist in the masters are
' flagged for manual review -- previously, every entry was
' re-checked by hand every month regardless of whether it was
' new or already classified.
'==============================================================

Sub FlagNewCostAndProfitCenters()

    Dim glSheet As Worksheet
    Dim costMaster As Worksheet
    Dim profitMaster As Worksheet
    Dim reviewSheet As Worksheet

    Dim lastRow As Long, i As Long
    Dim glCode As String, glName As String
    Dim isKnownCost As Boolean, isKnownProfit As Boolean

    Set glSheet = ThisWorkbook.Sheets("GL_Entries")
    Set costMaster = ThisWorkbook.Sheets("CostCenterMaster")
    Set profitMaster = ThisWorkbook.Sheets("ProfitCenterMaster")
    Set reviewSheet = ThisWorkbook.Sheets("PendingReview")

    ' Clear last run's pending-review list before repopulating
    reviewSheet.Cells.ClearContents
    reviewSheet.Cells(1, 1).Value = "GL Code"
    reviewSheet.Cells(1, 2).Value = "GL Name"
    reviewSheet.Cells(1, 3).Value = "Reason"

    lastRow = glSheet.Cells(glSheet.Rows.Count, 1).End(xlUp).Row
    Dim reviewRow As Long: reviewRow = 2

    For i = 2 To lastRow
        glCode = glSheet.Cells(i, 1).Value
        glName = glSheet.Cells(i, 2).Value

        isKnownCost = Not IsError(Application.Match(glCode, costMaster.Columns(1), 0))
        isKnownProfit = Not IsError(Application.Match(glCode, profitMaster.Columns(1), 0))

        If Not isKnownCost Then
            reviewSheet.Cells(reviewRow, 1).Value = glCode
            reviewSheet.Cells(reviewRow, 2).Value = glName
            reviewSheet.Cells(reviewRow, 3).Value = "New Cost Center - needs manager approval"
            reviewRow = reviewRow + 1
        ElseIf Not isKnownProfit Then
            reviewSheet.Cells(reviewRow, 1).Value = glCode
            reviewSheet.Cells(reviewRow, 2).Value = glName
            reviewSheet.Cells(reviewRow, 3).Value = "New Profit Center - needs manager approval"
            reviewRow = reviewRow + 1
        End If
        ' Entries matching both masters are already classified -- skipped entirely,
        ' which is the whole point: only genuinely new entries reach a human.
    Next i

    MsgBox (reviewRow - 2) & " new entries flagged for manager review.", vbInformation

End Sub
