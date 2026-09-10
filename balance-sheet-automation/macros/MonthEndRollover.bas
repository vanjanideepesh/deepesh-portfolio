Attribute VB_Name = "MonthEndRollover"
'==============================================================
' MonthEndRollover
'
' Recreates the "Paste Special" macro from the Balance Sheet &
' P&L automation project. The original manual process required
' someone to copy the current month's live-formula column, paste
' it back as static values, and manually open a new column for
' the next period -- a step that, done by hand, was also the
' team's informal way of creating an accountability trail (once
' pasted as values, a later edit is visibly a deliberate change,
' not a formula recalculating).
'
' This macro automates that exact step.
'==============================================================

Sub LockCurrentMonthAndRollForward()

    Dim ws As Worksheet
    Dim currentCol As Long
    Dim nextCol As Long

    Set ws = ThisWorkbook.Sheets("BalanceSheet")

    ' Identify the current "live" month column (last column with data)
    currentCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column
    nextCol = currentCol + 1

    ' Step 1: Lock the current month -- convert live formulas to static values.
    ' This is what previously required a manual Copy > Paste Special > Values.
    With ws.Columns(currentCol)
        .Copy
        .PasteSpecial Paste:=xlPasteValues
    End With
    Application.CutCopyMode = False

    ' Step 2: Roll formulas forward into the new period's column.
    ' Copies formula structure (not values) so the new column
    ' recalculates live against the next Trial Balance posting.
    ws.Columns(currentCol).Copy
    ws.Columns(nextCol).PasteSpecial Paste:=xlPasteFormulas
    Application.CutCopyMode = False

    ' Step 3: Label the new period column using the prior header + 1 month,
    ' so no one has to remember to rename it manually.
    ws.Cells(1, nextCol).Value = DateAdd("m", 1, ws.Cells(1, currentCol).Value)

    MsgBox "Month locked and rolled forward to column " & nextCol & ".", vbInformation

End Sub
