dotnet // --> Reports ForNAV Autogenerated code - do not delete or modify
{	
	assembly("ForNav.Reports.6.0.0.2078")
	{
		type(ForNav.Report_6_0_0_2078; ForNavReport6188682_v6_0_0_2078){}   
	}
} // Reports ForNAV Autogenerated code - do not delete or modify -->

Report 6188682 "ForNAV Vendor Payments"
{
	Caption = 'Vendor Payments';
	UsageCategory = ReportsAndAnalysis;
	RDLCLayout = './Layouts/ForNAV Vendor Payments.rdlc'; DefaultLayout = RDLC;

	dataset
	{
		dataitem(Args;"ForNAV Vendor Payments Args.")
		{
			DataItemTableView = sorting("Consider Discount");
			UseTemporary = true;
			column(ReportForNavId_1; 1) {} // Autogenerated by ForNav - Do not delete
			dataitem(Vendor;Vendor)
			{
				PrintOnlyIfDetail = true;
				RequestFilterFields = "No.", "Vendor Posting Group", "Purchaser Code", Priority, "Payment Method Code";
				column(ReportForNavId_3182; 3182) {} // Autogenerated by ForNav - Do not delete
				dataitem("Vendor Ledger Entry";"Vendor Ledger Entry")
				{
					CalcFields = Amount, "Remaining Amount", "Remaining Amt. (LCY)", "Amount (LCY)";
					DataItemLink = "Vendor No." = FIELD("No."), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter");
					DataItemTableView = sorting("Vendor No.", Open, Positive, "Due Date", "Currency Code") where(Open = const(true), "On Hold" = const(''));
					column(ReportForNavId_4114; 4114) {} // Autogenerated by ForNav - Do not delete
					column(DiscountToTake; DiscountToTake)
					{
						IncludeCaption = false;
					}
					trigger OnPreDataItem();
					begin
						FilterGroup(-1);
						SetRange("Pmt. Discount Date", Args."Payment Date", Args."Payment Discount Date");
						SetRange("Due Date", 0D, Args."Due Date Filter");
						FilterGroup(0);
						SetCurrentkey("Original Pmt. Disc. Possible");
					end;
					
					trigger OnAfterGetRecord();
					begin
						if "Original Pmt. Disc. Possible" < 0 then
							SetRange("Date Filter", Args."Payment Date", Args."Payment Discount Date");
						CalcAmounts("Vendor Ledger Entry");
					end;
					
				}
				trigger OnPreDataItem();
				begin
					if (Args."Due Date Filter" = 0D) then
						Args.TestField("Consider Discount");
				
					if not Args."Consider Discount" then
						Args.TestField("Due Date Filter");
				end;
				
			}
			trigger OnPreDataItem();
			begin
			end;
			
			trigger OnAfterGetRecord();
			begin
				if Args."Payment Date" = 0D then
					Args."Payment Date" := WorkDate;
				if "Consider Discount" and (Args."Payment Discount Date" < Args."Payment Date") then
					Args."Payment Discount Date" := Args."Payment Date";
			end;
			
		}
	}

	requestpage
	{

		SaveValues = true;

		layout
		{
			area(content)
			{
				group(Options)
				{
					Caption = 'Options';
					field(PaymentDate; Args."Payment Date")
					{
						ApplicationArea = Basic, Suite;
						Caption = 'Payment Date';
					}
					field(DueDateFilter; Args."Due Date Filter")
					{
						ApplicationArea = Basic, Suite;
						Caption = 'Due Date Filter';
					}
					field(TakePaymentDiscounts; Args."Consider Discount")
					{
						ApplicationArea = Basic, Suite;
						Caption = 'Consider Discount';
					}
					field(LastDiscDateToTake; Args."Payment Discount Date")
					{
						ApplicationArea = Basic, Suite;
						Caption = 'Payment Discount Date';
					}
					field(UseLocalCurrency; Args."Print Amounts in LCY")
					{
						ApplicationArea = Suite;
						Caption = 'Print Amounts in LCY';
					}
					field(UseExternalDocumentNo; Args."External Document No.")
					{
						ApplicationArea = Basic, Suite;
						Caption = 'External Document No.';
					}
					field(ForNavOpenDesigner; ReportForNavOpenDesigner)
					{
						ApplicationArea = All;
						Caption = 'Design';
						Visible = ReportForNavAllowDesign;
						trigger OnValidate()
						begin
							ReportForNav.LaunchDesigner(ReportForNavOpenDesigner);
							CurrReport.RequestOptionsPage.Close();
						end;
					}
				}
			}
		}

		trigger OnOpenPage()
		begin
			ReportForNavOpenDesigner := false;
			if (Args."Due Date Filter" = 0D) and (not Args."Consider Discount") then
				Args."Consider Discount" := true;
			if Args."Payment Date" = 0D then
				Args."Payment Date" := WorkDate;
			if Args."Due Date Filter" = 0D then
				Args."Due Date Filter" := WorkDate;
		end;

		trigger OnClosePage()
		begin
			if not Args."Consider Discount" then
				Args."Payment Discount Date" := 0D
			else
				if Args."Payment Discount Date" < Args."Payment Date" then
					Args."Payment Discount Date" := Args."Payment Date";
		end;
	}

	trigger OnInitReport()
	begin
		;ReportsForNavInit;
		Codeunit.Run(Codeunit::"ForNAV First Time Setup");
		Commit;
		LoadWatermark;
	end;

	trigger OnPostReport()
	begin

		;ReportForNav.Post;

	end;

	trigger OnPreReport()
	begin
		;

		Args.Insert;
		;ReportsForNavPre;

	end;
	var
		DiscountToTake: Decimal;

	procedure CalcAmounts(VendorLedgerEntry: Record "Vendor Ledger Entry")
	var
		DiscountToTakeLCY: Decimal;
		Currency: Record Currency;
		CurrExchRate: Record "Currency Exchange Rate";
	begin
		VendorLedgerEntry.SetRange("Date Filter", 0D, Args."Due Date Filter");
		VendorLedgerEntry.CalcFields(Amount, "Remaining Amount", "Remaining Amt. (LCY)");
		if (VendorLedgerEntry."Original Pmt. Disc. Possible" < 0) and (VendorLedgerEntry."Pmt. Discount Date" >= Args."Payment Date") then
			DiscountToTake := -VendorLedgerEntry."Original Pmt. Disc. Possible"
		else
			DiscountToTake := 0;
		if (Vendor."Currency Code" <> '') then begin
			if VendorLedgerEntry."Remaining Amount" <> 0 then
				DiscountToTakeLCY := DiscountToTake * VendorLedgerEntry."Remaining Amt. (LCY)" / VendorLedgerEntry."Remaining Amount"
			else
				DiscountToTakeLCY := 0;
			if Args."Print Amounts in LCY" then begin
				if VendorLedgerEntry."Currency Code" <> Vendor."Currency Code" then
					DiscountToTake :=
					  ROUND(
						CurrExchRate.ExchangeAmtFCYToFCY(
						  Args."Payment Date",
						  VendorLedgerEntry."Currency Code",
						  Vendor."Currency Code",
						  DiscountToTake),
						Currency."Amount Rounding Precision");
			end else
				DiscountToTake := DiscountToTakeLCY;
		end;
	end;

	local procedure LoadWatermark()
	var
		ForNAVSetup: Record "ForNAV Setup";
		OutStream: OutStream;
	begin
		ForNAVSetup.Get;
		ForNAVSetup.CalcFields(ForNAVSetup."List Report Watermark (Lands.)");
		if not ForNAVSetup."List Report Watermark (Lands.)".Hasvalue then
			exit;
		ForNAVSetup."List Report Watermark (Lands.)".CreateOutstream(OutStream);
		ForNavSetup."List Report Watermark (Lands.)".CreateOutstream(OutStream); ReportForNav.Watermark.Image.Load(OutStream);

	end;

	// --> Reports ForNAV Autogenerated code - do not delete or modify
	var 
		[WithEvents]
		ReportForNav : DotNet ForNavReport6188682_v6_0_0_2078;
		ReportForNavOpenDesigner : Boolean;
		[InDataSet]
		ReportForNavAllowDesign : Boolean;

	local procedure ReportsForNavInit();
	var
		addInFileName : Text;
		tempAddInFileName : Text;
		path: DotNet Path;
		ApplicationSystemConstants: Codeunit "Application System Constants";
	begin
		addInFileName := ApplicationPath() + 'Add-ins\ReportsForNAV_6_0_0_2078\ForNav.Reports.6.0.0.2078.dll';
		if not File.Exists(addInFileName) then begin
			tempAddInFileName := path.GetTempPath() + '\Microsoft Dynamics NAV\Add-Ins\' + ApplicationSystemConstants.PlatformFileVersion() + '\ForNav.Reports.6.0.0.2078.dll';
			if not File.Exists(tempAddInFileName) then
				Error('Please install the ForNAV DLL version 6.0.0.2078 in your service tier Add-ins folder under the file name "%1"\\If you already have the ForNAV DLL on the server, you should move it to this folder and rename it to match this file name.', addInFileName);
		end;
		ReportForNav:= ReportForNav.Report_6_0_0_2078(CurrReport.ObjectId(), CurrReport.Language(), SerialNumber(), UserId(), CompanyName());
		ReportForNav.Init();
	end;

	local procedure ReportsForNavPre();
	begin
		ReportForNav.OpenDesigner:=ReportForNavOpenDesigner;
		if not ReportForNav.Pre() then CurrReport.Quit();
	end;

	// Reports ForNAV Autogenerated code - do not delete or modify -->
}
